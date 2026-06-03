//
//  BookSessionView.swift
//  ShutterSpace
//
//  Created by Sean tandjaja on 31/05/26.
//

import SwiftUI

// Wrapper to hold the URL for the Full Screen Cover
struct PaymentURLWrapper: Identifiable {
    let id = UUID()
    let url: URL
}

struct BookSessionView: View {

    // MARK: - Properties
    @StateObject private var viewModel: BookingViewModel
    @Environment(\.dismiss) private var dismissView

    // NEW: Handles the payment sheet directly, no PaymentView required
    @State private var snapUrlWrapper: PaymentURLWrapper? = nil

    // MARK: - Lifecycle
    init(photographerId: String) {
        self._viewModel = StateObject(
            wrappedValue: BookingViewModel(photographerId: photographerId)
        )
    }

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                renderCalendarSection()
                renderTimeSlotsSection()
                renderPackagesSection()

                if viewModel.selectedPackage != nil
                    && viewModel.selectedTimeSlot != nil
                {
                    renderCheckoutSummarySection()
                }
            }
            .padding()
        }
        .navigationTitle("Book Session")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            async let packagesTask: () = viewModel.fetchPackages()
            async let slotsTask: () = viewModel.fetchAvailableTimeSlots()
            async let bookedTask: () = viewModel.fetchAllBookedTimeSlots()

            _ = await (packagesTask, slotsTask, bookedTask)
        }
        .onChange(of: viewModel.selectedDate) { _ in
            viewModel.selectedTimeSlot = nil
        }
        .onChange(of: viewModel.selectedPackage?.id) { _ in
            if let time = viewModel.selectedTimeSlot,
                !viewModel.isSlotAvailable(time)
            {
                viewModel.selectedTimeSlot = nil
            }
        }

        // --- ALERTS ---
        .alert("Booking Confirmed", isPresented: $viewModel.bookingComplete) {
            Button("Done") {
                dismissView()  // Returns user to photographer profile
            }
        } message: {
            Text(
                "Your session has been successfully booked and payment is held in Escrow."
            )
        }
        .alert("Payment Issue", isPresented: $viewModel.showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.paymentErrorMessage ?? "An unknown error occurred.")
        }

        // --- PAYMENT WEBVIEW (Bypasses the modal entirely) ---
        .fullScreenCover(item: $snapUrlWrapper) { wrapper in
            MidtransPaymentSheet(url: wrapper.url) { result in

                // 1. Instantly close the WebView
                self.snapUrlWrapper = nil

                // 2. Process result after dismissal
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    switch result {
                    case .success:
                        viewModel.markBookingAsPaid()  // This triggers the success alert above!

                    case .failed:
                        viewModel.paymentErrorMessage =
                            "Booking Failed: Payment was rejected or expired."
                        viewModel.showErrorAlert = true
                        viewModel.cancelBooking()

                    case .cancelled:
                        viewModel.paymentErrorMessage = "Booking Cancelled."
                        viewModel.showErrorAlert = true
                        viewModel.cancelBooking()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Private Methods

    private func renderCalendarSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Date")
                .font(.headline)

            DatePicker(
                "Select Date",
                selection: $viewModel.selectedDate,
                in: Date()...,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
    }

    private func renderTimeSlotsSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Available Times")
                .font(.headline)

            if viewModel.availableTimeSlots.isEmpty {
                Text("This photographer hasn't set their availability yet.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible()), GridItem(.flexible()),
                        GridItem(.flexible()), GridItem(.flexible()),
                    ],
                    spacing: 12
                ) {
                    ForEach(viewModel.availableTimeSlots, id: \.self) { time in
                        let isAvailable = viewModel.isSlotAvailable(time)

                        TimeSlotButton(
                            time: time,
                            isSelected: viewModel.selectedTimeSlot == time,
                            isBooked: !isAvailable,
                            action: { viewModel.selectTimeSlot(time) }
                        )
                    }
                }

                if !viewModel.activeBookings.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundColor(.red.opacity(0.7))
                        Text("Grey slots conflict with booked sessions")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                }
            }
        }
    }

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
                        .background(
                            viewModel.selectedPackage?.id == package.id
                                ? Color.blue.opacity(0.15)
                                : Color(UIColor.secondarySystemBackground)
                        )
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    viewModel.selectedPackage?.id == package.id
                                        ? Color.blue : Color.clear,
                                    lineWidth: 1.5
                                )
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private func renderCheckoutSummarySection() -> some View {
        CheckoutSummaryView(
            packageTitle: viewModel.selectedPackage?.title ?? "",
            packagePrice: viewModel.calculateSubtotal(),
            platformFee: viewModel.platformFee,
            totalCost: viewModel.calculateFinalTotal(),
            isProcessing: viewModel.isBookingInProgress,  // FIXED: Shows a loading spinner while fetching the URL
            payAction: {
                Task {
                    do {
                        // FIXED: Simply call the function, it handles the credentials internally
                        let url = try await viewModel.setupMidtransPayment()
                        self.snapUrlWrapper = PaymentURLWrapper(url: url)
                    } catch {
                        // Error is automatically handled by showErrorAlert
                    }
                }
            }
        )
    }
}
