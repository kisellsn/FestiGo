//
//  WelcomeView.swift
//  FestiGo
//
//  Created by kisellsn on 10/03/2025.
//

import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

struct WelcomeView: View {
    @State private var isAnimating = false
    @State private var navigateToMain = false
    @State var userValidator = UserValidator()
    @StateObject private var viewModel = SignInGoogleViewModel()
//    @StateObject private var viewModel = AuthenticationViewModel()

    var body: some View {
        NavigationView{
            VStack {
                Spacer()
                
                // іконка
                //Image(systemName: "ticket.fill")
                Image(uiImage:#imageLiteral(resourceName: "my-logo.png"))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .opacity(isAnimating ? 1 : 0)
                    .scaleEffect(isAnimating ? 1 : 0.8)
                    .animation(.easeOut(duration: 1), value: isAnimating)
                // Заголовок
                Text("FestiGo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeOut(duration: 1.2), value: isAnimating)
                
                // Опис
                Text("Знаходь улюблені концерти, театри та фестивалі у своєму місті.")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 10)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeOut(duration: 1.4), value: isAnimating)
                
                Spacer()
                
                // Кнопки
                VStack(spacing: 15) {
                    NavigationLink(destination: SignInEmailView()) {
                        ZStack {
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.black)
                                
                                Spacer()
                            }
                            
                            Text("Увійти з email")
                                .font(.headline)
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                    .padding(.horizontal, 30)
                    
                    
                    Button(action: {
                        viewModel.signInGoogle()
                    }) {
                        ZStack {
                            HStack {
                                Image("google-logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.black)
                                
                                Spacer()
                            }
                            
                            Text("Увійти з Google")
                                .font(.headline)
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                    .padding(.horizontal, 30)
                    
                    NavigationLink(destination: MapView()) {
                        Text("Продовжити як гість")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                        
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 10)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
            .background(LinearGradient(colors: [Color.lighterViolet, Color.ultraViolet], startPoint: .top, endPoint: .bottom))
            .ignoresSafeArea()
            .onAppear {
                isAnimating = true
            }
        }
    }
}


#Preview {
    WelcomeView()
        .environmentObject(EventListViewModel())
}

