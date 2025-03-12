//
//  Event.swift
//  FestiGo
//
//  Created by kisellsn on 10/03/2025.
//
import UIKit
import MapKit

import Foundation
import CoreLocation

struct EventArray: Codable {
    let events: [Event]
    let total, skip, limit: Int
}

struct Event: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let name: String
    let description: String?
    let link: String?
    let imageUrl: String?
    
    let startTime: Date
    let endTime: Date?
    let isVirtual: Bool
    
    let venue: Venue?
    
    // filters
    let categories: [String]
    let city: String
    let country: String
    
    let price: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case link
        case imageUrl = "imageUrl"
        case startTime = "startTime"
        case endTime = "endTime"
        case isVirtual = "isVirtual"
        case venue
        case categories = "main_categories"
        case city
        case country
        case price
    }
}
extension Event {
    var coordinate: CLLocationCoordinate2D? {
        guard let venue = venue else { return nil }
        return CLLocationCoordinate2D(latitude: venue.latitude, longitude: venue.longitude)
    }
}

struct Venue: Codable, Hashable {
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let subtypes: [String]
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

}





struct RawEvent: Decodable {
    let event_id: String
    let name: String
    let description: String?
    let link: String?
    let start_time: String
    let end_time: String?
    let is_virtual: Bool
    let thumbnail: String?
    let ticket_links: [TicketLink]?
    let venue: RawVenue?
    let city: String?
    let country: String?
    let subtypes: [String]?
    
    struct TicketLink: Decodable {
        let link: String
    }
    
    struct RawVenue: Decodable {
        let name: String
        let full_address: String
        let latitude: Double
        let longitude: Double
    }
}


