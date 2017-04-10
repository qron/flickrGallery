//
//  FavoredFlickrImageData+CoreDataProperties.swift
//  FlickrGallery
//
//  Created by Qron on 06/04/2017.
//  Copyright © 2017 qron. All rights reserved.
//

import Foundation
import CoreData


extension FavoredFlickrImageData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoredFlickrImageData> {
        return NSFetchRequest<FavoredFlickrImageData>(entityName: "FavoredFlickrImageData");
    }

    @NSManaged public var farm: String
    @NSManaged public var id: String
    @NSManaged public var secret: String
    @NSManaged public var server: String
    @NSManaged public var title: String

}
