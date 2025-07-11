//
//  EventFiltersView.swift
//  FestiGo
//
//  Created by kisellsn on 22/04/2025.
//

import SwiftUI


struct EventFiltersView: View {
    @EnvironmentObject var viewModel: EventListViewModel
//    @StateObject private var locationManager = LocationManager()

    
    @State private var showingDatePicker = false
    @Environment(\.calendar) var calendar
    
    let gridLayout = [GridItem(.flexible()), GridItem(.flexible())]
    
    
    var body: some View {
        VStack(spacing: 8) {
            categoryFilterView
                .padding(.bottom)
            
            HStack(spacing: 8) {
                
                Menu {
                    Button("Усі міста") {
                        Task {
                            try? await viewModel.citySelected(option: .all)
                        }
                    }
                    ForEach(viewModel.allCitiesMap.keys.sorted(), id: \.self) { city in
                        Button(city) {
                            Task {
                                try? await viewModel.citySelected(option: .named(city))
                            }
                        }
                    }
                } label: {
                    Label(viewModel.selectedCity.label, systemImage: "mappin.and.ellipse")
                }
                Spacer(minLength: 12)
                Button {
                    showingDatePicker.toggle()
                } label: {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            if let range = viewModel.dateRange {
                                Text("\(range.lowerBound.formatted(date: .abbreviated, time: .omitted)) – \(range.upperBound.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.footnote)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }else{
                                Text("Дата")
                            }
                        }
                    } icon: {
                        Image(systemName: "calendar")
                    }
                }
                
                Spacer(minLength: 12)
                
                Menu {
                    ForEach(EventListViewModel.TypeOption.allCases, id: \.self) { option in
                        Button(option.rawValue) {
                            Task {
                                try? await viewModel.typeSelected(option: option)
                            }
                        }
                    }
                }
                label: {
                    Label(viewModel.isOnline?.rawValue ?? "Тип", systemImage: "laptopcomputer")
                }
                
            }
            .popover(isPresented: $showingDatePicker) {
                HStack(spacing: -40){
                    
                    DatePicker(
                        "Початок",
                        selection: Binding(
                            get: { viewModel.startDate ?? Date() },
                            set: { newStart in
                                viewModel.startDate = newStart
                                if let end = viewModel.endDate, newStart > end {
                                    viewModel.endDate = newStart
                                }
                                viewModel.updateDateRange()
                            }
                        ),
                        in: Date()...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .scaleEffect(0.7)
                    .frame(width: 200, height: 140)
                    .fixedSize()
                    
                    DatePicker(
                        "Кінець",
                        selection: Binding(
                            get: { viewModel.endDate ?? Date() },
                            set: { newEnd in
                                viewModel.endDate = newEnd
                                if let start = viewModel.startDate, newEnd < start {
                                    viewModel.startDate = newEnd
                                }
                                viewModel.updateDateRange()
                            }
                        ),
                        in: (viewModel.startDate ?? Date())...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .scaleEffect(0.7)
                    .frame(width: 200, height: 140)
                    .fixedSize()
                    
                }
                .frame(width: 340, height: 200)
                .padding(.top ) .presentationCompactAdaptation(.popover)
            }
        }
        
    }
    
    @ViewBuilder
    var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 15) {
                    HStack(spacing: 15) {
                        // Перший ряд категорій
                        categoryButton(text: "Усі", selected: viewModel.selectedCategories == nil) {
                            Task { try? await viewModel.categorySelected(option: .all) }
                        }

                        categoryRow(from: Array(EventListViewModel.CategoryOption.allCases.filter { $0 != .all }.prefix(3)))
                    }

                    HStack(spacing: 15) {
                        // Другий ряд категорій
                        categoryRow(from: Array(EventListViewModel.CategoryOption.allCases.filter { $0 != .all }.suffix(from: 3)))
                    }
                }
            }
            .padding(.horizontal)
            .frame(height: 90)
        }
    }
    @ViewBuilder
    func categoryRow(from categories: [EventListViewModel.CategoryOption]) -> some View {
        ForEach(categories, id: \.self) { category in
            let isSelected = viewModel.selectedCategories?.contains(category.rawValue) ?? false
            categoryButton(text: category.label, selected: isSelected) {
                Task { try? await viewModel.categorySelected(option: category) }
            }
        }
    }

    @ViewBuilder
    func categoryButton(text: LocalizedStringResource, selected: Bool, action: @escaping () -> Void) -> some View
 {
        Button(action: action) {
            Text(text)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(selected ? Color.lighterViolet : Color.gray.opacity(0.2))
                .foregroundColor(selected ? .white : .primary)
                .cornerRadius(20)
        }
    }


}
#Preview {
    EventFiltersView()/*(viewModel: EventListViewModel())*/
        .environmentObject(EventListViewModel())
}
