//
//  MiniMapView.swift
//  FestiGo
//
//  Created by kisellsn on 12/05/2025.
//

import SwiftUI
import MapKit

struct MiniMapView: View {
    var coordinate: CLLocationCoordinate2D

    @State private var region: MKCoordinateRegion

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        _region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: [MapPin(coordinate: coordinate)]) { pin in
            MapMarker(coordinate: pin.coordinate, tint: .purple)
        }
        .frame(height: 140)
        .cornerRadius(12)
        .disabled(true) // зробити недоступною для взаємодії
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }

    struct MapPin: Identifiable {
        let id = UUID()
        var coordinate: CLLocationCoordinate2D
    }
}
