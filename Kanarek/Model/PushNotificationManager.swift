//
//  PushNotificationManager.swift
//  Kanarek
//
//  Created by Chris Yarosh on 22/02/2021.
//

import UIKit
import Firebase

struct  PushNotificationManager {
    
    let userDefaults = UserDefaults.standard // Accessing the user defaults
    
    //## - Function is triggered by SettingsController and onAppStart() and perfroms action:
        // -> unsubscribes from all currently available pushNotificationTopics
        // -> saves the set value of userDefaults to "Unsubscribed"
    func unsubscribe(){
        for topic in [K.PushNotifications.poznanTopic, K.PushNotifications.warsawTopic]{
            Messaging.messaging().unsubscribe(fromTopic: topic) { error in
                if error != nil{
                    print(error!)
                }
            }
        }
        userDefaults.setValue("Unsubscribed", forKey: K.UserDefaults.pushNotificationSubscription)
        print("Unsubscribed from ALL push_notifications")
    }
    
    //## - Function is triggered by SettingsController and onAppStart() and perfroms action:
        // -> subscribes to pushNotificationTopic for current city
        // -> saves the set value of userDefaults to "Unsubscribed"
    func subscribe(to city: String){
        Messaging.messaging().subscribe(toTopic: "push_notifications_\(city)") { error in
            if error == nil{
                print("Subscribed to push_notifications_\(city)")
                userDefaults.setValue("Subscribed to \(city)", forKey: K.UserDefaults.pushNotificationSubscription)
            }
        }
    }
    
    //## The initial subsciption happens only once ever (when there is no data in UserDefaults) -> then the whole process takes place in the settings
    //## - Function performs the actions according to the Push Notification Subscription Status
        // -> if initial app launch (no value in userDefaults) and current city is defined -> Subscribes to the city push notifications
        // -> if Unsubscribed in the settings -> Do nothing
        // -> if Subscribed to the current city -> No nothing
        // -> if Subscribed to a different city -> Unsubscribe form all cities and Subscribe to the current one
    func onAppStart(){
        if let city = userDefaults.string(forKey: K.UserDefaults.cityName){
            if let subStatus = userDefaults.string(forKey: K.UserDefaults.pushNotificationSubscription){ // Checks if the subscription status is defined
                if subStatus.contains("Unsubscribed"){
                    print("Already unsubscribed!")
                } else if subStatus.contains(city) { // (if one is subscribing to poznan and is in poznan)
                    print("Already subscried to current city")
                } else { //(subStatus DOES NOT CONTAIN city but CONTAINS subscribed)
                    unsubscribe()
                    subscribe(to: city)
                    //unsubscribe form ALL && subscribe to push_notifications_city // (if one is subscribing to poznan and moves to warsaw)
                    print("Unsubscribed from all cities and subscrbed to the new current city")
                }
            } else { //(initial App Start-up only)
                subscribe(to: city)
            }
        }
    }
}
