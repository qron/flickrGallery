import Foundation

class FlickrService {

    // Singleton instance
    static let sharedInstance = FlickrService()
    
    // Private initializer
    private init() {
    }
    
    // Instance getter
    static func getInstance() -> FlickrService {
        return FlickrService.sharedInstance
    }
    
    // Pages cache
    var pendingPageDownloads: [Int: Bool] = [:]
    var completionHandlers: [Int: [() -> Void]] = [:]

    // Flickr API key
    static let apiKey = "68f9a3498ff770330ef51429836ba68a" // To change every 24H
    
    // Flickr response format
    static let responseFormat = "json"
    
    // Flickr images list url pattern
    static let flickrResultsByTagsPageUrlPattern = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&tags=%@&page=%d&per_page=%d&extras=original_format&format=%@&nojsoncallback=1"
    
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
        let flickrResultsByTagsPageUrl =  String(format: FlickrService.flickrResultsByTagsPageUrlPattern, FlickrService.apiKey, tagsParameters, page, resultsPerPages, FlickrService.responseFormat)
 
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
        let flickrResultsByTagsPageUrl =  String(format: FlickrService.flickrResultsByTagsPageUrlPattern, FlickrService.apiKey, tagsParameters, page, resultsPerPages, FlickrService.responseFormat)
        
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
