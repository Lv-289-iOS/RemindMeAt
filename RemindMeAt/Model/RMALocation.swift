//
//  RMALocation.swift
//  RemindMeAt
//
//  Created by Artem Rieznikov on 09.02.18.
//  Copyright © 2018 SoftServe Academy. All rights reserved.
//

import RealmSwift
import CoreLocation

class RMALocation: Object {
    
    @objc dynamic var locationID = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var latitude = CLLocationDegrees(0)
    @objc dynamic var longitude = CLLocationDegrees(0)
    @objc dynamic var radius = CLLocationDistance(0)
    @objc dynamic var whenEnter = true
    
    override static func primaryKey() -> String? {
        return "locationID"
    }
    
    func clone() -> RMALocation {
        let result = RMALocation()
        result.name = self.name
        result.latitude = self.latitude
        result.longitude = self.longitude
        result.radius = self.radius
        result.whenEnter = self.whenEnter
        return result
    }
    
}
