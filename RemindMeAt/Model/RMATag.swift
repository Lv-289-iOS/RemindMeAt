//
//  RMATag.swift
//  RemindMeAt
//
//  Created by Artem Rieznikov on 09.02.18.
//  Copyright © 2018 SoftServe Academy. All rights reserved.
//

import RealmSwift

class RMATag: Object {
    
    @objc dynamic var tagID = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var color: String = UIColor.clear.hexString()
    
    convenience init(tagName: String, tagColor: UIColor) {
        self.init() // Please note this says 'self' and not 'super'
        self.name = tagName
        self.color = tagColor.hexString()
    }
    
    override static func primaryKey() -> String? {
        return "tagID"
    }
    
}
