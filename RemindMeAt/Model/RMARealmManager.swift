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
        return uiRealm.objects(RMATask.self)
    }
    
    static func getAllTasksByDate(_ date: NSDate) -> Results<RMATask> {
        let dateAndTime = date as Date
        let startOfDay = dateAndTime.startOfDay
        let endOfDayOptional = dateAndTime.endOfDay
        var endOfDay = dateAndTime
        if let endOfDayUnwrapped = endOfDayOptional {
            endOfDay = endOfDayUnwrapped
        }
        return getAllTasks().filter("(date >= %@) AND (date <= %@)", startOfDay, endOfDay)
    }
    
    static func isTasksAvailableByDate(_ date: NSDate) -> Bool {
        return getAllTasksByDate(date).count > 0
    }
    
    static func getTasksWithLocation() -> Results<RMATask> {
        return getAllTasks().filter("location != nil")
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
    
    static func updateTaskCompletion(updatedTask: RMATask, taskIsCompleted: Bool) {
        try! uiRealm.write {
            updatedTask.isCompleted = taskIsCompleted
        }
    }
    
    static func updateTask(_ updatedTask: RMATask, withData: RMATask) {
        var newLocation: RMALocation? = nil
        if let withDataLocation = withData.location {
            newLocation = withDataLocation.clone()
        }
        
        try! uiRealm.write {
            if let previousLocation = updatedTask.location {
                if let newLocationUnwrapped = newLocation {
                    previousLocation.name = newLocationUnwrapped.name
                    previousLocation.latitude = newLocationUnwrapped.latitude
                    previousLocation.longitude = newLocationUnwrapped.longitude
                    previousLocation.radius = newLocationUnwrapped.radius
                    previousLocation.whenEnter = newLocationUnwrapped.whenEnter
                } else {
                    uiRealm.delete(previousLocation)
                }
            }
            else {
                updatedTask.location = withData.location
            }
        }
        
        try! uiRealm.write {
            updatedTask.name = withData.name
            updatedTask.fullDescription = withData.fullDescription
            updatedTask.date = withData.date
            updatedTask.imageURL = withData.imageURL
            updatedTask.repeatPeriod = withData.repeatPeriod
            updatedTask.isCompleted = withData.isCompleted
            updatedTask.tags.removeAll()
            for tag in withData.tags {
                updatedTask.tags.append(tag)
            }
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
            seedDataForDemo()
        }
    }
    
    static func seedDataForDemo() {
        let task1 = RMATask()
        task1.name = "Demo #2"
        task1.fullDescription = "Provide presentation for demo"
        task1.date = NSDate()
        task1.imageURL = nil
        task1.repeatPeriod = 0
        task1.isCompleted = false
        task1.location = RMALocation()
        task1.location?.name = "Yaroslava Pasternaka Street, 5, L'viv, Lviv Oblast, Ukraine"
        task1.location?.latitude = 49.8326244584506
        task1.location?.longitude = 23.9990768954158
        task1.location?.radius = 200
        
        let task2 = RMATask()
        task2.name = "Visit main office"
        task2.fullDescription = nil
        task2.date = NSDate()
        task2.imageURL = nil
        task2.repeatPeriod = 0
        task2.isCompleted = false
        task2.location = RMALocation()
        task2.location?.name = "Sadova Street, 8, L'viv, Lviv Oblast, Ukraine"
        task2.location?.latitude = 49.8227035625848
        task2.location?.longitude = 23.985345326364
        task2.location?.radius = 200
        
        try! uiRealm.write {
            uiRealm.add(task1)
            uiRealm.add(task2)
        }
    }
    
}
