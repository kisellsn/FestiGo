//
//  CheckboxToggleStyle.swift
//  FestiGo
//
//  Created by kisellsn on 16/05/2025.
//

import SwiftUI


struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                configuration.label
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
