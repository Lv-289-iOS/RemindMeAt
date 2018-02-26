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
import UIKit

class NotificationManager {
    var imageDoc = RMAFileManager()
    var counter = idForTask()
    static var stCounter = 0
    
    static func idForTask() -> Int {
        return stCounter + 1
    }
    func setNotification(with task: RMATask) {
        let identifier = task.taskID
        let content = UNMutableNotificationContent()
        content.title = task.name
        print(counter)
        if let description = task.fullDescription {
            content.body = description
        }
        content.badge = NSNumber(value: counter)
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "category"
        //add userinfo for identifing
        content.userInfo = [counter: task.taskID]
        if let image = task.imageURL{
            print("url is \(image)")
        let imageUrl = imageDoc.loadImageUrl(imageURL: image)
            if let attachment = try? UNNotificationAttachment(identifier: identifier, url: imageUrl, options: nil){
            content.attachments = [attachment]
            }
        }
        if let nsDate = task.date {
            if task.location != nil {
                content.subtitle = "You have a task at \(task.location!.name)"
            }
            let dataInfo = dateParser(nsDate: nsDate)
            let calendarTrigger = UNCalendarNotificationTrigger(dateMatching: dataInfo, repeats: true)
            let request = UNNotificationRequest(identifier: identifier + "date", content: content, trigger: calendarTrigger)
            UNUserNotificationCenter.current().add(request) { error in
                if error != nil {
                    print("Notification wasn't set")
                } else {
                    // Request was added successfully
                    print("date added successfully")
                }
            }
        }
        if let place = task.location {
            if task.date != nil {
                content.subtitle = "You have a task here at \(String(describing: task.date))"
            }
            let center = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
            let region = CLCircularRegion(center: center, radius: place.radius, identifier: "Location")
            region.notifyOnEntry = place.whenEnter
            region.notifyOnExit = !place.whenEnter
            let locationTrigger = UNLocationNotificationTrigger(region: region, repeats: false)
            let request = UNNotificationRequest(identifier: identifier + "loc", content: content, trigger: locationTrigger)
            UNUserNotificationCenter.current().add(request) { error in
                if error != nil {
                    print("Notification wasn't set")
                } else {
                    print("location added succesfully")
                }
            }
        }
    }
    
    func dateParser(nsDate: NSDate) -> DateComponents {
        var components = DateComponents()
        let date = nsDate as Date
        let calendar = Calendar.current
        components.hour = calendar.component(.hour, from: date)
        components.minute = calendar.component(.minute, from: date)
        components.month = calendar.component(.month, from: date)
        components.year = calendar.component(.year, from: date)
        return components
    }
    
//    func updateNotifications(){
//        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
//
//        UNUserNotificationCenter.current().getDeliveredNotifications(completionHandler: <#T##([UNNotification]) -> Void#>)
//        if let notifications = notifications{
//            for not in  notifications{
//
//            }
//        }
//    }
    
}
