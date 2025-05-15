//
//  SignInEmailView.swift
//  FestiGo
//
//  Created by kisellsn on 13/03/2025.
//


import SwiftUI

struct SignInEmailView: View {
    @StateObject private var viewModel = SignInEmailViewModel(userValidator: UserValidator())
    
//    init(viewModel: SignInEmailViewModel = SignInEmailViewModel(userValidator: UserValidator())) {
//           _viewModel = StateObject(wrappedValue: viewModel)
//       }
       
    
    var body: some View {
    
        VStack {
            Spacer()
            Image(uiImage: #imageLiteral(resourceName: "singInEmailPic.jpg"))
                .resizable()
                .scaledToFit()
            
            Spacer()
            
            Text("Вхід у акаунт")
                .font(.title)
                .fontWeight(.semibold)
                .padding(.top, 20)
                .padding(.bottom, 20)
            
            
            FieldView(imageName: "at", placeholder: "Email", text: $viewModel.userValidator.email, isSecure: false, borderColor: .saffron, textInputType: .emailAddress)
                            
            FieldView(imageName: "lock", placeholder: "Password", text: $viewModel.userValidator.password, isSecure: true, borderColor: .saffron)
            
            if !viewModel.errorMessage.isEmpty {
                ErrorView(message: viewModel.errorMessage, foregroundColor:.burgundy)
//                    .padding(.top, 20)
            }
            Button(action: {
                viewModel.login()
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Увійти")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.saffron)
            .cornerRadius(10)
            .opacity(viewModel.userValidator.isLoginBtnDisabled ? 0.6 : 1.0)
            .padding(.horizontal, 30)
            .padding(.top, 10)
            .disabled(viewModel.userValidator.isLoginBtnDisabled)
            
            
            
            VStack{
                Text("Ще не маєш профілю?")
                NavigationLink("Зареєструватись"){
                    SingUpEmailView()
                }
            }
            .padding(.top, 50)
            
        }
        .padding()
        .padding(.bottom, 20)
        
    
    }
    
}

#Preview {
    SignInEmailView()
}
//#Preview {
//    let mockValidator = UserValidator()
//    mockValidator.email = "s@gmail.com"
//    mockValidator.password = "12345678"
//    
//    let mockViewModel = SignInEmailViewModel(userValidator: mockValidator)
//    
//    return SignInEmailView(viewModel: mockViewModel)
//}
