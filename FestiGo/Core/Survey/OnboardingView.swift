//
//  OnboardingView.swift
//  FestiGo
//
//  Created by kisellsn on 10/03/2025.
//


import CoreLocation
import SwiftUI
import FirebaseAuth

struct OnboardingView: View {
    @StateObject var viewModel = OnboardingViewModel()
    @State var locationManager = LocationSearchManager()
    @StateObject private var locationFetcher = LocationFetcher()
    
    var onComplete: () -> Void
    
    var body: some View {
        VStack {
            // Question
            Text(viewModel.questions[viewModel.currentStep].question)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()

            let question = viewModel.questions[viewModel.currentStep]

            // Options (if any)
            if let options = question.options {
                ForEach(options, id: \.self) { option in
                    ChoiceButton(
                        title: option,
                        isSelected: viewModel.isSelected(step: viewModel.currentStep, option: option)
                    ) {
                        viewModel.toggleAnswer(for: viewModel.currentStep, option: option)
                    }
                }
            }

            // Location Input
            if question.inputType == .location {
                LocationInputView(
                    query: $locationManager.query,
                    results: locationManager.results,
                    status: locationManager.status,
                    onLocationSelect: { selected in
                        locationManager.query = selected.title
                        viewModel.answers[viewModel.currentStep] = ["\(selected.title), \(selected.subtitle)"]
                        locationManager.results = []
                        print(viewModel.answers)
                    },
                    onDetectTap: {
                        locationFetcher.requestLocation { detectedLocation in
                            locationManager.query = detectedLocation
                            viewModel.answers[viewModel.currentStep] = [detectedLocation]
                        }
                        print(viewModel.answers)
                    },
                    onQueryChange: {
//                        viewModel.answers[viewModel.currentStep] = []
                        print(viewModel.answers)
                    }
                )
            }

            // Navigation buttons
            HStack {
                if viewModel.currentStep > 0 {
                    Button("Назад") {
                        viewModel.previousQuestion()
                    }
                    .modifier(NavButtonStyle(background: .persianPink))
                }

                Spacer()

                Button(viewModel.currentStep == viewModel.questions.count - 1 ? "Завершити" : "Далі") {
                    if viewModel.currentStep == viewModel.questions.count - 1 {
                        viewModel.saveCurrentUserAnswers { success in
                            if success {
                                onComplete()
                            } else {
                                print("Saving failed.")
                            }
                        }
                    } else {
                    viewModel.nextQuestion()
                    }
                }
                .disabled(!viewModel.isCurrentStepValid())
                .opacity(viewModel.isCurrentStepValid() ? 1.0 : 0.5)
                .modifier(NavButtonStyle(background: .ultraViolet))
            }
            .padding(.top)
        }
        .padding()
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
