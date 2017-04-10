import Foundation

class DownloadedFlickrImageData: FlickrImageData {
    
    static let flickrImageUrlPattern = "https://farm%@.staticflickr.com/%@/%@_%@_%@.%@"
    let title: String
    let id: String
    let secret: String
    let server: String
    let farm: String

    init(_ rawData: Dictionary<String, Any>) {

        self.title = rawData["title"] as! String
        self.id = rawData["id"] as! String
        self.secret = rawData["secret"] as! String
        self.server = rawData["server"] as! String
        self.farm = "\(rawData["farm"] as! Int)"
    }
    
    init(title: String, id: String, secret: String, server: String, farm: String) {
       
        self.title = title
        self.id = id
        self.secret = secret
        self.server = server
        self.farm = farm
    
    }
    
    func getFlickrImageUrl(imageSize: String, imageFormat: String) -> String {
        
        return String(format: DownloadedFlickrImageData.flickrImageUrlPattern, farm, server, id, secret, imageSize, imageFormat)
    
    }
    
}
