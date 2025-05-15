//
//  ProductCellViewBuilder.swift
//  FestiGo
//
//  Created by kisellsn on 04/05/2025.
//


import SwiftUI

struct EventCardViewBuilder: View {
    
    let eventId: String
    @State private var event: Event? = nil
    
    var body: some View {
        ZStack {
            if let event {
                EventCardView(event: event)
            }
        }
        .task {
            self.event = try? await EventsManager.shared.getEvent(eventId: eventId)
        }
    }
}
#Preview {
    EventCardViewBuilder(eventId: "L2F1dGhvcml0eS9ob3Jpem9uL2NsdXN0ZXJlZF9ldmVudC8yMDI1LTA0LTAxfDQyMjAyNDcxMjg0NTQzNTgyNjM=")
}
