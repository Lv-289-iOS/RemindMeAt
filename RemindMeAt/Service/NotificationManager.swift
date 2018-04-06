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
   
    func setNotification(with task: RMATask) {
        let identifier = task.taskID
        let content = UNMutableNotificationContent()
        content.title = task.name
        if let description = task.fullDescription {
            content.body = description
        }
        content.badge = 1
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "category"
        //add userinfo for identifing
        content.userInfo = [task.taskID : task.taskID]
        print(task.taskID)
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
            let dataInfo = dateParser(nsDate: nsDate, periodicity: task.repeatPeriod)
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
    
    func dateParser(nsDate: NSDate, periodicity: Int) -> DateComponents {
        var components = DateComponents()
        let date = nsDate as Date
        let calendar = Calendar.current
        components.hour = calendar.component(.hour, from: date)
        components.minute = calendar.component(.minute, from: date)
        components.day = calendar.component(.day, from: date)
        components.month = calendar.component(.month, from: date)
        components.year = calendar.component(.year, from: date)
        switch periodicity {
        case 1:
            components.day = 0
            components.month = 0
            components.year = 0
        case 2:
            components.day = components.day! + 7
            components.month = 0
            components.year = 0
        case 3:
            components.month = 0
            components.year = 0
        case 4:
            components.year = 0
        default:
            break
        }
        return components
    }
    
    func updateNotifications(at task: RMATask) {
        let taskID = task.taskID
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: {requests -> () in
            for request in requests{
                for userInfo in request.content.userInfo.values {
                    if (taskID == String(describing: userInfo)) {
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [taskID+"loc", taskID+"date"])
                    }
                }

            }
        })
    }
    
}
