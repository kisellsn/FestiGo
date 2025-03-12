//
//  SingInEmailController.swift
//  FestiGo
//
//  Created by kisellsn on 13/03/2025.
//

import Foundation
import FirebaseAuth

class SignInEmailViewModel: ObservableObject {
    @Published var userValidator: UserValidator
    @Published var isLoading: Bool = false
    @Published var errorMessage = ""

    init(userValidator: UserValidator) {
        self.userValidator = userValidator
    }

    func login() {
        guard !userValidator.isLoginBtnDisabled else {
            return
        }
        isLoading = true
        errorMessage = ""

        Auth.auth().signIn(withEmail: userValidator.email, password: userValidator.password) { authResult, error in
            self.isLoading = false

            if let error = error {
                self.errorMessage = "Користувач не знайдений або неправильний пароль"
            }
        }
    }
//    func login(completion: @escaping (Result<Void, AuthError>) -> Void) {
//        guard !userValidator.isLoginBtnDisabled else {
//            return
//        }
//        
//        isLoading = true
//        
//        Auth.auth().signIn(withEmail: userValidator.email, password: userValidator.password) { authResult, error in
//            self.isLoading = false
//            
//            if let error = error {
//                completion(.failure(.custom("Користувач не знайдений або неправильний пароль")))
//            } else {
//                completion(.success(()))
//            }
//        }
//    }
//    
}
