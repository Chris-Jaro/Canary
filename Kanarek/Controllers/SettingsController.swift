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
    
    @IBOutlet weak var currentUserLabel: UILabel!
    @IBOutlet weak var mainSettingsView: UIView!
    @IBOutlet weak var whiteLineView: UIView!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    
    //## - Changes the color of battery and time an service to white
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    //## Checks the settings and adjusts the switch state on the screen accordingly
    override func viewWillAppear(_ animated: Bool) {
        //## These two lines round up the corners of the white line
        whiteLineView.layer.cornerRadius = 10
        mainSettingsView.layer.cornerRadius = 10
        
        //## These two lines round up the corners of the white line
        logOutButton.layer.cornerRadius = 8
        termsButton.layer.cornerRadius = 8
        
        //## To make the switch background white and rounded
        stateSwitch.layer.cornerRadius = 15
        stateSwitch.clipsToBounds = true
    
        //# This line sets the user to the current user If it exists (but it tecnically has to)
        if let user = userDefaults.string(forKey: "UserEmail"){
            currentUserLabel.text = user
        }
        
        //## These lines set the switch state depending on the setting
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
    }
    
    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        userDefaults.removeObject(forKey: "UserPassword")
        userDefaults.removeObject(forKey: "UserEmail")
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    //## preforms segue to the terms and conditions view
    @IBAction func termsButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "GoToTermsFromSettings", sender: self)
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
