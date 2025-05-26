//
//  ProfileView.swift
//  FestiGo
//
//  Created by kisellsn on 17/03/2025.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @ObservedObject var languageManager = LanguageManager.shared


    var body: some View {
        NavigationStack {
            ZStack {
                Color.ultraViolet.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    
                    if let user = viewModel.user {
                        VStack(spacing: 20) {
                            if let photoUrl = URL(string: user.photoUrl ?? "") {
                                AsyncImage(url: photoUrl) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 120, height: 120)
                                .background(Circle().fill(Color.white))
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white.opacity(0.8), lineWidth: 4))
                                .shadow(color: .black.opacity(0.3), radius: 6)
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                                    .foregroundColor(.gray.opacity(0.4))
                                    .frame(width: 120, height: 120)
                                    .background(Circle().fill(Color.white))
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white.opacity(0.8), lineWidth: 4))
                            }
                            
                            // Імʼя
                            Text("Привіт, \(user.name)")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Divider()
                                .background(Color.gray.opacity(0.3))
                                .padding(.horizontal, 30)

                            
                            // Інфо
                            VStack(alignment: .leading, spacing: 40) {
                                profileRow(title: "📧 Пошта", value: user.email)
                                profileRow(title: "📅 Зареєстровано", value: formattedDate(user.joined))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 30)
                            
                            Spacer()
                            
                            FullButtonView(
                                title: "Вийти",
                                action: {
                                    viewModel.logOut()
                                },
                                backgroundColor: .clear,
                                isDisabled: false,
                                isLoading: false,
                                iconName: "rectangle.portrait.and.arrow.right",
                                textColor: .burgundy
                            )
                            .padding(.top, 20)
                            
                            
                            
                        }
                        .padding(.bottom, 50)
                        .padding(.top, 40)
                        .frame(maxWidth: .infinity)
                       
                        .background(
                            ZStack(alignment: .bottom) {
                                Color.myWhite
                                    .clipShape(RoundedCorner(radius: 30, corners: [.topLeft, .topRight]))
                                    .shadow(radius: 10)
                                    
                                
//                                Image(uiImage: #imageLiteral(resourceName: "bottomPic"))
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(maxWidth: .infinity)
//                                    .opacity(0.2)
//                                    .padding(.bottom, 0)
                            }
                                .edgesIgnoringSafeArea(.bottom)
                        )

                        
                        
                    } else {
                        Spacer()
                        ProgressView("Завантаження профілю…")
                            .foregroundColor(.white)
                        Spacer()
                    }
                    
                    
                    
                }
                .padding(.top, 20)
                    
                    
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Твій профіль")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(.top, 7)
                    
                }

                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("UA|ENG") {
                        languageManager.toggleLanguage()
                    }
                    .foregroundColor(.primary)

                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                    }
                    .foregroundColor(.primary)
                }

            }
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbarBackground(.primary, for: .navigationBar)

        }
        .onAppear {
            viewModel.fetchUser()
        }
    }

    //  для рядків профілю
    func profileRow(title: LocalizedStringResource, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
        }
    }

    func formattedDate(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        return date.formatted(date: .abbreviated, time: .shortened)
    }
}

//    @ViewBuilder
//    var premiumFunctionality: some View{
//        if viewModel.user?.isPremium == true {
//            NavigationLink(destination: CreateEventView()) {
//                Label("Створити подію", systemImage: "plus.circle")
//                    .font(.headline)
//                    .padding()
//                    .background(Color.ultraViolet)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//            }
//        } else {
//            Button("Отримати Premium") {
//                // TODO: Show paywall or upgrade screen
//            }
//            .font(.headline)
//            .padding()
//            .background(Color.burgundy)
//            .foregroundColor(.white)
//            .cornerRadius(8)
//        }
//
//    }
    


#Preview {
    ProfileView()
}
