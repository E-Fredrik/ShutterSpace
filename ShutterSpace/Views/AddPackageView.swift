//
//  AddPackageView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 28/05/26.
//

import SwiftUI

struct AddPackageView: View {
    
    @Environment(\.dismiss) var dismissView
    @ObservedObject var portfolioViewModel: ManagePortfolioViewModel
    
    @State private var packageTitleInput: String = ""
    @State private var packagePriceInput: String = ""
    @State private var packageDeliverablesInput: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Package Title", text: $packageTitleInput)
                    TextField("Price", text: $packagePriceInput)
                        .keyboardType(.decimalPad)
                    TextField("Deliverables/Description", text: $packageDeliverablesInput)
                }
            }
            .navigationTitle("New Package")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismissView()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let parsedPrice: Double = Double(packagePriceInput) {
                            portfolioViewModel
                                .addNewPackage(
                                    packageTitle: packageTitleInput,
                                    packagePrice: parsedPrice,
                                    packageDeliverables: packageDeliverablesInput
                                )
                            dismissView()
                        }
                    }.disabled(packageTitleInput.isEmpty || packagePriceInput.isEmpty || packageDeliverablesInput.isEmpty)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    AddPackageView(portfolioViewModel: ManagePortfolioViewModel())
}
