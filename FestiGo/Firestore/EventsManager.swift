//
//  EventsManager.swift
//  FestiGo
//
//  Created by kisellsn on 01/05/2025.
//


import Foundation
import FirebaseFirestore
import CoreLocation

final class EventsManager {
    
    static let shared = EventsManager()
    private init() { }
    
    private let eventsCollection = Firestore.firestore().collection("events")

    private var eventsListener: ListenerRegistration? = nil

    
    private func eventDocument(eventId: String) -> DocumentReference {
        eventsCollection.document(eventId)
    }
    
    func uploadEvent(event: Event) async throws {
        try eventDocument(eventId: String(event.id)).setData(from: event, merge: false)
    }
    
    func getEvent(eventId: String) async throws -> Event {
        try await eventDocument(eventId: eventId).getDocument(as: Event.self)
    }
    

    private func getAllEventsQuery() -> Query {
        eventsCollection.order(by: "startTime", descending: false)
    }
    
    func getAllCities() async throws -> [String: CLLocationCoordinate2D?] {
        let snapshot = try await eventsCollection.getDocuments()
        var cityCoordinates: [String: CLLocationCoordinate2D?] = [:]
        
        for document in snapshot.documents {
            do {
                let event = try document.data(as: Event.self)
                let city = event.city.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !city.isEmpty else { continue }

                if cityCoordinates[city] == nil {
                    cityCoordinates[city] = event.coordinate 
                }
            } catch {
                print("⚠️ Не вдалося декодувати Event з документу \(document.documentID): \(error)")
                continue
            }
        }
        
        return cityCoordinates
    }


    private func getAllEvents( count: Int, lastDocument: DocumentSnapshot?) async throws -> (events: [Event], lastDocument: DocumentSnapshot?) {
        let query: Query = getAllEventsQuery()

        return try await query
                .startOptionally(afterDocument: lastDocument)
                .getDocumentsWithSnapshot(as: Event.self)
                
    }
    
    func getAllEvents(
        selectedCategories: [String]? = nil,
        city: String? = nil,
        isOnline: Bool? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        count: Int = 10,
        lastDocument: DocumentSnapshot? = nil
    ) async throws -> (events: [Event], lastDocument: DocumentSnapshot?) {
        print("Getting events with filters:")
        print("Categories: \(selectedCategories ?? [])")
        print("City: \(city ?? "none")")
        print("Online: \(isOnline ?? false)")
        print("StartDate: \(String(describing: startDate))")
        print("EndDate: \(String(describing: endDate))")

        var query: Query = eventsCollection
        
        if (selectedCategories == nil), (city == nil), (isOnline == nil), (startDate == nil), (endDate == nil){
            return try await getAllEvents(count: count, lastDocument: lastDocument)
        }
        
        if let selectedCategories {
            query = query.whereField(Event.CodingKeys.categories.rawValue, arrayContainsAny: selectedCategories)
        }
        
        if let city {
            query = query.whereField(Event.CodingKeys.city.rawValue, isEqualTo: city)
        }
        
        if let isOnline {
            query = query.whereField(Event.CodingKeys.isVirtual.rawValue, isEqualTo: isOnline)
        }

        if let startDate {
            query = query.whereField(Event.CodingKeys.startTime.rawValue, isGreaterThanOrEqualTo: startDate)
        }

        if let endDate {
            query = query.whereField(Event.CodingKeys.endTime.rawValue, isLessThanOrEqualTo: endDate)
        }

        return try await query
                .order(by: "startTime", descending: false)
                .startOptionally(afterDocument: lastDocument)
                .getDocumentsWithSnapshot(as: Event.self)
    }
    
//    func removeListenerForAllUserFavoriteProducts() {
//        self.eventsListener?.remove()
//    }
//    
//    func addListenerForAllEvents(completion: @escaping (_ events: [Event]) -> Void) {
//        self.eventsListener = eventsCollection.addSnapshotListener { querySnapshot, error in
//            guard let documents = querySnapshot?.documents else {
//                print("No documents")
//                return
//            }
//            
//            let events: [Event] = documents.compactMap({ try? $0.data(as: Event.self) })
//            completion(events)
//            
//            querySnapshot?.documentChanges.forEach { diff in
//                if (diff.type == .added) {
//                    print("New event: \(diff.document.data())")
//                }
//                if (diff.type == .modified) {
//                    print("Modified event: \(diff.document.data())")
//                }
//                if (diff.type == .removed) {
//                    print("Removed event: \(diff.document.data())")
//                }
//            }
//        }
//    }

    
    func getAllEventsCount() async throws -> Int {
        try await eventsCollection
            .aggregateCount()
    }
    
    func getEventsByIds(ids: [String]) async throws -> [Event] {
        guard !ids.isEmpty else { return [] }

        let chunkedIds = ids.chunked(into: 10)
        var allEvents: [Event] = []

        for chunk in chunkedIds {
            let query = eventsCollection
                .whereField(FieldPath.documentID(), in: chunk)
            let snapshot = try await query.getDocuments()

            let events = snapshot.documents.compactMap { doc in
                try? doc.data(as: Event.self)
            }
            allEvents.append(contentsOf: events)
        }

        return allEvents
    }
}

