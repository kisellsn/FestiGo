//
//  FirestoreService.swift
//  FestiGo
//
//  Created by kisellsn on 30/04/2025.
//


import FirebaseFirestore

class FirestoreService {
    
    static let shared = FirestoreService()
        private let db = Firestore.firestore()
        private var firestoreListener: ListenerRegistration?
        
        private init() {}
        
        func loadEvents(completion: @escaping (Result<[Event], Error>) -> Void) {
            if firestoreListener != nil {
                return
            }
 
            firestoreListener = db.collection("events").addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let snapshot = snapshot else {
                    completion(.failure(NSError(domain: "FirestoreService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data found."])))
                    return
                }
                
                let events: [Event] = snapshot.documents.compactMap { document in
                    do {
                        return try self.parseEventFromFirestore(data: document.data())
                    } catch {
                        print("Error parsing event: \(error.localizedDescription)")
                        return nil
                    }
                }
                
                completion(.success(events))
            }
        }
    
    private func parseEventFromFirestore(data: [String: Any]) throws -> Event {
        guard let eventId = data["event_id"] as? String,
              let name = data["name"] as? String,
              let startTimeString = data["start_time"] as? String,
              let startTime = DateFormatter.eventAPIDateFormatter.date(from: startTimeString) else {
                  throw NSError(domain: "Event parsing", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing required fields"])
              }

        let endTimeString = data["end_time"] as? String
        let endTime = endTimeString.flatMap { DateFormatter.eventAPIDateFormatter.date(from: $0) }

        let isVirtual = data["is_virtual"] as? Bool ?? false
        let thumbnail = data["thumbnail"] as? String
        let link = data["link"] as? String
        let description = data["description"] as? String
        let price = data["price"] as? String

        let venueData = data["venue"] as? [String: Any]
        let venue = venueData.map {
            Venue(
                name: $0["name"] as? String ?? "",
                address: $0["full_address"] as? String ?? "",
                latitude: $0["latitude"] as? Double ?? 0.0,
                longitude: $0["longitude"] as? Double ?? 0.0,
                subtypes: $0["subtypes"] as? [String] ?? []
            )
        }

        let categories = data["main_categories"] as? [String] ?? []

        let city = venueData?["city"] as? String ?? ""
        let country = venueData?["country"] as? String ?? ""

        return Event(
            id: eventId,
            name: name,
            description: description,
            link: link,
            imageUrl: thumbnail,
            startTime: startTime,
            endTime: endTime,
            isVirtual: isVirtual,
            venue: venue,
            categories: categories,
            city: city,
            country: country,
            price: price
        )
    }
    
    deinit {
        firestoreListener?.remove()
        print("Firestore listener removed")
    }
}
