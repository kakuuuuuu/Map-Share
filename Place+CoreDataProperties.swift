//
//  Place+CoreDataProperties.swift
//  socketTest
//
//  Created by Kyle Tsuyemura on 7/20/16.
//  Copyright © 2016 Kyle Tsuyemura. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Place {

    @NSManaged var location: String?
    @NSManaged var lat: NSNumber?
    @NSManaged var lng: NSNumber?

}
