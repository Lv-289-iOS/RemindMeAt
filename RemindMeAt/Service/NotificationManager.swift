//
//  NotificationManager.swift
//  RemindMeAt
//
//  Created by Roman Shveda on 2/18/18.
//  Copyright © 2018 SoftServe Academy. All rights reserved.
//

import Foundation
import CoreLocation
import UserNotifications

class NotificationManager{
    
    var counter = idForTask()
    static var stCounter = 0
    static func idForTask()->Int{
        return stCounter + 1
    }
    
    var badgeNumber = 0
    func increment() -> Int{
        return badgeNumber + 1
    }
   

    func setNotification(with task: RMATask){
        let content = UNMutableNotificationContent()
        content.title = task.name
        if let description = task.fullDescription{
            content.body = description
        }
        content.badge = NSNumber(value: increment())
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "category"
        //add userinfo for identifing
        content.userInfo = [counter:task.taskID]
        
        if let nsDate = task.date{
            let dataInfo = dateParser(nsDate: nsDate)
            let calendarTrigger = UNCalendarNotificationTrigger(dateMatching: dataInfo, repeats: true)
            let request = UNNotificationRequest(identifier: task.taskID, content: content, trigger: calendarTrigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let _ = error {
                    print("Notification wasn't set")
                }else {
                    // Request was added successfully
                    print("date added succesfully")
                }
            }
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        }
        if let place = task.location{
            let center = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
            let region = CLCircularRegion(center: center, radius: place.radius, identifier: "Location")
            region.notifyOnEntry = place.whenEnter
            region.notifyOnExit = !place.whenEnter
            let locationTrigger = UNLocationNotificationTrigger(region: region, repeats: false)
            let request = UNNotificationRequest(identifier: task.taskID, content: content, trigger: locationTrigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let _ = error {
                    print("Notification wasn't set")
                } else {
                    // Request was added successfully
                    print("location added succesfully")
                }
            }
        }
    }
    
    func dateParser(nsDate : NSDate) -> DateComponents{
        var components = DateComponents()
        let date = nsDate as Date
        let calendar = Calendar.current
        components.hour = calendar.component(.hour, from: date)
        components.minute = calendar.component(.minute, from: date)
        components.month = calendar.component(.month, from: date)
        components.year = calendar.component(.year, from: date)
        return components
    }

}
