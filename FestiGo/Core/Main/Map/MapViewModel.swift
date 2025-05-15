//
//  MapViewModel.swift
//  FestiGo
//
//  Created by kisellsn on 22/04/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import CoreLocation

 
class MapViewModel: ObservableObject {
    @Published var userCoordinate: CLLocationCoordinate2D?

    func loadUserLocation() {
        guard let userId = Auth.auth().currentUser?.uid else{
            return
        }
        Firestore.firestore().collection("onboardingResponses")
            .document(userId)
            .getDocument
        { snapshot, error in
                if let data = snapshot?.data(),
                   let answers = data["answers"] as? [String: Any],
                   let locationArray = answers["3"] as? [String],
                   let location = locationArray.first {
                    self.geocode(location) { coordinate in
                        DispatchQueue.main.async {
                            self.userCoordinate = coordinate
                        }
                    }
                }
            }
    }

    private func geocode(_ address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        CLGeocoder().geocodeAddressString(address) { placemarks, error in
            if let coordinate = placemarks?.first?.location?.coordinate {
                completion(coordinate)
            } else {
                print("Geocoding failed: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
            }
        }
    }
}

