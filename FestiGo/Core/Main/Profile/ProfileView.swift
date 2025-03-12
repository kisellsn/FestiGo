//
//  ProfileView.swift
//  FestiGo
//
//  Created by kisellsn on 17/03/2025.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    
    var body: some View {
        NavigationView{
            
            VStack{
                
                if let user = viewModel.user{
                    profile(user: user)
//                    premiumFunctionality
                }else{
                    Text("Дані профілю завантажуються...")
                }
            }
            .navigationTitle("Профіль")
            .toolbar{
                Button{
                    //
                } label: {
                    Text("UA|ENG")
                }
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape")
                }
            }
        }
        .onAppear{
            viewModel.fetchUser()
        }

        
    }
    @ViewBuilder
    func profile(user: User) -> some View{
        if let photoUrl = viewModel.user?.photoUrl, let url = URL(string: photoUrl) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 125, height: 125)
            .clipShape(Circle())
            .padding(.top, 20)
        } else {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(.sage)
                .frame(width: 125, height: 125)
                .padding(.top, 20)
        }
        VStack(alignment: .leading){
            HStack{
                Text("Імʼя: ")
                Text(user.name)
            }
            .padding()
            HStack{
                Text("Пошта: ")
                Text(user.email)
            }
            .padding()
            HStack{
                Text("Зареєстрований з: ")
                Text("\(Date(timeIntervalSince1970: user.joined).formatted(date: .abbreviated, time: .shortened))")
            }
            .padding()
        }
        Spacer()
        

    }
    @ViewBuilder
    var premiumFunctionality: some View{
        if viewModel.user?.isPremium == true {
            NavigationLink(destination: CreateEventView()) {
                Label("Створити подію", systemImage: "plus.circle")
                    .font(.headline)
                    .padding()
                    .background(Color.ultraViolet)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        } else {
            Button("Отримати Premium") {
                // TODO: Show paywall or upgrade screen
            }
            .font(.headline)
            .padding()
            .background(Color.burgundy)
            .foregroundColor(.white)
            .cornerRadius(8)
        }

    }
    
}

#Preview {
    ProfileView()
}
