//
//  NotificationManager.swift
//  Kanarek
//
//  Created by Chris Yarosh on 01/02/2021.
//
import UserNotifications
import UIKit


//## - Struct defines a localNotification object and its variables
struct LocalNotification {
    var id: String
    var title: String
    var body: String
}

struct NotificationManager {
    var notifications = [LocalNotification]()
    
    //## Function is triggered by MainController's locationManager when user enters dangerous region and preforms action:
        // -> adds the notification to the notification list
        // -> schedules all the notifications in the list
    mutating func setNotification(title: String, body: String, userInfo:[AnyHashable : Any]){
        addNotification(title: title, body: body)
        scheduleNotification(userInfo: userInfo)
    }
    
    //## - Function is triggered by setNotification method and performs action:
        // -> creates a localNotification object and appends it to the list
    mutating func addNotification(title: String, body: String){
        notifications.append(LocalNotification(id: UUID().uuidString, title: title, body: body))
    }
    
    //## - Function is triggered by the setNotification method and performs action:
        // -> creates real notification object for every notification in the list
        // -> removes all pending notifications
        // -> clears the list on notification after they are scheduled
    mutating func scheduleNotification(userInfo:[AnyHashable : Any]){
        UIApplication.shared.applicationIconBadgeNumber = 0
        for notification in notifications{
            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.body = notification.body
            content.sound = UNNotificationSound.default
            content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
            content.userInfo = userInfo
            
            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: nil)
            
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().add(request) { (error) in
                guard error == nil else { return }
                print("Scheduling notification with id:\(notification.id)")
            }
        }
        notifications.removeAll()
    }
    
}

