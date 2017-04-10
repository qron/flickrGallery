import UIKit
import CoreImage

private let reuseIdentifier = "thumbnailCell"

class FavoritesGalleryCollectionViewController: UICollectionViewController {
    
    var i = 0
    
    let flickrService: FlickrService = FlickrService.sharedInstance
    
    let favoritesRepository = FavoritesRepository()
    let fileService = FileService()
    
    var favoredFlickerImageDataList: [FlickrImageData]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Favorites"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Load flicker image data list
        favoritesRepository.fetchFavorites() {
            (favoredFlickerImageDataList) in
            self.favoredFlickerImageDataList = favoredFlickerImageDataList
            DispatchQueue.main.async {
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
        if favoredFlickerImageDataList != nil {
            return favoredFlickerImageDataList!.count
        } else {
            return 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let thumbnailCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ThumbnailCollectionViewCell
        
        // Get flickr image data
        let cellFlickrImageData = favoredFlickerImageDataList?[indexPath.row]
        
        setThumbnail(thumbnailCell: thumbnailCell, flickrImageData: cellFlickrImageData!)
        
        return thumbnailCell
    }
    
    func setThumbnail(thumbnailCell: ThumbnailCollectionViewCell, flickrImageData: FlickrImageData) {
        
        // Thumbnail cell settings
        
        thumbnailCell.thumbnailTitleLabel.text = flickrImageData.title
        
        if fileService.fileExist(fileName: flickrImageData.id, directoryName: "favorites-thumbnails") {
            thumbnailCell.thumbnailImageView.image = UIImage(data: fileService.getFileContent(fileName: flickrImageData.id, directoryName: "favorites-thumbnails")!)
        } else {
            flickrService.getImageFromFlickrImageUrl(flickrImageData.getFlickrImageUrl(imageSize: "q", imageFormat: "jpg")) {
                
                (rawImage) in
                DispatchQueue.main.async {
                    thumbnailCell.setImage(rawImage: rawImage)
                }
                
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Image detail segue
        if segue.identifier == "imageDetailShowSegue" {
            let imageDetailViewController = segue.destination as! ImageDetailViewController
            
            let thumbnailCollectionViewCell = sender as! ThumbnailCollectionViewCell
            
            imageDetailViewController.flickrImageData = favoredFlickerImageDataList?[(collectionView?.indexPath(for: thumbnailCollectionViewCell)?.row)!]
            
        }
        
    }
    
}
