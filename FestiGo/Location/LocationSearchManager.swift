//
//  LocationSearchManager.swift
//  FestiGo
//
//  Created by kisellsn on 15/04/2025.
//

import Foundation
import MapKit

class LocationSearchManager: NSObject, ObservableObject {
    static let shared = LocationSearchManager()
    @Published var query: String = "" {
        didSet {
            handleSearchFragment(query)
        }
    }
    
    @Published var results: [LocationResult] = []
    @Published var status: SearchStatus = .idle
    
    var completer: MKLocalSearchCompleter

    init(
        filter: MKPointOfInterestFilter = .excludingAll,
        region: MKCoordinateRegion = MKCoordinateRegion(.world),
        types: MKLocalSearchCompleter.ResultType = [.pointOfInterest, .query, .address]
    ) {
        completer = MKLocalSearchCompleter()
        super.init()
        completer.delegate = self
        completer.pointOfInterestFilter = filter
        completer.region = region
        completer.resultTypes = types
    }

    private func handleSearchFragment(_ fragment: String) {
        status = .searching
        if !fragment.isEmpty {
            completer.queryFragment = fragment
        } else {
            status = .idle
            results = []
        }
    }
    
    func getCoordinates(for cityName: String) async throws -> CLLocationCoordinate2D? {
        return try await withCheckedThrowingContinuation { continuation in
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(cityName) { placemarks, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let coordinate = placemarks?.first?.location?.coordinate {
                    continuation.resume(returning: coordinate)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}

extension LocationSearchManager: MKLocalSearchCompleterDelegate{
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results.map({ result in
            LocationResult(title: result.title, subtitle: result.subtitle)
        })
        self.status = .result
    }
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        self.status = .error(error.localizedDescription)
    }
    
}



struct LocationResult: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var subtitle: String
}
enum SearchStatus: Equatable {
    case idle
    case searching
    case error(String)
    case result
}
