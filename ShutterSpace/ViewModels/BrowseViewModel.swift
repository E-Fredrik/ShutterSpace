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

                let ratingsMap = await withTaskGroup(
                    of: (String, Double, Int)?.self
                ) { group in
                    let photographerIds = fetchedPhotographers.map { $0.id }

                    for id in photographerIds {
                        group.addTask {
                            do {
                                let reviewSnap = try await self.databaseRef
                                    .child("reviews").child(id)
                                    .getData()

                                if let reviewDict = reviewSnap.value
                                    as? [String: Any]
                                {
                                    let ratings = reviewDict.values.compactMap {
                                        review -> Double? in
                                        if let dict = review as? [String: Any],
                                            let ratingVal = dict["rating"]
                                        {
                                            if let doubleVal = ratingVal
                                                as? Double
                                            {
                                                return doubleVal
                                            }
                                            if let intVal = ratingVal as? Int {
                                                return Double(intVal)
                                            }
                                        }
                                        return nil
                                    }

                                    if !ratings.isEmpty {
                                        let average =
                                            ratings.reduce(0, +)
                                            / Double(ratings.count)
                                        return (id, average, ratings.count)
                                    }
                                }
                            } catch {
                            }
                            return nil
                        }
                    }

                    var results: [String: (Double, Int)] = [:]
                    for await result in group {
                        if let validResult = result {
                            results[validResult.0] = (
                                validResult.1, validResult.2
                            )
                        }
                    }
                    return results
                }

                for photographer in fetchedPhotographers {
                    if let newRatingData = ratingsMap[photographer.id] {
                        photographer.rating = newRatingData.0
                        photographer.reviewCount = newRatingData.1
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
