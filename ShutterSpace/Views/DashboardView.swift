//
//  DashboardView.swift
//  ShutterSpace
//
//  Created by Sean tandjaja on 31/05/26.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    renderActionCards()
                    renderStatCards()
                    renderPendingRequests()
                }
                .padding()
            }
            .navigationTitle(viewModel.photographerName)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            // Navigate to settings view
                        }) {
                            Label("Settings", systemImage: "gear")
                        }
                        
                        Button(role: .destructive, action: {
                            authViewModel.logout()
                        }) {
                            Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundColor(.primary)
                            .padding(8)
                    }
                }
            }
            .task {
                await viewModel.fetchDashboardData()
            }
            .preferredColorScheme(.dark)
            .refreshable {
                await viewModel.fetchDashboardData()
            }
        }
    }
    
    private func renderActionCards() -> some View {
        HStack(spacing: 16) {
            NavigationLink(destination: ManagePortfolioView()) {
                ActionCardView(title: "Manage\nPortfolio", iconName: "photo.on.rectangle")
            }
            .buttonStyle(PlainButtonStyle())
            
            NavigationLink(destination: AddPackageView(portfolioViewModel: ManagePortfolioViewModel())) {
                ActionCardView(title: "Manage\nPackages", iconName: "shippingbox")
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private func renderStatCards() -> some View {
        HStack(spacing: 16) {
            StatCardView(
                iconName: "dollarsign.circle.fill",
                value: "$\(String(format: "%.0f", viewModel.totalEarnings))"
            )
            
            StatCardView(
                iconName: "camera.fill",
                value: "\(viewModel.totalSessions)"
            )
        }
    }
    
    private func renderPendingRequests() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Pending Requests")
                .font(.title3)
                .fontWeight(.bold)
            
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if viewModel.pendingRequests.isEmpty {
                Text("No pending requests.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(viewModel.pendingRequests) { request in
                    PendingRequestRowView(
                        request: request,
                        onAccept: {
                            Task { await viewModel.acceptBooking(bookingId: request.id) }
                        },
                        onDecline: {
                            Task { await viewModel.declineBooking(bookingId: request.id) }
                        }
                    )
                }
            }
        }
    }
}
