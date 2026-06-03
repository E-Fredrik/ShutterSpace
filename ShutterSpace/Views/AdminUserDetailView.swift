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
                }
                .padding(.top)
                
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Account Action")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            Task { await viewModel.changeStatus(to: "Active") }
                        }) {
                            Text("Reactivate")
                                .fontWeight(.semibold)
                                .frame(width: .infinity, height: 44)
                                .background(Color.green.opacity(0.2))
                                .foregroundColor(.green)
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            Task { await viewModel.changeStatus(to: "Suspended") }
                        }) {
                            Text("Suspend")
                                .fontWeight(.semibold)
                                .frame(width: .infinity, height: 44)
                                .background(Color.orange.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            Task { await viewModel.changeStatus(to: "Banned") }
                        }) {
                            Text("Ban User")
                                .fontWeight(.semibold)
                                .frame(width: .infinity, height: 44)
                                .background(Color.red.opacity(0.2))
                                .foregroundColor(.red)
                                .cornerRadius(8)
                        }
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
