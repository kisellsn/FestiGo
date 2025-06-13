//
//  ProfileViewModel.swift
//  FestiGo
//
//  Created by kisellsn on 17/03/2025.
//
import FirebaseAuth
import FirebaseFirestore
import Foundation
import GoogleSignIn

struct InterestProfile {
    let category: LocalizedStringResource
    let score: Double
    let description: LocalizedStringResource
    let emoji: String
}

class ProfileViewModel: ObservableObject {
    @Published var user: User? = nil
    
    func fetchUser() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else { return }
            
            //  main_categories 
            let profileVectors = data["component_profile_vectors"] as? [String: Any]
            let rawScores = profileVectors?["main_categories"] as? [NSNumber] ?? []

            // -> [Double]
            let vector = rawScores.map { $0.doubleValue }

            DispatchQueue.main.async {
                self.user = User(
                    id: data["id"] as? String ?? "",
                    name: data["name"] as? String ?? "",
                    email: data["email"] as? String ?? "",
                    joined: data["joined"] as? TimeInterval ?? 0,
                    photoUrl: data["photoUrl"] as? String,
                    isPremium: data["premium"] as? Bool ?? false,
                    mainCategoryVector: vector
                )
            }
        }
    }
    
    func logOut() {
        do {
            GIDSignIn.sharedInstance.signOut()
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
    }
    
    
    var culturalProfile: [InterestProfile] {
        let staticDefinitions: [InterestProfile] = [
            InterestProfile(category: "Музика", score: 0, description: "У твоєму серці завжди звучить музика ", emoji: "🎶"),
            InterestProfile(category: "Театр", score: 0, description: "Ти цінуєш глибокі історії й живі емоції сцени ", emoji: "🎭"),
            InterestProfile(category: "Фестивалі", score: 0, description: "Тебе надихає атмосфера великих подій і спільноти ", emoji: "🎡"),
            InterestProfile(category: "Виставки", score: 0, description: "Ти знаходиш натхнення в мистецтві й деталях ", emoji: "🖼️"),
            InterestProfile(category: "Кіно", score: 0, description: "Ти любиш історії, що залишають слід у душі ", emoji: "🎬"),
            InterestProfile(category: "Освіта", score: 0, description: "Твій шлях — це постійне пізнання й розвиток ", emoji: "📚"),
            InterestProfile(category: "Спорт", score: 0, description: "Твоя енергія та рух — це стиль життя ", emoji: "⚡"),
        ]

        
        guard let rawScores = user?.mainCategoryVector, rawScores.count >= staticDefinitions.count else {
            return []
        }

        let profiles: [InterestProfile] = zip(staticDefinitions, rawScores).map { (definition, score) in
            InterestProfile(
                category: definition.category,
                score: score,
                description: definition.description,
                emoji: definition.emoji
            )
        }

        return profiles
    }


    func scaledRadarScores(from scores: [Double]) -> [Double] {
        let adjusted = scores.map { log($0 + 1e-6) }
        let minLog = adjusted.min() ?? 0.0
        let maxLog = adjusted.max() ?? 1.0
        let range = maxLog - minLog

        let normalized = adjusted.map { ($0 - minLog) / (range == 0 ? 1 : range) }

        let minVisual: Double = 0.15
        return normalized.map { $0 * (1 - minVisual) + minVisual }
    }
    var radarScores: [Double] {
        scaledRadarScores(from: culturalProfile.map { $0.score })
    }



    var radarLabels: [String] {
        culturalProfile.map { $0.emoji }
    }

    var topCategory: InterestProfile? {
        culturalProfile.max(by: { $0.score < $1.score })
    }

}

