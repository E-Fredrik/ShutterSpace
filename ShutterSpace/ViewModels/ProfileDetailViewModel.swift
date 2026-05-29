//
//  ProfileDetailViewModel.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 29/05/26.
//

import Combine
import FirebaseDatabase
import Foundation

class ProfileDetailViewModel: ObservableObject {
    @Published var servicePackages: [ServicePackage] = []
    @Published var portfolioImageUrls: [String] = []
    @Published var isLoading: Bool = false

    let photographerId: String
    private let databaseReference = Database.database().reference()

    init(photographerId: String) {
        self.photographerId = photographerId
    }

    func fetchProfileData() async {
        isLoading = true

        do {
            try await fetchPackages()
            try await fetchPortfolioImages()
        } catch {
            print(error)
        }

        isLoading = false
    }

    private func fetchPackages() async throws {
        let snapshot = try await databaseReference.child("servicePackages")
            .child(photographerId).getData()
        if let children = snapshot.children.allObjects as? [DataSnapshot] {
            var fetchedPackages: [ServicePackage] = []
            for child in children {
                if let dict = child.value as? [String: Any],
                    let jsonData = try? JSONSerialization.data(
                        withJSONObject: dict
                    ),
                    let package = try? JSONDecoder().decode(
                        ServicePackage.self,
                        from: jsonData
                    )
                {
                    fetchedPackages.append(package)
                }
            }
            self.servicePackages = fetchedPackages
        }
    }

    private func fetchPortfolioImages() async throws {

        let snapshot = try await databaseReference.child("portfolios").child(
            photographerId
        ).child("imageUrls").getData()

        if let array = snapshot.value as? [String] {

            self.portfolioImageUrls = array.map {
                CloudinaryManager.shared.getOptimizedUrl(from: $0, width: 1000)
            }
        }
    }
}
