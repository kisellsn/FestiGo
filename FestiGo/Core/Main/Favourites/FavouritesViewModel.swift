//
//  FavouritesViewModel.swift
//  FestiGo
//
//  Created by kisellsn on 23/04/2025.
//
import Foundation
import FirebaseAuth

@MainActor
class FavouritesViewModel: ObservableObject {
    @Published private(set) var userFavouriteEvents: [UserFavouriteEvent] = []
    @Published private(set) var eventsMap: [String: Event] = [:]
    @Published var isLoading = true

    

    func getFavourites() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        Task {
            isLoading = true
            defer { isLoading = false }
            
            self.userFavouriteEvents = try await UserManager.shared.getAllUserFavouriteEvents(userId: userId)
            self.eventsMap = [:]

            for fav in userFavouriteEvents {
                if let event = try? await EventsManager.shared.getEvent(eventId: fav.eventId) {
                    eventsMap[fav.eventId] = event
                }
            }
        }
    }
}


