//
//  ReportBookingView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 03/06/26.
//

import SwiftUI

struct ReportBookingView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ReportBookingViewModel()
    
    let bookingId: String
    let reportedUserId: String
    
    @State private var selectedReason: String = "Scam / Fraud"
    @State private var descriptionText: String = ""
    
    let reportReasons = [
        "Scam / Fraud",
        "No Show",
        "Inappropriate Behavior",
        "Payment Issue",
        "Other"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Reason for Report").foregroundColor(.secondary)) {
                    Picker("Reason", selection: $selectedReason) {
                        ForEach(reportReasons, id: \.self) { reason in
                            Text(reason).tag(reason)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("Details").foregroundColor(.secondary)) {
                    TextEditor(text: $descriptionText)
                        .frame(minHeight: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.subheadline)
                    }
                }
            }
            .navigationTitle("Report Booking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Submit") {
                        Task {
                            await viewModel.submitReport(
                                bookingId: bookingId,
                                reportedUserId: reportedUserId,
                                reason: selectedReason,
                                description: descriptionText
                            )
                        }
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                    .disabled(descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isSubmitting)
                }
            }
            .overlay {
                if viewModel.isSubmitting {
                    ProgressView()
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                }
            }
            .onChange(of: viewModel.isSuccess) { success in
                if success {
                    dismiss()
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}
