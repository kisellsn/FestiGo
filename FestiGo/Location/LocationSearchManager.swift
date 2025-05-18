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
    @Published var hasSelectedLocation: Bool = false
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
        region: MKCoordinateRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 49.0, longitude: 31.0), // Центр України
            span: MKCoordinateSpan(latitudeDelta: 8.0, longitudeDelta: 10.0) // Покриває Україну
        ),
        types: MKLocalSearchCompleter.ResultType = [.address]
    )
    {
        completer = MKLocalSearchCompleter()
        super.init()
        completer.delegate = self
        completer.pointOfInterestFilter = filter
        completer.region = region
        completer.resultTypes = types
    }

    private func handleSearchFragment(_ fragment: String) {
        status = .searching
        hasSelectedLocation = false 
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
        // Відфільтруй лише результати, які містять згадку про Україну
        let filtered = completer.results.filter {
            let lowerSubtitle = $0.subtitle.lowercased()
            return lowerSubtitle.contains("ukraine") || lowerSubtitle.contains("україна")
        }

        // Зберігаємо результати як об'єкти LocationResult
        self.results = filtered.map { result in
            LocationResult(title: result.title, subtitle: result.subtitle)
        }

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
