//
//  UserProfileView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 29/05/26.
//

import SwiftUI

struct UserProfileView: View {
    @StateObject private var profileViewModel = UserProfileViewModel()
    @AppStorage("currentUserRole") private var currentUserRole: String =
        "Client"
    @AppStorage("currentUserId") private var currentUserId: String = ""

    @State private var isShowingEditProfile = false
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32.0) {
                    renderProfileHeader()
                    renderActionMenu()
                }
                .padding()
            }
            .navigationTitle("My Profile")
            .task {
                await profileViewModel.fetchCurrentUser()
            }
        }
    }
}

extension UserProfileView {
    func renderProfileHeader() -> some View {
        VStack(spacing: 16.0) {
            if profileViewModel.isLoading {
                ProgressView()
                    .frame(width: 120.0, height: 120.0)
            } else {
                AsyncImage(url: URL(string: profileViewModel.profileImageUrl)) {
                    phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure(_):
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.secondary)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 120.0, height: 120.0)
                .clipShape(Circle())
            }
            VStack(spacing: 4.0) {
                Text(
                    "\(profileViewModel.firstName) \(profileViewModel.lastName)"
                )
                .font(.title2)
                .fontWeight(.bold)
                Text(profileViewModel.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(currentUserRole.uppercased())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12.0)
                    .padding(.vertical, 4.0)
                    .background(Color(UIColor.tertiarySystemFill))
                    .cornerRadius(8.0)
                    .padding(.top, 4.0)
            }
        }
        .padding(.top, 24.0)
    }

    @ViewBuilder
    func renderActionMenu() -> some View {
        VStack(spacing: 0.0) {
            Button(action: {
                isShowingEditProfile = true
            }) {
                HStack {
                    Image(systemName: "pencil")
                        .frame(width: 30.0)
                    Text("Edit Profile")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .foregroundColor(.primary)
            }

            Divider()

            if currentUserRole == "Photographer" {
                NavigationLink(destination: ManagePortfolioView()) {
                    HStack {
                        Image(systemName: "photo.on.rectangle.angled")
                            .frame(width: 30.0)
                        Text("Manage Portfolio")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .foregroundColor(.primary)
                }

                Divider()
            }
            Button(action: {
                profileViewModel.logout()
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .frame(width: 30.0)
                    Text("Log Out")
                    Spacer()
                }
                .padding()
                .foregroundColor(.red)
            }
        }
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12.0)
        .sheet(
            isPresented: $isShowingEditProfile,
            onDismiss: {
                Task { await profileViewModel.fetchCurrentUser() }
            }
        ) {
            EditProfileView(userId: currentUserId, userRole: currentUserRole)
        }
    }
}

#Preview {
    UserProfileView()
}
