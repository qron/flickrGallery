import Foundation

extension FavoredFlickrImageData: FlickrImageData {
    
    static let flickrImageUrlPattern = "https://farm%@.staticflickr.com/%@/%@_%@_%@.%@"
    
    func build(flickrImageData: FlickrImageData) {
        
        title = flickrImageData.title
        id = flickrImageData.id
        secret = flickrImageData.secret
        server = flickrImageData.server
        farm = flickrImageData.farm
        latitude = flickrImageData.latitude
        longitude = flickrImageData.longitude
        
    }
    
    func getFlickrImageUrl(imageSize: String, imageFormat: String) -> String {
        
        return String(format: FavoredFlickrImageData.flickrImageUrlPattern, farm, server, id, secret, imageSize, imageFormat)
        
    }
    
    func clone() -> FlickrImageData {
        return DownloadedFlickrImageData(title: title, id: id, secret: secret, server: server, farm: farm, latitude: latitude, longitude: longitude)
    }

}
