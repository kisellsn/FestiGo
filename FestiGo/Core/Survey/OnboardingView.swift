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
    @StateObject private var locationManager = LocationSearchManager()
    @StateObject private var locationFetcher = LocationFetcher()
    @State private var hasAgreedToTerms = false
    @State private var isChecked = false
    
    @State private var hasSelectedLocation = false
    @State private var isSelectingLocation = false

    var onComplete: () -> Void

    var body: some View {
        if !hasAgreedToTerms {
            firstPage
        } else {
            questionPage
        }
    }
    
    @ViewBuilder
    var firstPage: some View {
        ZStack {
            Image("bgPic")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            

            VStack(spacing: 30) {
                Spacer()

                VStack(spacing: 20) {
                    Text("Давайте познайомимось ближче!")
                        .font(.title)
                        .bold()
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.primary)
                        

                    Text("Ми задамо кілька питань, щоб персоналізувати ваш досвід користування FestiGo.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.primary.opacity(0.85))
                        .padding(.horizontal)
                        .padding(.top, 60)
                }

                Spacer()

                Toggle(isOn: $isChecked) {
                    HStack(spacing: 4) {
                        Text("Погоджуюсь з")
                        
                        Link("Terms & Privacy Policy",
                             destination: URL(string: "https://kisellsn.github.io/festigo-terms/")!)
                            .foregroundColor(.blue)
                            .underline()
                    }
                    .font(.footnote)
                    .foregroundColor(Color.secondary.opacity(0.7))
                }
                .toggleStyle(CheckboxToggleStyle())
                .padding(.horizontal)


                Button("Продовжити") {
                    hasAgreedToTerms = true
                }
                .disabled(!isChecked)
                .opacity(isChecked ? 1 : 0.5)
                .buttonStyle(OnboardingNavButtonStyle(color: .ultraViolet))
                .cornerRadius(50)
                .padding(.bottom, 20)
            }
            .padding()
            .padding(.bottom, 60)
        }
    }


    @ViewBuilder
    var questionPage: some View{
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
                        Text(LocalizedStringResource(stringLiteral: viewModel.questions[viewModel.currentStep].question))
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
                            questionBody
                            .padding(.horizontal)
                            .padding(.top, 30)
                        }
                        .padding(.bottom, 150)
                    }
                    .contentShape(Rectangle())
//                    .onTapGesture {
//                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//                    }

                    Spacer()
                }
                .background(
                    Color.myWhite
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
                .background(Color.myWhite.ignoresSafeArea(edges: .bottom))
            }
        }
    }
    @ViewBuilder
    var questionBody: some View {
        VStack(spacing: 15) {
            // Пояснення
            if let helper = viewModel.questions[viewModel.currentStep].helperText {
                Text(helper)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            let question = viewModel.questions[viewModel.currentStep]

            if let options = question.options {
                ForEach(options, id: \.self) { option  in
                    ChoiceButton(
                        title: option,
                        isSelected: viewModel.answers[viewModel.currentStep]?.contains(option) ?? false,
                        action: {
                            viewModel.toggleAnswer(for: viewModel.currentStep, option: option)
                        }
                    )
                }
            }

            if question.inputType == .location {
                LocationInputView(
                    query: $locationManager.query,
                    hasSelectedLocation: $hasSelectedLocation,
                    results: locationManager.results,
                    status: locationManager.status,
                    onLocationSelect: { selected in
                        isSelectingLocation = true
                        let full = "\(selected.title), \(selected.subtitle)"
                        locationManager.query = full
                        locationManager.results = []
                        hasSelectedLocation = true

                        Task {
                            if let coords = try? await locationManager.getCoordinates(for: full) {
                                viewModel.setLocationAnswer(for: viewModel.currentStep, title: full, coordinates: (coords.latitude, coords.longitude))
                            } else {
                                viewModel.setLocationAnswer(for: viewModel.currentStep, title: full, coordinates: nil)
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isSelectingLocation = false
                            }
                        }
                    },
                    onDetectTap: {
                        locationFetcher.requestLocation { location in
                            locationManager.query = location
                            viewModel.toggleAnswer(for: viewModel.currentStep, option: location)
                            hasSelectedLocation = true
                        }
                    },
                    onQueryChange: {
                        if !isSelectingLocation {
                            hasSelectedLocation = false
                        }
                    }
                )
                .zIndex(1)
            }
        }
    }

}

#Preview {
    OnboardingView(onComplete: {})
}
