//
//  MapView.swift
//  FestiGo
//
//  Created by kisellsn on 10/03/2025.
//


import SwiftUI
import MapKit
import FirebaseAuth


struct MapView: View {
    
    @EnvironmentObject var eventViewModel: EventListViewModel
    @StateObject var mapViewModel = MapViewModel()
//    @Environment(\.presentationMode) var presentationMode

    
    let manager = CLLocationManager()

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 50.4501, longitude: 30.5234),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )
    )
    @State private var selectedEvent: Event? = nil
    
    

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                mapView
                
//                 Filters
                EventFiltersView(viewModel: _eventViewModel)
                    .padding(.vertical, 4)
                    .padding(.horizontal)
                
                Divider()
                
                List(selectedEvent.map { [$0] } ?? eventViewModel.filteredEvents) { event in
                    NavigationLink(destination: EventDetailView(event: event)) {
                        EventCardView(event: event)
                    }
                }
                .listStyle(.plain)
                
            }
            .onAppear {
                mapViewModel.loadUserLocation()
                if eventViewModel.events.isEmpty {
                    eventViewModel.getEvents()
                }
                
            }
            .onReceive(mapViewModel.$userCoordinate.compactMap { $0 }) { coordinate in
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                    )
                )
            }
            
            .navigationBarHidden(true)
            .navigationTitle("Карта")

//            .toolbar {
//                if showsBackButton {
//                    ToolbarItem(placement: .navigationBarLeading) {
//                        Button(action: {
//                            presentationMode.wrappedValue.dismiss()
//                        }) {
//                            Image(systemName: "chevron.left")
//                                .foregroundColor(.blue)
//                        }
//                    }
//                }
//            }
        }
    }
    
    @ViewBuilder
    var mapView: some View{
        // Map
        Map(position: $cameraPosition) {
            UserAnnotation()
            ForEach(eventViewModel.events) { event in
                if let coordinate = event.coordinate {
                    Annotation(event.name, coordinate: coordinate) {
                        EventAnnotationView(
                            event: event,
                            isSelected: event.id == selectedEvent?.id,
                            onTap: {
                                withAnimation {
                                    selectedEvent = event
                                }
                            }
                        )
                    }
                }
            }

        }
        .mapControls({
            MapUserLocationButton()
        })
        .onAppear{
            //TODO: request always for notificationss
            manager.requestWhenInUseAuthorization()
        }
        .frame(height: 400)
        .padding(.bottom)
        
    }
}

struct EventAnnotationView: View {
    let event: Event
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Image(systemName: "mappin.circle.fill")
            .foregroundColor(isSelected ? .burgundy : .red.opacity(0.8))
            .font(.title)
            .onTapGesture {
                onTap()
            }
    }
}


#Preview {
    MapView()
        .environmentObject(EventListViewModel())
        .environmentObject(FavouritesViewModel())
}
