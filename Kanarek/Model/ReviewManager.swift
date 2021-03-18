//
//  ReviewManager.swift
//  Kanarek
//
//  Created by Chris Yarosh on 17/03/2021.
//

import Foundation
import StoreKit

struct ReviewManager{
    
    ///# Function is called by MainController's ViewWillAppear and performs action:
    // -> retrieves the count of reports made from UserDefaults
    // -> IF the reportCount is = to 3 OR 10 OR is >50 AND this app version has not been reviewed yet -> request review from the user
    func requestReviewIfAppropriate(){
        let count = UserDefaults.standard.integer(forKey: K.UserDefaults.reportCount)
        let infoDictionaryKey = kCFBundleVersionKey as String
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String else { fatalError("Expected to find a bundle version in the info dictionary") }
        
        let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: K.UserDefaults.lastReviewVersion)
        
        if (count == 3 || count == 10 || count > 50) && currentVersion != lastVersionPromptedForReview {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                requestReview()
                UserDefaults.standard.set(currentVersion, forKey: K.UserDefaults.lastReviewVersion)
            }
        }
        
    }
    
    ///# Saves report data to userDefaults and performs action:
    // -> reads the current reportCount value form the UserDefaults and saves it increased by one
    func saveReportNumber(){
        var count = UserDefaults.standard.integer(forKey: K.UserDefaults.reportCount)
        count += 1
        UserDefaults.standard.setValue(count, forKey: K.UserDefaults.reportCount)
    }
    
    ///# Function takes care of the reviewRequesting process depending on user's OS version (different for iOS14)
    //$ function is fileprivate because it can only be used be the requestReviewIfAppropriate()
    fileprivate func requestReview() {
        if #available(iOS 14.0, *) {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        } else {
            SKStoreReviewController.requestReview()
        }
    }
}
