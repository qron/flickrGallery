import Foundation

class ImagesCache {
    
    // Singleton instance
    static let sharedInstance = ImagesCache()
    
    // Private initializer
    private init() {
    }
    
    // Instance getter
    static func getInstance() -> ImagesCache {
        return ImagesCache.sharedInstance
    }
    
    var cached: [String:Data] = [:]
    
    var pending: [String:Bool] = [:]
    
    var completionHandlers: [String:[(_ imageData: Data) -> Void]] = [:]
    
    func addPendingDownload(imageKey: String) {
        pending[imageKey] = true
    }
    
    func hasPendingDownload(imageKey: String) -> Bool {
        return pending[imageKey] != nil
    }
    
    func addCachedImage(imageKey: String, imageData: Data) {
        cached[imageKey] = imageData
        if completionHandlers[imageKey] != nil {
            for completionHandler in completionHandlers[imageKey]! {
                completionHandler(cached[imageKey]!)
            }
            completionHandlers[imageKey] = nil
        }
        pending[imageKey] = false
    }
    
    func onDownloadComplete(imageKey: String, _ completionHandler: @escaping (_ imageData: Data) -> Void) {
        if completionHandlers[imageKey] != nil {
            completionHandlers[imageKey] = [completionHandler]
        } else {
            completionHandlers[imageKey]?.append(completionHandler)
        }
    }
    
    func hasCachedImage(imageKey: String) -> Bool {
        return cached[imageKey] != nil
    }
    
    func getCachedImage(imageKey: String) -> Data {
        return cached[imageKey]!
    }
    
}
