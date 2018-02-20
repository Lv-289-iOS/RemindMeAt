//
//  RMARealmManager.swift
//  RemindMeAt
//
//  Created by Artem Rieznikov on 08.02.18.
//  Copyright © 2018 SoftServe Academy. All rights reserved.
//

import RealmSwift

class RMARealmManager {
    
    // MARK: - CRUD functions for Realm
    
    static func addTask(newTask: RMATask) {
        try! uiRealm.write {
            uiRealm.add(newTask)
        }
    }
    
    static func getAllTasks() -> Results<RMATask> {
        // TODO: Consider returning [RMATaskList]
        // Since class Results conforms to protocol NSFastEnumeration,
        // it is possible to access each separate RMATaskList through it's index like [index]
        return uiRealm.objects(RMATask.self)
    }
    
    static func getAllTags() -> Results<RMATag> {
        return uiRealm.objects(RMATag.self)
    }
    
    static func getTagByName(name: String) -> RMATag? {
        return getAllTags().filter("name == '\(name)'").first
    }
    
    static func getTasksWithNames(nameFilter: String) -> Results<RMATask> {
        return uiRealm.objects(RMATask.self).filter("name CONTAINS '\(nameFilter)'")
    }
    
    // MARK: - UPDATE functions for Task
    
    static func updateTaskName(updatedTask: RMATask, taskName: String) {
        try! uiRealm.write {
            updatedTask.name = taskName
        }
    }
    
    static func updateTask(_ updatedTask: RMATask) {
        let name = updatedTask.name
        let fullDescription = updatedTask.fullDescription
        let date = updatedTask.date
        let location = updatedTask.location
        let imageURL = updatedTask.imageURL
        let isCompleted = updatedTask.isCompleted
        
        try! uiRealm.write {
            updatedTask.name = name
            updatedTask.fullDescription = fullDescription
            updatedTask.date = date
            updatedTask.location = location
            updatedTask.imageURL = imageURL
            updatedTask.isCompleted = isCompleted
            // TODO: updatedTask.tags
            // task.tags.append(tag)
        }
    }
    
    // MARK: - DELETE functions for Realm
    
    static func deleteTag(tagToBeDeleted: RMATag) {
        try! uiRealm.write {
            uiRealm.delete(tagToBeDeleted)
        }
    }
    
    static func deleteTask(taskToBeDeleted: RMATask) {
        try! uiRealm.write {
            uiRealm.delete(taskToBeDeleted)
        }
    }
    
    // MARK: - Soring functions for Realm
    
    /// Returns list sorted by name in "A-Z" order
    static func sortTasksByName(listsTasks: Results<RMATask>) -> Results<RMATask> {
        return listsTasks.sorted(byKeyPath: "name")
    }
    
    static func sortTasksByDate(listsTasks: Results<RMATask>) -> Results<RMATask> {
        return listsTasks.sorted(byKeyPath: "date", ascending: false)
    }
    
    // MARK: - Helper functions for Realm
    
    /// Seed the database i.e. import a set of initial data into DB (load a fixture)
    static func seedData() {
        let allTags = uiRealm.objects(RMATag.self)
        if allTags.count == 0 {
            try! uiRealm.write {
                uiRealm.add(RMATag(tagName: "holidays", tagColor: #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)))
                uiRealm.add(RMATag(tagName: "home", tagColor: #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1)))
                uiRealm.add(RMATag(tagName: "shopping", tagColor: #colorLiteral(red: 1, green: 0.1857388616, blue: 0.5733950138, alpha: 1)))
                uiRealm.add(RMATag(tagName: "family", tagColor: #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)))
                uiRealm.add(RMATag(tagName: "rest", tagColor: #colorLiteral(red: 0.5810584426, green: 0.1285524964, blue: 0.5745313764, alpha: 1)))
                uiRealm.add(RMATag(tagName: "studying", tagColor: #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)))
                uiRealm.add(RMATag(tagName: "other", tagColor: #colorLiteral(red: 0.5807225108, green: 0.066734083, blue: 0, alpha: 1)))
            }
        }
    }
        
}
