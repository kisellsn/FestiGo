//
//  FieldView.swift
//  FestiGo
//
//  Created by kisellsn on 13/03/2025.
//

import SwiftUI

struct FieldView: View {
    let imageName: String
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    let borderColor: Color
    var textInputType: UIKeyboardType = .default
    var textAutocapitalization: TextInputAutocapitalization = .never
    
//    let errorMessage: String?
//    let showErrors: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5){
            HStack {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.black)
                    .padding(.leading, 10)
                
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .textInputAutocapitalization(textAutocapitalization)
                        .disableAutocorrection(true)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(textInputType)
                        .textInputAutocapitalization(textAutocapitalization)
                        .disableAutocorrection(true)
                }
                
                Spacer()
            }
            .frame(height: 50)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(borderColor, lineWidth: 2)
            )
            .padding(.horizontal, 30)
            
//            if let errorMessage = errorMessage,!errorMessage.isEmpty {
//                Text(errorMessage)
//                    .font(.caption)
//                    .foregroundColor(.red)
//                    .multilineTextAlignment(.leading)
//                    .padding(.leading, 30)
//            }
        }
    }
}


#Preview {
    @Previewable @State var userEmail: String = ""
    FieldView(imageName: "person", placeholder: "Name", text: $userEmail, isSecure: false, borderColor: .saffron, textAutocapitalization: .words)
}
