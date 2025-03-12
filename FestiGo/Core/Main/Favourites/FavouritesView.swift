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
            .navigationTitle("Вподобане")
            .onAppear{
                favouritesVM.getFavourites()
            }

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
