//
//  BrowseViewModel.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 28/05/26.
//

import Foundation
import Combine

@MainActor
class BrowseViewModel: ObservableObject {
    
    @Published var photographers: [Photographer] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: String = "All"
    @Published var isLoading: Bool = false
    
    func fetchPhotographers() async {
        isLoading = true
        
        do {
            let fetchedPhotographers: [Photographer] = try await getMockPhotographers()
            self.photographers = fetchedPhotographers
        } catch {
            print(error)
        }
        
        isLoading = false
    }
    
    func getMockPhotographers() async throws -> [Photographer] {
        return [
            Photographer(id: "1", firstName: "Alice", lastName: "Smith", startingPrice: 200.0, rating: 4.5, location: "New York", category: "Wedding", profileImageURL: "https://example.com/alice.jpg"),
            Photographer(id: "2", firstName: "Bob", lastName: "Johnson", startingPrice: 150.0, rating: 4.0, location: "Los Angeles", category: "Portrait", profileImageURL: "https://example.com/bob.jpg"),
            Photographer(id: "3", firstName: "Charlie", lastName: "Brown", startingPrice: 300.0, rating: 5.0, location: "Chicago", category: "Event", profileImageURL: "https://example.com/charlie.jpg")
        ]
    }
    
    func getFilteredPhotographers() -> [Photographer] {
        return photographers.filter { currentPhotographer in
            let matchesSearch: Bool = searchText.isEmpty || currentPhotographer.firstName.localizedCaseInsensitiveContains(searchText) || currentPhotographer.lastName.localizedCaseInsensitiveContains(searchText)
            let matchesCategory: Bool = selectedCategory == "All" || currentPhotographer.category == selectedCategory
            
            return matchesSearch && matchesCategory
                
        }
    }
    
}
