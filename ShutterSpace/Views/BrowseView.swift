//
//  BrowseView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 28/05/26.
//

import SwiftUI

struct BrowseView: View {
    @StateObject private var browseViewModel: BrowseViewModel = BrowseViewModel()
    let availableCategories: [String] = ["Wedding", "Portrait", "Landscape", "Event", "Fashion", "Food", "Travel"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    renderCategorySelector()
                    renderPhotographerGrid()
                }.padding()
            }
            .navigationTitle("Discover")
            .searchable(text: $browseViewModel.searchText, prompt: "Search photographers")
            .task {
                await browseViewModel.fetchPhotographers()
            }.preferredColorScheme(.dark)
        }
    }
}

extension BrowseView {
    func renderCategorySelector() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(availableCategories, id: \.self) { category in
                    CategoryPillView(
                        categoryTitle: category,
                        isCategorySelected: browseViewModel.selectedCategory == category,
                        tapAction: {
                            browseViewModel.selectedCategory = category
                        }
                    )
                }
            }
        }
    }
    
    func renderPhotographerGrid() -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(browseViewModel.getFilteredPhotographers()) { photographer in
                NavigationLink(destination: PhotographerDetailView(photographer: photographer)) {
                    PhotographerCardView(photographer: photographer)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

#Preview {
    BrowseView()
}
