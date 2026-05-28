//
//  ManagePortfolioViewModel.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 28/05/26.
//

import Foundation
import Combine
import PhotosUI
import _PhotosUI_SwiftUI

@MainActor
class ManagePortfolioViewModel: ObservableObject {
    
    @Published var servicePackage: [ServicePackage] = []
    @Published var portfolioImageUrls: [String] = []
    @Published var selectedPhotoItem: PhotosPickerItem? = nil
    @Published var isDataLoading: Bool = false
    
    func loadPortfolioData() async {
        isDataLoading = true
        
        do {
            self.servicePackage = try await fetchMockPackages()
            self.portfolioImageUrls = try await fetchMockPortfolioImages()
        } catch {
            print(error)
        }
        
        isDataLoading = false
    }
    
    func fetchMockPackages() async throws -> [ServicePackage] {
        return [
            ServicePackage(id: "1", title: "Basic Package", price: 200.0, deliverables: "2 hours of shooting, 20 edited photos"),
            ServicePackage(id: "2", title: "Standard Package", price: 400.0, deliverables: "4 hours of shooting, 50 edited photos"),
            ServicePackage(id: "3", title: "Premium Package", price: 600.0, deliverables: "8 hours of shooting, 100 edited photos")
        ]
    }
    
    func fetchMockPortfolioImages() async throws -> [String] {
        return [
            "https://example.com/portfolio1.jpg",
            "https://example.com/portfolio2.jpg",
            "https://example.com/portfolio3.jpg"
        ]
    }
    
    func addNewPackage(packageTitle: String, packagePrice: Double, packageDeliverables: String) {
        let newPackage: ServicePackage = ServicePackage(id: UUID().uuidString, title: packageTitle, price: packagePrice, deliverables: packageDeliverables)
        servicePackage.append(newPackage)
    }
    
    func processImageSelection(pickerItem: PhotosPickerItem?) async {
        if pickerItem != nil {
            portfolioImageUrls.insert("https://example.com/newly_selected_image.jpg", at: 0)
        }
    }
}
