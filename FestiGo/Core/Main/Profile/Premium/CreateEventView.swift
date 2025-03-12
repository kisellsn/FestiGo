//
//  CreateEventView.swift
//  FestiGo
//
//  Created by kisellsn on 25/04/2025.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore


struct CreateEventView: View {
    @State private var title = ""
    @State private var description = ""
    @State private var date = Date()
    @State private var location = ""

    var body: some View {
        Form {
            Section(header: Text("Деталі події")) {
                TextField("Назва", text: $title)
                TextField("Опис", text: $description)
                DatePicker("Дата", selection: $date)
                TextField("Локація", text: $location)
            }

            Button("Створити") {
                createEvent()
            }
        }
        .navigationTitle("Нова подія")
    }

    func createEvent() {
        guard let userId = Auth.auth().currentUser?.uid else { return
        }

        let db = Firestore.firestore()
        let newEvent: [String: Any] = [
            "title": title,
            "description": description,
            "date": Timestamp(date: date),
            "location": location,
            "createdBy": userId
        ]

        db.collection("events").addDocument(data: newEvent) { error in
            if let error = error {
                print("❌ Error creating event: \(error.localizedDescription)")
            } else {
                print("✅ Event created")
            }
        }
    }
}

#Preview{
    CreateEventView()
}
