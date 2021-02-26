//
//  SignUpController.swift
//  Kanarek
//
//  Created by Chris Yarosh on 24/11/2020.
//

import UIKit
import Firebase

class SignUpController: UIViewController{
    
    var signingUpView: UIView? //View displayed then the signing-up process is taking place
    let userLoginDetails = UserDefaults.standard //Accessing user defaults
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var checkbox: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    
    //## - Changes the color of battery and time an service to white
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    //## - Rounding button corners
    override func viewWillAppear(_ animated: Bool) {
        signUpButton.layer.cornerRadius = 10
    }
    //## - Resetting error label and placeholders
    override func viewDidDisappear(_ animated: Bool) {
        setPlaceholder()
        errorLabel.isHidden = true
        errorLabel.text = ""
    }
    
    //## - Function is called after the view is loaded:
        // -> sets placeholders for text fields
        // -> sets up the tap gesutre for toggling the keyboard
        // -> sets the textField delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        setPlaceholder()
        
        //#### When the user taps somewhere on the screen the keyboard toogles
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    //## - Functions handles clicking the 'I accept terms&conditions' checkbox
    @IBAction func checkboxClicked(_ sender: UIButton) {
        if checkbox.currentImage == UIImage.init(systemName: "square") {
        checkbox.setImage(UIImage.init(systemName: "checkmark.square"), for: .normal)
        } else {
            checkbox.setImage(UIImage.init(systemName: "square"), for: .normal)
        }
    }
    
    //## - Function handles clicking 'Sign up' button -> If text fields are not empty it triggers sign-up function
    @IBAction func SignUpButtonPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text{
            signingUp(email: email, password: password)
        }
    }
    
    //## - Function handles clicking 'Sign up' button:
        // -> Displays and removes spinner on top of the views
        // -> checks if the checkbox is selected
        // -> performs Authentication.createUser function and creates user in Firebase consol
        // -> saves the user's login data for Automatic SignIn
        // -- If there are any error they are displayed on the error label
        // -- If everything is successful it performs a segue to Main View
    func signingUp(email: String, password: String){
        showSpinner(onView: self.view)
        guard checkbox.currentImage == UIImage.init(systemName: "checkmark.square") else {
            self.errorLabel.text = "! Proszę zaakceptować regulamin !"
            self.errorLabel.isHidden = false
            self.removeSpinner()
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let e = error{
                self.errorLabel.text = "! \(e.localizedDescription) !"
                self.errorLabel.isHidden = false
                self.removeSpinner()
            } else {
                self.userLoginDetails.setValue(email, forKey: K.UserDefaults.email)
                self.userLoginDetails.setValue(password, forKey: K.UserDefaults.password)
                self.removeSpinner()
                self.performSegue(withIdentifier: K.Segues.signUpToMain, sender: self)
            }
        }
        
    }

    //## - Function sets the placeholder in both text fields
    func setPlaceholder(){
        emailTextField.text = "Adress Email"
        passwordTextField.text = "Hasło"
        emailTextField.textColor = UIColor.gray
        passwordTextField.textColor = UIColor.gray
        passwordTextField.isSecureTextEntry = false
    }
}

//MARK: - Loading Indicaiton Methods
extension SignUpController {
    //## - Function create the spinner view and displays it on top of self.view by setting it as signingUpView
    func showSpinner(onView : UIView) {
        // The view and its background
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 15/255, green: 139/255, blue: 205/255, alpha: 0.4)
        // The loading image ("activity indicator")
        let activityIndicator = UIActivityIndicatorView.init(style: .large)
        activityIndicator.color = UIColor.white
        activityIndicator.startAnimating()
        activityIndicator.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(activityIndicator)
            onView.addSubview(spinnerView)
        }
        signingUpView = spinnerView
    }
    
    //## - Functions that removes the spinnerView from self.view
    func removeSpinner() {
        DispatchQueue.main.async {
            self.signingUpView?.removeFromSuperview()
            self.signingUpView = nil
        }
    }
}

//MARK: - UITextFieldDelegate
extension SignUpController: UITextFieldDelegate{
    //## - Function handles the disapearance of the placeholder and adjusting text display when user strats editing
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text! == "Hasło"{
            textField.isSecureTextEntry = true
            textField.text = ""
        }
        if textField.text! == "Adress Email"{
            textField.text = ""
        }
        textField.textColor = UIColor.black
    }
    //## - Function sets the placeholder back if the user left the textField empty
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == ""{
            setPlaceholder()
        }
    }
    //## - Function toggles the keyboard when the user presses return button on the keyboard -> if the keyboard was editing the passowrd text filed when return is pressed the sign-up function is triggered
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isSecureTextEntry == true{
            if let email = emailTextField.text, let password = passwordTextField.text{
                signingUp(email: email, password: password)
            }
        }
        textField.resignFirstResponder()
        return true
    }

}
