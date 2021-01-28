//
//  SignInController.swift
//  Kanarek
//
//  Created by Chris Yarosh on 24/11/2020.
//

import UIKit
import Firebase

class SignInController: UIViewController {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setPlaceholder()

        //#### When the user taps somewhere on the screen the keyboard toogles
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @IBAction func logInButtonPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text{
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    self.errorLabel.isHidden = false
                    self.errorLabel.text = "! \(e.localizedDescription) !"
                } else {
                    self.performSegue(withIdentifier: "SignInToMain", sender: self)
                }
              
            }
        }
        
    }
    
    func setPlaceholder(){
        emailTextField.text = "Adress Email"
        emailTextField.textColor = UIColor.gray
        passwordTextField.text = "Hasło"
        passwordTextField.textColor = UIColor.gray
        passwordTextField.isSecureTextEntry = false
    }

}

//MARK: - UITextFieldDelegate
extension SignInController: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text! == "Hasło"{
            passwordTextField.isSecureTextEntry = true
        }
        textField.textColor = UIColor.black
        textField.text = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == ""{
            setPlaceholder()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
