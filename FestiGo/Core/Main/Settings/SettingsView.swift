//
//  SettingsView.swift
//  FestiGo
//
//  Created by kisellsn on 24/04/2025.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @StateObject private var locationManager = LocationSearchManager()
    @StateObject private var locationFetcher = LocationFetcher()
    @State private var colorScheme: ColorScheme? = nil


    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Picker("Режим", selection: $colorScheme) {
                    Text("Системний").tag(nil as ColorScheme?)
                    Text("Світлий").tag(ColorScheme.light as ColorScheme?)
                    Text("Темний").tag(ColorScheme.dark as ColorScheme?)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                GroupBox(
                    label: SettingsLabelView(labelText: "Локація за замовчуванням", labelImage: "location.circle")
                ) {
                    LocationInputView(
                        query: $locationManager.query,
                        results: locationManager.results,
                        status: locationManager.status,
                        onLocationSelect: { selected in
                            let full = "\(selected.title), \(selected.subtitle)"
                            locationManager.query = full
                            locationManager.results = []
                        },
                        onDetectTap: {
                            locationFetcher.requestLocation { detectedLocation in
                                locationManager.query = detectedLocation
                            }
                        },
                        onQueryChange: {
                            // Optional if needed
                        }
                    )
                }

                GroupBox(
                    label: SettingsLabelView(labelText: "Оптимальна відстань (км)", labelImage: "location.north.line")
                ) {
                    Divider().padding(.vertical, 4)
                    Text("Максимальна бажана відстань події від вас")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Slider(value: $viewModel.optimalRangeKm, in: 1...100, step: 1)
                    Text("\(Int(viewModel.optimalRangeKm)) km")
                        .bold()
                }

                GroupBox(
                    label: SettingsLabelView(labelText: "Сповіщення", labelImage: "bell.badge.fill")
                ) {
                    Toggle("Увімкнути сповіщення", isOn: $viewModel.notificationsEnabled)
                        .foregroundStyle(.ultraViolet)
                }

              

                GroupBox {
                    Button("Зберегти налаштування") {
                        viewModel.saveSettings()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.ultraViolet.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                GroupBox {
                    Button("Вийти") {
                        viewModel.logOut()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.burgundy)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            .padding()
            .navigationBarTitle("Налаштування")
            .preferredColorScheme(colorScheme)
            .onReceive(viewModel.$defaultLocation) { newValue in
                if !newValue.isEmpty {
                    locationManager.query = newValue
                }
            }
        }
        
        
    }
}

#Preview{
    SettingsView()
}
