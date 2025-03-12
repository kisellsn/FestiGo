//
//  ProfileViewModel.swift
//  FestiGo
//
//  Created by kisellsn on 17/03/2025.
//
import FirebaseAuth
import FirebaseFirestore
import Foundation


class ProfileViewModel: ObservableObject {
    @Published var user: User? = nil

    
    func fetchUser(){
        guard let userId = Auth.auth().currentUser?.uid else{
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument {snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                return
            }
            DispatchQueue.main.async {
                self.user = User(
                    id: data["id"] as? String ?? "",
                    name: data["name"] as? String ?? "",
                    email: data["email"] as? String ?? "",
                    joined: data["joined"] as? TimeInterval ?? 0,
                    photoUrl: data["photoUrl"] as? String,
                    isPremium: data["premium"] as? Bool ?? false)
            }
        }
    }
    
    
}
