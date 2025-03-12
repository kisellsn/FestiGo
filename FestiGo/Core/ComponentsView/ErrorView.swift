//
//  ErrorView.swift
//  FestiGo
//
//  Created by kisellsn on 08/04/2025.
//


import SwiftUI

enum AuthError: Error {
    case custom(String)
}

struct ErrorView: View {
    let message: String
//    var backgroundColor: Color = .white
    var foregroundColor: Color = .burgundy
    
    var body: some View {
        Text(message)
            .frame(maxWidth: .infinity)
//            .background(backgroundColor)
            .foregroundColor(foregroundColor)
//            .cornerRadius(12)
//            .shadow(radius: 5)
//            .padding(.horizontal, 16)
//            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.easeInOut(duration: 0.3), value: message)
            .multilineTextAlignment(.leading)
            .font(.caption)
//            .opacity(0.7)
            
    }
}

#Preview {
    ErrorView(message: "error")
}
