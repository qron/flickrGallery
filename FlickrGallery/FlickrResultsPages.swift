import Foundation

class FlickrResultsPages {
    
    var pagesNumber: Int
    var totalFlickrImage: Int
    
    var flickrImageDataList: [Int: FlickrImageData] = [:]
    
    init(currentPage: Int, resultsPerPage: Int, pagesNumber: Int, totalFlickrImages: Int, flickrImageDataList: [Int: FlickrImageData]) {
        self.pagesNumber = pagesNumber
        self.totalFlickrImage = totalFlickrImages
        
        for i in 0 ..< flickrImageDataList.count {
            self.flickrImageDataList[((currentPage - 1) * resultsPerPage) + i] = flickrImageDataList[i]
        }
    }
    
    func getFlickrImageDataListCount() -> Int {
        return flickrImageDataList.count
    }
    
    func getFlickrImageData(_ index: Int) throws -> FlickrImageData? {

        if index + 1 > totalFlickrImage {
            throw FlickrServiceError.resultsListIndexOutOfRange(index: index)
        } else {
            return flickrImageDataList[index]
        }
    }

    func concatenateResults(flickrResultsPages: FlickrResultsPages) {
        //pagesNumber = flickrResultsPages.pagesNumber
        //totalFlickrImage = flickrResultsPages.totalFlickrImage
        
        for(index, flickrImageData) in flickrResultsPages.flickrImageDataList {
            self.flickrImageDataList[index] = flickrImageData
        }
        
    }
    
}
