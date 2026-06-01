//
//  EditPackageView.swift
//  ShutterSpace
//
//  Created by Sean tandjaja on 01/06/26.
//

import SwiftUI

struct EditPackageView: View {
    @Environment(\.dismiss) var dismissView
    @ObservedObject var portfolioViewModel: ManagePortfolioViewModel
    var packageToEdit: ServicePackage

    @State private var packageTitleInput: String = ""
    @State private var packagePriceInput: String = ""
    @State private var packageDurationInput: String = ""
    @State private var packageDeliverablesInput: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Package Title", text: $packageTitleInput)
                    TextField("Price", text: $packagePriceInput)
                        .keyboardType(.decimalPad)
                    TextField("Duration (e.g. 4 Hours)", text: $packageDurationInput)
                    TextField("Deliverables/Description", text: $packageDeliverablesInput)
                }
            }
            .navigationTitle("Edit Package")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                self.packageTitleInput = self.packageToEdit.title
                self.packagePriceInput = String(self.packageToEdit.price)
                self.packageDurationInput = self.packageToEdit.duration
                self.packageDeliverablesInput = self.packageToEdit.deliverables
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismissView()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let parsedPrice: Double = Double(packagePriceInput) {
                            let editedPackage = ServicePackage(
                                packageId: packageToEdit.packageId,
                                title: packageTitleInput,
                                price: parsedPrice,
                                deliverables: packageDeliverablesInput,
                                duration: packageDurationInput
                            )
                            portfolioViewModel.updatePackage(editedPackage: editedPackage)
                            dismissView()
                        }
                    }
                    .disabled(packageTitleInput.isEmpty || packagePriceInput.isEmpty || packageDeliverablesInput.isEmpty || packageDurationInput.isEmpty)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}
