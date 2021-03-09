//
//  AppDelegate.swift
//  Kanarek
//
//  Created by Chris Yarosh on 22/11/2020.
//

import UIKit
import Firebase
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let gcmMessageIDKey = "gcm.message_id" //Google cloud messaging key
    let userDefaults = UserDefaults.standard //Accessing user defaults
    
    //## - Function is triggered when app finished launching (first lines of code action that are performed in app process) and performs actions:
        // -> configures Firebase
        // -> setting FirebaseCloudMessaging's delegate
        // -> requesting user permission for notifications
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure() //Necessary for firebase functionality
        
        Messaging.messaging().delegate = self
        
        //#### -> Requesting notification from the user
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }
        
        DispatchQueue.main.async {
            application.registerForRemoteNotifications()
        }
        
        return true
    }
    
    //## - Functions that handle the remoteNotification receiving
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if let messageID = userInfo[gcmMessageIDKey] {
          print("Message ID: \(messageID)")
        }
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let messageID = userInfo[gcmMessageIDKey] {
          print("Message ID: \(messageID)")
        }

        completionHandler(UIBackgroundFetchResult.newData)
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }

}

//MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    //## - Function is triggered when remote notification was received and will be presented
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        if let messageID = userInfo[gcmMessageIDKey] {
          print("Message ID: \(messageID)")
        }

        completionHandler([[UNNotificationPresentationOptions.banner, .badge, .sound]])
    }
    
    //#### ACCESSING NOTIFICATION'S DATA When the user clicks on the notification
    //## - Function is triggered when user taps on the push notification (response is received) and can perform action:
        // -> notifications data can be accessed (coordinates of the stop that was reported to show it on the map)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
          print("Message ID: \(messageID)")
        }
          //##Printing the data
//        if let lat = userInfo["latitude"], let lon = userInfo["longitude"] {
//            print("Latitude: \(lat) \nLongitude: \(lon)")
//        }
        completionHandler()
    }

}

//MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate{
    
    //## - Function is triggered when FCM registration token of the device is received
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict:[String: String] = ["token": fcmToken ]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
    
}

