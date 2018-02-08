//
//  RMARealmService.swift
//  RemindMeAt
//
//  Created by Artem Rieznikov on 08.02.18.
//  Copyright © 2018 SoftServe Academy. All rights reserved.
//

import RealmSwift

class RMARealmService {
    
    // MARK: - CRUD functions for Realm
    
    static func addTaskList(listName: String) -> RMATaskList {
        let newTaskList = RMATaskList()
        newTaskList.name = listName
        
        try! uiRealm.write {
            uiRealm.add(newTaskList)
        }
        
        return newTaskList
    }
    
    static func addTask(taskList: RMATaskList, taskName: String) -> RMATask {
        let newTask = RMATask()
        newTask.name = taskName
        
        try! uiRealm.write {
            taskList.tasks.append(newTask)
        }
        
        return newTask
    }
    
    static func getAllTasks() -> Results<RMATaskList> {
        // TODO: Consider returning [RMATaskList]
        // Since class Results conforms to protocol NSFastEnumeration,
        // it is possible to access each separate RMATaskList through it's index like [index]
        return uiRealm.objects(RMATaskList.self)
    }
    
    static func getTasksWithNames(nameFilter: String) -> Results<RMATaskList> {
        return uiRealm.objects(RMATaskList.self).filter("name CONTAINS '\(nameFilter)'")
    }
    
    static func updateTaskListName(updatedList: RMATaskList, listName: String) {
        try! uiRealm.write {
            updatedList.name = listName
        }
    }
    
    static func updateTaskName(updatedTask: RMATask, taskName: String) {
        try! uiRealm.write {
            updatedTask.name = taskName
        }
    }
    
    static func deleteTaskList(taskListToBeDeleted: RMATaskList) {
        try! uiRealm.write {
            uiRealm.delete(taskListToBeDeleted)
        }
    }
    
    static func deleteTask(taskToBeDeleted: RMATask) {
        try! uiRealm.write {
            uiRealm.delete(taskToBeDeleted)
        }
    }
    
    // MARK: - Soring functions for Realm
    
    /// Returns list sorted by name in "A-Z" order
    static func sortByName(listsTasks: Results<RMATaskList>) -> Results<RMATaskList> {
        return listsTasks.sorted(byKeyPath: "name")
    }
    
    static func sortByCreatedAtDate(listsTasks: Results<RMATaskList>) -> Results<RMATaskList> {
        return listsTasks.sorted(byKeyPath: "createdAt", ascending: false)
    }
        
}
