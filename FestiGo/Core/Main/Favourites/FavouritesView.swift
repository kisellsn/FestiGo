//
//  FavouritesView.swift
//  FestiGo
//
//  Created by kisellsn on 23/04/2025.
//

import SwiftUI

@MainActor
struct FavouritesView: View {
    @EnvironmentObject var favouritesVM: FavouritesViewModel
    
    var groupedEvents: [(date: Date, events: [Event])] {
        let calendar = Calendar.current

        let events = favouritesVM.eventsMap.values
        let grouped = Dictionary(grouping: events) { event in
            calendar.startOfDay(for: event.startTime)
        }

        return grouped
            .map { (key, value) in (date: key, events: value) }
            .sorted { $0.date < $1.date }
    }


    var body: some View {
        NavigationStack {
            ZStack {
                // Фонове зображення
                Image(uiImage: #imageLiteral(resourceName: "bgPic"))
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                if favouritesVM.isLoading {
                    ProgressView("Завантаження...")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .padding()
                } else if groupedEvents.isEmpty {
                    VStack {
                        Spacer()
                        Text("Ще немає збережених подій")
                            .font(.title3)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding()
                            .transition(.opacity)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(groupedEvents, id: \.date) { group in
                            Section(header: Text(formattedDate(group.date))) {
                                ForEach(group.events) { event in
                                    NavigationLink(destination: EventDetailView(event: event)) {
                                        EventCardView(event: event)
                                    }
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .padding(.top, 100)
                    .transition(.opacity)
                }
            }
            .onAppear {
                favouritesVM.getFavourites()
            }
//            .onReceive(NotificationCenter.default.publisher(for: .favouritesDidChange)) { _ in
//                favouritesVM.getFavourites()
//            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Вподобане")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color.black)
                        .padding(.top, 7)
                }
            }
            .toolbarBackground(Color.white.opacity(0.1), for: .navigationBar)
        }
    }


    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "uk_UA")
        return formatter.string(from: date)
    }
}


#Preview(){
    FavouritesView()
        .environmentObject(FavouritesViewModel())
}
