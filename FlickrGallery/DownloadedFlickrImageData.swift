import Foundation

class DownloadedFlickrImageData: FlickrImageData {
    
    let flickrService = FlickrService.sharedInstance
    
    static let flickrImageUrlPattern = "https://farm%@.staticflickr.com/%@/%@_%@_%@.%@"
    let title: String
    let id: String
    let secret: String
    let server: String
    let farm: String
    
    var latitude: Double
    var longitude: Double
    
    init(title: String, id: String, secret: String, server: String, farm: String, latitude: Double, longitude: Double) {
       
        self.title = title
        self.id = id
        self.secret = secret
        self.server = server
        self.farm = farm
        
        self.latitude = latitude
        self.longitude = longitude
    
    }
    
    func getFlickrImageUrl(imageSize: String, imageFormat: String) -> String {
    
        return String(format: DownloadedFlickrImageData.flickrImageUrlPattern, farm, server, id, secret, imageSize, imageFormat)
    
    }
    
}
