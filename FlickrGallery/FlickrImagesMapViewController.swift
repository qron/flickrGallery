import UIKit
import MapKit

class FlickrImagesMapViewController: UIViewController {

    @IBOutlet weak var flickrImagesMKMapView: MKMapView!
    
    let flickrService: FlickrService = FlickrService.sharedInstance
    
    let favoritesRepository = FavoritesRepository()
    let fileService = FileService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flickrImagesMKMapView.delegate = self
        
        flickrImagesMKMapView.showsScale = true
        flickrImagesMKMapView.showsCompass = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.flickrImagesMKMapView.removeAnnotations(flickrImagesMKMapView.annotations)
        
        // Load flicker image data list
        favoritesRepository.fetchFavorites() {
            (favoredFlickerImageDataList) in
            
            for favoredFlickrImageData in favoredFlickerImageDataList {
                if favoredFlickrImageData.latitude != 999 && favoredFlickrImageData.longitude != 999 {
                    let flickrImageAnnotation = FlickrImageMKPointAnnotation()
                    flickrImageAnnotation.flickrImageData = favoredFlickrImageData
                    flickrImageAnnotation.coordinate = CLLocationCoordinate2D(latitude: favoredFlickrImageData.latitude, longitude: favoredFlickrImageData.longitude)
                    flickrImageAnnotation.title = favoredFlickrImageData.title
                    
                    self.flickrImagesMKMapView.addAnnotation(flickrImageAnnotation)
                    
                }
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension FlickrImagesMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let flickrImageMKPointAnnotation = annotation as! FlickrImageMKPointAnnotation
        
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "flickrImageView") {
            annotationView.annotation = flickrImageMKPointAnnotation
            return annotationView
        }

        let annotationView = MKAnnotationView(annotation: flickrImageMKPointAnnotation, reuseIdentifier: "flickrImageView")
        
        if fileService.fileExist(fileName: (flickrImageMKPointAnnotation.flickrImageData?.id)!, directoryName: "favorites-annotations") {
            annotationView.image = UIImage(data: fileService.getFileContent(fileName: (flickrImageMKPointAnnotation.flickrImageData?.id)!, directoryName: "favorites-annotations")!)
        } else {
            flickrService.getImageFromFlickrImageUrl((flickrImageMKPointAnnotation.flickrImageData?.getFlickrImageUrl(imageSize: "s", imageFormat: "jpg"))!) {
                
                (rawImage) in
                DispatchQueue.main.async {
                    annotationView.image = UIImage(data: rawImage)
                }
                
            }
        }
        
        
        annotationView.canShowCallout = true
        
        return annotationView
        
    }
}
