//
//  MoreButtons.swift
//  FestiGo
//
//  Created by kisellsn on 15/04/2025.
//

import Foundation
import SwiftUI


struct NavButtonStyle: ViewModifier {
    var background: Color

    func body(content: Content) -> some View {
        content
            .padding()
            .background(background)
            .cornerRadius(10)
            .foregroundColor(.white)
    }
}

struct ChoiceButton: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.ultraViolet.opacity(0.7) : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .black)
                .cornerRadius(10)
        }
        .padding(.vertical, 4)
    }
}
