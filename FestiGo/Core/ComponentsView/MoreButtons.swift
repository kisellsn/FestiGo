//
//  MoreButtons.swift
//  FestiGo
//
//  Created by kisellsn on 15/04/2025.
//

import Foundation
import SwiftUI

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}



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
            Text(LocalizedStringResource(stringLiteral: title))
                .padding()
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.accentColor.opacity(0.8) : .myWhite)
                .foregroundColor(isSelected ? Color.white : Color.primary)
                .cornerRadius(50)
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
        }
        .padding(.vertical, 4)
    }
}


struct AuthButton: View {
    var label: LocalizedStringResource
    var icon: String? = nil
    var imageName: String? = nil

    var body: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .frame(width: 20, height: 20)
            }
            if let imageName = imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }
            Spacer()
            Text(label)
                .font(.headline)
            Spacer()
        }
        .foregroundColor(.primary)
        .padding()
        .background(Color.myWhite)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

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
struct OnboardingNavButtonStyle: ButtonStyle {
    var color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(color)
            .foregroundColor(.white)
            .font(.headline)
            .cornerRadius(16)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
