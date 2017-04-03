import UIKit

private let reuseIdentifier = "thumbnailCell"

class GalleryCollectionViewController: UICollectionViewController {
    
    var tags : [String]?
    let resultsPerPages = 100
    
    var flickrResultsPages: FlickrResultsPages?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.tags!.joined(separator: ", ") + " (Calculating...)"
        
        FlickrService.getInstance().getFlickrResultsByTagsPage(tags!, 1, resultsPerPages) {
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
        
        // Get flickr image data
        let cellFlickrImageData = try! flickrResultsPages!.getFLickrImageData(indexPath.row)
        
        if cellFlickrImageData != nil {
            
            setThumbnailCellImageView(thumbnailCell: thumbnailCell, flickrImageData: cellFlickrImageData!)
            
        } else {
            // Results page must be downloaded urgently
            // Calculate page number
            let resultsPageNumber = ((indexPath.row - (indexPath.row % resultsPerPages)) / resultsPerPages) + 1
            
            // Check if page download is pending
            if FlickrService.getInstance().isPageDownloadPending(page: resultsPageNumber) {
                FlickrService.getInstance().onPageDownloadComplete(page: resultsPageNumber) {
                    () in
                    FlickrService.getInstance().getFlickrResultsByTagsPage(self.tags!, resultsPageNumber, self.resultsPerPages) {
                        (flickrResultsPages) in
                        self.flickrResultsPages?.concatenateResults(flickrResultsPages: flickrResultsPages)
                        
                        // TO CHANGE BECAUSE IT IS HORRIBLE: launch cached completion handler
                        if FlickrService.getInstance().completionHandlers[resultsPageNumber] != nil {
                            for completionHandler in FlickrService.getInstance().completionHandlers[resultsPageNumber]! {
                                completionHandler()
                            }
                            FlickrService.getInstance().completionHandlers[resultsPageNumber] = nil
                        }
                        FlickrService.getInstance().pendingPageDownloads[resultsPageNumber] = false
                        
                        // Ok results are there next set thumbnail cell
                        self.setThumbnailCellImageView(thumbnailCell: thumbnailCell, flickrImageData: try!flickrResultsPages.getFLickrImageData(indexPath.row)!)
                    }
                }
            } else {
             
                FlickrService.getInstance().getFlickrResultsByTagsPage(tags!, resultsPageNumber, resultsPerPages) {
                    (flickrResultsPages) in
                    self.flickrResultsPages?.concatenateResults(flickrResultsPages: flickrResultsPages)
                    // Ok results are there next set thumbnail cell
                    if try! flickrResultsPages.getFLickrImageData(indexPath.row) != nil {
                     
                        self.setThumbnailCellImageView(thumbnailCell: thumbnailCell, flickrImageData: try! flickrResultsPages.getFLickrImageData(indexPath.row)!)
                        
                    }
                }
                
            }
            
        }
    
        return thumbnailCell
    }
    
    func setThumbnailCellImageView(thumbnailCell: ThumbnailCollectionViewCell, flickrImageData: FlickrImageData) {
        // Build image URL
        let imageUrl = flickrImageData.getFlickrImageUrl(imageSize: "t", imageFormat: "jpg")
        
        // Download image
        FlickrService.getInstance().getImageFromFlickrImageUrl(imageUrl){
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
