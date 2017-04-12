import Foundation

class FavoritesRepository {
    
    let coreDataHelper = CoreDataHelper()
    
    func addFavorite(flickrImageData: FlickrImageData, _ completionHandler: @escaping (FavoredFlickrImageData) -> Void) {
        
        isFavored(flickrImageData: flickrImageData) {
            (isFavored, favoredFlickrImageData) in
            if isFavored == false {
                let newFavoredFlickrImageData: FavoredFlickrImageData = self.coreDataHelper.create()
                newFavoredFlickrImageData.build(flickrImageData: flickrImageData)
                self.coreDataHelper.save()
                completionHandler(newFavoredFlickrImageData)
            } else {
                completionHandler(favoredFlickrImageData as! FavoredFlickrImageData)
            }
        }
        
    }
    
    func removeFavorite(flickrImageData: FlickrImageData, _ completionHandler: @escaping (FlickrImageData) -> Void) {
        isFavored(flickrImageData: flickrImageData) {
            (isFavored, favoredFlickrImageData) in
            if isFavored == true {
                completionHandler((favoredFlickrImageData as! FavoredFlickrImageData).clone())
                self.coreDataHelper.remove(entityInstance: favoredFlickrImageData as! FavoredFlickrImageData)
                self.coreDataHelper.save()
            } else {
                completionHandler(flickrImageData)
            }
        }
    }
    
    func fetchFavorites(_ completionHandler: @escaping ([FavoredFlickrImageData]) -> Void) {
        
        try? coreDataHelper.fetch(completionHandler)
        
    }

    private func findFavoriteById(id: String, _ completionHandler: @escaping (FavoredFlickrImageData?) -> Void) {
        
        try? coreDataHelper.predicatedFetch(predicate: String(format: "id == %@", id)) {
            (fetched: [FavoredFlickrImageData]) in
            if fetched.count > 0 {
                completionHandler(fetched[0])
            } else {
                completionHandler(nil)
            }
        }
        
    }
    
    func isFavored(flickrImageData: FlickrImageData, _ completionHandler: @escaping (Bool, FlickrImageData?) -> Void) {
        
        findFavoriteById(id: flickrImageData.id) {
            (flickrImageData) in
            if flickrImageData != nil {
                completionHandler(true, flickrImageData)
            } else {
                completionHandler(false, nil)
            }
        }
        
    }
    
}
