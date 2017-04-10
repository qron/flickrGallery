import Foundation

protocol FlickrImageData {
    
    static var flickrImageUrlPattern: String { get }
    var title: String { get }
    var id: String { get }
    var secret: String { get }
    var server: String { get }
    var farm: String { get }
    
    func getFlickrImageUrl(imageSize: String, imageFormat: String) -> String
    
}
