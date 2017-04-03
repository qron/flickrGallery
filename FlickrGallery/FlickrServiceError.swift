import Foundation
enum FlickrServiceError: Error {
    case resultsListIndexOutOfRange(index: Int)
    case configReading
}
