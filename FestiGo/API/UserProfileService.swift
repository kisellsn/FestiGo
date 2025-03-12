//
//  UserProfileService.swift
//  FestiGo
//
//  Created by kisellsn on 13/05/2025.
//


import Foundation

class UserProfileService {
    static let shared = UserProfileService()
    
    private init() {}

    func initProfile(completion: ((Bool) -> Void)? = nil) {
        guard let request = TokenManager.shared.authorizedRequest(to: "/user/init_profile", method: "POST") else {
            print("❌ Failed to create request for init_profile")
            completion?(false)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Init profile error: \(error.localizedDescription)")
                completion?(false)
            } else if let httpResponse = response as? HTTPURLResponse {
                print("✅ Init profile status: \(httpResponse.statusCode)")
                completion?(httpResponse.statusCode == 200)
            }
        }.resume()
    }

    func updateProfile(completion: ((Bool) -> Void)? = nil) {
        guard let request = TokenManager.shared.authorizedRequest(to: "/user/update_profile", method: "POST") else {
            print("❌ Failed to create request for update_profile")
            completion?(false)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Update profile error: \(error.localizedDescription)")
                completion?(false)
            } else if let httpResponse = response as? HTTPURLResponse {
                print("✅ Update profile status: \(httpResponse.statusCode)")
                completion?(httpResponse.statusCode == 200)
            }
        }.resume()
    }

    func getRecommendations(completion: @escaping ([String]) -> Void) {
        guard let request = TokenManager.shared.authorizedRequest(to: "/user/get_recommendations") else {
            print("❌ Failed to create request for get_recommendations")
            completion([])
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Get recommendations error: \(error.localizedDescription)")
                completion([])
                return
            }

            guard let data = data else {
                print("❌ No data received")
                completion([])
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                let recommendations = json?["recommendations"] as? [String] ?? []
                print("✅ Recommendations received:", recommendations)
                completion(recommendations)
            } catch {
                print("❌ JSON parsing error: \(error.localizedDescription)")
                completion([])
            }
        }.resume()
    }
}
