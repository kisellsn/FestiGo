//
//  LanguageManager.swift
//  FestiGo
//
//  Created by kisellsn on 19/05/2025.
//


import SwiftUI

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    @AppStorage("appLanguage") var selectedLanguage: String = Locale.current.language.languageCode?.identifier ?? "en" {
        didSet {
            Bundle.setLanguage(selectedLanguage)
            objectWillChange.send()
        }
    }

    func toggleLanguage() {
        selectedLanguage = selectedLanguage == "uk" ? "en" : "uk"
    }

    var displayLanguage: String {
        selectedLanguage.uppercased()
    }
}

extension LanguageManager {
    static var currentCityFieldName: String {
        return shared.selectedLanguage == "uk" ? "city_uk" : "city"
    }
}
