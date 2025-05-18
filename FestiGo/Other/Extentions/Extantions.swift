//
//  Extantions.swift
//  FestiGo
//
//  Created by kisellsn on 13/03/2025.
//

import Foundation
import FirebaseFirestore
import Combine

extension Encodable{
    func asDictionary() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else {
            return [:]
        }
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            return json ?? [:]
        } catch {
            return [:]
        }
    }
}

extension DateFormatter {
    static let eventAPIDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "Europe/Kiev")
        return formatter
    }()
}


extension Calendar {
    func generateDates(from start: Date, to end: Date) -> [Date] {
        var dates: [Date] = []
        var current = start

        while current <= end {
            dates.append(current)
            guard let next = self.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }

        return dates
    }
}


extension Query {
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
        try await getDocumentsWithSnapshot(as: type).events
    }
    
    func getDocumentsWithSnapshot<T>(as type: T.Type) async throws -> (events: [T], lastDocument: DocumentSnapshot?) where T : Decodable {
        let snapshot = try await self.getDocuments()
        
        let events = try snapshot.documents.map { document in
            do {
                return try document.data(as: T.self)
            } catch {
                print("Decoding error for document \(document.documentID): \(error)")
                throw error
            }
        }
        
        return (events, snapshot.documents.last)
    }
    
    func startOptionally(afterDocument lastDocument: DocumentSnapshot?) -> Query {
        guard let lastDocument else { return self }
        return self.start(afterDocument: lastDocument)
    }
    
    func aggregateCount() async throws -> Int {
        let snapshot = try await self.count.getAggregation(source: .server)
        return Int(truncating: snapshot.count)
    }
    
    func addSnapshotListener<T>(as type: T.Type) -> (AnyPublisher<[T], Error>, ListenerRegistration) where T : Decodable {
        let publisher = PassthroughSubject<[T], Error>()
        
        let listener = self.addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            let products: [T] = documents.compactMap({ try? $0.data(as: T.self) })
            publisher.send(products)
        }
        
        return (publisher.eraseToAnyPublisher(), listener)
    }
    
}

extension Notification.Name {
    static let favouritesDidChange = Notification.Name("favouritesDidChange")
}


extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}


extension String {
    var isSafeInput: Bool {
        let regex = try! NSRegularExpression(pattern: "^[\\p{L}0-9 ,.-]{1,100}$", options: [])
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) != nil
    }
}
