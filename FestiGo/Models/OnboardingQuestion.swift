//
//  OnboardingQuestion.swift
//  FestiGo
//
//  Created by kisellsn on 10/03/2025.
//
import UIKit

struct OnboardingQuestion: Codable {
    let id: Int
    let question: String
    let options: [String]?
    let inputType: InputType
}

enum InputType: String, Codable {
    case multipleChoice
    case singleChoice
    case textInput
    case location
}

