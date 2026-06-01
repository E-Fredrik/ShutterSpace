//
//  BookSessionView.swift
//  ShutterSpace
//
//  Created by Sean tandjaja on 31/05/26.
//

import SwiftUI

struct BookSessionView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel: BookingViewModel
    @Environment(\.dismiss) private var dismissView
    
    @State private var isShowingPayment = false
    
    // MARK: - Lifecycle
    init(photographerId: String) {
        self._viewModel = StateObject(wrappedValue: BookingViewModel(photographerId: photographerId))
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                renderCalendarSection()
                renderTimeSlotsSection()
                renderPackagesSection()
                
                if viewModel.selectedPackage != nil && viewModel.selectedTimeSlot != nil {
                    renderCheckoutSummarySection()
                }
            }
            .padding()
        }
        .navigationTitle("Book Session")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchPackages()
        }
        .alert("Booking Confirmed", isPresented: $viewModel.bookingComplete) {
            Button("Done") {
                dismissView()
            }
        } message: {
            Text("Your session has been successfully booked.")
        }
        // NEW: Attach the Payment Sheet
        .sheet(isPresented: $isShowingPayment) {
            PaymentView(viewModel: viewModel)
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Private Methods
    
    /// Renders the calendar for date selection, restricting past dates.
    private func renderCalendarSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Date")
                .font(.headline)
            
            DatePicker("Select Date", selection: $viewModel.selectedDate, in: Date()..., displayedComponents: .date)
                .datePickerStyle(.graphical)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
        }
    }
    
    /// Renders the grid of available time slots.
    private func renderTimeSlotsSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Available Times")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(viewModel.availableTimeSlots, id: \.self) { time in
                    TimeSlotButton(
                        time: time,
                        isSelected: viewModel.selectedTimeSlot == time,
                        action: { viewModel.selectTimeSlot(time) }
                    )
                }
            }
        }
    }
    
    /// Renders the list of service packages fetched from Firebase.
    private func renderPackagesSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Packages")
                .font(.headline)
            
            ForEach(viewModel.packages) { package in
                Button(action: {
                    viewModel.selectPackage(package)
                }) {
                    PackageRowView(activeServicePackage: package)
                        .padding()
                        .background(viewModel.selectedPackage?.id == package.id ? Color.blue.opacity(0.15) : Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(viewModel.selectedPackage?.id == package.id ? Color.blue : Color.clear, lineWidth: 1.5)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    /// Renders the summary of costs and triggers the payment sheet.
    private func renderCheckoutSummarySection() -> some View {
        CheckoutSummaryView(
            packageTitle: viewModel.selectedPackage?.title ?? "",
            packagePrice: viewModel.calculateSubtotal(),
            platformFee: viewModel.platformFee,
            totalCost: viewModel.calculateFinalTotal(),
            isProcessing: false,
            payAction: {
                isShowingPayment = true
            }
        )
    }
}
