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
            id: "123456",
            name: "CupcakKe Live at 1015 Folsom",
            description: "FRIDAY JUNE 14 2024 - DJ Dials & 1015 Folsom Present: cupcakKe",
            nameUK: "lalala",
            descriptionUK: "descriptionUK lalala",
            link: "https://www.eventbrite.com/e/cupcakke-tickets-900711340867",
            imageUrl: "https://img.evbuc.com/https%3A%2F%2Fcdn.evbuc.com%2Fimages%2F762008039%2F121998919041%2F1%2Foriginal.20240507-212848?w=1000&auto=format%2Ccompress&q=75&sharp=10&rect=0%2C198%2C1920%2C960&s=182c6aab47493c1b87d41a43cff0597d",
            startTime: ISO8601DateFormatter().date(from: "2024-06-15T05:00:00Z")!,
            endTime: ISO8601DateFormatter().date(from: "2024-06-15T06:30:00Z"),
            isVirtual: false,
            venue: Venue(
                name: "1015 Folsom",
                address: "1015 Folsom Street, San Francisco, CA 94103, United States",
                nameUK:"nameUK",
                addressUK:"addressUK",
                latitude: 37.77811,
                longitude: -122.4058, subtypes: ["bar"]
            ),
            categories: ["music", "nightlife", "live_music_venue"],
            city: "San Francisco",
            country: "US",
            cityUK: "cityUK llalalal",
            price: "--"
        ),
            //TODO: not all imgs r loading
        Event(
            id: "123456",
            name: "CupcakKe Live at 1015 Folsom",
            description: "FRIDAY JUNE 14 2024 - DJ Dials & 1015 Folsom Present: cupcakKe",
            nameUK: "lalala",
            descriptionUK: "descriptionUK lalala",
            link: "https://www.eventbrite.com/e/cupcakke-tickets-900711340867",
            imageUrl: nil,
            startTime: ISO8601DateFormatter().date(from: "2024-06-15T05:00:00Z")!,
            endTime: ISO8601DateFormatter().date(from: "2024-06-15T06:30:00Z"),
            isVirtual: false,
            venue: Venue(
                name: "1015 Folsom",
                address: "1015 Folsom Street, San Francisco, CA 94103, United States",
                nameUK:"nameUK",
                addressUK:"addressUK",
                latitude: 37.77811,
                longitude: -122.4058, subtypes: ["bar"]
            ),
            categories: ["music", "nightlife", "live_music_venue"],
            city: "San Francisco",
            country: "US",
            cityUK: "cityUK llalalal",
            price: "--"
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
                    nameUK:"nameUK",
                    addressUK:"addressUK",
                    latitude: $0.latitude,
                    longitude: $0.longitude,
                    subtypes: $0.subtypes
                )
            }
            
            return Event(
                id: apiEvent.event_id,
                name: apiEvent.name,
                description: apiEvent.description,
                nameUK: "lalala",
                descriptionUK: "descriptionUK lalala",
                link: apiEvent.link,
                imageUrl: apiEvent.thumbnail,
                startTime: DateFormatter.eventAPIDateFormatter.date(from: apiEvent.start_time) ?? Date(),
                endTime: apiEvent.end_time.flatMap { DateFormatter.eventAPIDateFormatter.date(from: $0) },
                isVirtual: apiEvent.is_virtual,
                venue: venue,
                categories: apiEvent.tags ?? venue?.subtypes ?? [],
                city: apiEvent.venue?.city ?? "",
                country: apiEvent.venue?.country ?? "",
                cityUK: "cityUK llalalal",
                price: apiEvent.price
            )
        }
    }
}
