//
//  Movie.swift
//  FestiGo
//
//  Created by kisellsn on 04/04/2025.
//


import Foundation
import FirebaseFirestore


struct UserFavouriteEvent: Codable {
    let eventId: String
    let dateCreated: Date
    
    enum CodingKeys: String, CodingKey {
        case eventId = "id"
        case dateCreated = "date_created"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.eventId = try container.decode(String.self, forKey: .eventId)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.eventId, forKey: .eventId)
        try container.encode(self.dateCreated, forKey: .dateCreated)
    }
    
}

 
final class UserManager {
    
    static let shared = UserManager()
    private init() { }
    
    private let userCollection: CollectionReference = Firestore.firestore().collection("users")
    private let onboardingResponsesCollection: CollectionReference = Firestore.firestore().collection("onboardingResponses")

    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    private func onboardingResponsesDocument(userId: String) -> DocumentReference {
        onboardingResponsesCollection.document(userId)
    }
    
    private func userFavouriteEventsCollection(userId: String) -> CollectionReference {
        userDocument(userId: userId).collection("favourite_events")
    }
    
    private func userFavouriteEventDocument(userId: String, eventId: String) -> DocumentReference {
        userFavouriteEventsCollection(userId: userId).document(eventId)
    }
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        //        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        //        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    func getUserCityAndRadiusFromOnboardingResponses(userId: String) async throws -> (city: String?, radius: Double?) {
        let snapshot = try await onboardingResponsesCollection
            .whereField("userId", isEqualTo: userId)
            .limit(to: 1)
            .getDocuments()

        guard let data = snapshot.documents.first?.data(),
              let answers = data["answers"] as? [String: Any] else {
            print("Failed to parse answers")
            return (nil, nil)
        }

        var city: String? = nil
        if let cityArray = answers["3"] as? [[String: Any]],
           let firstCity = cityArray.first,
           let title = firstCity["title"] as? String {
            city = title
        }

        var radius: Double? = nil
        if let radiusArray = answers["4"] as? [String],
           let radiusString = radiusArray.first {
            let digitsOnly = radiusString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            radius = Double(digitsOnly) ?? 50
        }

        return (city, radius)
    }

    func addUserFavouriteEvent(userId: String, eventId: String) async throws {
        let document = userFavouriteEventsCollection(userId: userId).document(eventId)

        let data: [String:Any] = [
            UserFavouriteEvent.CodingKeys.eventId.rawValue : eventId,
            UserFavouriteEvent.CodingKeys.dateCreated.rawValue : Timestamp()
        ]
        
        try await document.setData(data, merge: false)
    }
    
    func removeUserFavouriteEvent(userId: String, eventId: String) async throws {
        try await userFavouriteEventDocument(userId: userId, eventId: eventId).delete()
    }
    
    func getAllUserFavouriteEvents(userId: String) async throws -> [UserFavouriteEvent] {
        try await userFavouriteEventsCollection(userId: userId).getDocuments(as: UserFavouriteEvent.self)
    }
    func areFavouritesExist(userId: String) async throws -> Bool {
        let snapshot = try await userFavouriteEventsCollection(userId: userId)
            .limit(to: 1)
            .getDocuments()
        
        return !snapshot.documents.isEmpty
    }

    
    func getUser(userId: String) async throws -> User {
        try await userDocument(userId: userId).getDocument(as: User.self)
    }
    func getOnboardingResponses(userId: String) async throws  {
        try await onboardingResponsesDocument(userId: userId).getDocument()
    }
    func isOnboardingCompleted(userId: String) async throws -> Bool {
        let snapshot = try await userDocument(userId: userId).getDocument()

        guard let data = snapshot.data() else {
            print("🛑 User document not found for user \(userId)")
            return false
        }

        let didComplete = data["didCompleteOnboarding"] as? Bool ?? false

        if didComplete {
            print("✅ User \(userId) has completed onboarding")
        } else {
            print("🚫 User \(userId) has NOT completed onboarding")
        }

        return didComplete
    }
    
//    func getUser(userId: String) async throws -> DBUser {
//        let snapshot = try await userDocument(userId: userId).getDocument()
//
//        guard let data = snapshot.data(), let userId = data["user_id"] as? String else {
//            throw URLError(.badServerResponse)
//        }
//
//        let isAnonymous = data["is_anonymous"] as? Bool
//        let email = data["email"] as? String
//        let photoUrl = data["photo_url"] as? String
//        let dateCreated = data["date_created"] as? Date
//
//        return User(userId: userId, isAnonymous: isAnonymous, email: email, photoUrl: photoUrl, dateCreated: dateCreated)
//    }
}
//
//    private var userFavoriteProductsListener: ListenerRegistration? = nil
//    
//    func createNewUser(user: DBUser) async throws {
//        try userDocument(userId: user.userId).setData(from: user, merge: false)
//    }
    
//    func createNewUser(auth: AuthDataResultModel) async throws {
//        var userData: [String:Any] = [
//            "user_id" : auth.uid,
//            "is_anonymous" : auth.isAnonymous,
//            "date_created" : Timestamp(),
//        ]
//        if let email = auth.email {
//            userData["email"] = email
//        }
//        if let photoUrl = auth.photoUrl {
//            userData["photo_url"] = photoUrl
//        }
//
//        try await userDocument(userId: auth.uid).setData(userData, merge: false)
//    }
    
    
    
//
    
//    func updateUserPremiumStatus(user: DBUser) async throws {
//        try userDocument(userId: user.userId).setData(from: user, merge: true)
//    }
    
//    func updateUserPremiumStatus(userId: String, isPremium: Bool) async throws {
//        let data: [String:Any] = [
//            DBUser.CodingKeys.isPremium.rawValue : isPremium,
//        ]
//
//        try await userDocument(userId: userId).updateData(data)
//    }
//    
//    func updateUserProfileImagePath(userId: String, path: String?, url: String?) async throws {
//        let data: [String:Any] = [
//            DBUser.CodingKeys.profileImagePath.rawValue : path,
//            DBUser.CodingKeys.profileImagePathUrl.rawValue : url,
//        ]
//
//        try await userDocument(userId: userId).updateData(data)
//    }
//    
//    func addUserPreference(userId: String, preference: String) async throws {
//        let data: [String:Any] = [
//            DBUser.CodingKeys.preferences.rawValue : FieldValue.arrayUnion([preference])
//        ]
//
//        try await userDocument(userId: userId).updateData(data)
//    }
//    
//    func removeUserPreference(userId: String, preference: String) async throws {
//        let data: [String:Any] = [
//            DBUser.CodingKeys.preferences.rawValue : FieldValue.arrayRemove([preference])
//        ]
//
//        try await userDocument(userId: userId).updateData(data)
//    }
//    
//    func addFavoriteMovie(userId: String, movie: Movie) async throws {
//        guard let data = try? encoder.encode(movie) else {
//            throw URLError(.badURL)
//        }
//        
//        let dict: [String:Any] = [
//            DBUser.CodingKeys.favoriteMovie.rawValue : data
//        ]
//
//        try await userDocument(userId: userId).updateData(dict)
//    }
//    
//    func removeFavoriteMovie(userId: String) async throws {
//        let data: [String:Any?] = [
//            DBUser.CodingKeys.favoriteMovie.rawValue : nil
//        ]
//
//        try await userDocument(userId: userId).updateData(data as [AnyHashable : Any])
//    }
//    
//
//    
//    func removeListenerForAllUserFavoriteProducts() {
//        self.userFavoriteProductsListener?.remove()
//    }
//    
//    func addListenerForAllUserFavoriteProducts(userId: String, completion: @escaping (_ products: [UserFavoriteProduct]) -> Void) {
//        self.userFavoriteProductsListener = userFavoriteProductCollection(userId: userId).addSnapshotListener { querySnapshot, error in
//            guard let documents = querySnapshot?.documents else {
//                print("No documents")
//                return
//            }
//            
//            let products: [UserFavoriteProduct] = documents.compactMap({ try? $0.data(as: UserFavoriteProduct.self) })
//            completion(products)
//            
//            querySnapshot?.documentChanges.forEach { diff in
//                if (diff.type == .added) {
//                    print("New products: \(diff.document.data())")
//                }
//                if (diff.type == .modified) {
//                    print("Modified products: \(diff.document.data())")
//                }
//                if (diff.type == .removed) {
//                    print("Removed products: \(diff.document.data())")
//                }
//            }
//        }
//    }
    
//    func addListenerForAllUserFavoriteProducts(userId: String) -> AnyPublisher<[UserFavoriteProduct], Error> {
//        let publisher = PassthroughSubject<[UserFavoriteProduct], Error>()
//
//        self.userFavoriteProductsListener = userFavoriteProductCollection(userId: userId).addSnapshotListener { querySnapshot, error in
//            guard let documents = querySnapshot?.documents else {
//                print("No documents")
//                return
//            }
//
//            let products: [UserFavoriteProduct] = documents.compactMap({ try? $0.data(as: UserFavoriteProduct.self) })
//            publisher.send(products)
//        }
//
//        return publisher.eraseToAnyPublisher()
//    }
//    func addListenerForAllUserFavoriteProducts(userId: String) -> AnyPublisher<[UserFavoriteProduct], Error> {
//        let (publisher, listener) = userFavoriteProductCollection(userId: userId)
//            .addSnapshotListener(as: UserFavoriteProduct.self)
//        
//        self.userFavoriteProductsListener = listener
//        return publisher
//    }
//    
//}
//import Combine
//
//struct UserFavoriteProduct: Codable {
//    let id: String
//    let productId: Int
//    let dateCreated: Date
//    
//    enum CodingKeys: String, CodingKey {
//        case id = "id"
//        case productId = "product_id"
//        case dateCreated = "date_created"
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.id = try container.decode(String.self, forKey: .id)
//        self.productId = try container.decode(Int.self, forKey: .productId)
//        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(self.id, forKey: .id)
//        try container.encode(self.productId, forKey: .productId)
//        try container.encode(self.dateCreated, forKey: .dateCreated)
//    }
//    
//}
