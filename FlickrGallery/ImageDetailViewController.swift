import UIKit

class ImageDetailViewController: UIViewController {

    @IBOutlet weak var detailImageView: UIImageView!
    
    var flickerImageData: FlickrImageData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //FlickrService.getInstance().getImageFromFlickrImageUrl((flickerImageData?.getFlickrOriginalImageUrl())!) {
        FlickrService.getInstance().getImageFromFlickrImageUrl((flickerImageData?.getFlickrImageUrl(imageSize: "c", imageFormat: "jpg"))!) {

            (rawImage) in
            //self.detailImageView.image = UIImage(data: rawImage)
            //self.view.reloadInputViews()
            DispatchQueue.main.async {
                self.detailImageView.image = UIImage(data: rawImage)
                //self.view.reloadInputViews()
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
