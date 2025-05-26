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
    let nameUK: String?
    let descriptionUK: String?
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
    
    let cityUK: String?    
    let price: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case nameUK = "name_uk"
        case descriptionUK = "description_uk"
        case link
        case imageUrl = "imageUrl"
        case startTime = "startTime"
        case endTime = "endTime"
        case isVirtual = "isVirtual"
        case venue
        case categories = "main_categories"
        case city
        case country
        case cityUK = "city_uk"
        case price
    }
}
extension Event {
    var coordinate: CLLocationCoordinate2D? {
        guard let venue = venue else { return nil }
        return CLLocationCoordinate2D(latitude: venue.latitude, longitude: venue.longitude)
    }
}
extension Event {
    var localizedName: String {
        if LanguageManager.shared.selectedLanguage == "uk",
           let nameUK = nameUK, !nameUK.isEmpty {
            return nameUK
        }
        return name
    }

    var localizedDescription: String? {
        if LanguageManager.shared.selectedLanguage == "uk",
           let descriptionUK = descriptionUK, !descriptionUK.isEmpty {
            return descriptionUK
        }
        return description
    }

    var localizedCity: String {
        if LanguageManager.shared.selectedLanguage == "uk",
           let cityUK = cityUK, !cityUK.isEmpty {
            return cityUK
        }
        return city
    }
}


struct Venue: Codable, Hashable {
    let name: String
    let address: String
    let nameUK: String?
    let addressUK: String?
    let latitude: Double
    let longitude: Double
    let subtypes: [String]
    
    enum CodingKeys: String, CodingKey {
        case name
        case nameUK = "name_uk"
        case address
        case addressUK = "address_uk"
        case latitude
        case longitude
        case subtypes
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

}

extension Venue {
    var localizedName: String {
        if LanguageManager.shared.selectedLanguage == "uk",
           let nameUK = nameUK, !nameUK.isEmpty {
            return nameUK
        }
        return name
    }

    var localizedAddress: String {
        if LanguageManager.shared.selectedLanguage == "uk",
           let addressUK = addressUK, !addressUK.isEmpty {
            return addressUK
        }
        return address
    }
}
