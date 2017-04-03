import Foundation

class FlickrService {

    // Singleton instance
    static let sharedInstance = try! FlickrService()
    
    // Private initializer
    private init() throws {
        // Set config
        guard let configPath = Bundle.main.path(forResource: "Config", ofType: "plist"),
            let config = NSDictionary(contentsOfFile: configPath) as? [String: Any] else {
            throw FlickrServiceError.configReading
        }
        // Flickr API key
        // To change every 24H
        apiKey = config["Flickr API key"] as! String
        // Flickr response format
        responseFormat = config["Flickr response format"] as! String
        // Flickr images list url pattern
        flickrResultsByTagsPageUrlPattern = config["Flickr URL pattern"] as! String
    }
    
    let apiKey: String
    let responseFormat: String
    let flickrResultsByTagsPageUrlPattern: String
    
    // Pages cache
    var pendingPageDownloads: [Int: Bool] = [:]
    var completionHandlers: [Int: [() -> Void]] = [:]
    
    // Async queues
    let downloadResultsListQueue = DispatchQueue(label: "com.FlickrGallery.httpRequestQueue.getFlickrResultsByTagsPage", qos: .background)
    let downloadPrioritizedResultsListQueue = DispatchQueue(label: "com.FlickrGallery.httpRequestQueue.getPrioritizedFlickrResultsByTagsPage", qos: .userInitiated)
    let downloadImageQueue = DispatchQueue(label: "com.FlickrGallery.httpRequestQueue.getImage", qos: .background)
    
    // Cached images container
    var cache: ImagesCache = ImagesCache.getInstance()
    
    func isPageDownloadPending(page: Int) -> Bool {
        if pendingPageDownloads[page] != nil {
            return pendingPageDownloads[page]!
        } else {
            return false
        }
    }
    
    func onPageDownloadComplete(page: Int, _ completionHandler: @escaping () -> Void) {
        if completionHandlers[page] != nil {
            completionHandlers[page] = [completionHandler]
        } else {
            completionHandlers[page]?.append(completionHandler)
        }
    }
    
    // Download flickr results by tags page
    func getFlickrResultsByTagsPage(_ imagesTags: [String], _ page: Int, _ resultsPerPages: Int, _ resultsHandler: @escaping (_ flickrResultsPages: FlickrResultsPages) -> Void) {
        
        // Prepare tags list
        let tagsParameters = imagesTags.joined(separator: ",")
        
        // Prepare URL
        let flickrResultsByTagsPageUrl =  String(format: flickrResultsByTagsPageUrlPattern, apiKey, tagsParameters, page, resultsPerPages, responseFormat)
 
        // Prepare async queue
        downloadResultsListQueue.async {
            
            let session = URLSession.shared
            let task = session.dataTask(with: URL(string: flickrResultsByTagsPageUrl)!)
            { (data, response, error) in
                
                guard error == nil else {
                    print(error!)
                    return
                }
                
                // Parse JSON from flickr response
                let rawResult = try? JSONSerialization.jsonObject(with: data!)
                resultsHandler(FlickrResultsPages(rawResult: rawResult as! [String: Any]))
                
            }
            
            task.resume()
        }
        
    }
    
    // Download flickr results by tags page urgently
    func getPrioritizedFlickrResultsByTagsPage(_ imagesTags: [String], _ page: Int, _ resultsPerPages: Int, _ resultsHandler: @escaping (_ flickrResultsPages: FlickrResultsPages) -> Void) {
    
        // Prepare tags list
        let tagsParameters = imagesTags.joined(separator: ",")
        
        // Prepare URL
        let flickrResultsByTagsPageUrl =  String(format: flickrResultsByTagsPageUrlPattern, apiKey, tagsParameters, page, resultsPerPages, responseFormat)
        
        // Prepare prioritized async queue
        downloadPrioritizedResultsListQueue.async {
            
            let session = URLSession.shared
            let task = session.dataTask(with: URL(string: flickrResultsByTagsPageUrl)!)
            { (data, response, error) in
                
                guard error == nil else {
                    print(error!)
                    return
                }
                
                // Parse JSON from flickr response
                let rawResult = try? JSONSerialization.jsonObject(with: data!)
                resultsHandler(FlickrResultsPages(rawResult: rawResult as! [String: Any]))
                
            }
            
            task.resume()
        }
    
    }
    
    // Download image
    func getImageFromFlickrImageUrl(_ flickrImageUrl: String, _ resultsHandler: @escaping (_ rawImage: Data) -> Void) {
        
        // Check cache
        if cache.hasCachedImage(imageKey: flickrImageUrl) {
            // Get cached image
            resultsHandler(cache.getCachedImage(imageKey: flickrImageUrl))
            
        } else if cache.hasPendingDownload(imageKey: flickrImageUrl) { // Check pending download
            
            // Add handler on download completion
            cache.onDownloadComplete(imageKey: flickrImageUrl) {
                (rawImage) in
                resultsHandler(rawImage)
            }
            
        } else {
            
            cache.addPendingDownload(imageKey: flickrImageUrl)
            // Prepare async queue
            downloadImageQueue.async {
                
                let session = URLSession.shared
                let task = session.dataTask(with: URL(string: flickrImageUrl)!)
                { (data, response, error) in
                    
                    guard error == nil else {
                        print(error!)
                        return
                    }
                    
                    self.cache.addCachedImage(imageKey: flickrImageUrl, imageData: data!)
                    resultsHandler(data!)
                    
                }
                
                task.resume()
            }
        }
        
    }
    
}
