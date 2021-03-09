//
//  SettingsController.swift
//  Kanarek
//
//  Created by Chris Yarosh on 24/11/2020.
//

import UIKit
import Firebase

class SettingsController: UIViewController {
    
    let pushNotificationManager = PushNotificationManager() // Getting the functionality to subscribe and unsubscribe form push-notification topics
    let userDefaults = UserDefaults.standard // Accessing user defaults
    @IBOutlet weak var stateSwitch: UISwitch!
    @IBOutlet weak var currentUserLabel: UILabel!
    @IBOutlet weak var mainSettingsView: UIView!
    @IBOutlet weak var whiteLineView: UIView!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    
    //## - Changes the colour of battery and time an service to white
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    //## - Function is called before appearance of the view and performs actions:
        // -> Checks the settings and adjusts the switch state on the screen accordingly
        // -> Adjust the ui by rounding the corners and
        // -> Displays the user identifier
    override func viewWillAppear(_ animated: Bool) {
        //## These two lines round up the corners of the white line
        whiteLineView.layer.cornerRadius = 15
        mainSettingsView.layer.cornerRadius = 15
        
        //## These two lines round up the corners of the white line
        logOutButton.layer.cornerRadius = 8
        termsButton.layer.cornerRadius = 8
        
        //## To make the switch background white and rounded
        stateSwitch.layer.cornerRadius = 15
        stateSwitch.clipsToBounds = true
    
        //# This line sets the user to the current user If it exists (but it technically has to)
        if let user = userDefaults.string(forKey: K.UserDefaults.email){
            currentUserLabel.text = user
        }
        
        //## These lines set the switch state depending on the setting
        if let subscriptionSetting = userDefaults.string(forKey: K.UserDefaults.pushNotificationSubscription){
            if subscriptionSetting.contains("Subscribed"){
                stateSwitch.isOn = true
            } else {
                stateSwitch.isOn = false
            }
        }
    }
    
    //## - Functions is called when the view is loaded -> adds an observer to watch for the value change of the switch
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stateSwitch.addTarget(self, action: #selector(stateChanged), for: .valueChanged) // sets up the observer of the switch - which triggers on value-change
    }
    
    //## - Function is triggered when the user taps sign-out button and performs action:
        // -> removes saved login data (kept for auto-login)
        // -> dismisses main navigation controller (goes back to first navigation controller which handles the login/sign-up process)
    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        userDefaults.removeObject(forKey: K.UserDefaults.password)
        userDefaults.removeObject(forKey: K.UserDefaults.email)
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    //## - Function is triggered when the user presses on "regulamin" label -> preforms segue to the terms and conditions view
    @IBAction func termsButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: K.Segues.toTerms, sender: self)
    }
    
    //## Implements the functionality of the switch -> subscribes to or unsubscribes from push notifications
    @objc func stateChanged(switchState: UISwitch) {
        if switchState.isOn {
            if let cityName = userDefaults.string(forKey: K.UserDefaults.cityName){
                pushNotificationManager.subscribe(to: cityName)
            }
        } else {
            pushNotificationManager.unsubscribe()
            
        }
    }

}
