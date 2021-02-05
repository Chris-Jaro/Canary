//
//  NotificationManager.swift
//  Kanarek
//
//  Created by Chris Yarosh on 01/02/2021.
//
import UserNotifications
import UIKit


struct LocalNotification {
    var id: String
    var title: String
    var body: String
}

struct NotificationManager {
    var notifications = [LocalNotification]()
    
    func requestPermission(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                if granted == true && error == nil {
                    // We have permission!
                }
            }
    }
    
    mutating func addNotification(title: String, body: String){
        notifications.append(LocalNotification(id: UUID().uuidString, title: title, body: body))
    }
    
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
    
    func cancel(){
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    mutating func setNotification(title: String, body: String, userInfo:[AnyHashable : Any]){
        requestPermission()
        addNotification(title: title, body: body)
        scheduleNotification(userInfo: userInfo)
    }
}

