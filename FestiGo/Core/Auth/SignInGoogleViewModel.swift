//
//  SignInGoogleViewModel.swift
//  FestiGo
//
//  Created by kisellsn on 02/04/2025.
//

import Foundation

import FirebaseFirestore
import FirebaseAuth
import FirebaseCore

import GoogleSignIn


class SignInGoogleViewModel: ObservableObject {
    func signInGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: Utilities.rootViewController) { result, error in
            
            if let error = error {
                print("Google Sign-In error: \(error.localizedDescription)")
                return
            }
            
            guard
                let user = result?.user,
                let idToken = user.idToken else {
                print("Google user or token missing")
                return
            }
            
            let accessToken = user.accessToken
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken.tokenString,
                accessToken: accessToken.tokenString
            )
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase Auth error: \(error.localizedDescription)")
                    return
                }
                
                guard let firebaseUser = authResult?.user else { return }
                
                self.checkOrCreateUserDocument(user: firebaseUser)
            }
        }
    }
    
    private func checkOrCreateUserDocument(user: FirebaseAuth.User) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)
        
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                print("User already exists in Firestore.")
            } else {
                let newUser = User(
                    id: user.uid,
                    name: user.displayName ?? "Unknown",
                    email: user.email ?? "",
                    joined: Date().timeIntervalSince1970,
//                    isAnonymous: user.isAnonymous,
                    photoUrl: user.photoURL?.absoluteString
                )
                
                userRef.setData(newUser.asDictionary()) { error in
                    if let error = error {
                        print("Error saving new user: \(error.localizedDescription)")
                    } else {
                        print("New user created in Firestore")
                    }
                }
            }
        }
    }
}

