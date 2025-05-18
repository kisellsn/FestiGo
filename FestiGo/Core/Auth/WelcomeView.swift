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
            TabView {
                firstPage
                
                secondPage
            }
            .background(LinearGradient(colors: [Color.lighterViolet, Color.ultraViolet], startPoint: .top, endPoint: .bottom))
            .ignoresSafeArea()
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .navigationBarHidden(true)
        }
    }
    
    @ViewBuilder
    var firstPage: some View {
        VStack {
            Spacer(minLength: 60)
            Image(uiImage:#imageLiteral(resourceName: "my-logo"))
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .shadow(color: Color.white.opacity(0.7), radius: 12, x: 0, y: 0)
                .scaleEffect(isAnimating ? 1.05 : 1)
                .opacity(isAnimating ? 1 : 0)
                .animation(
                    .easeInOut(duration: 1.5),
                    value: isAnimating
                )

            Text("Вітаємо у FestiGo!")
                .font(.system(size: 37, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 40)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
                .animation(.easeOut(duration: 1).delay(0.1), value: isAnimating)
                .padding(.top, 100)
            
            // Роздільник
            Divider()
                .background(Color.white.opacity(0.5))
                .frame(height: 1)
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
                .opacity(isAnimating ? 1 : 0)
                .animation(.easeOut(duration: 0.8).delay(0.5), value: isAnimating)
            
            
            // Абзаци тексту, розбиті на два блоки
            VStack(alignment: .leading, spacing: 16) {
                Text("Знаходь улюблені концерти, театри та фестивалі у своєму місті.")
                Text("Слідкуй за новинками, отримуй рекомендації та не пропускай нічого цікавого.")
            }
            .font(.headline)
            .foregroundColor(.white.opacity(0.85))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 40)
            .padding(.top, 12)
            .opacity(isAnimating ? 1 : 0)
            .offset(y: isAnimating ? 0 : 20)
            .animation(.easeOut(duration: 1.2).delay(0.9), value: isAnimating)
            
            Spacer()
            
            // Свайп для продовження
            Text("Свайпніть вправо, щоб продовжити")
                .foregroundColor(.white.opacity(0.65))
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 70)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 10)
                .animation(.easeOut(duration: 1.3).delay(1.2), value: isAnimating)
        }
        .background(
            LinearGradient(colors: [Color.lighterViolet, Color.ultraViolet], startPoint: .top, endPoint: .bottom)
        )
        .ignoresSafeArea()
        .onAppear {
            isAnimating = true
        }
    }


    
    @ViewBuilder
    var secondPage: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 15) {
                // Верхня частина
                VStack(spacing: 15){
                   Image(uiImage: #imageLiteral(resourceName: "welcome"))
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)

                    Text("Почнімо з вибору")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)

                    Text("Оберіть спосіб, як ви хочете увійти або продовжити.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 30)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
                
                //  нижня  частина
                VStack(spacing: 20) {
                    VStack(spacing: 15) {
                        Spacer()
                        NavigationLink(destination: SignInEmailView()) {
                            AuthButton(label: "Увійти з Email", icon: "envelope.fill")
                        }
                        .padding(.top, 30)
                        
                        
                        Button(action: {
                            viewModel.signInGoogle()
                        }) {
                            AuthButton(label: "Увійти з Google", imageName: "google-logo")
                        }
                        
                        HStack {
                            Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
                            Text("АБО")
                                .foregroundColor(.gray)
                                .font(.caption)
                            Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
                        }
                        
                        NavigationLink(destination: MapView()) {
                            Text("Продовжити як гість")
                                .opacity(0.9)
                                .font(.headline)
                                .foregroundColor(.ultraViolet)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.ultraViolet.opacity(0.5), lineWidth: 1)
                                       
                                )
                        }
                        Spacer()
                    }
                }
                .padding(30)
                .background(
                    RoundedTopBackground()
                        .fill(.myWhite)
                        .edgesIgnoringSafeArea(.bottom)
                )
            }
        }
    }
}


#Preview {
    WelcomeView()
        .environmentObject(EventListViewModel())
}

