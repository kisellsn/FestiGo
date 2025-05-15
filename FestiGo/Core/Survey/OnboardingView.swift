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
        ZStack {
            Color.ultraViolet.ignoresSafeArea()

            VStack(spacing: 0) {
                // Верхня частина — фіолетовий фон із заголовком
                VStack(alignment: .leading, spacing: 16) {
                    // "Крок X з Y"
                    Text("Крок \(viewModel.currentStep + 1) з \(viewModel.questions.count)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.top, 5)
                        .padding(.horizontal)

                    VStack(spacing: 12) {
                        Text(viewModel.questions[viewModel.currentStep].question)
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)

                        if let subtitle = viewModel.questions[viewModel.currentStep].subtitle, !subtitle.isEmpty {
                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                }
                .padding(.bottom, 30)
                .background(
                    Color.ultraViolet
                        .edgesIgnoringSafeArea(.top)
                )


                Spacer(minLength: 0)
                

                // Нижня частина — білого кольору
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 20) {
                            QuestionView(
                                question: viewModel.questions[viewModel.currentStep],
                                selectedAnswers: viewModel.answers[viewModel.currentStep] ?? [],
                                onSelect: { option in
                                    viewModel.toggleAnswer(for: viewModel.currentStep, option: option)
                                },
                                locationManager: $locationManager,
                                locationFetcher: locationFetcher
                            )
                            .padding(.horizontal)
                            .padding(.top, 30)
                        }
                        .padding(.bottom, 150)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }

                    Spacer()
                }
                .background(
                    Color.white
                        .clipShape(RoundedCorner(radius: 30, corners: [.topLeft, .topRight]))
                        .edgesIgnoringSafeArea(.bottom)
                )
            }
            
            // Навігаційні кнопки (завжди внизу)
            VStack {
                Spacer()
                HStack(spacing: 15) {
                    if viewModel.currentStep > 0 {
                        Button("Назад") {
                            viewModel.previousQuestion()
                        }
                        .buttonStyle(OnboardingNavButtonStyle(color: .persianPink))
                        .cornerRadius(50)
                    }

                    Button(viewModel.isLastStep ? "Завершити" : "Далі") {
                        if viewModel.isLastStep {
                            viewModel.saveCurrentUserAnswers { success in
                                if success {
                                    onComplete()
                                }
                            }
                        } else {
                            viewModel.nextQuestion()
                        }
                    }
                    // TODO:
                    .disabled(!viewModel.isCurrentStepValid(with: locationManager))
                    .opacity(viewModel.isCurrentStepValid(with: locationManager) ? 1 : 0.5)
                    .buttonStyle(OnboardingNavButtonStyle(color: .ultraViolet))
                    .cornerRadius(50)
                }
                .padding(.top, 5)
                .padding(.horizontal)
                .padding(.bottom, 30)
                .background(Color.white.ignoresSafeArea(edges: .bottom))
            }
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
