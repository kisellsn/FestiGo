//
//  QuestionView.swift
//  FestiGo
//
//  Created by kisellsn on 14/05/2025.
//

import SwiftUI

struct QuestionView: View {
    let question: OnboardingQuestion
    var selectedAnswers: [String]
    var onSelect: (String) -> Void

    @Binding var locationManager: LocationSearchManager
    @ObservedObject var locationFetcher: LocationFetcher

    var body: some View {
        VStack(spacing: 15) {


            // Пояснення
            if let helper = question.helperText {
                Text(helper)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            if let options = question.options {
                ForEach(options, id: \.self) { option in
                    ChoiceButton(
                        title: option,
                        isSelected: selectedAnswers.contains(option),
                        action: {
                            onSelect(option)
                        }
                    )
                }
            }
            

            if question.inputType == .location {
                LocationInputView(
                    query: $locationManager.query,
                    results: locationManager.results,
                    status: locationManager.status,
                    onLocationSelect: { selected in
                        locationManager.query = selected.title
                        locationManager.results = []
                        onSelect("\(selected.title), \(selected.subtitle)")
                    },
                    onDetectTap: {
                        locationFetcher.requestLocation { location in
                            locationManager.query = location
                            onSelect(location)
                        }
                    },
                    onQueryChange: {
                        // do nothing or refresh suggestions
                    }
                )
            }
        }
    }
}
#Preview {
    OnboardingView(onComplete: {})
}
