//
//  TermsController.swift
//  Kanarek
//
//  Created by Chris Yarosh on 24/11/2020.
//

import UIKit

class TermsController: UIViewController {
    
    @IBOutlet weak var termsTextView: UITextView!
    @IBOutlet weak var termsView: UIView!
    @IBOutlet weak var whiteLineView: UIView!
    
    //## - Changes the color of battery and time an service to white
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //## Rounds the corners of the white line
        termsView.layer.cornerRadius = 15
        whiteLineView.layer.cornerRadius = 15
        
        //## Sets the contant set Terms&Conditions text as the text of the textView
        termsTextView.text = K.Regulamin.text
    }
    

}

