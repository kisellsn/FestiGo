//
//  MainViewController.swift
//  FestiGo
//
//  Created by kisellsn on 13/03/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class MainViewModel: ObservableObject {
    @Published var currentUserId: String = ""
    @Published var needsOnboarding: Bool = false
    
    private var handler: AuthStateDidChangeListenerHandle?
    
    init() {
        self.handler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUserId = user?.uid ?? ""
                
                if let uid = user?.uid {
                    self?.checkOnboardingStatus(for: uid)
                } else {
                    self?.needsOnboarding = false
                }
            }
        }
    }
     
    public var isSignIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    private func checkOnboardingStatus(for uid: String) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let didComplete = data["didCompleteOnboarding"] as? Bool {
                DispatchQueue.main.async {
                    self.needsOnboarding = !didComplete
                }
            } else {
                DispatchQueue.main.async {
                    self.needsOnboarding = true
                }
            }
        }
    }
    
    func completeOnboarding() {
        let db = Firestore.firestore()
        db.collection("users").document(currentUserId).updateData([
            "didCompleteOnboarding": true
        ]) { error in
            if error == nil {
                DispatchQueue.main.async {
                    self.needsOnboarding = false
                }
            }
        }
    }
}

