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
                        ScrollView {
                            VStack(spacing: 20) {
                                avatarSection(for: user)
                                greetingSection(for: user)
                                Divider().padding(.horizontal, 30)
                                infoSection(for: user)

                                analytics
                                logoutButton
                            }
                            
                        }
                        .padding(.top, 40)
                        .frame(maxWidth: .infinity)
                        .background(
                            ZStack(alignment: .bottom) {
                                Color.myWhite
                                    .clipShape(RoundedCorner(radius: 30, corners: [.topLeft, .topRight]))
                                    .shadow(radius: 10)
                            }.edgesIgnoringSafeArea(.bottom)
                        )
                    } else {
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

    // MARK: - Avatar
    @ViewBuilder
    private func avatarSection(for user: User) -> some View {
        if let photoUrl = URL(string: user.photoUrl ?? "") {
            AsyncImage(url: photoUrl) { image in
                image.resizable().aspectRatio(contentMode: .fill)
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
                .background(Circle().fill(Color.white))
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.8), lineWidth: 4))
        }
    }

    // MARK: - Greeting
    private func greetingSection(for user: User) -> some View {
        Text("Привіт, \(user.name)")
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
    }

    // MARK: - Info
    private func infoSection(for user: User) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            profileRow(title: "📧 Пошта", value: user.email)
            profileRow(title: "📅 Зареєстровано", value: formattedDate(user.joined))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 30)
    }

    // MARK: - Analytics
    @State private var isVisible = false
    @ViewBuilder
    var analytics: some View {
        VStack(spacing: 24) {
            if let top = viewModel.topCategory {
                VStack(spacing: 0) {
                    HStack {
                        Label("Що про тебе каже апка", systemImage: "flame.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                        Spacer()
                    }
                    .background(LinearGradient(colors: [Color.lighterViolet, .persianPink], startPoint: .leading, endPoint: .trailing))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    VStack(spacing: 16) {
                        RadarChartView(data: viewModel.radarScores, labels: viewModel.radarLabels)
                            .frame(width: 250, height: 250)
                            .padding(.top, 20)
    
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(top.emoji)
                                    .font(.title2)
                                Text(top.category)
                                    .font(.title3.bold())
                            }
                            Text(top.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
                
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.cardBackground)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                )
                .padding(.horizontal)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 20)
                .animation(.easeOut(duration: 0.5), value: isVisible)
                .onAppear {
                    isVisible = true
                }
                .padding(.top, 15)
            }
        }
    }



    // MARK: - Logout
    private var logoutButton: some View {
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
        .padding(.vertical, 20)
    }

    // MARK: - Profile Row
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

    // MARK: - Date Formatting
    func formattedDate(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        return date.formatted(date: .abbreviated, time: .shortened)
    }
}


#Preview {
    ProfileView()
}
