//
//  UserValidator.swift
//  FestiGo
//
//  Created by kisellsn on 12/03/2025.
//

import Foundation
import Observation

@Observable class UserValidator{
    var name = ""
    var password = ""
    var email = ""
    
    // Error messages for each field
    var emailError: String = ""
    var passwordError: String = ""
    var nameError: String = ""

    
    var isLoginBtnDisabled: Bool {
        return !isValidEmail(string: email) || email.count > 30 || password.count < 8 || password.count > 15 || password.trimmingCharacters(in: .whitespaces).isEmpty

    }
    var isSubmitBtnDisabled: Bool {
        return !isValidEmail(string: email) || email.count > 30 || password.count < 8 || name.count < 2 ||  name.count > 15 || password.trimmingCharacters(in: .whitespaces).isEmpty || name.trimmingCharacters(in: .whitespaces).isEmpty || password.count > 15
    }
    
    func isValidEmail(string: String) -> Bool {
        let emailRegex = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/
            .ignoresCase()
        
        return !string.ranges(of: emailRegex).isEmpty
    }
}
