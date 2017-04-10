//
//  FavoritesRepositoryTests.swift
//  FlickrGallery
//
//  Created by Qron on 05/04/2017.
//  Copyright © 2017 qron. All rights reserved.
//

import XCTest
@testable import FlickrGallery

import CoreData
import UIKit

class FavoritesRepositoryTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        context.perform {
            
            let fetchRequest: NSFetchRequest<FavoredFlickrImageData> = FavoredFlickrImageData.fetchRequest()
            
            do {
                let fetched = try fetchRequest.execute()
                
                for item in fetched {
                    context.delete(item)
                }
                appDelegate.saveContext()
                
                
            } catch {
                fatalError("Failed to fetch entity: \(error)")
            }
            
        }
        
        super.tearDown()
    }
    
    func testBuildFavoriteFlickerImageData() {

        let mockRawData: [String: Any] = [
            "title": "testTitle",
            "id": "testId",
            "secret": "testSecret",
            "server": "testServer",
            "farm": 1
        ]
        
        let flickrImageData = DownloadedFlickrImageData(mockRawData) as FlickrImageData
        
        let favoredFlickrImageData = NSEntityDescription.insertNewObject(forEntityName: "FavoredFlickrImageData", into: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext) as! FavoredFlickrImageData
        
        favoredFlickrImageData.build(flickrImageData: flickrImageData)
        
        XCTAssertEqual(mockRawData["title"] as! String, favoredFlickrImageData.title)
        XCTAssertEqual(mockRawData["id"] as! String, favoredFlickrImageData.id)
        XCTAssertEqual(mockRawData["secret"] as! String, favoredFlickrImageData.secret)
        XCTAssertEqual(mockRawData["server"] as! String, favoredFlickrImageData.server)
        XCTAssertEqual("\(mockRawData["farm"] as! Int)", favoredFlickrImageData.farm)
        
    }
    
//    func testAddFavoriteToFavoritesRepository() {
//        
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//        
//        let favoritesRepository = FavoritesRepository()
//        
//        let mockRawData: [String: Any] = [
//            "title": "testTitle",
//            "id": "testId",
//            "secret": "testSecret",
//            "server": "testServer",
//            "farm": 1
//        ]
//        
//        let flickrImageData = DownloadedFlickrImageData(mockRawData) as FlickrImageData
//        
//        favoritesRepository.addFavorite(flickrImageData: flickrImageData) {
//            _ in
//        }
//        
//        let expect = expectation(description: "context.perform has been called")
//        
//        context.perform {
//            
//            let fetchRequest: NSFetchRequest<FavoredFlickrImageData> = FavoredFlickrImageData.fetchRequest()
//            
//            do {
//                let fetched = try fetchRequest.execute()
//                
//                let favoredFlickrImageData = fetched[0]
//                
//                XCTAssertEqual(mockRawData["title"] as! String, favoredFlickrImageData.title)
//                XCTAssertEqual(mockRawData["id"] as! String, favoredFlickrImageData.id)
//                XCTAssertEqual(mockRawData["secret"] as! String, favoredFlickrImageData.secret)
//                XCTAssertEqual(mockRawData["server"] as! String, favoredFlickrImageData.server)
//                XCTAssertEqual("\(mockRawData["farm"] as! Int)", favoredFlickrImageData.farm)
//                
//                expect.fulfill()
//                
//            } catch {
//                fatalError("Failed to fetch entity: \(error)")
//            }
//            
//        }
//        
//        self.waitForExpectations(timeout: 1) {
//            error in
//            // handle errors
//        }
//        
//    }
    
}
