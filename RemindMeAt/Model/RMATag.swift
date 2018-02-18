//
//  RMATag.swift
//  RemindMeAt
//
//  Created by Artem Rieznikov on 09.02.18.
//  Copyright © 2018 SoftServe Academy. All rights reserved.
//

import RealmSwift

class RMATag: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var color: String = UIColor.clear.hexString()
    
}
