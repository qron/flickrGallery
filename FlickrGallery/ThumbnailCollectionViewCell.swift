import UIKit

class ThumbnailCollectionViewCell: UICollectionViewCell {
    
    static let context = CIContext()
    
    @IBOutlet weak var thumbnailContainerView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var thumbnailTitleLabel: UILabel!
    @IBOutlet weak var localizedLabel: UILabel!
    
    var cellImageUrl: String?
    
    override func draw(_ rect: CGRect) {
        
        // Thumbnail shadow
        thumbnailContainerView.layer.masksToBounds = false
        thumbnailContainerView.layer.shadowColor = UIColor.black.cgColor
        thumbnailContainerView.layer.shadowOpacity = 0.5
        thumbnailContainerView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        thumbnailContainerView.layer.shadowRadius = 1
        
        thumbnailContainerView.layer.shadowPath = UIBezierPath(rect: thumbnailContainerView.bounds).cgPath
        thumbnailContainerView.layer.shouldRasterize = true
        
    }
    
    func setImage(rawImage: Data) {
        
        let image = CIImage(image: UIImage(data: rawImage)!)
        
        let chromeColorFilter = CIFilter(name: "CIPhotoEffectChrome")
        
        chromeColorFilter?.setDefaults()
        
        chromeColorFilter?.setValue(image, forKey: kCIInputImageKey)
        
        let sepiaFilter = CIFilter(name: "CISepiaTone")!
        sepiaFilter.setValue(0.5, forKey: kCIInputIntensityKey)
        
        sepiaFilter.setValue(chromeColorFilter?.outputImage!, forKey: kCIInputImageKey)
        
        let result = sepiaFilter.outputImage!
        let cgImage = ThumbnailCollectionViewCell.context.createCGImage(result, from: result.extent)
        DispatchQueue.main.async {
            self.thumbnailImageView.image = UIImage(cgImage: cgImage!)
        }
        
    }

}
