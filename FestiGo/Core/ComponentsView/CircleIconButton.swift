//
//  HeartButton.swift
//  FestiGo
//
//  Created by kisellsn on 22/04/2025.
//

import SwiftUI


struct CircleIconButton: View {
    let systemImageName: String
    var foregroundColor: Color = .primary
    var backgroundColor: Color = .white
    var shadowRadius: CGFloat = 5
    var size: CGFloat = 24
    var isFilled: Bool = false

    var action: (() -> Void)?

    var body: some View {
        Button(action: {
            action?()
        }) {
            Image(systemName: systemImageName)
                .font(.system(size: size))
                .padding()
                .background(backgroundColor)
                .clipShape(Circle())
                .shadow(radius: shadowRadius)
                .foregroundStyle(foregroundColor)
        }
    }
}

struct HeartButton: View {
    @Binding var isLiked: Bool
    var onTap: (() -> Void)?

    var body: some View {
        CircleIconButton(
            systemImageName: isLiked ? "heart.fill" : "heart",
            foregroundColor: .burgundy,
            action: {
                onTap?()
            }
        )
    }
}
