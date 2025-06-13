//
//  User.swift
//  FestiGo
//
//  Created by kisellsn on 11/03/2025.
//

import Foundation


struct User: Codable{
    let id: String
    let name: String
    let email: String
    let joined: TimeInterval
    let isAnonymous: Bool?
    let photoUrl: String?
    
    let isPremium: Bool?
    let preferences: [String]?
//    let favoriteEvents: [Event]?
    let profileImagePath: String?
    let profileImagePathUrl: String?
    let didCompleteOnboarding: Bool
    
    let premium: Bool
    let mainCategoryVector: [Double]?
    
    init(
        id: String,
        name: String,
        email: String,
        joined: TimeInterval,
        
        isAnonymous: Bool? = nil,
        photoUrl: String? = nil,
        isPremium: Bool? = nil,
        preferences: [String]? = nil,
//        favoriteEvents: [Event]? = nil,
        profileImagePath: String? = nil,
        profileImagePathUrl: String? = nil,
        mainCategoryVector: [Double]? = nil

    ) {
        self.id = id
        self.name = name
        self.email = email
        self.joined = joined
        
        self.isAnonymous = isAnonymous
        self.photoUrl = photoUrl
        self.isPremium = isPremium
        self.preferences = preferences
//        self.favoriteEvents = favoriteEvents
        self.profileImagePath = profileImagePath
        self.profileImagePathUrl = profileImagePathUrl
        self.didCompleteOnboarding = false
        
        self.premium = false
        self.mainCategoryVector = mainCategoryVector
    }
}
