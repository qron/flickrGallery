import UIKit

private let reuseIdentifier = "thumbnailCell"

class GalleryCollectionViewController: UICollectionViewController {
    
    var tags : [String]?
    let resultsPerPages = 100
    let flickrService: FlickrService = FlickrService.sharedInstance
    
    var flickrResultsPages: FlickrResultsPages?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.tags!.joined(separator: ", ") + " (Calculating...)"
        
        flickrService.getFlickrResultsByTagsPage(tags!, 1, resultsPerPages) {
            (flickrResultsPages) in
            
            self.flickrResultsPages = flickrResultsPages
            
            DispatchQueue.main.async {
                self.navigationItem.title = self.tags!.joined(separator: ", ") + " (\(flickrResultsPages.totalFlickrImage))"
                self.collectionView?.reloadData()
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if flickrResultsPages != nil {
            return flickrResultsPages!.totalFlickrImage
        } else {
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let thumbnailCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ThumbnailCollectionViewCell
        
        // Thumbnail cell settings
        
        // Thumbnail shadow
        thumbnailCell.thumbnailContainerView.layer.masksToBounds = false
        thumbnailCell.thumbnailContainerView.layer.shadowColor = UIColor.black.cgColor
        thumbnailCell.thumbnailContainerView.layer.shadowOpacity = 0.5
        thumbnailCell.thumbnailContainerView.layer.shadowOffset = CGSize(width: -0.5, height: 0.5)
        thumbnailCell.thumbnailContainerView.layer.shadowRadius = 1
        
        thumbnailCell.thumbnailContainerView.layer.shadowPath = UIBezierPath(rect: thumbnailCell.thumbnailContainerView.bounds).cgPath
        thumbnailCell.thumbnailContainerView.layer.shouldRasterize = true
        
        // Get flickr image data
        let cellFlickrImageData = try! flickrResultsPages!.getFLickrImageData(indexPath.row)
        
        if cellFlickrImageData != nil {
            
            setThumbnail(thumbnailCell: thumbnailCell, flickrImageData: cellFlickrImageData!)
            
        } else {
            // Results page must be downloaded urgently
            // Calculate page number
            let resultsPageNumber = ((indexPath.row - (indexPath.row % resultsPerPages)) / resultsPerPages) + 1
            
            // Check if page download is pending
            if flickrService.isPageDownloadPending(page: resultsPageNumber) {
                flickrService.onPageDownloadComplete(page: resultsPageNumber) {
                    () in
                    self.flickrService.getFlickrResultsByTagsPage(self.tags!, resultsPageNumber, self.resultsPerPages) {
                        (flickrResultsPages) in
                        self.flickrResultsPages?.concatenateResults(flickrResultsPages: flickrResultsPages)
                        
                        // TO CHANGE BECAUSE IT IS HORRIBLE: launch cached completion handler
                        if self.flickrService.completionHandlers[resultsPageNumber] != nil {
                            for completionHandler in self.flickrService.completionHandlers[resultsPageNumber]! {
                                completionHandler()
                            }
                            self.flickrService.completionHandlers[resultsPageNumber] = nil
                        }
                        self.flickrService.pendingPageDownloads[resultsPageNumber] = false
                        
                        // Ok results are there next set thumbnail cell
                        self.setThumbnail(thumbnailCell: thumbnailCell, flickrImageData: try!flickrResultsPages.getFLickrImageData(indexPath.row)!)
                    }
                }
            } else {
             
                flickrService.getFlickrResultsByTagsPage(tags!, resultsPageNumber, resultsPerPages) {
                    (flickrResultsPages) in
                    self.flickrResultsPages?.concatenateResults(flickrResultsPages: flickrResultsPages)
                    // Ok results are there next set thumbnail cell
                    if try! flickrResultsPages.getFLickrImageData(indexPath.row) != nil {
                     
                        self.setThumbnail(thumbnailCell: thumbnailCell, flickrImageData: try! flickrResultsPages.getFLickrImageData(indexPath.row)!)
                        
                    }
                }
                
            }
            
        }
    
        return thumbnailCell
    }
    
    func setThumbnail(thumbnailCell: ThumbnailCollectionViewCell, flickrImageData: FlickrImageData) {
        
        thumbnailCell.thumbnailTitleLabel.text = flickrImageData.imageTitle
        
        // Build image URL
        let imageUrl = flickrImageData.getFlickrImageUrl(imageSize: "t", imageFormat: "jpg")
        
        // Download image
        flickrService.getImageFromFlickrImageUrl(imageUrl){
            (rawImage) in
            DispatchQueue.main.async {
                thumbnailCell.thumbnailImageView.image = UIImage(data: rawImage)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Image detail segue
        if segue.identifier == "imageDetailShowSegue" {
            let imageDetailViewController = segue.destination as! ImageDetailViewController
            
            let thumbnailCollectionViewCell = sender as! ThumbnailCollectionViewCell
            
            imageDetailViewController.flickerImageData = try!flickrResultsPages?.getFLickrImageData((collectionView?.indexPath(for: thumbnailCollectionViewCell)?.row)!)
            
        }
    
    }

}
