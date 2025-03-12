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
    

    func getFavourites() {
        Task {
            guard let userId = Auth.auth().currentUser?.uid else { return }
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

