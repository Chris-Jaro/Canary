//
//  SettingsController.swift
//  Kanarek
//
//  Created by Chris Yarosh on 24/11/2020.
//

import UIKit
import Firebase

class SettingsController: UIViewController {
    
    let pushNotificationManager = PushNotificationManager()
    
    let userDefaults = UserDefaults.standard // Accessing user defaults

    @IBOutlet weak var stateSwitch: UISwitch!
    
    //## - Changes the color of battery and time an service to white
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    //## Checks the settings and adjusts the switch state on the screen accordingly
    override func viewWillAppear(_ animated: Bool) {
        if let subscriptionSetting = userDefaults.string(forKey: "topicSubscription"){
            if subscriptionSetting.contains("Subscribed"){
                stateSwitch.isOn = true
            } else {
                stateSwitch.isOn = false
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stateSwitch.addTarget(self, action: #selector(stateChanged), for: .valueChanged) // sets up the observer of the switch - which triggers on value-change
        //## To make the switch background white and rounded
        stateSwitch.layer.cornerRadius = 15
        stateSwitch.clipsToBounds = true
    }
    
    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        userDefaults.removeObject(forKey: "UserPassword")
        userDefaults.removeObject(forKey: "UserEmail")
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    //## Implements the functionality of the switch
    @objc func stateChanged(switchState: UISwitch) {
        if switchState.isOn {
            if let cityName = userDefaults.string(forKey: K.UserDefualts.cityName){
                pushNotificationManager.subscribe(to: cityName)
            }
        } else {
            pushNotificationManager.unsubscribe()
            
        }
    }

}
