//
//  EventCardView.swift
//  FestiGo
//
//  Created by kisellsn on 20/04/2025.
//


import SwiftUI
import Kingfisher


struct EventCardView: View {
    let event: Event

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text("")
            if let imageUrl = event.imageUrl, let _ = URL(string: imageUrl) {
//                AsyncImage(url: url) { image in
//                    image
//                        .resizable()
//                        .scaledToFill()
//                }
                KFImage(URL(string: imageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 110, height: 90)
                    .clipped()
                    .cornerRadius(12)

//                placeholder: {
//                    Rectangle().fill(Color.gray.opacity(0.3))
//                }
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(event.name)
                    .font(.headline)
                    .lineLimit(1)

                if let venue = event.venue {
                    Text("\(venue.name), \(event.city)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Text(event.startTime, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)

//                if let price = event.price {
//                    Text("Price: \(price)")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)

    }
}


#Preview {
    EventCardView(event: Event(
        id: "123456",
        name: "CupcakKe Live at 1015 Folsom",
        description: "FRIDAY JUNE 14 2024 - DJ Dials & 1015 Folsom Present: cupcakKe",
        link: "https://www.eventbrite.com/e/cupcakke-tickets-900711340867",
        imageUrl: "https://img.evbuc.com/https%3A%2F%2Fcdn.evbuc.com%2Fimages%2F762008039%2F121998919041%2F1%2Foriginal.20240507-212848?w=1000&auto=format%2Ccompress&q=75&sharp=10&rect=0%2C198%2C1920%2C960&s=182c6aab47493c1b87d41a43cff0597d",
        startTime: ISO8601DateFormatter().date(from: "2024-06-15T05:00:00Z")!,
        endTime: ISO8601DateFormatter().date(from: "2024-06-15T06:30:00Z"),
        isVirtual: false,
        venue: Venue(
            name: "1015 Folsom",
            address: "1015 Folsom Street, San Francisco, CA 94103, United States",
            latitude: 37.77811,
            longitude: -122.4058, subtypes: ["bar"]
        ),
        categories: ["music", "nightlife", "live_music_venue"],
        city: "San Francisco",
        country: "US", price: "--"
    ))
}
