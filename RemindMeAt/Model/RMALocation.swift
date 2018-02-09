//
//  RMALocation.swift
//  RemindMeAt
//
//  Created by Artem Rieznikov on 09.02.18.
//  Copyright © 2018 SoftServe Academy. All rights reserved.
//

import RealmSwift

class RMALocation: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0
    
}
