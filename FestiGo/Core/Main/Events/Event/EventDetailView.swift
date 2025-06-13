//
//  EventDetailView.swift
//  FestiGo
//
//  Created by kisellsn on 21/04/2025.
//


import SwiftUI
import MapKit
import Kingfisher

struct EventDetailView: View {
    let event: Event
//    let isGuest: Bool
//    @Environment(\.presentationMode) var presentationMode

    @Environment(\.openURL) var openURL

    @StateObject private var viewModel = EventDetailViewModel()

    
    var body: some View {
        ScrollView {
            ZStack(alignment: .topTrailing) {
                if let imageUrl = event.imageUrl, let url = URL(string: imageUrl) {
                    KFImage(url)
                        .placeholder { Color.gray.opacity(0.3) }
                        .onFailure { error in print("Image loading failed: \(error)") }
                        .resizable()
                        .scaledToFill()
                        .drawingGroup()
                        .frame(width: UIScreen.main.bounds.width, height: 300)
                        .clipped()
                } else {
                    Color.sage.opacity(0.5).frame(height: 100)
                }

                if viewModel.isUserAuthenticated {
                    HStack(spacing: 12) {
                        HeartButton(isLiked: $viewModel.isLiked) {
                            Task { await viewModel.toggleLike() }
                        }

                        CircleIconButton(
                            systemImageName: "square.and.arrow.up",
                            foregroundColor: .saffron,
                            action: {
                                viewModel.shareEvent()
                            }
                        )
//                        if let shareContent = viewModel.shareContent {
//                            ShareLink(item: shareContent) {
//                                Image(systemName: "square.and.arrow.up")
//                                    .foregroundColor(.saffron)
//                                    .font(.title2)
//                                    .padding(8)
//                                    .background(Color.white)
//                                    .clipShape(Circle())
//                                    .shadow(radius: 3)
//                            }
//                        }

                    }
                    .offset(x: -20, y: (event.imageUrl != nil ? 300 : 100) - 30)
                }
            }
            
            VStack(alignment: .leading, spacing: 16) {
                
                
                
                // Час проведення
                HStack(alignment: .center, spacing: 12) {
                    Image(systemName: "calendar")
                        .foregroundStyle(.gray)
                    
                    if let endTime = event.endTime {
                        if Calendar.current.isDate(event.startTime, inSameDayAs: endTime) {
                            Text("\(event.startTime.formatted(.dateTime.day().month(.wide).hour().minute())) – \(endTime.formatted(.dateTime.hour().minute()))")
                        } else {
                            Text("\(event.startTime.formatted(.dateTime.day().month(.wide).hour().minute())) – \(endTime.formatted(.dateTime.day().month(.wide).hour().minute()))")
                        }
                    } else {
                        Text(event.startTime.formatted(.dateTime.day().month(.wide).hour().minute()))
                    }
                }
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 15)
            
                
                Text(event.localizedName)
                    .font(.title)
                    .bold()
                
                // 3. Description
                if let description = event.localizedDescription {
                    Text("Про подію")
                        .font(.headline)
                    Text(description)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // 5. Venue & MiniMap (Sticker Style)
                if let venue = event.venue {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Локація")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(venue.localizedName)
                                .font(.subheadline)
                                .bold()
                            Text(venue.localizedAddress)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    
                        // Mini Map Style Button
                        MiniMapView(coordinate: CLLocationCoordinate2D(latitude: venue.latitude, longitude: venue.longitude))
                            .onTapGesture {
                                viewModel.openMapAt(
                                    latitude: venue.latitude,
                                    longitude: venue.longitude,
                                    name: venue.localizedName,
                                    openURL: openURL
                                )
                            }
//                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                
                // 6. Save to Calendar
                if viewModel.isUserAuthenticated {
                    Button {
                        Task {
                            await viewModel.calendarLike()
                            viewModel.addToCalendar(openURL: openURL)
                        }
                    } label: {
                        Label("Save to Calendar", systemImage: "calendar.badge.plus")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.lighterViolet.opacity(0.2))
                            .cornerRadius(12)
                    }
                }
                
                if let link = event.link, let url = URL(string: link) {
                    Link("Get Tickets / More Info", destination: url)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.lighterViolet.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundStyle(.ultraViolet)
                }
            }
            .padding()
        }
        .task {
            await viewModel.configure(with: event)
        }
        .navigationBarTitleDisplayMode(.inline)
        .edgesIgnoringSafeArea(.top)

    }
}

#Preview {
    NavigationStack {
        EventDetailView(event: MockEvents.sampleEvents[0])
    }
    .environment(\.locale, Locale(identifier: "uk"))
}
