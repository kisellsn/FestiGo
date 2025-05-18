//
//  LocationInputView.swift
//  FestiGo
//
//  Created by kisellsn on 15/04/2025.
//

import SwiftUI

struct LocationInputView: View {
    @Binding var query: String
    @Binding var hasSelectedLocation: Bool

    var results: [LocationResult]
    var status: SearchStatus
    var onLocationSelect: (LocationResult) -> Void
    var onDetectTap: () -> Void
    var onQueryChange: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button(action: onDetectTap) {
                    Image(systemName: "location.fill")
                        .foregroundColor(.ultraViolet)
                }

                TextField("Введіть ваше місто", text: $query)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .onChange(of: query) { _, newValue in
                        onQueryChange()
                    }
                    .overlay(
                        HStack {
                            Spacer()
                            if !query.isEmpty {
                                Button(action: {
                                    query = ""
                                    onQueryChange()
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 8)
                                }
                            }
                        }
                    )
            }
            .padding(.horizontal)
            if !hasSelectedLocation {
                switch status {
                case .searching:
                    HStack {
                        ProgressView()
                        Text("Пошук...")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                case .error(let message):
                    Label(message, systemImage: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                    
                case .result where results.isEmpty:
                    Text("Нічого не знайдено 😕")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                case .result where !results.isEmpty:
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(results.prefix(5)) { result in
                            Button(action: {
                                onLocationSelect(result)
                                hasSelectedLocation = true
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(result.title)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        if !result.subtitle.isEmpty {
                                            Text(result.subtitle)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.ultraViolet)
                                }
                                .padding(8)
                                .background(Color.ultraViolet.opacity(0.05))
                                .cornerRadius(10)
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .animation(.easeInOut, value: results)
                    .padding(.horizontal)
                default:
                    EmptyView()
                }
            }
        }
        .padding(.vertical)
    }
}
