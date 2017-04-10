import UIKit

class ImageDetailViewController: UIViewController {
    
    let flickrService: FlickrService = FlickrService.sharedInstance
    let favoritesRepository = FavoritesRepository()
    let fileService = FileService()

    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var isFavoredLabel: UILabel!
    
    var flickrImageData: FlickrImageData?
    
    @IBAction func onImageDetailViewDoubleTap(_ sender: UITapGestureRecognizer) {
        favoritesRepository.isFavored(flickrImageData: flickrImageData!) {
            (isFavored, favoredFlickrImageData) in
            if isFavored {
                self.removeFavorite(favoredFlickrImageData: favoredFlickrImageData)
            } else {
                self.addFavorite()
            }
        }
    }
    
    func addFavorite() {
        
        // Add favorites to core data
        favoritesRepository.addFavorite(flickrImageData: self.flickrImageData!) {
            (favoredFlickrImageData) in
            self.flickrImageData = favoredFlickrImageData
            self.refreshIsFavoredLabelTextColor(favored: true)
        }
        
        // Add image files to documents
        flickrService.getImageFromFlickrImageUrl((flickrImageData?.getFlickrImageUrl(imageSize: "q", imageFormat: "jpg"))!) {
            
            (rawImage) in
            self.fileService.writeFile(fileName: (self.flickrImageData?.id)!, content: rawImage, directoryName: "favorites-thumbnails")
            
        }
        
        flickrService.getImageFromFlickrImageUrl((flickrImageData?.getFlickrImageUrl(imageSize: "c", imageFormat: "jpg"))!) {
            
            (rawImage) in
            self.fileService.writeFile(fileName: (self.flickrImageData?.id)!, content: rawImage, directoryName: "favorites-details")
            
        }
        
    }
    
    func removeFavorite(favoredFlickrImageData: FlickrImageData?) {
        
        // Remove favorites from core data
        favoritesRepository.removeFavorite(flickrImageData: favoredFlickrImageData!) {
            (downloadedFlickrImageData) in
            self.flickrImageData = downloadedFlickrImageData
            self.refreshIsFavoredLabelTextColor(favored: false)
        }
        
        // Remove image files from documents
        fileService.removeFile(fileName: (favoredFlickrImageData?.id)!, directoryName: "favorites-thumbnails")
        fileService.removeFile(fileName: (favoredFlickrImageData?.id)!, directoryName: "favorites-details")
    }
    
    func refreshIsFavoredLabelTextColor(favored: Bool) {
        DispatchQueue.main.async {
            if favored {
                self.isFavoredLabel.text = "★"
            } else {
                self.isFavoredLabel.text = ""
            }
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkFlickrImageDataState()
        
        navigationItem.title = flickrImageData?.title
        if fileService.fileExist(fileName: (flickrImageData?.id)!, directoryName: "favorites-details") {
            detailImageView.image = UIImage(data: fileService.getFileContent(fileName: (flickrImageData?.id)!, directoryName: "favorites-details")!)
        } else {
            flickrService.getImageFromFlickrImageUrl((flickrImageData?.getFlickrImageUrl(imageSize: "c", imageFormat: "jpg"))!) {
                
                (rawImage) in
                //self.detailImageView.image = UIImage(data: rawImage)
                //self.view.reloadInputViews()
                DispatchQueue.main.async {
                    self.detailImageView.image = UIImage(data: rawImage)
                    //self.view.reloadInputViews()
                }
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkFlickrImageDataState()
    }
    
    func checkFlickrImageDataState() {
        favoritesRepository.isFavored(flickrImageData: flickrImageData!) {
            (isFavored, favoredFlickrImageData) in
            if isFavored == true {
                self.flickrImageData = favoredFlickrImageData!
                self.refreshIsFavoredLabelTextColor(favored: true)
            } else {
                self.refreshIsFavoredLabelTextColor(favored: false)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
