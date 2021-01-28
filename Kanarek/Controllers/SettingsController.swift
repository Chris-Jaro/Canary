//
//  SettingsController.swift
//  Kanarek
//
//  Created by Chris Yarosh on 24/11/2020.
//

import UIKit

class SettingsController: UIViewController {
    
    let userLoginDetails = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func signOuyButtonPressed(_ sender: UIButton) {
        userLoginDetails.removeObject(forKey: "UserPassword")
        userLoginDetails.removeObject(forKey: "UserEmail")
        
        navigationController?.dismiss(animated: true, completion: nil)
    }

}
