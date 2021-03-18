//
//  SubscriptionController.swift
//  Kanarek
//
//  Created by Chris Yarosh on 09/03/2021.
//

import UIKit
import Purchases

class SubscriptionController: UIViewController {
    
    var packageForPurchase: Purchases.Package? //saving product
    let errorManager = ErrorManager() // accessing error-handling methods
    
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var priceButton: UIButton!
    @IBOutlet weak var subscribeButtonView: UIView!
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var restoreButtonView: UIView!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var checkmarkImage: UIImageView!
    
    ///# - Two functions that hide the navigation bar on the main screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        setUI()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }

    ///# - Function is triggered when the view is loaded and performs actions:
        // -> Loading In-App Purchases products from RevenueCat
        // -> Saving the current Package(product) as the product for purchase to be accessed by the other methods
    override func viewDidLoad() {
        super.viewDidLoad()
        //Loads the offers from RevenueCat
        Purchases.shared.offerings { (offerings, error) in
            if let offerings = offerings {
                let offer = offerings.current
                if let currentPackage = offer?.availablePackages.first{
                    //Saves the package object as the one for purchase
                    self.packageForPurchase = currentPackage
                }
            }
        }
    }
    
    ///# - Function is called in ViewWillAppear and performs actions:
        // -> rounds the corners of the visible objects
        // -> sets the yellow colour for the priceRim and checkmark
    func setUI(){
        checkmarkImage.layer.cornerRadius = 25
        priceView.layer.cornerRadius = 15
        priceButton.layer.cornerRadius = 15
        subscribeButton.layer.cornerRadius = 15
        subscribeButtonView.layer.cornerRadius = 15
        restoreButton.layer.cornerRadius = 15
        restoreButtonView.layer.cornerRadius = 15
        checkmarkImage.tintColor = UIColor(cgColor: CGColor(red: 255/255, green: 201/255, blue: 60/255, alpha: 1))
        priceView.backgroundColor = UIColor(cgColor: CGColor(red: 255/255, green: 201/255, blue: 60/255, alpha: 1))
    }
    
    ///# - Function is called when subscribeButton is pressed and performs actions:
        // -> tries to perform a purchase of the chosen package (in this case there is only one product -> monthly subscription)
        // -> IF SUCCESS -> pops the SubscriptionView and allows the user to perform sign-in or sign-up]
        // -> IF User is already a subscriber -> performs restoration
        // -> IF user cancelled the purchase -> simply return
        // -> IF FAILURE -> displays the alert to the user with the error message
    @IBAction func subscribeButtonPressed(_ sender: UIButton) {
        if let package = packageForPurchase{
            Purchases.shared.purchasePackage(package) { (transaction, purchaserInfo, error, userCancelled) in
                if purchaserInfo?.entitlements.all["fullAccess"]?.isActive == true {
                    // Unlock that great "pro" content -> pop the view -> check for subscription with viewWillAppear -> perform actions
                    self.navigationController?.popViewController(animated: true)
                } else {
                    if userCancelled == true { return }
                    if let e = error{
                        self.errorManager.displayBasicAlert(title: "Błąd", subtitle: "Wystąpił błąd podczas dokonywania zakupu.\n Treść błędu: \(e.localizedDescription)", controller: self)
                    }
                }
            }
        }
    }
    
    ///# Function is called when the restoreButton is pressed and performs action:
        // -> Checks if current User has the entitlements
        // -> IF user is indeed a subscriber and has entitlements -> display a successAlert to the user (and on clicking "OK" button action) -> allow access to the app by popping SubscriptionView
        // -> IF user does not have the entitlements -> Only display the errorAlert to the user (there is no subscription data for this user)
    @IBAction func restoreButtonPressed(_ sender: UIButton) {
         Purchases.shared.restoreTransactions { (purchaserInfo, error) in
            if purchaserInfo?.entitlements.all["fullAccess"]?.isActive == true {
                // IF successful
                self.errorManager.displayBasicAlert(title: "Gotowe", subtitle: "Subskrypcja została odnowiona.", controller: self) { _ in
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                // If the restoration process does not go as successfully, display the message to the user that there is no subscription to restore.
                self.errorManager.displayBasicAlert(title: "Błąd", subtitle: "Nie znaleziono subskrypcji do odzyskania.", controller: self)
                if let e = error {
                    print("Failed with error: \(e)")
                }
            }
         }
    }
    
}
