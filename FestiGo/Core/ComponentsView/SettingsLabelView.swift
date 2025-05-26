//
//  SettingsLabelView.swift
//  FestiGo
//
//  Created by kisellsn on 24/04/2025.
//

import SwiftUI

struct SettingsLabelView: View {
    var labelText: LocalizedStringResource
    var labelImage: String
    
    var body: some View {
        HStack {
            Text(labelText)
                .fontWeight(.bold)
                .font(.system(.body, design: .monospaced))
            Spacer()
            Image(systemName: labelImage)
        }
    }
}
#Preview {
    SettingsLabelView(labelText: "String", labelImage: "paperplane.circle.fill")
}
