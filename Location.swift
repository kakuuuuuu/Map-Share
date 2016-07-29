//
//  Location.swift
//  socketTest
//
//  Created by Kyle Tsuyemura on 7/20/16.
//  Copyright © 2016 Kyle Tsuyemura. All rights reserved.
//

import Foundation
import MapKit

class Location: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    let link: String
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D, link: String) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        self.link = link
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
}