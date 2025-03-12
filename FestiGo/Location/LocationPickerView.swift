//
//  LocationPickerView.swift
//  FestiGo
//
//  Created by kisellsn on 05/05/2025.
//

//
//import SwiftUI
//import MapKit
//
//struct LocationPickerView: View {
//    @StateObject private var fetcher = LocationFetcher()
//    @StateObject private var searchManager = LocationSearchManager()
//    
//    @State private var selectedLocation: String = "Немає вибраного місця"
//    @State private var isUsingCurrentLocation = false
//    
//    var body: some View {
//        VStack(spacing: 16) {
//            HStack {
//                Button("Визначити моє місцезнаходження") {
//                    isUsingCurrentLocation = true
//                    fetcher.requestLocation { location in
//                        selectedLocation = location
//                        searchManager.query = "" // Очистити ручний пошук
//                    }
//                }
//                .padding()
//                .background(Color.blue.opacity(0.1))
//                .cornerRadius(10)
//            }
//            
//            TextField("Пошук місця", text: $searchManager.query)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding(.horizontal)
//            
//            if searchManager.status == .searching {
//                ProgressView("Пошук...")
//            } else if searchManager.status == .error {
//                Text("Помилка: \()").foregroundColor(.red)
//            } else if !searchManager.results.isEmpty {
//                List(searchManager.results, id: \.self) { result in
//                    VStack(alignment: .leading) {
//                        Text(result.title).fontWeight(.bold)
//                        Text(result.subtitle).font(.subheadline).foregroundColor(.gray)
//                    }
//                    .contentShape(Rectangle())
//                    .onTapGesture {
//                        isUsingCurrentLocation = false
//                        selectedLocation = "\(result.title), \(result.subtitle)"
//                        searchManager.query = ""
//                        searchManager.results = []
//                    }
//                }
//                .listStyle(PlainListStyle())
//                .frame(maxHeight: 250)
//            }
//
//            Divider()
//
//            Text("Вибране місце:")
//                .font(.headline)
//            Text(selectedLocation)
//                .font(.title3)
//                .multilineTextAlignment(.center)
//                .padding()
//
//            Spacer()
//        }
//        .padding()
//    }
//}
