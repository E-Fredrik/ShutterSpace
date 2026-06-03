//
//  AdminFinancialReportView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 03/06/26.
//


import SwiftUI

struct AdminFinancialReportView: View {
    @StateObject private var viewModel = AdminBookingViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                
                VStack(spacing: 12) {
                    Text("Total Platform Revenue")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    
                    Text("Rp \(String(format: "%.0f", viewModel.totalPlatformRevenue))")
                        .font(.system(size: 40, weight: .bold)) // Slightly smaller font to fit larger IDR numbers
                        .foregroundColor(.green)
                    
                    Text("Based on a 10% platform fee from completed sessions.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
                
                // Secondary Stats
                HStack(spacing: 16) {
                    StatCard(
                        title: "Total Volume",
                        amount: viewModel.totalPlatformVolume,
                        icon: "arrow.up.right.circle.fill",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Pending Payouts",
                        amount: viewModel.pendingPayouts,
                        icon: "clock.fill",
                        color: .orange
                    )
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Financials")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await viewModel.fetchAllBookings()
        }
        .task {
            await viewModel.fetchAllBookings()
        }
        .overlay {
            if viewModel.isLoading && viewModel.totalPlatformVolume == 0 {
                ProgressView()
            }
        }
        .preferredColorScheme(.dark)
    }
}

