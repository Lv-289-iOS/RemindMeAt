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
    
    @objc dynamic var name = ""
    @objc dynamic var latitude = CLLocationDegrees(0)
    @objc dynamic var longitude = CLLocationDegrees(0)
    @objc dynamic var radius = CLLocationDistance(0)
    @objc dynamic var whenEnter = true
    
}
