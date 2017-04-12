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
    let downloadImageLocationsQueue = DispatchQueue(label: "com.FlickrGallery.httpRequestQueue.getImageLocations", qos: .background)
    
    // Tasks container
    var tasks: [String: URLSessionDataTask] = [:]
    
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
    
    private func urlifyTags(tag: String) -> String {
        var formatedTag: String
        
        formatedTag = tag.replacingOccurrences(of: " ", with: "+")
        
        return formatedTag
    }
    
    // Download flickr results by tags page
    func getFlickrResultsByTagsPage(_ imagesTags: [String], _ page: Int, _ resultsPerPages: Int, _ resultsHandler: @escaping (_ flickrResultsPages: FlickrResultsPages) -> Void) {
        
        // Prepare tags list
        let tagsParameters = imagesTags.map({urlifyTags(tag: $0)}).joined(separator: ",")
        
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
                let rawResult = try? JSONSerialization.jsonObject(with: data!) as! [String: Any]
                
                self.parseFlickrResultsPageJson(result: rawResult!, resultsHandler)
                
            }
            
            task.resume()
        }
        
    }
    
    func parseFlickrResultsPageJson(result: [String: Any], _ resultsHandler: @escaping (_ flickrResultsPages: FlickrResultsPages) -> Void) {
        
        // Prepare flickr results page arguments
        
        let rawPage = result["photos"] as! [String: Any]
        
        let currentPage = rawPage["page"] as! Int
        let resultsPerPage = rawPage["perpage"] as! Int
        
        let pagesNumber = rawPage["pages"] as! Int
        let totalFlickrImage = Int(rawPage["total"] as! String)!
        
        let rawList = rawPage["photo"] as! [[String: Any]]
        
        
        // Prepare flickr image data list
        var flickrImageDataList: [Int: FlickrImageData] = [:]
        
        let prepareFlickrImageDataGroup = DispatchGroup()
        
        for i in 0 ..< rawList.count {
            
            prepareFlickrImageDataGroup.enter()
            
            let rawData = rawList[i]
            
            let title = rawData["title"] as! String
            let id = rawData["id"] as! String
            let secret = rawData["secret"] as! String
            let server = rawData["server"] as! String
            let farm = "\(rawData["farm"] as! Int)"
            
            let flickrImageDataIndex = ((currentPage - 1) * resultsPerPage) + i
            
            self.getImageLocationFromFlickrImageId(id: id) {
                (latitude, longitude) in
                
                flickrImageDataList[flickrImageDataIndex] = DownloadedFlickrImageData(title: title, id: id, secret: secret, server: server, farm: farm, latitude: latitude, longitude: longitude)
                
                prepareFlickrImageDataGroup.leave()
                
            }
            
        }
        
        prepareFlickrImageDataGroup.notify(queue: DispatchQueue.main, work: DispatchWorkItem(block: {
            resultsHandler(FlickrResultsPages(currentPage: currentPage, resultsPerPage: resultsPerPage, pagesNumber: pagesNumber, totalFlickrImages: totalFlickrImage, flickrImageDataList: flickrImageDataList))
        }))
        
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
                let rawResult = try? JSONSerialization.jsonObject(with: data!) as! [String: Any]
                self.parseFlickrResultsPageJson(result: rawResult!, resultsHandler)
                
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
                
                self.tasks[flickrImageUrl] = task
                
                task.resume()
            }
        }
        
    }
    
    func cancelPendingTask(taskUrl: String) {
        if tasks[taskUrl] != nil {
            tasks[taskUrl]?.cancel()
        }
        cache.cancelPendingDownload(imageKey: taskUrl)
    }
    
    func getImageLocationFromFlickrImageId(id: String, _ resultsHandler: @escaping (_ latitude: Double, _ longitude: Double) -> Void) {
        
        let url = String(format: "https://api.flickr.com/services/rest/?method=flickr.photos.geo.getLocation&api_key=%@&photo_id=%@&format=json&nojsoncallback=1", apiKey, id)
        
        downloadImageLocationsQueue.async {
            let session = URLSession.shared
            let task = session.dataTask(with: URL(string: url)!)
            { (data, response, error) in
                
                guard error == nil else {
                    print(error!)
                    return
                }
                
                let rawResult = try? JSONSerialization.jsonObject(with: data!) as! [String: Any]
                
                let stat = rawResult?["stat"] as! String
                
                if  stat == "ok" {
                    let locations = (rawResult?["photo"] as! [String: Any])["location"] as! [String: Any]
                    resultsHandler(Double(locations["latitude"] as! String)!, Double(locations["longitude"] as! String)!)
                } else {
                    // Cannot set latitude/longitude as optional in this damned xcode core data, thus set invalid value
                    resultsHandler(999, 999)
                }
                
            }
            
            task.resume()
        }
        
        
    }
    
}
