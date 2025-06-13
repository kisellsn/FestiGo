//
//  OnboardingViewModel.swift
//  FestiGo
//
//  Created by kisellsn on 10/03/2025.
//
import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseMessaging

class OnboardingViewModel: ObservableObject {
    @Published var currentStep = 0
    @Published var answers: [Int: [String]] = [:]
    @Published var questions: [OnboardingQuestion] = []
    @Published var selectedLocationCoordinates: (lat: Double, lon: Double)? = nil

    init() {
        loadQuestions()
    }

    func loadQuestions() {
        if let url = Bundle.main.url(forResource: "questions", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let loadedQuestions = try? JSONDecoder().decode([OnboardingQuestion].self, from: data) {
            self.questions = loadedQuestions
        } else {
            print("Failed to load onboarding questions")
        }
    }

    func toggleAnswer(for step: Int, option: String) {
        let inputType = questions[step].inputType
        switch inputType {
        case .multipleChoice:
            var currentAnswers = answers[step] ?? []
            if currentAnswers.contains(option) {
                currentAnswers.removeAll { $0 == option }
            } else {
                currentAnswers.append(option)
            }
            answers[step] = currentAnswers
        case .singleChoice:
            answers[step] = [option]
        default:
            break
        }
    }

    func setLocationAnswer(for step: Int, title: String, coordinates: (Double, Double)?) {
        answers[step] = [title]
        if step == 3 {
            selectedLocationCoordinates = coordinates
        }
    }

    func nextQuestion() {
        if currentStep < questions.count - 1 {
            currentStep += 1
        }
    }

    func previousQuestion() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }

    func finalAnswers() -> [String: Any] {
        var result: [String: Any] = [:]

        for question in questions {
            if let answer = answers[question.id] {
                result["\(question.id)"] = answer
            }
        }

        if let location = answers[3]?.first {
            var locationDict: [String: Any] = ["title": location]
            if let coords = selectedLocationCoordinates {
                locationDict["lat"] = coords.lat
                locationDict["lon"] = coords.lon
            }
            result["3"] = [locationDict]
        }

        return result
    }

    func saveCurrentUserAnswers(completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in.")
            completion(false)
            return
        }

        saveAnswers(for: userId, answers: finalAnswers(), completion: completion)
    }

    func saveAnswers(for userId: String, answers: [String: Any], completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let responseData: [String: Any] = [
            "userId": userId,
            "timestamp": Date().timeIntervalSince1970,
            "answers": answers
        ]

        db.collection("onboardingResponses")
            .document(userId)
            .setData(responseData) { error in
                if let error = error {
                    print("Failed to save answers:", error.localizedDescription)
                    completion(false)
                } else {
                    print("Answers saved!")
                    completion(true)
                }

                TokenManager.shared.sendUserIdToBackend(userId)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    UserProfileService.shared.initProfile()
                }
            }
    }

    func isSelected(step: Int, option: String) -> Bool {
        return answers[step]?.contains(option) ?? false
    }

    func isCurrentStepValid(with locationManager: LocationSearchManager? = nil) -> Bool {
        let question = questions[currentStep]

        switch question.inputType {
        case .multipleChoice, .singleChoice:
            return answers[currentStep]?.isEmpty == false
        case .textInput:
            let text = answers[currentStep]?.first ?? ""
            return !text.trimmingCharacters(in: .whitespaces).isEmpty
        case .location:
            guard let locationManager = locationManager else { return false }
            let query = locationManager.query.trimmingCharacters(in: .whitespaces)
            let savedAnswer = answers[currentStep]?.first ?? ""
            return !query.isEmpty && query == savedAnswer && query.isSafeInput
        }
    }
}

extension OnboardingViewModel {
    var isLastStep: Bool {
        currentStep == questions.count - 1
    }
}
