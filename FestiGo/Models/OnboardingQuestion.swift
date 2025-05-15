//
//  OnboardingQuestion.swift
//  FestiGo
//
//  Created by kisellsn on 10/03/2025.
//
import UIKit

struct OnboardingQuestion: Codable, Identifiable {
    let id: Int
    let question: String
    let helperText: String?
    let subtitle: String?
    let inputType: InputType
    let options: [String]?
}
enum InputType: String, Codable {
    case multipleChoice
    case singleChoice
    case textInput
    case location
}

