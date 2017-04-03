import Foundation
import UIKit

class FlickrImageData {
    
    // Flickr image url pattern
    static let flickrImageUrlPattern = "https://farm%d.staticflickr.com/%@/%@_%@_%@.%@"
    static var i = 0
    let imageTitle: String
    let photoId: String
    let secretId: String
    let serverId: String
    let farmId: Int
    //let originalSecretId: String
    //let originalFormat: String

    init(_ rawData: Dictionary<String, Any>) {

        self.imageTitle = rawData["title"] as! String
        self.photoId = rawData["id"] as! String
        self.secretId = rawData["secret"] as! String
        self.serverId = rawData["server"] as! String
        self.farmId = rawData["farm"] as! Int
        //self.originalSecretId = rawData["originalsecret"] as! String
        //self.originalFormat = rawData["originalformat"] as! String
    }
    
    func getFlickrImageUrl(imageSize: String, imageFormat: String) -> String {
        return String(format: FlickrImageData.flickrImageUrlPattern, farmId, serverId, photoId, secretId, imageSize, imageFormat)
    }
    
    //func getFlickrOriginalImageUrl() -> String {
    //    return String(format: FlickrImageData.flickrImageUrlPattern, farmId, serverId, photoId, originalSecretId, "o", originalFormat)
    //}
    
}
