//
//  Tag.swift
//  addNewAndEditTask
//
//  Created by Ganna Melnyk on 2/10/18.
//  Copyright © 2018 Ganna Melnyk. All rights reserved.
//

import Foundation
import UIKit

struct Tag {
    let tagName: String
    let tagColor: UIColor
    var isTagChoosen: Bool
    
    init (tagName: String, tagColor: UIColor, isTagChoosen: Bool) {
        self.tagName = tagName
        self.tagColor = tagColor
        self.isTagChoosen = isTagChoosen
    }
}
