//
//  LocationInputView.swift
//  FestiGo
//
//  Created by kisellsn on 15/04/2025.
//

import SwiftUI

struct LocationInputView: View {
    @Binding var query: String
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

                TextField("Введіть місцезнаходження", text: $query)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: query) { _, _ in onQueryChange() }
            }
            .padding(.horizontal)

            switch status {
            case .searching:
                ProgressView().frame(maxWidth: .infinity)

            case .error(let message):
                Label(message, systemImage: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)

            case .result where !results.isEmpty:
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(results.prefix(3)) { result in
                        Button(action: { onLocationSelect(result) }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(result.title).foregroundColor(.primary)
                                    if !result.subtitle.isEmpty {
                                        Text(result.subtitle)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                            }
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)

            case .result where query.isEmpty:
                EmptyView()

            default:
                if !query.isEmpty {
                    Text("Збігів не знайдено")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
    }
}
