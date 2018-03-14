//
//  RMATask.swift
//  RemindMeAt
//
//  Created by Artem Rieznikov on 07.02.18.
//  Copyright © 2018 SoftServe Academy. All rights reserved.
//

import RealmSwift

class RMATask: Object {
    
    @objc dynamic var taskID = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var fullDescription: String?
    @objc dynamic var date: NSDate?
    @objc dynamic var location: RMALocation?
    @objc dynamic var taskImageURL: String?
    @objc dynamic var imageURL: String?
    @objc dynamic var repeatPeriod: Int = 0
    @objc dynamic var isCompleted = false
    let tags = List<RMATag>()
    
    override static func primaryKey() -> String? {
        return "taskID"
    }
    
    func clone() -> RMATask {
        let result = RMATask()
        result.name = self.name
        result.fullDescription = self.fullDescription
        result.date = self.date
        result.location = self.location
        result.imageURL = self.imageURL
        result.taskImageURL = self.taskImageURL
        result.repeatPeriod = self.repeatPeriod
        result.isCompleted = self.isCompleted
        return result
    }
    
}
