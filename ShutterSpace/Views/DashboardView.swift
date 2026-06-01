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

    @State private var sessionToComplete: AcceptedSession? = nil
    @State private var isShowingCompleteSheet: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    renderActionCards()
                    renderStatCards()
                    renderPendingRequests()
                    renderAcceptedSessions()
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

                        Button(
                            role: .destructive,
                            action: {
                                authViewModel.logout()
                            }
                        ) {
                            Label(
                                "Log Out",
                                systemImage:
                                    "rectangle.portrait.and.arrow.right"
                            )
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
            .sheet(isPresented: $isShowingCompleteSheet) {
                renderCompleteSessionSheet()
            }
        }
    }

    private func renderActionCards() -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                NavigationLink(destination: ManagePortfolioView()) {
                    ActionCardView(
                        title: "Manage\nPortfolio",
                        iconName: "photo.on.rectangle"
                    )
                }
                .buttonStyle(PlainButtonStyle())

                NavigationLink(
                    destination: AddPackageView(
                        portfolioViewModel: ManagePortfolioViewModel()
                    )
                ) {
                    ActionCardView(
                        title: "Manage\nPackages",
                        iconName: "shippingbox"
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }

            NavigationLink(destination: ManageAvailabilityView()) {
                ActionCardView(
                    title: "Manage\nAvailability",
                    iconName: "clock.badge.checkmark"
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }


    private func renderStatCards() -> some View {
        HStack(spacing: 16) {
            // FIX: Changed from dollarsign to banknote, and $ to Rp
            StatCardView(
                iconName: "banknote.fill",
                value: "Rp \(String(format: "%.0f", viewModel.totalEarnings))"
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
                            Task {
                                await viewModel.acceptBooking(
                                    bookingId: request.id
                                )
                            }
                        },
                        onDecline: {
                            Task {
                                await viewModel.declineBooking(
                                    bookingId: request.id
                                )
                            }
                        }
                    )
                }
            }
        }
    }

    private func renderAcceptedSessions() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Upcoming Gigs")
                .font(.title3)
                .fontWeight(.bold)

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if viewModel.acceptedSessions.isEmpty {
                Text("No upcoming gigs.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(viewModel.acceptedSessions) { session in
                    
                    AcceptedSessionRowView(
                        session: session,
                        onMarkCompleted: {
                            // Automatically triggers the complete sheet
                            self.sessionToComplete = session
                            self.isShowingCompleteSheet = true
                        }
                    )
                }
            }
        }
    }

    private func renderCompleteSessionSheet() -> some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.seal")
                        .font(.system(size: 48))
                        .foregroundColor(.green)
                    Text("Mark Session as Completed")
                        .font(.title3)
                        .fontWeight(.bold)
                    if let session = sessionToComplete {
                        Text("Client: \(session.clientName)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 24)

                Button {
                    if let session = sessionToComplete {
                        isShowingCompleteSheet = false
                        Task {
                            await viewModel.markSessionAsCompleted(
                                bookingId: session.id,
                                totalCost: session.totalCost
                            )
                        }
                    }
                } label: {
                    Text("Confirm Completion")
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isShowingCompleteSheet = false
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}
