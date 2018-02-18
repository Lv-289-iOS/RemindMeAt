//
//  AppDelegate.swift
//  RemindMeAt
//
//  Created by Artem Rieznikov on 07.02.18.
//  Copyright © 2018 SoftServe Academy. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications
import CoreLocation

let uiRealm = try! Realm()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Ask user's permision for sending notifications
        UNUserNotificationCenter.current().delegate = self
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        center.requestAuthorization(options: options) { (granted, error) in
            if granted {
                DispatchQueue.main.async(execute: {
                    application.registerForRemoteNotifications()
                })
                
            }
        }
        //define actions
        let remindLaterAction = UNNotificationAction(identifier: "remindLater", title: "Remind me later", options: [])
        let markAsSeenAction = UNNotificationAction(identifier: "markAsSeen", title: "Mark as seen", options: [])
        
        let category = UNNotificationCategory(identifier: "category", actions: [remindLaterAction,markAsSeenAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        return true
    }

    func calendarNotification(){
        var date = DateComponents()
        date.hour = 11
        date.minute = 00
        let calendarTrigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        
        let content = UNMutableNotificationContent()
        content.title = "Notification Title"
        content.body = "Some notification body information to be displayed."
        content.badge = 1
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "category"
        
        //----------------adding image 4 notifications---------------//
        //        guard let path = Bundle.main.path(forResource: "cardBack", ofType: "png")else{return}
        //        let url = URL(fileURLWithPath: path)
        //        do{
        //            let attachment = try UNNotificationAttachment(identifier: "logo", url: url, options: nil)
        //            content.attachments = [attachment]
        //        }catch{
        //            print("Attachment crashed")
        //        }
        
        let request = UNNotificationRequest(identifier: "calendarNotification", content: content, trigger: calendarTrigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let _ = error {
                // Do something with error
            }else {
                // Request was added successfully
            }
        }
    }
    
    func locationNotification(){
        let center = CLLocationCoordinate2D(latitude: 40.0, longitude: 120.0)
        let region = CLCircularRegion(center: center, radius: 500.0, identifier: "Location")
        region.notifyOnEntry = true;
        region.notifyOnExit = false;
        let locationTrigger = UNLocationNotificationTrigger(region: region, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = "Notification Title"
        content.subtitle = "Notification Subtitle"
        content.body = "Some notification body information to be displayed."
        content.badge = 1
        content.sound = UNNotificationSound.default()
        
        let request = UNNotificationRequest(identifier: "locationNotification", content: content, trigger: locationTrigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let _ = error {
                // Do something with error
            } else {
                // Request was added successfully
            }
        }
    }
    //called when your app is running in the foreground and receives a notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //        let content = notification.request.content
        // Process notification content
        
        
        completionHandler([.alert, .sound]) // Display notification as regular alert and play sound
    }
    
    //called when the user interacts with a notification for your app in any way,
    //including dismissing it or opening your app from it
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let actionIdentifier = response.actionIdentifier
        
        switch actionIdentifier {
        case UNNotificationDismissActionIdentifier: // Notification was dismissed by user
            // Do something
            completionHandler()
        case UNNotificationDefaultActionIdentifier: // App was opened from notification
            // Do something
            completionHandler()
        default:
            completionHandler()
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func doSomethig()
    {
        let group = DispatchGroup.init()
        
        
        group.enter()
        DispatchQueue.main.async {
            // 1
            group.leave()
        }
        
        
        group.enter()
        DispatchQueue.main.async {
            // 2
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.main) {
            // after 1 and 2 are done
        }
    }
    
    //    func notification(at time: Date?, by location: RMALocation){
    //
    //    }
    
}

