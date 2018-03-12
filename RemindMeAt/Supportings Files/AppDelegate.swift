//
//  AppDelegate.swift
//  RemindMeAt
//
//  Created by Artem Rieznikov on 07.02.18.
//  Copyright © 2018 SoftServe Academy. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps
import GooglePlaces
import RealmSwift
import UserNotifications
import CoreLocation

let uiRealm = try! Realm()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        RMARealmManager.seedData()
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
        //define actions FIXME: will be changed
        let remindLaterAction = UNNotificationAction(identifier: "remindLater", title: "Remind me later", options: [])
        let markAsSeenAction = UNNotificationAction(identifier: "markAsCompleted", title: "Mark as completed", options: [])
        
        let category = UNNotificationCategory(identifier: "category", actions: [remindLaterAction, markAsSeenAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        GMSServices.provideAPIKey("AIzaSyAXHCA90jDxqtQuEtESsfTGs4xWv6R_TNY")
        GMSPlacesClient.provideAPIKey("AIzaSyAXHCA90jDxqtQuEtESsfTGs4xWv6R_TNY")
        return true
    }
    
    func incrementBadgeNumberBy(badgeNumberIncrement: Int) {
        let currentBadgeNumber = UIApplication.shared.applicationIconBadgeNumber
        let updatedBadgeNumber = currentBadgeNumber + badgeNumberIncrement
        if (updatedBadgeNumber > -1) {
            UIApplication.shared.applicationIconBadgeNumber = updatedBadgeNumber
        }
    }
    
    //called when your app is running in the foreground and receives a notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
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
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
}

