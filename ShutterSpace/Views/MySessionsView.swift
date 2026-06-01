//
//  MySessionsView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 01/06/26.
//

import SwiftUI

struct MySessionsView: View {
    @StateObject private var viewModel: MySessionsViewModel = MySessionsViewModel()
    @State private var selectedSessionForReview: SessionItem? = nil

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    renderLoadingState()
                } else if viewModel.activeSessions.isEmpty && viewModel.completedSessions.isEmpty {
                    renderEmptyState()
                } else {
                    renderSessionsList()
                }
            }
            .navigationTitle("My Sessions")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.fetchSessions()
            }
            .onAppear {
                Task { await viewModel.fetchSessions() }
            }
            .refreshable {
                await viewModel.fetchSessions()
            }
            .sheet(item: $selectedSessionForReview) { reviewSession in
                WriteReviewView(session: reviewSession, viewModel: viewModel)
            }
            .overlay(
                Group {
                    if viewModel.shouldShowReviewSubmittedBanner {
                        renderSuccessBanner()
                    }
                },
                alignment: .top
            )
            .preferredColorScheme(.dark)
        }
    }

    private func renderLoadingState() -> some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Loading your sessions...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func renderEmptyState() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 56))
                .foregroundColor(.secondary)
            Text("No Sessions Yet")
                .font(.title3)
                .fontWeight(.semibold)
            Text("Book a photographer to see your sessions here.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func renderSessionsList() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if !viewModel.activeSessions.isEmpty {
                    renderSectionHeader(title: "Active Sessions", iconName: "clock.fill")
                    ForEach(viewModel.activeSessions) { session in
                        SessionRowView(session: session, onLeaveReview: nil)
                    }
                }

                if !viewModel.completedSessions.isEmpty {
                    renderSectionHeader(title: "Completed Sessions", iconName: "checkmark.seal.fill")
                    ForEach(viewModel.completedSessions) { session in
                        SessionRowView(session: session) {
                            selectedSessionForReview = session
                        }
                    }
                }
            }
            .padding()
        }
    }

    private func renderSectionHeader(title: String, iconName: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
                .foregroundColor(.secondary)
                .font(.subheadline)
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
        }
    }

    private func renderSuccessBanner() -> some View {
        HStack(spacing: 10) {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
            Text("Review submitted successfully!")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.regularMaterial)
        .cornerRadius(12)
        .shadow(radius: 8)
        .padding(.top, 12)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                viewModel.shouldShowReviewSubmittedBanner = false
            }
        }
    }
}

#Preview {
    MySessionsView()
}
