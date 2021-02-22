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
    
    //## Signing out from Push Notifications + setting the deault
    func unsubscribe(){
        for topic in ["push_notifications_poznan", "push_notifications_warsaw"]{
            Messaging.messaging().unsubscribe(fromTopic: topic) { error in
                if error != nil{
                    print(error!)
                }
            }
        }
        userDefaults.setValue("Unsubscribed", forKey: "topicSubscription")
        print("Unsubscribed from ALL push_notifications")
    }
    
    //## Signing up for Push Notifications + setting the deault
    func subscribe(to city: String){
        Messaging.messaging().subscribe(toTopic: "push_notifications_\(city)") { error in
            if error == nil{
                print("Subscribed to push_notifications_\(city)")
                userDefaults.setValue("Subscribed to \(city)", forKey: "topicSubscription")
            }
        }
    }
    
    //## The initial subsciption happens only once ever -> then the whole process takes place in the settings
    //## The Function performs the actions according to the Push Notification Subscription Status
        //$$ If initial app launch (no value in userDefaults) and current city is defined -> Subscribes to the city push notifications
        //$$ If Unsubscribed in the settings -> Do nothing
        //$$ If Subscribed to the current city -> No nothing
        //$$ IF Subscribed to a different city -> Unsubscribe form all cities and Subscribe to the current one
    func onAppStart(){
        if let city = userDefaults.string(forKey: K.UserDefualts.cityName){
            if let subStatus = userDefaults.string(forKey:"topicSubscription"){ // Checks if the subscription status is defined
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
