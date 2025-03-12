//
//  SignUpEmailViewModel.swift
//  FestiGo
//
//  Created by kisellsn on 13/03/2025.
//

import FirebaseFirestore
import Foundation
import FirebaseAuth

class SignUpEmailViewModel: ObservableObject {
    @Published var userValidator: UserValidator
    @Published var isLoading: Bool = false
    @Published var errorMessage = ""

    init(userValidator: UserValidator) {
        self.userValidator = userValidator
    }
    
    //TODO: check if email is valid
    func register() {
        guard !userValidator.isSubmitBtnDisabled else {
            return
        }
        isLoading = true
        errorMessage = ""

        Auth.auth().createUser(withEmail: userValidator.email, password: userValidator.password){ [weak self] result, error in
            self!.isLoading = false
            if let error = error as NSError? {
                if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    self?.errorMessage = "Користувач з таким email вже існує"
                } else {
                    self?.errorMessage = "Сталася помилка. Спробуйте ще раз"
                }
                return
            }
            guard let userId = result?.user.uid else{
                return
            }
            self?.insertUserRecord(userId)
        }
        
    }
    private func insertUserRecord(_ userId: String){
        let newUser = User(id: userId,
                           name: userValidator.name,
                           email: userValidator.email,
                           joined: Date().timeIntervalSince1970
        )
        let db = Firestore.firestore()
        db.collection("users")
            .document(userId)
            .setData(
                newUser.asDictionary())
    }
    
    
}

