//
//  EventDetailViewModel.swift
//  FestiGo
//
//  Created by kisellsn on 21/04/2025.
//


import Foundation
import SwiftUI

import SwiftUI
import FirebaseAuth
 
@MainActor
class EventDetailViewModel: ObservableObject {
    @Published var event: Event?
    @Published var isLiked: Bool = false
    @Published var isUserAuthenticated: Bool = false

    func configure(with event: Event) async {
        self.event = event
        self.isUserAuthenticated = Auth.auth().currentUser != nil
        if isUserAuthenticated {
            await fetchIsLiked(eventId: event.id)
        }
    }

    func openMapAt(latitude: Double, longitude: Double, name: String, openURL: OpenURLAction) {
        guard let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "http://maps.apple.com/?q=\(encodedName)&ll=\(latitude),\(longitude)") else { return }
        openURL(url)
    }

    func addToCalendar(openURL: OpenURLAction) {
        guard let event = event else { return }

        let formatter = ISO8601DateFormatter()
        let start = formatter.string(from: event.startTime)
        let end = formatter.string(from: event.endTime ?? event.startTime.addingTimeInterval(7200))
        let encodedTitle = event.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Event"

        let urlStr = "https://www.google.com/calendar/render?action=TEMPLATE&text=\(encodedTitle)&dates=\(start.cleanedGoogleDate)/\(end.cleanedGoogleDate)"
        if let url = URL(string: urlStr) {
            openURL(url)
        }
    }
    
    private func fetchIsLiked(eventId: String) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        do {
            let favourites = try await UserManager.shared.getAllUserFavouriteEvents(userId: userId)
            self.isLiked = favourites.contains(where: { $0.eventId == eventId })
        } catch {
            print("Error fetching favourites:", error)
        }
    }

    func toggleLike() async {
        guard let eventId = event?.id,
              let userId = Auth.auth().currentUser?.uid else { return }

        if isLiked {
            await removeFromFavourites(userId: userId, eventId: eventId)
            isLiked = false
        } else {
            await addUserFavouriteEvent(userId: userId, eventId: eventId)
            isLiked = true
        }
//        NotificationCenter.default.post(name: .favouritesDidChange, object: nil)
    }
    
    func calendarLike() async {
        guard let eventId = event?.id,
              let userId = Auth.auth().currentUser?.uid else { return }

        if !isLiked {
            await addUserFavouriteEvent(userId: userId, eventId: eventId)
            isLiked = true
        }
    }

    
    func removeFromFavourites(userId: String, eventId: String) async {
        try? await UserManager.shared.removeUserFavouriteEvent(userId: userId, eventId: eventId)
    }

    
    func addUserFavouriteEvent(userId: String, eventId: String) async{
        Task {
            try? await UserManager.shared.addUserFavouriteEvent(userId: userId, eventId: eventId)
            UserProfileService.shared.updateProfile(eventId: eventId) { success in
                print("Update result: \(success)")
            }
        }
    }
    
//    func shareEvent() {
//        guard let event = event else { return }
//
//        var message = "Check out this event: \(event.name)"
//        
//        if let link = event.link {
//            message += "\n\nMore info: \(link)"
//        }
//
//        let av = UIActivityViewController(activityItems: [message], applicationActivities: nil)
//
//        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//           let rootVC = scene.windows.first?.rootViewController {
//            rootVC.present(av, animated: true, completion: nil)
//        }
//    }
    func shareEvent() {
        guard let event = event else { return }

        var items: [Any] = []

        let message = "Check out this event: \(event.name)\n\n\(event.venue?.localizedAddress ?? "")\n\nMore info: \(event.link ?? "")"
        items.append(message)

        let av = UIActivityViewController(activityItems: items, applicationActivities: nil)

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = scene.windows.first?.rootViewController {
            rootVC.present(av, animated: true, completion: nil)
        }
    }

}

private extension String {
    var cleanedGoogleDate: String {
        self.replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: ":", with: "")
            .replacingOccurrences(of: "+0000", with: "Z")
    }
}

struct ShareEventContent: Transferable {
    let title: String
    let address: String
    let link: URL
    let image: Image?

    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.title)
    }
}

extension ShareEventContent: CustomStringConvertible {
    var description: String {
        "\(title)\n\(address)\n\nMore info: \(link.absoluteString)"
    }
}
