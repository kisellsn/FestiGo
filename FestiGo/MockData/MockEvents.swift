//
//  MockEvents.swift
//  FestiGo
//
//  Created by kisellsn on 22/04/2025.
//

import Foundation



struct MockEvents {
    static let sampleEvents: [Event] = [
            Event(
                id: "1",
                name: "CupcakKe Live",
                description: "DJ Dials & 1015 Folsom Present: CupcakKe live concert in San Francisco.",
                link: "https://www.eventbrite.com/e/cupcakke-tickets-900711340867",
                imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRAJaz55sNq0XqDESEFPPSh07-bUZ_NxE3pkY3cOc9eBeDzgtVIdMK6CUpRqA&s=10",
                startTime: Date().addingTimeInterval(86400), // +1 day
                endTime: Date().addingTimeInterval(90000),   // +1 day + 1 hour
                isVirtual: false,
                venue: Venue(
                    name: "1015 Folsom",
                    address: "1015 Folsom Street, San Francisco, CA 94103",
                    latitude: 37.77811,
                    longitude: -122.4058,
                    subtypes: ["pub"]
                ),
                categories: ["music", "concert"],
                city: "San Francisco",
                country: "US",
                price: "$25"
            ),
            //TODO: not all imgs r loading
            Event(
                id: "2",
                name: "Art & Wine Festival",
                description: "Enjoy local artists, crafts, and wine tastings.",
                link: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSqVyX29eDfi2vfxDJelnaedAWI-xtlWow8S0mNGcAHoA&s=10",
                imageUrl: nil,
                startTime: Date().addingTimeInterval(172800),
                endTime: Date().addingTimeInterval(280000),
                isVirtual: false,
                venue: Venue(
                    name: "Downtown Plaza",
                    address: "123 Main St, Napa, CA",
                    latitude: 38.2975,
                    longitude: -122.2869,
                    subtypes: ["pub"]
                ),
                categories: ["festival", "art", "food"],
                city: "Napa",
                country: "US",
                price: "Free"
            )
        ]
    static func loadEvents() -> [Event] {
            guard let fileURL = Bundle.main.url(forResource: "mockEvents", withExtension: "json") else {
                fatalError("JSON file not found.")
            }

            do {
                let jsonData = try Data(contentsOf: fileURL)
                let events = try parseEvents(from: jsonData)
                print("Parsed \(events.count) events")
                return events
            } catch {
                print("Failed to parse events:", error)
                return []
            }
        }
    static func parseEvents(from apiResponse: Data) throws -> [Event] {
        struct APIResponse: Codable {
            struct APIEvent: Codable {
                let event_id: String
                let name: String
                let description: String?
                let link: String?
                let start_time: String
                let end_time: String?
                let is_virtual: Bool
                let thumbnail: String?
                let venue: APIVenue?
                let price: String?
                let tags: [String]?
                
                struct APIVenue: Codable {
                    let name: String
                    let full_address: String
                    let latitude: Double
                    let longitude: Double
                    let city: String
                    let country: String
                    let subtypes: [String]
                }
            }
            
            let data: [APIEvent]
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.eventAPIDateFormatter)
        
        let response = try decoder.decode(APIResponse.self, from: apiResponse)
        
        return response.data.map { apiEvent in
            let venue = apiEvent.venue.map {
                Venue(
                    name: $0.name,
                    address: $0.full_address,
                    latitude: $0.latitude,
                    longitude: $0.longitude,
                    subtypes: $0.subtypes
                )
            }
            
            return Event(
                id: apiEvent.event_id,
                name: apiEvent.name,
                description: apiEvent.description,
                link: apiEvent.link,
                imageUrl: apiEvent.thumbnail,
                startTime: DateFormatter.eventAPIDateFormatter.date(from: apiEvent.start_time) ?? Date(),
                endTime: apiEvent.end_time.flatMap { DateFormatter.eventAPIDateFormatter.date(from: $0) },
                isVirtual: apiEvent.is_virtual,
                venue: venue,
                categories: apiEvent.tags ?? venue?.subtypes ?? [],
                city: apiEvent.venue?.city ?? "",
                country: apiEvent.venue?.country ?? "",
                price: apiEvent.price
            )
        }
    }
}
