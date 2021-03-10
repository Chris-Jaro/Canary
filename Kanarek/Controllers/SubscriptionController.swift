//
//  SubscriptionController.swift
//  Kanarek
//
//  Created by Chris Yarosh on 09/03/2021.
//

import UIKit

class SubscriptionController: UIViewController {
    
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var priceButton: UIButton!
    @IBOutlet weak var subscribeButtonView: UIView!
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var restoreButtonView: UIView!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var checkmarkImage: UIImageView!
    
    //## - Changes the colour of battery and time an service to white
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    //#### Two functions that hide the navigation bar on the main screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        setUI()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
    }
    
    func setUI(){
        checkmarkImage.layer.cornerRadius = 25
        priceView.layer.cornerRadius = 15
        priceButton.layer.cornerRadius = 15
        subscribeButton.layer.cornerRadius = 15
        subscribeButtonView.layer.cornerRadius = 15
        restoreButton.layer.cornerRadius = 15
        restoreButtonView.layer.cornerRadius = 15
    }
    
    @IBAction func subscribeButtonPressed(_ sender: UIButton) {
        // Subscribes a new user
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func restoreButtonPressed(_ sender: UIButton) {
        // Restores user's subscription
        navigationController?.popViewController(animated: true)
    }
    
}
