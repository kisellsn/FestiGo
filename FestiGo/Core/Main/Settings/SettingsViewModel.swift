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
    @Published var locationCoordinates: (lat: Double, lon: Double)? = nil

 
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
                if let locationAnswer = answers["3"] as? [[String: Any]],
                   let locationDict = locationAnswer.first {
                    if let title = locationDict["title"] as? String, self.defaultLocation.isEmpty {
                        self.defaultLocation = title
                    }
                    if let lat = locationDict["lat"] as? Double,
                       let lon = locationDict["lon"] as? Double {
                        self.locationCoordinates = (lat, lon)
                    }
                }

                if let rangeAnswer = answers["4"] as? [String],
                   let rangeStr = rangeAnswer.first {
                    let numberString = rangeStr.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                    if let extractedNumber = Double(numberString), self.optimalRangeKm == 50 {
                        self.optimalRangeKm = extractedNumber
                    }
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

            var locationDict: [String: Any] = ["title": self.defaultLocation]
            if let coords = self.locationCoordinates {
                locationDict["lat"] = coords.lat
                locationDict["lon"] = coords.lon
            }

            updatedAnswers["3"] = [locationDict]
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

    
    func deleteAccount() {
        guard let user = Auth.auth().currentUser else {
            print("⚠️ No logged in user.")
            return
        }

        let userId = user.uid
        let db = Firestore.firestore()

        // Спочатку видаляємо документ користувача з Firestore
        db.collection("onboardingResponses").document(userId).delete { error in
            if let error = error {
                print("❌ Error deleting user data: \(error.localizedDescription)")
                return
            }

            print("🗑️ User data deleted from Firestore.")

            // Тепер видаляємо обліковий запис Firebase
            user.delete { error in
                if let error = error {
                    print("❌ Error deleting Firebase user: \(error.localizedDescription)")
                } else {
                    print("✅ Firebase user account deleted.")
                }
            }
        }
    }
}

