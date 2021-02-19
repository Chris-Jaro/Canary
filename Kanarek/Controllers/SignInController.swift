//
//  SignInController.swift
//  Kanarek
//
//  Created by Chris Yarosh on 24/11/2020.
//
import UIKit
import Firebase

class SignInController: UIViewController {
    
    var vSpinner : UIView?
    let userLoginDetails = UserDefaults.standard
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    //## - Changes the color of battery and time an service to white
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
        setPlaceholder()
        errorLabel.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setPlaceholder()
        if let userEmail = userLoginDetails.string(forKey: "UserEmail"), let userPassword = userLoginDetails.string(forKey: "UserPassword") {
            loggingIn(email: userEmail, password: userPassword)
        } else {
            print("No data in the user defaults")
        }

        //#### When the user taps somewhere on the screen the keyboard toogles
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @IBAction func logInButtonPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text{
            loggingIn(email: email, password: password)
        }
    }
    
    func loggingIn(email:String, password:String){
        showSpinner(onView: self.view)
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let e = error {
                self.removeSpinner()
                self.errorLabel.isHidden = false
                self.errorLabel.text = "! \(e.localizedDescription) !"
            } else {
                self.userLoginDetails.setValue(email, forKey: "UserEmail")
                self.userLoginDetails.setValue(password, forKey: "UserPassword")
                self.removeSpinner()
                self.performSegue(withIdentifier: "SignInToMain", sender: self)
            }
        }
    }
    
    func setPlaceholder(){
        emailTextField.text = "Adress Email"
        passwordTextField.text = "Hasło"
        emailTextField.textColor = UIColor.gray
        passwordTextField.textColor = UIColor.gray
        passwordTextField.isSecureTextEntry = false
    }
}


//MARK: - Loading Indicaiton
extension SignInController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 15/255, green: 139/255, blue: 205/255, alpha: 0.4)
        let ai = UIActivityIndicatorView.init(style: .large)
        ai.color = UIColor.white
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            self.vSpinner?.removeFromSuperview()
            self.vSpinner = nil
        }
    }
}

//MARK: - UITextFieldDelegate
extension SignInController: UITextFieldDelegate{
    // Placeholder functionlaity
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == ""{
            setPlaceholder()
        }
    }
    
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
