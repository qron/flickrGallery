import Foundation


class FileService {
    
    
    let fileManager = FileManager.default
    let rootUrl: URL
    
    init() {
        guard let documentDirectoryUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Cannot find document directory in file system")
        }
        
        rootUrl = documentDirectoryUrl
        
    }
    
    func writeFile(fileName: String, content: Data, directoryName: String) {
        
        writeFile(fileName: URL(string: directoryName)!.appendingPathComponent(fileName).path, content: content)
    
    }
    
    func writeFile(fileName: String, content: Data) {
        
        let filePath = rootUrl.appendingPathComponent(fileName)
        
        fileManager.createFile(atPath: filePath.path, contents: content)
        
    }
    
    func getFileContent(fileName: String, directoryName: String) -> Data? {
        return getFileContent(fileName: URL(string: directoryName)!.appendingPathComponent(fileName).path)
    }
    
    func getFileContent(fileName: String) -> Data? {
        if fileExist(fileName: fileName) {
            return try! Data(contentsOf: rootUrl.appendingPathComponent(fileName))
        } else {
            return nil
        }
    }

    func fileExist(fileName: String, directoryName: String) -> Bool {
        
        return fileExist(fileName: URL(string: directoryName)!.appendingPathComponent(fileName).path)
        
    }
    
    func fileExist(fileName: String) -> Bool {
        
        return fileManager.fileExists(atPath: rootUrl.appendingPathComponent(fileName).path)
        
    }
    
    func removeFile(fileName: String, directoryName: String) {
        removeFile(fileName: URL(string: directoryName)!.appendingPathComponent(fileName).path)
    }
    
    func removeFile(fileName: String) {
        if fileExist(fileName: fileName) {
            do {
                try fileManager.removeItem(at: rootUrl.appendingPathComponent(fileName))
            } catch {
                fatalError("Cannot remove \(fileName) from file system: \(error)")
            }
        }
    }
    
}
