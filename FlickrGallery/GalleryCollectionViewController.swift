import UIKit
import CoreImage

private let reuseIdentifier = "thumbnailCell"

class GalleryCollectionViewController: UICollectionViewController {
    
    var tags : [String]?
    let resultsPerPages = 500
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
        
        thumbnailCell.thumbnailImageView.image = nil
        
        
        // Get flickr image data
        let cellFlickrImageData = try! flickrResultsPages!.getFlickrImageData(indexPath.row)
        
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
                        self.setThumbnail(thumbnailCell: thumbnailCell, flickrImageData: try!flickrResultsPages.getFlickrImageData(indexPath.row)!)
                    }
                }
            } else {
             
                flickrService.getFlickrResultsByTagsPage(tags!, resultsPageNumber, resultsPerPages) {
                    (flickrResultsPages) in
                    self.flickrResultsPages?.concatenateResults(flickrResultsPages: flickrResultsPages)
                    // Ok results are there next set thumbnail cell
                    if try! flickrResultsPages.getFlickrImageData(indexPath.row) != nil {
                     
                        self.setThumbnail(thumbnailCell: thumbnailCell, flickrImageData: try! flickrResultsPages.getFlickrImageData(indexPath.row)!)
                        
                    }
                    
                }
                
            }
            
        }
        
        return thumbnailCell
        
    }
    
    func setThumbnail(thumbnailCell: ThumbnailCollectionViewCell, flickrImageData: FlickrImageData) {
        
        // Thumbnail cell settings
        
        thumbnailCell.thumbnailTitleLabel.text = flickrImageData.title
        
        // Display localized label
        if flickrImageData.latitude != 999 && flickrImageData.longitude != 999 {
            thumbnailCell.localizedLabel.text = "◥"
        } else {
            thumbnailCell.localizedLabel.text = ""
        }

        // Build image URL
        let imageUrl = flickrImageData.getFlickrImageUrl(imageSize: "s", imageFormat: "jpg")
        
        if thumbnailCell.cellImageUrl == nil {
            thumbnailCell.cellImageUrl = imageUrl
        } else {
            if thumbnailCell.cellImageUrl != imageUrl {
                flickrService.cancelPendingTask(taskUrl: thumbnailCell.cellImageUrl!)
                thumbnailCell.cellImageUrl = imageUrl
                thumbnailCell.thumbnailImageView.image = nil
            }
        }
        // Download image
        flickrService.getImageFromFlickrImageUrl(imageUrl){
            (rawImage) in
                thumbnailCell.setImage(rawImage: rawImage)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Image detail segue
        if segue.identifier == "imageDetailShowSegue" {
            let imageDetailViewController = segue.destination as! ImageDetailViewController
            
            let thumbnailCollectionViewCell = sender as! ThumbnailCollectionViewCell
            
            imageDetailViewController.flickrImageData = try!flickrResultsPages?.getFlickrImageData((collectionView?.indexPath(for: thumbnailCollectionViewCell)?.row)!)
            
        }
    
    }

}
