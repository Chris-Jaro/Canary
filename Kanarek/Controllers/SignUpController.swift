//
//  SignUpController.swift
//  Kanarek
//
//  Created by Chris Yarosh on 24/11/2020.
//

import UIKit
import Firebase

class SignUpController: UIViewController{
    
    let userLoginDetails = UserDefaults.standard
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var checkbox: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    //## - Changes the color of battery and time an service to white
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    override func viewDidDisappear(_ animated: Bool) {
        setPlaceholder()
        errorLabel.isHidden = true
//        navigationController?.popToRootViewController(animated: true)
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
    
    @IBAction func checkboxClicked(_ sender: UIButton) {
        if checkbox.currentImage == UIImage.init(systemName: "square") {
        checkbox.setImage(UIImage.init(systemName: "checkmark.square"), for: .normal)
        } else {
            checkbox.setImage(UIImage.init(systemName: "square"), for: .normal)
        }
    }
    
    @IBAction func SignUpButtonPressed(_ sender: UIButton) {
        guard checkbox.currentImage == UIImage.init(systemName: "checkmark.square") else {
            self.errorLabel.text = "! Prosze zaakceptować regulamin !"
            self.errorLabel.isHidden = false
            return
        }
        
        if let email = emailTextField.text, let password = passwordTextField.text{
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error{
                    self.errorLabel.text = "! \(e.localizedDescription) !"
                    self.errorLabel.isHidden = false
                } else {
                    self.userLoginDetails.setValue(email, forKey: "UserEmail")
                    self.userLoginDetails.setValue(password, forKey: "UserPassword")
                    self.performSegue(withIdentifier: "SignUpToMain", sender: self)
                }
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

//MARK: - UITextFieldDelegate
extension SignUpController: UITextFieldDelegate{
    
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
        textField.resignFirstResponder()
        return true
    }

}
