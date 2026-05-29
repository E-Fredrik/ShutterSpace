//
//  ManagePortfolioViewModel.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 28/05/26.
//

import Combine
import FirebaseDatabase
import Foundation
import PhotosUI
import _PhotosUI_SwiftUI

@MainActor
class ManagePortfolioViewModel: ObservableObject {

    @Published var servicePackage: [ServicePackage] = []
    @Published var portfolioImageUrls: [String] = []
    @Published var selectedPhotoItem: PhotosPickerItem? = nil
    @Published var isDataLoading: Bool = false

    private let databaseRef = Database.database().reference()
    private let photographerId: String = "photo_001"

    func loadPortfolioData() async {
        isDataLoading = true

        do {
            try await fetchPackages()
            try await fetchPortfolioImages()
        } catch {
            print(error)
        }

        isDataLoading = false
    }

    func fetchPackages() async throws {
        let snapshot = try await databaseRef.child("servicePackages")
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

            self.servicePackage = fetchedPackages
        }
    }

    func fetchPortfolioImages() async throws {

        let snapshot = try await databaseRef.child("portfolios").child(
            photographerId
        ).child("imageUrls").getData()

        if let array = snapshot.value as? [String] {
            self.portfolioImageUrls = array.map {
                CloudinaryManager.shared.getOptimizedUrl(from: $0, width: 800)
            }
        }
    }

    func addNewPackage(
        packageTitle: String,
        packagePrice: Double,
        packageDeliverables: String
    ) {
        let newPackageId = UUID().uuidString
        let newlyCreatedPackage = ServicePackage(
            packageId: newPackageId,
            title: packageTitle,
            price: packagePrice,
            deliverables: packageDeliverables
        )

        self.servicePackage.append(newlyCreatedPackage)

        if let encodedData = try? JSONEncoder().encode(newlyCreatedPackage),
            let dict = try? JSONSerialization.jsonObject(with: encodedData)
                as? [String: Any]
        {
            databaseRef.child("servicePackages").child(
                photographerId
            ).child(newPackageId).setValue(dict)
        }
    }

    func processImageSelection(pickerItem: PhotosPickerItem?) {
        guard let pickerItem = pickerItem else { return }
        Task {
            isDataLoading = true
            do {
                if let imageData = try await pickerItem.loadTransferable(
                    type: Data.self
                ) {
                    let uploadedUrl = try await CloudinaryManager.shared
                        .uploadImage(data: imageData)
                    let optimizedUrl = CloudinaryManager.shared.getOptimizedUrl(
                        from: uploadedUrl,
                        width: 800
                    )
                    self.portfolioImageUrls.insert(optimizedUrl, at: 0)
                    try await databaseRef.child("portfolios").child(
                        photographerId
                    ).child("imageUrls").setValue(self.portfolioImageUrls)
                }
            } catch {
                print(error)
            }
            self.selectedPhotoItem = nil
            isDataLoading = false
        }
    }
}
