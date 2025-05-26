//
//  EventListView.swift
//  FestiGo
//
//  Created by kisellsn on 17/03/2025.
//

import SwiftUI

struct EventListView: View {
    @EnvironmentObject var eventViewModel: EventListViewModel
    @State private var didAppear = false
    

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Image("sceneryPic")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                    if !eventViewModel.recommendedEvents.isEmpty {
                        Text("Спеціально для вас")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        horisontalListView
                        
                        Divider()
                    }

                    
                    EventFiltersView()/*(viewModel: eventViewModel)*/
                        .padding(.vertical, 4)
                        .padding(.horizontal)
                    
                    Divider()
                    
                    Text("Інші події поблизу")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    verticalListView
                }
                .padding(.bottom)
            }
            .navigationTitle("Головна")
            .navigationBarHidden(true)
            
        }
    }
    
    @ViewBuilder
    var horisontalListView: some View{
        VStack(alignment: .leading, spacing: 12){
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(eventViewModel.recommendedEvents) { event in
                        NavigationLink(destination: EventDetailView(event: event)) {
                            VerticalEventCardView(event: event)
                                .frame(width: 200, height: 200)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    var verticalListView: some View{
        VStack(alignment: .leading) {
            if eventViewModel.isLoadingEvents && eventViewModel.events.isEmpty{
                VStack(alignment: .center) {
                    Spacer()
                    ProgressView("Завантаження подій…")
                        .padding(.top, 40)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 50)
            } else if eventViewModel.events.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass.circle")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("Схоже, нічого не знайшлося")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("Спробуй змінити фільтри або перевір підключення до мережі.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray.opacity(0.7))
                        .padding(.horizontal, 30)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 50)
            } else {
                
                LazyVStack {
                    ForEach(eventViewModel.events) { event in
                        NavigationLink(destination: EventDetailView(event: event)) {
                            EventCardView(event: event)
                        }
                        if event == eventViewModel.events.last {
                            ProgressView()
                                .onAppear {
                                    eventViewModel.getEvents()
                                }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top)
        .onAppear {
            if !didAppear{
                eventViewModel.getEvents()
                eventViewModel.loadRecommendationsIfNeeded()
                eventViewModel.addRealtimeEventsListener()
                didAppear = true
            }
        }
        
    }
    
}


#Preview {
    EventListView()
        .environmentObject(EventListViewModel())
        .environmentObject(FavouritesViewModel())
}
