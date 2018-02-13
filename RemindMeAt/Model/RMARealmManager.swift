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
    
    static func addTagToTask(task: RMATask, tag: RMATag) {
        try! uiRealm.write {
            task.tags.append(tag)
        }
    }
    
    static func getAllTasks() -> Results<RMATask> {
        // TODO: Consider returning [RMATaskList]
        // Since class Results conforms to protocol NSFastEnumeration,
        // it is possible to access each separate RMATaskList through it's index like [index]
        return uiRealm.objects(RMATask.self)
    }
    
    static func getTasksWithNames(nameFilter: String) -> Results<RMATask> {
        return uiRealm.objects(RMATask.self).filter("name CONTAINS '\(nameFilter)'")
    }
    
    static func updateTagName(updatedTag: RMATag, tagName: String) {
        try! uiRealm.write {
            updatedTag.name = tagName
        }
    }
    
    static func updateTaskName(updatedTask: RMATask, taskName: String) {
        try! uiRealm.write {
            updatedTask.name = taskName
        }
    }
    
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
        
}
