//
//  AdminUserDetailView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 03/06/26.
//

import SwiftUI

struct AdminUserDetailView: View {
    @StateObject private var viewModel: AdminUserDetailViewModel
    
    init(user: User) {
        _viewModel = StateObject(wrappedValue: AdminUserDetailViewModel(user: user))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // 1. User Info Header
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.badge.exclamationmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.red)
                    
                    Text("\(viewModel.user.firstName) \(viewModel.user.lastName)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(viewModel.user.email)
                        .foregroundColor(.secondary)
                    
                    Text("ID: \(viewModel.user.id)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    
                    Text("Current Status: \(viewModel.currentStatus)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(statusColor(for: viewModel.currentStatus))
                        .padding(.top, 4)
                        .accessibilityIdentifier("admin_status_text")
                }
                .padding(.top)
                
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Account Actions")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        actionButton(title: "Reactivate", color: .green, status: "Active", identifier: "admin_reactivate_button")
                        actionButton(title: "Suspend", color: .orange, status: "Suspended", identifier: "admin_suspend_button")
                        actionButton(title: "Ban User", color: .red, status: "Banned", identifier: "admin_ban_button")
                    }
                }
                .padding(.horizontal)
                
                Divider().padding(.vertical, 8)
                
                // 3. Chat Log Review Area
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Recent Chat Logs")
                            .font(.headline)
                        Spacer()
                        Button("Refresh") {
                            Task { await viewModel.fetchRecentChats() }
                        }
                        .font(.caption)
                    }
                    
                    if viewModel.isLoadingChats {
                        ProgressView().padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else if viewModel.recentMessages.isEmpty {
                        Text("No recent messages found for this user.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(8)
                    } else {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(viewModel.recentMessages, id: \.self) { msg in
                                Text(msg)
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
            }
        }
        .navigationTitle("Manage User")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .task {
            // Fetch everything when the view appears
            await viewModel.fetchInitialData()
        }
    }
    
    // Helper to create modern action buttons
    @ViewBuilder
    private func actionButton(title: String, color: Color, status: String, identifier: String) -> some View {
        let isCurrent = viewModel.currentStatus == status
        
        Button(action: {
            Task { await viewModel.changeStatus(to: status) }
        }) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isCurrent ? color : color.opacity(0.15))
                .foregroundColor(isCurrent ? .black : color)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: isCurrent ? 0 : 1)
                )
        }
        .disabled(isCurrent)
        .opacity(isCurrent ? 0.6 : 1.0)
        .accessibilityIdentifier(identifier)
    }
    
    // Helper function for dynamic UI coloring
    private func statusColor(for status: String) -> Color {
        switch status {
        case "Active": return .green
        case "Suspended": return .orange
        case "Banned": return .red
        default: return .primary
        }
    }
}

#Preview {
    AdminUserDetailView(
        user: User(
            id: "12345",
            firstName: "John",
            lastName: "Doe",
            email: "john.doe@example.com",
            role: "Admin"
        )
    )
}
