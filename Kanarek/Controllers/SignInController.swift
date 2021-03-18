//
//  SignInController.swift
//  Kanarek
//
//  Created by Chris Yarosh on 24/11/2020.
//
import UIKit
import Firebase
import Purchases

class SignInController: UIViewController {
    
    var loggingInView : UIView? //View displayed then the logging in process is taking place
    let userLoginDetails = UserDefaults.standard // Accessing user defaults
    let errorManager = ErrorManager() // Access the error-handling methods
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var buttonRim: UIView!
    
    ///# - Function is called just before the view appears (also when the view gets back on top of the navigation stack) and performs actions:
        // -> rounds the corners of 'log in' button and hides navigationBar
        // -> checks if the current user has entitlements
            // -> IF successful -> try auto-sign-in if there is a logged user(already registered that did not log out)
            // -> ELSE go to SubscriptionView to either subscribe or restore
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        signInButton.layer.cornerRadius = 15
        buttonRim.layer.cornerRadius = 15
        
        //Checks if the current user has entitlements
        Purchases.shared.purchaserInfo { (purchaserInfo, error) in
            if purchaserInfo?.entitlements.all["fullAccess"]?.isActive == true {
                // if successful -> try to do automatic login
                if let userEmail = self.userLoginDetails.string(forKey: K.UserDefaults.email), let userPassword = self.userLoginDetails.string(forKey: K.UserDefaults.password) {
                    self.loggingIn(email: userEmail, password: userPassword)
                }
            } else {
                // Go to SubscriptionView
                self.performSegue(withIdentifier: K.Segues.subscription, sender: self)
                return
            }
        }
        
    }
    ///## - Function reveals navigation bar, resets placeholders and error label
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
        setPlaceholder()
        errorLabel.isHidden = true
        errorLabel.text = "Error label"
    }
    
    ///# - Function is called after the view is loaded:
        // -> sets placeholders for text fields
        // -> sets up the tap gesture for toggling the keyboard
        // -> sets the textField delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        setPlaceholder()

        // When the user taps somewhere on the screen the keyboard toggles
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    ///# - Functions performs log-in when 'log in' button is pressed provided that text fields are not empty
    @IBAction func logInButtonPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text{
            loggingIn(email: email, password: password)
        }
    }
    
    ///# - Function defines the login process:
        // -> Displays spinnerView (to indicate loading process)
        // -> Performs sign-in to Firebase Console
        // -- If fails -> checks if it's one of the most common errors and prints its Polish translation -> if not common it returns localisedDescription (in English)
        // -- If success -> save login data for auto-sign-in remove spinner and perform segue to Main View
    func loggingIn(email:String, password:String){
        showSpinner(onView: self.view)
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let e = error {
                self.removeSpinner()
                self.errorLabel.isHidden = false
                self.errorLabel.text = "! \(self.errorManager.translateError(error: e)) !"
            } else {
                self.userLoginDetails.setValue(email, forKey: K.UserDefaults.email)
                self.userLoginDetails.setValue(password, forKey: K.UserDefaults.password)
                self.removeSpinner()
                self.performSegue(withIdentifier: K.Segues.singInToMain, sender: self)
            }
        }
    }
    
    ///# - Function sets the placeholder in both text fields
    func setPlaceholder(){
        emailTextField.text = "Adres Email"
        passwordTextField.text = "Hasło"
        emailTextField.textColor = UIColor.gray
        passwordTextField.textColor = UIColor.gray
        passwordTextField.isSecureTextEntry = false
    }
}

//MARK: - Loading Spinner Methods
extension SignInController {
    ///# - Function create the spinner view and displays it on top of self.view by setting it as loggingInView
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
        loggingInView = spinnerView
    }
    
    ///# - Functions that removes the spinnerView from self.view
    func removeSpinner() {
        DispatchQueue.main.async {
            self.loggingInView?.removeFromSuperview()
            self.loggingInView = nil
        }
    }
}

//MARK: - UITextFieldDelegate Methods
extension SignInController: UITextFieldDelegate{
    ///# - Function handles the disappearance of the placeholder and adjusting text display when user starts editing
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text! == "Hasło"{
            textField.isSecureTextEntry = true
            textField.text = ""
        }
        if textField.text! == "Adres Email"{
            textField.text = ""
        }
        textField.textColor = UIColor.black
    }
    ///# - Function sets the placeholder back if the user left the textField empty
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == ""{
            setPlaceholder()
        }
    }
    ///# - Function toggles the keyboard when the user presses return button on the keyboard -> if the keyboard was editing the password text filed when return is pressed the login function is triggered
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isSecureTextEntry == true{
            if let email = emailTextField.text, let password = passwordTextField.text{
                loggingIn(email: email, password: password)
            }
        }
        textField.resignFirstResponder()
        return true
    }
}
