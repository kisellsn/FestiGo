//
//  MainView.swift
//  FestiGo
//
//  Created by kisellsn on 13/03/2025.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewModel()
    @StateObject var favouritesVM = FavouritesViewModel()
//    @StateObject var eventListVM = EventListViewModel()


    
    var body: some View {
        if viewModel.isSignIn, !viewModel.currentUserId.isEmpty {
            if viewModel.needsOnboarding {
                OnboardingView {
                    viewModel.completeOnboarding()
                }
            } else {
                accountView
//                    .environmentObject(eventListVM)
                    .environmentObject(favouritesVM)
            }
        } else {
            WelcomeView()
        }
    }
    
    @ViewBuilder
    var accountView: some View{
        TabView{
            EventListView()
                .tabItem{
                    Label("Головна", systemImage: "house")
                }
             MapView()
                .tabItem{
                    Label("Карта", systemImage: "map")
                }
            FavouritesView()
                .tabItem{
                    Label("Вподобане", systemImage: "heart")
                }
            ProfileView()
                .tabItem{
                    Label("Профіль", systemImage: "person.circle")
                }
            }
        .tint(Color.ultraViolet)
    }
}

#Preview {
    MainView()
        .environmentObject(EventListViewModel())
}
