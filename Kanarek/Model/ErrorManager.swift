//
//  ErrorManager.swift
//  Kanarek
//
//  Created by Chris Yarosh on 01/03/2021.
//

import Foundation

struct ErrorManager {
    
    //## - Function is triggered by SignInController or SignUpController and performs action:
        // -> takes the error provided by FirebaseAuth and depending on the error code it returns an appropriate message in Polish
        // $ Only the most popular errors are translated, if something else happens the localized descripciton will be displayed (in English)
    func translateError(error: Error) -> String{
        let errorMessage = "\(error)"
        if errorMessage.contains("Code=17005"){
            return "Użytkowink został zablokowany przez administratora."
        } else if errorMessage.contains("Code=17007") {
            return "Konto już istnieje / jest w użytku."
        } else if errorMessage.contains("Code=17008") {
            return "Źle sformułowany adress email."
        } else if errorMessage.contains("Code=17009") {
            return "Wprowadzone hasło jest błędne."
        } else if errorMessage.contains("Code=17010") {
            return "Konto zostało zablokowane ze względu na zbyt wiele prób zalogowania. Spróbuj poźniej."
        } else if errorMessage.contains("Code=17011") {
            return "Brak użytkownika z takim adresem email."
        } else if errorMessage.contains("Code=17020") {
            return "Brak połączenia z Internetem."
        } else if errorMessage.contains("Code=17026") {
            return "Za krótkie hasło - wymagana jest długość min. 6 znaków."
        } else {
            return error.localizedDescription
        }
    }
}
