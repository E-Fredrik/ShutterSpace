//
//  AdminUserListView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 03/06/26.
//



import SwiftUI

struct AdminUserListView: View {
    @StateObject private var viewModel = AdminDashboardViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.filteredUsers) { user in
                NavigationLink(destination: AdminUserDetailView(user: user)) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(user.firstName) \(user.lastName)")
                                .font(.headline)
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Badges for role
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(user.role)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(UIColor.tertiarySystemFill))
                                .cornerRadius(4)
                            
                            Text("Manage")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Manage Users")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.searchText, prompt: "Search by name or email")
        .refreshable {
            await viewModel.fetchAllUsers()
        }
        .task {
            await viewModel.fetchAllUsers()
        }
        .preferredColorScheme(.dark)
        .overlay {
            if viewModel.isLoading && viewModel.allUsers.isEmpty {
                ProgressView()
            } else if !viewModel.isLoading && viewModel.filteredUsers.isEmpty {
                Text("No users found.")
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AdminUserListView()
    }
}
