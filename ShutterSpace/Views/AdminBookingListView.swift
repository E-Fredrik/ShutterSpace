//
//  AdminBookingListView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 03/06/26.
//

import SwiftUI

struct AdminBookingListView: View {
    @StateObject private var viewModel = AdminBookingViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.filteredBookings) { booking in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("ID: \(booking.id.prefix(8))...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(booking.status)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(statusColor(for: booking.status).opacity(0.2))
                            .foregroundColor(statusColor(for: booking.status))
                            .cornerRadius(8)
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Client: \(booking.clientId.prefix(5))")
                                .font(.subheadline)
                            Text("Photog: \(booking.photographerId.prefix(5))")
                                .font(.subheadline)
                        }
                        Spacer()
                        // FIXED: Display as Rupiah with no decimals
                        Text("Rp \(String(format: "%.0f", booking.price))")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    
                    Text("Date: \(booking.date)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("All Bookings")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.searchText, prompt: "Search ID or Status")
        .refreshable {
            await viewModel.fetchAllBookings()
        }
        .task {
            await viewModel.fetchAllBookings()
        }
        .overlay {
            if viewModel.isLoading && viewModel.allBookings.isEmpty {
                ProgressView()
            } else if !viewModel.isLoading && viewModel.allBookings.isEmpty {
                Text("No bookings found on the platform.")
                    .foregroundColor(.secondary)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "completed": return .green
        case "pending", "accepted": return .orange
        case "cancelled", "declined": return .red
        default: return .gray
        }
    }
}
