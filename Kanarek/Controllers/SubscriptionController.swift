//
//  SubscriptionController.swift
//  Kanarek
//
//  Created by Chris Yarosh on 09/03/2021.
//

import UIKit
import Purchases

class SubscriptionController: UIViewController {
    
    var performingPurchaseView : UIView? //View displayed when the loading process is taking place
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
        // -> Shows spinnerView (to indicate to the user that clicking the button initiated some process and purchase is loading)
            //$ spinnerView is displayed only when a product is available for purchase (if user clicks too early an error message is displayed to let him know tho try again in a minute)
            //$ spinnerView is removed when 1. purchase is successful, 2. purchase fails (removed before the errorAlert)
        // -> tries to perform a purchase of the chosen package (in this case there is only one product -> monthly subscription)
        // -> IF SUCCESS -> pops the SubscriptionView and allows the user to perform sign-in or sign-up]
        // -> IF User is already a subscriber -> performs restoration
        // -> IF user cancelled the purchase -> simply return
        // -> IF FAILURE -> displays the alert to the user with the error message
    @IBAction func subscribeButtonPressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Miesięczna Subskrypcja Canary" , message: "Po próbnym okresie (3 miesięcy) użytkownik zostanie obciążony 1.99PLN. Subskrypcja odnawia się automatycznie, można ją anulować w dowolnym momencie w App Store", preferredStyle: .alert)
        
        //Loading the points for the current default location in central Poznan
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            self.performPurchase()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    ///# Function is called when the restoreButton is pressed and performs action:
        // -> Shows spinnerView (to indicate to the user that clicking the button initiated some process and purchaseRestoration is loading)
            //$ spinnerView is removed (before the alert is displayed) when 1. restoration is successful, 2. restoration fails
        // -> Checks if current User has the entitlements
        // -> IF user is indeed a subscriber and has entitlements -> display a successAlert to the user (and on clicking "OK" button action) -> allow access to the app by popping SubscriptionView
        // -> IF user does not have the entitlements -> Only display the errorAlert to the user (there is no subscription data for this user)
    @IBAction func restoreButtonPressed(_ sender: UIButton) {
        showSpinner(onView: self.view)
         Purchases.shared.restoreTransactions { (purchaserInfo, error) in
            if purchaserInfo?.entitlements.all["fullAccess"]?.isActive == true {
                // IF successful
                self.errorManager.displayBasicAlert(title: "Gotowe", subtitle: "Subskrypcja została odnowiona.", controller: self) { _ in
                    self.removeSpinner()
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                // If the restoration process does not go as successfully, display the message to the user that there is no subscription to restore.
                self.removeSpinner()
                self.errorManager.displayBasicAlert(title: "Błąd", subtitle: "Nie znaleziono subskrypcji do odzyskania.", controller: self)
                if let e = error {
                    print("Failed with error: \(e)")
                }
            }
         }
    }
    
    func performPurchase(){
        if let package = packageForPurchase{
            showSpinner(onView: self.view)
            Purchases.shared.purchasePackage(package) { (transaction, purchaserInfo, error, userCancelled) in
                if purchaserInfo?.entitlements.all["fullAccess"]?.isActive == true {
                    // Unlock that great "pro" content -> pop the view -> check for subscription with viewWillAppear -> perform actions
                    self.removeSpinner()
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.removeSpinner()
                    if userCancelled == true { return }
                    if let e = error{
                        self.errorManager.displayBasicAlert(title: "Błąd", subtitle: "Wystąpił błąd podczas dokonywania zakupu.\n Treść błędu: \(e.localizedDescription)", controller: self)
                    }
                }
            }
        } else {
            errorManager.displayBasicAlert(title: "Brak produktu", subtitle: "Brak produktu do zakupu.\nSpróbuj jeszcze raz za chwilę.", controller: self)
        }
    }
    
}

//MARK: - Loading Spinner Methods
extension SubscriptionController {
    ///# - Function create the spinner view and displays it on top of self.view by setting it as performingPurchaseView
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
        performingPurchaseView = spinnerView
    }
    
    ///# - Functions that removes the spinnerView from self.view
    func removeSpinner() {
        DispatchQueue.main.async {
            self.performingPurchaseView?.removeFromSuperview()
            self.performingPurchaseView = nil
        }
    }
}
