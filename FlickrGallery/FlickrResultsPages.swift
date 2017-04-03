import Foundation

class FlickrResultsPages {
    
    var pagesNumber: Int
    var totalFlickrImage: Int
    
    var flickrImageDataList: [Int: FlickrImageData] = [:]
    
    init(rawResult: [String: Any]) {
        
        let rawPage = rawResult["photos"] as! [String: Any]
        
        let currentPage = rawPage["page"] as! Int
        let resultsPerPage = rawPage["perpage"] as! Int
        
        self.pagesNumber = rawPage["pages"] as! Int
        self.totalFlickrImage = Int(rawPage["total"] as! String)!
        
        var rawList = rawPage["photo"] as! [[String: Any]]
        
        for i in 0 ..< rawList.count {
            flickrImageDataList[((currentPage - 1) * resultsPerPage) + i] = FlickrImageData(rawList[i])
        }

    }
    
    func getFlickrImageDataListCount() -> Int {
        return flickrImageDataList.count
    }
    
    func getFLickrImageData(_ index: Int) throws -> FlickrImageData? {

        if index + 1 > totalFlickrImage {
            throw FlickrServiceError.resultsListIndexOutOfRange(index: index)
        } else {
            return flickrImageDataList[index]
        }
    }

    func concatenateResults(flickrResultsPages: FlickrResultsPages) {
        pagesNumber = flickrResultsPages.pagesNumber
        totalFlickrImage = flickrResultsPages.totalFlickrImage
        
        for(index, flickrImageData) in flickrResultsPages.flickrImageDataList {
            self.flickrImageDataList[index] = flickrImageData
        }
        
    }
    
}
