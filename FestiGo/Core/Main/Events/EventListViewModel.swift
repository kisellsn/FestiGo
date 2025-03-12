//
//  EventListViewModel.swift
//  FestiGo
//
//  Created by kisellsn on 16/04/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

import Combine

@MainActor
class EventListViewModel: ObservableObject {
    @Published private(set) var events: [Event] = []
    private var lastDocument: DocumentSnapshot? = nil

    @Published var selectedCategories: [String]? = nil
    @Published var isOnline: TypeOption? = nil         // nil = all, true = only online, false = only offline
    @Published var selectedCity: CityOption = .all
    @Published var allCitiesMap: [String: CLLocationCoordinate2D?] = [:]

    @Published var startDate: Date? = nil
    @Published var endDate: Date? = nil
    @Published var dateRange: ClosedRange<Date>? {
        didSet {
            getEvents(reset: true) 
        }
    }
    
//    private var firestoreListener: ListenerRegistration? = nil
//    private var cancellables = Set<AnyCancellable>()
//
//    init() {
//        observeFilters()
//    }
    init() {
        fetchAllCities()
        print(self.allCitiesMap)
        Task {
            await applyUserDefaultCity()
        }
    }

        
    func updateDateRange() {
        if let start = startDate, let end = endDate {
            dateRange = start...end
        }
    }
    
    @Published var selectedEventOnly: Event? = nil
    
    //MARK: - Category filter

    enum CategoryOption: String, CaseIterable {
        case all
        case music
        case show
        case festival
        case exhibition
        case cinema
        case education
        case sport
        
        var label: String {
            switch self {
                case .all: return "Все"
                case .music: return "Музика"
                case .show: return "Вистави/Театр"
                case .festival: return "Фестивалі"
                case .exhibition: return "Виставки"
                case .cinema: return "Кіно"
                case .education: return "Освіта"
                case .sport: return "Спорт/Активний відпочинок"
            }
        }
    }
    func categorySelected(option: CategoryOption) async throws {
        if option == .all {
            selectedCategories = nil
        } else {
            if selectedCategories == nil {
                selectedCategories = [option.rawValue]
            } else if selectedCategories!.contains(option.rawValue) {
                selectedCategories!.removeAll { $0 == option.rawValue }
                if selectedCategories!.isEmpty {
                    selectedCategories = nil
                }
            } else {
                selectedCategories!.append(option.rawValue)
            }
        }

        self.events = []
        self.lastDocument = nil
        self.getEvents(reset: true)
    }

    //MARK: - Type filter

    enum TypeOption: String, CaseIterable {
        case noType = "Усі"
        case online = "Онлайн"
        case offline = "Офлайн"
        
        var typeKey: Bool? {
            switch self {
            case .noType: return nil
            case .online: return true
            case .offline: return false
            }
        }
    }
    func typeSelected(option: TypeOption) async throws {
        self.isOnline = option
        self.events = []
        self.lastDocument = nil
        self.getEvents(reset: true)
        
    }

    //MARK: - City filter
    enum CityOption: Equatable {
        case all
        case named(String)
        
        var value: String? {
            switch self {
            case .all: return nil
            case .named(let name): return name
            }
        }

        var label: String {
            switch self {
            case .all: return "Усі"
            case .named(let name): return name
            }
        }

        static func == (lhs: CityOption, rhs: CityOption) -> Bool {
            return lhs.value == rhs.value
        }
    }

//
//    var allCities: [String] {
//        Set(events.map { $0.city }).sorted()
//    }
    func fetchAllCities() {
        Task {
            do {
                self.allCitiesMap = try await EventsManager.shared.getAllCities()
//                print(self.allCitiesMap)
            } catch {
                print("Error fetching cities: \(error)")
            }
        }
    }
    
    func citySelected(option: CityOption) async throws {
        self.selectedCity = option
        self.events = []
        self.lastDocument = nil
        self.getEvents(reset: true)
    }
   
    func applyUserDefaultCity() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        do {
            let (userCity, userRadius) = try await UserManager.shared.getUserCityAndRadiusFromOnboardingResponses(userId: userId)

            guard let userCity = userCity else {
                try? await citySelected(option: .all)
                return
            }

            var userCoord: CLLocationCoordinate2D?

            if let coord = allCitiesMap[userCity] {
                userCoord = coord
            } else {
                do {
                    userCoord = try await LocationSearchManager.shared.getCoordinates(for: userCity)
                } catch {
                    print("Failed to geocode city: \(error.localizedDescription)")
                    try? await citySelected(option: .all)
                    return
                }
            }

            guard let finalUserCoord = userCoord else {
                try? await citySelected(option: .all)
                return
            }

            let nearbyCities = allCitiesMap.compactMap { city, optionalCoord -> (String, CLLocationDistance)? in
                guard let coord = optionalCoord, let radius = userRadius else { return nil }
                let distance = calculateDistance(from: finalUserCoord, to: coord)
                return distance <= radius ? (city, distance) : nil
            }

            if let closestCity = nearbyCities.min(by: { $0.1 < $1.1 }) {
                try await citySelected(option: .named(closestCity.0))
            } else {
                try await citySelected(option: .all)
            }

        } catch {
            print("❌ Failed to apply city filter: \(error)")
            try? await citySelected(option: .all)
        }
    }



    func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let loc1 = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let loc2 = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return loc1.distance(from: loc2) / 1000.0
    }

    
   
    //MARK: - load
    var filteredEvents: [Event] {
       if let selectedOnly = selectedEventOnly {
           return [selectedOnly]
       }

       return events
   }
    
    func loadMockData() {
        events = MockEvents.loadEvents()
    }
    
//    func addListenerForEvents() {
//        guard let userId = Auth.auth().currentUser?.uid else { return }
//
////        UserManager.shared.addListenerForAllUserFavoriteProducts(userId: authDataResult.uid) { [weak self] products in
////            self?.userFavoriteProducts = products
////        }
//        
//        EventsManager.shared.addListenerForAllEvents(completion: userId)
//            .sink { completion in
//                
//            } receiveValue: { [weak self] products in
//                self?.userFavoriteProducts = products
//            }
//            .store(in: &cancellables)
//
//    }

    func getEvents(reset: Bool = false) {
        Task {
            do {
                if reset {
                        self.events = []
                        self.lastDocument = nil
                }

                let (newEvents, lastDocument) = try await EventsManager.shared.getAllEvents(
                    selectedCategories: selectedCategories,
                    city: selectedCity.value,
                    isOnline: isOnline?.typeKey,
                    startDate: startDate,
                    endDate: endDate,
                    count: 10,
                    lastDocument: lastDocument
                )

                self.events.append(contentsOf: newEvents)
                if let lastDocument {
                    self.lastDocument = lastDocument
                }
            } catch {
                print("Error fetching events: \(error)")
            }
        }
    }
    
    func getUserRecommendations() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in.")
            return
        }

        guard let token = TokenManager.load() else {
            print("Failed to load token.")
            return
        }

        // Створюємо запит на сервер
        let urlString = "\(TokenManager.serverBaseUrl ?? "")/get_recommendations"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Додаємо параметри до запиту (user_id)
        let queryItems = [URLQueryItem(name: "user_id", value: userId)]
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems
        guard let finalUrl = components?.url else { return }
        
        request.url = finalUrl

        // Відправляємо запит
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error getting recommendations: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ No data received.")
                return
            }

            do {
                // Декодуємо рекомендації з відповіді сервера
                let recommendationsResponse = try JSONDecoder().decode([String: [String]].self, from: data)
                if let recommendations = recommendationsResponse["recommendations"] {
                    // Збереження або використання отриманих рекомендацій
                    DispatchQueue.main.async {
                        self.handleRecommendations(recommendations)
                    }
                } else {
                    print("❌ No recommendations found.")
                }
            } catch {
                print("❌ Failed to decode recommendations: \(error.localizedDescription)")
            }
        }.resume()
    }

    private func handleRecommendations(_ recommendations: [String]) {
        // Обробка рекомендацій, наприклад, оновлення внутрішнього стану для відображення на UI
        print("Received recommendations: \(recommendations)")
    }


    
}

