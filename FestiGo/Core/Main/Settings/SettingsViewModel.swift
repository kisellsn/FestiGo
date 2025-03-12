//
//  SettingsViewModel.swift
//  FestiGo
//
//  Created by kisellsn on 24/04/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn


class SettingsViewModel: ObservableObject {
    @Published var defaultLocation: String = ""
    @Published var optimalRangeKm: Double = 50
    @Published var notificationsEnabled: Bool = true

    
    private var hasLoadedFromFirestore = false

    init() {
        loadSettings()
    }

    func loadSettings() {
        guard !hasLoadedFromFirestore,
              let userId = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("onboardingResponses").document(userId).getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil,
                  let answers = data["answers"] as? [String: Any] else { return }

            DispatchQueue.main.async {
                if let locationAnswer = answers["3"] as? [String], let location = locationAnswer.first, self.defaultLocation.isEmpty {
                    self.defaultLocation = location
                }

                if let rangeAnswer = answers["4"] as? [String],
                   let rangeStr = rangeAnswer.first,
                   let extractedNumber = Double(rangeStr.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()),
                   self.optimalRangeKm == 50 {
                    self.optimalRangeKm = extractedNumber
                }


                self.hasLoadedFromFirestore = true
            }
        }
    }

    func saveSettings() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        guard !defaultLocation.isEmpty else {
            print("⚠️ Invalid location.")
            return
        }

        let db = Firestore.firestore()
        let docRef = db.collection("onboardingResponses").document(userId)

        docRef.getDocument { snapshot, error in
            var updatedAnswers = (snapshot?.data()?["answers"] as? [String: Any]) ?? [:]

            updatedAnswers["3"] = [self.defaultLocation]
            updatedAnswers["4"] = ["\(Int(self.optimalRangeKm)) км"]

            docRef.setData(["answers": updatedAnswers], merge: true) { error in
                if let error = error {
                    print("Error saving settings: \(error.localizedDescription)")
                } else {
                    print("✅ Settings saved successfully.")
                }
            }
        }
    }
    func logOut(){
        do{
            GIDSignIn.sharedInstance.signOut()
            try Auth.auth().signOut()
        }catch{
            print(error)
        }
    }
    
    

}

