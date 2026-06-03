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

                var localRatingsMap:
                    [String: (totalScore: Double, reviewCount: Int)] = [:]

                do {
                    let allReviewsSnap = try await databaseRef.child("reviews")
                        .getData()

                    if let allReviewsDict = allReviewsSnap.value
                        as? [String: Any]
                    {
        
                        for (_, reviewData) in allReviewsDict {
                            if let reviewDict = reviewData as? [String: Any],
                                let photographerId = reviewDict[
                                    "photographerId"
                                ] as? String,
                                let ratingVal = reviewDict["starRating"]
                            {

                                var ratingAsDouble: Double? = nil
                                if let doubleVal = ratingVal as? Double {
                                    ratingAsDouble = doubleVal
                                }
                                if let intVal = ratingVal as? Int {
                                    ratingAsDouble = Double(intVal)
                                }

                                if let validRating = ratingAsDouble {
                                    let currentStats =
                                        localRatingsMap[photographerId] ?? (
                                            totalScore: 0.0, reviewCount: 0
                                        )
                                    localRatingsMap[photographerId] = (
                                        totalScore: currentStats.totalScore
                                            + validRating,
                                        reviewCount: currentStats.reviewCount
                                            + 1
                                    )
                                }
                            }
                        }
                    }
                } catch {
                    print(
                        "Error fetching the reviews batch: \(error.localizedDescription)"
                    )
                }

                for photographer in fetchedPhotographers {
                    if let stats = localRatingsMap[photographer.id] {
                        photographer.rating =
                            stats.totalScore / Double(stats.reviewCount)
                        photographer.reviewCount = stats.reviewCount
                    } else {
                        photographer.rating = 0.0
                        photographer.reviewCount = 0
                    }
                }

                self.photographers = fetchedPhotographers
            }
        } catch {
            print("Error fetching photographers: \(error.localizedDescription)")
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
