//
//  SignUpController.swift
//  Kanarek
//
//  Created by Chris Yarosh on 24/11/2020.
//

import UIKit

class SignUpController: UIViewController {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var checkbox: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func checkboxClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func SignInButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "SignUpToMain", sender: self)
    }
    
    

}
