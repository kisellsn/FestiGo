//
//  FullButtonView.swift
//  FestiGo
//
//  Created by kisellsn on 17/03/2025.
//

import SwiftUI

struct FullButtonView: View {
    let title: LocalizedStringResource
    let action: () -> Void
    let backgroundColor: Color
    let isDisabled: Bool
    let isLoading: Bool
    let iconName: String?
    let textColor: Color
    
    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                HStack {
                    if let iconName = iconName {
                        Image(systemName: iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(textColor)
                    }
            
                    Text(title)
                        .font(.headline)
                        .foregroundColor(textColor)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 50)
        .background(backgroundColor)
        .cornerRadius(10)
        .opacity(isDisabled ? 0.6 : 1.0)
        .padding(.horizontal, 30)
        .padding(.top, 10)
        .disabled(isDisabled)
    }
}


#Preview {
    FullButtonView(title: "Створити", action: {}, backgroundColor: .persianPink, isDisabled: false, isLoading: false, iconName: nil, textColor: .white);
}
