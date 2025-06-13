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

    func updateProfile(eventId: String, completion: ((Bool) -> Void)? = nil) {
        guard var request = TokenManager.shared.authorizedRequest(to: "/user/update_profile", method: "POST") else {
            print("❌ Failed to create request for update_profile")
            completion?(false)
            return
        }

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json: [String: String] = ["event_id": eventId]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: json)
        } catch {
            print("❌ JSON serialization error:", error.localizedDescription)
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
    
    func getSimilarEvents(completion: @escaping ([Event], String?) -> Void) {
        guard let request = TokenManager.shared.authorizedRequest(to: "/user/get_similar_events") else {
            print("❌ Failed to create request for get_similar_events")
            completion([], nil)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Get similar events error: \(error.localizedDescription)")
                completion([], nil)
                return
            }

            guard let data = data else {
                print("❌ No data received for similar events")
                completion([], nil)
                return
            }

            do {
                struct Response: Decodable {
                    let similar: [String]
                    let lastLikedEventId: String?
                }

                let decoded = try JSONDecoder().decode(Response.self, from: data)
                print("✅ Similar event IDs received:", decoded.similar)

                Task {
                    do {
                        let events = try await EventsManager.shared.getEventsByIds(ids: decoded.similar)
                        completion(events, decoded.lastLikedEventId)
                    } catch {
                        print("❌ Failed to fetch events by IDs:", error)
                        completion([], decoded.lastLikedEventId)
                    }
                }
            } catch {
                print("❌ JSON decoding error for similar events: \(error.localizedDescription)")
                completion([], nil)
            }
        }.resume()
    }


}
