//
//  SingUpEmailView.swift
//  FestiGo
//
//  Created by kisellsn on 13/03/2025.
//

import SwiftUI

struct SingUpEmailView: View {
    @StateObject private var viewModel = SignUpEmailViewModel(userValidator: UserValidator())
    
    var body: some View {
        VStack {
            Spacer()
            Image(uiImage: #imageLiteral(resourceName: "singUpEmailPic"))
                .resizable()
                .scaledToFit()
            
            Spacer()
            
            Text("Реєстрація")
                .font(.title)
                .fontWeight(.semibold)
                .padding(.top, 20)
                .padding(.bottom, 20)
            
            FieldView(imageName: "person", placeholder: "Name", text: $viewModel.userValidator.name, isSecure: false, borderColor: .persianPink, textAutocapitalization: .words)
            
            FieldView(imageName: "at", placeholder: "Email", text: $viewModel.userValidator.email, isSecure: false, borderColor: .persianPink, textInputType: .emailAddress)
                            
            FieldView(imageName: "lock", placeholder: "Password", text: $viewModel.userValidator.password, isSecure: true, borderColor: .persianPink)
            
            if !viewModel.errorMessage.isEmpty {
                ErrorView(message: viewModel.errorMessage, foregroundColor:.burgundy)
            }
            Button(action: {
                viewModel.register()
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Створити")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.persianPink)
            .cornerRadius(10)
            .opacity(viewModel.userValidator.isLoginBtnDisabled ? 0.6 : 1.0)
            .padding(.horizontal, 30)
            .padding(.top, 10)
            .disabled(viewModel.userValidator.isLoginBtnDisabled)
        }
        .padding()
        .padding(.bottom, 50)
    }
}

#Preview {
    SingUpEmailView()
}
