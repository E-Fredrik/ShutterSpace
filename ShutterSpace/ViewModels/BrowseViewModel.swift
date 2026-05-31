//
//  BrowseViewModel.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 28/05/26.
//

import Combine
import FirebaseDatabase
import Foundation

@MainActor
class BrowseViewModel: ObservableObject {

    @Published var photographers: [Photographer] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: String = "All"
    @Published var isLoading: Bool = false

    private let databaseRef = Database.database().reference()

    func fetchPhotographers() async {
        isLoading = true

        do {
            let snapshot = try await databaseRef.child("users")
                .queryOrdered(byChild: "role")
                .queryEqual(toValue: "Photographer")
                .getData()

            if let children = snapshot.children.allObjects as? [DataSnapshot] {
                var fetchedPhotographers: [Photographer] = []

                for child in children {
                    if let dict = child.value as? [String: Any],
                        let jsonData = try? JSONSerialization.data(
                            withJSONObject: dict
                        ),
                        let photographer = try? JSONDecoder().decode(
                            Photographer.self,
                            from: jsonData
                        )
                    {
                        fetchedPhotographers.append(photographer)
                    }
                }

                self.photographers = fetchedPhotographers
            }
        } catch {
            print(error)
        }

        isLoading = false
    }

    func getFilteredPhotographers() -> [Photographer] {
        return photographers.filter { currentPhotographer in
            let matchesSearch: Bool =
                searchText.isEmpty
                || currentPhotographer.firstName
                    .localizedCaseInsensitiveContains(searchText)
                || currentPhotographer.lastName
                    .localizedCaseInsensitiveContains(searchText)
            let matchesCategory: Bool =
                selectedCategory == "All"
                || currentPhotographer.category == selectedCategory

            return matchesSearch && matchesCategory

        }
    }

}
