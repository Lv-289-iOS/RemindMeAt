//
//  RMATask.swift
//  RemindMeAt
//
//  Created by Artem Rieznikov on 07.02.18.
//  Copyright © 2018 SoftServe Academy. All rights reserved.
//

import RealmSwift

class RMATask: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var fullDescription: String?
    @objc dynamic var date: NSDate?
    @objc dynamic var location: RMALocation?
    @objc dynamic var imageURL: String? // TODO: it will be NSURL? (will use something like URL.absoluteString)
    @objc dynamic var isCompleted = false
    let tags = List<RMATag>() // Consider making this Set<RMATag> (not supported by Realm) or RLMArray or RLMLinkingObjects
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
    
}
