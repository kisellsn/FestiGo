//
//  SettingsView.swift
//  FestiGo
//
//  Created by kisellsn on 24/04/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @StateObject private var locationManager = LocationSearchManager()
    @StateObject private var locationFetcher = LocationFetcher()

    @State private var hasSelectedLocation = false
    @State private var isSelecting = false
    @State private var showDeleteConfirmation = false
    @State private var showSavedAlert = false


    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @State private var colorScheme: ColorScheme? = {
        let isDark = UserDefaults.standard.bool(forKey: "isDarkMode")
        return UserDefaults.standard.object(forKey: "isDarkMode") != nil ? (isDark ? .dark : .light) : nil
    }()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Тема
                GroupBox(
                    label: SettingsLabelView(labelText:"Тема застосунку", labelImage: "sun.max")
                ){
                    Picker("Режим", selection: $colorScheme) {
                        Text("Системна").tag(nil as ColorScheme?)
                        Text("Світла").tag(ColorScheme.light as ColorScheme?)
                        Text("Темна").tag(ColorScheme.dark as ColorScheme?)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .onChange(of: colorScheme) { oldValue, newValue in
                        if let newValue {
                            isDarkMode = (newValue == .dark)
                        } else {
                            UserDefaults.standard.removeObject(forKey: "isDarkMode")
                        }
                    }
                }

                // Локація
                GroupBox(
                    label: SettingsLabelView(labelText:"Локація за замовчуванням", labelImage: "location.circle")
                ) {
                    LocationInputView(
                        query: $locationManager.query,
                        hasSelectedLocation: $hasSelectedLocation,
                        results: locationManager.results,
                        status: locationManager.status,
                        onLocationSelect: { selected in
                            isSelecting = true
                            let full = "\(selected.title), \(selected.subtitle)"
                            locationManager.query = full
                            viewModel.defaultLocation = full
                            locationManager.results = []

                            Task {
                                if let coords = try? await locationManager.getCoordinates(for: full) {
                                    viewModel.locationCoordinates = (coords.latitude, coords.longitude)
                                }
                                hasSelectedLocation = true
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isSelecting = false
                            }
                        },
                        onDetectTap: {
                            locationFetcher.requestLocation { detectedLocation in
                                locationManager.query = detectedLocation
                                viewModel.defaultLocation = detectedLocation
                                hasSelectedLocation = true
                            }
                        },
                        onQueryChange: {
                            if !isSelecting {
                                hasSelectedLocation = false
                            }
                        }
                    )
                }

                // Відстань
                GroupBox(
                    label: SettingsLabelView(labelText: LocalizedStringResource("Оптимальна відстань (км)"), labelImage: "location.north.line")
                ) {
                    Divider().padding(.vertical, 4)
                    Text("Максимальна бажана відстань події від вас")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Slider(value: $viewModel.optimalRangeKm, in: 1...100, step: 1)
                    Text("\(Int(viewModel.optimalRangeKm)) км")
                        .bold()
                }

                // Сповіщення
                GroupBox(
                    label: SettingsLabelView(labelText: "Сповіщення", labelImage: "bell.badge.fill")
                ) {
                    Toggle("Увімкнути сповіщення", isOn: $viewModel.notificationsEnabled)
                        .foregroundStyle(.ultraViolet)
                }

                
                Button("Зберегти налаштування") {
                    viewModel.saveSettings()
                    showSavedAlert = true
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.ultraViolet.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
                .alert("✅ Налаштування збережено", isPresented: $showSavedAlert) {
                    Button("OK", role: .cancel) {}
                }
                

                // Видалити акаунт
                FullButtonView(
                    title: "Видалити акаунт",
                    action: {
                        showDeleteConfirmation = true
                    },
                    backgroundColor: .clear,
                    isDisabled: false,
                    isLoading: false,
                    iconName: "trash",
                    textColor: .burgundy
                )
                .alert("Видалити акаунт?", isPresented: $showDeleteConfirmation) {
                    Button("Видалити", role: .destructive) {
                        viewModel.deleteAccount()
                    }
                    Button("Скасувати", role: .cancel) { }
                } message: {
                    Text("Цю дію не можна скасувати. Ваш профіль і дані буде повністю видалено.")
                }
            }
            .padding()
            .navigationBarTitle("Налаштування")
            .preferredColorScheme(colorScheme)
            .onAppear {
//                if !viewModel.defaultLocation.isEmpty {
//                    locationManager.query = viewModel.defaultLocation
//                    hasSelectedLocation = true
                if locationManager.query.isEmpty {
                    print(viewModel.defaultLocation)
                        locationManager.query = viewModel.defaultLocation
                        hasSelectedLocation = true
                    
                }
            }
            .onChange(of: viewModel.defaultLocation) { _, newValue in
                if locationManager.query.isEmpty, !newValue.isEmpty {
                    locationManager.query = newValue
                    hasSelectedLocation = true
                    isSelecting = true
                }
            }
            .onChange(of: viewModel.notificationsEnabled) { _, newValue in
                if newValue {
                    NotificationManager.shared.requestPermission()

                    Task {
                        if let topEvent = await viewModel.fetchTopRecommendedEvent() {
                            NotificationManager.shared.sendLocalNotification(
                                title: "🔥 Рекомендована подія",
                                body: topEvent.localizedName
                            )
                        }
                    }
                }
            }


        }
    }
}

#Preview{
    SettingsView()
}

#Preview("ua"){
    SettingsView()
        .environment(\.locale, Locale(identifier: "uk"))
}
