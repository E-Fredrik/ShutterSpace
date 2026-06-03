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

    @State private var selectedHours: Int = 1
    @State private var selectedMinutes: Int = 0

    var isFormValid: Bool {
        let isTitleValid =
            packageTitleInput.trimmingCharacters(in: .whitespaces).count >= 3
        let isPriceValid = (Double(packagePriceInput) ?? 0) > 0
        let isDeliverablesValid =
            packageDeliverablesInput.trimmingCharacters(in: .whitespaces).count
            >= 5
        let isDurationValid = selectedHours > 0 || selectedMinutes > 0

        return isTitleValid && isPriceValid && isDeliverablesValid
            && isDurationValid
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(
                    header: Text("Package Details"),
                    footer: Text(
                        isFormValid
                            ? ""
                            : "Please fill out all fields correctly. Price must be greater than 0."
                    ).foregroundColor(.red)
                ) {
                    TextField("Package Title", text: $packageTitleInput)

                    TextField("Price (Rp)", text: $packagePriceInput)
                        .keyboardType(.decimalPad)

                    TextField(
                        "Deliverables/Description",
                        text: $packageDeliverablesInput
                    )
                }

                Section(header: Text("Duration")) {
                    HStack {
                        Picker("Hours", selection: $selectedHours) {
                            ForEach(0..<24) { hour in
                                Text("\(hour) hr").tag(hour)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .clipped()

                        Picker("Minutes", selection: $selectedMinutes) {
                            ForEach([0, 15, 30, 45], id: \.self) { minute in
                                Text("\(minute) min").tag(minute)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .clipped()
                    }
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
                        if let parsedPrice = Double(packagePriceInput) {
                            let totalMinutes =
                                (selectedHours * 60) + selectedMinutes

                            portfolioViewModel.addNewPackage(
                                packageTitle: packageTitleInput,
                                packagePrice: parsedPrice,
                                packageDeliverables: packageDeliverablesInput,
                                packageDuration: totalMinutes
                            )
                            dismissView()
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    AddPackageView(portfolioViewModel: ManagePortfolioViewModel())
}
