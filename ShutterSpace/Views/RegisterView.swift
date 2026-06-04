//
//  RegisterView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 29/05/26.
//

import PhotosUI
import SwiftUI

@MainActor
struct RegisterView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismissView

    let availableCategories = [
        "Wedding", "Portrait", "Landscape", "Event", "Fashion", "Food",
        "Travel", "Custom",
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24.0) {
                renderPhotoSelector()
                renderRoleSelector()
                renderForm()
                renderActionButtons()
            }
            .padding()
        }
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .animation(.easeInOut, value: authViewModel.selectedRole)
        .animation(.easeInOut, value: authViewModel.selectedCategory)
        // NEW: Dismiss this view back to the Login Page upon success
        .onChange(of: authViewModel.isAuthenticated) { _, isAuthenticated in
            if isAuthenticated {
                dismissView()
            }
        }
    }
}

extension RegisterView {
    func renderPhotoSelector() -> some View {
        PhotosPicker(
            selection: $authViewModel.selectedPhotoItem,
            matching: .images
        ) {
            ZStack {
                if let profileImageDisplay = authViewModel.profileImageDisplay {
                    profileImageDisplay
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120.0, height: 120.0)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color(UIColor.secondarySystemBackground))
                        .frame(width: 120.0, height: 120.0)
                    Image(systemName: "camera.fill")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                }
            }
        }
        .onChange(of: authViewModel.selectedPhotoItem) { _, newlySelectedItem in
            authViewModel.processImageSelection(item: newlySelectedItem)
        }
        .padding(.top, 20.0)
    }

    func renderRoleSelector() -> some View {
        Picker("Role", selection: $authViewModel.selectedRole) {
            Text("Client").tag("Client")
            Text("Photographer").tag("Photographer")
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.vertical, 8.0)
    }

    func renderForm() -> some View {
        VStack(spacing: 16.0) {

            HStack(alignment: .top, spacing: 16.0) {
                VStack(alignment: .leading, spacing: 4) {
                    AuthTextField(
                        placeholder: "First Name",
                        text: $authViewModel.firstNameInput,
                        isSecure: false
                    )
                }

                VStack(alignment: .leading, spacing: 4) {
                    AuthTextField(
                        placeholder: "Last Name",
                        text: $authViewModel.lastNameInput,
                        isSecure: false
                    )
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                AuthTextField(
                    placeholder: "Email Address",
                    text: $authViewModel.emailInput,
                    isSecure: false,
                    keyboardType: .emailAddress
                )

                if !authViewModel.emailInput.isEmpty
                    && !authViewModel.isValidEmail
                {
                    Text("Please enter a valid email address.")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.leading, 4)
                }
            }

            if authViewModel.selectedRole == "Photographer" {
                VStack(alignment: .leading, spacing: 4) {
                    AuthTextField(
                        placeholder: "Location (e.g. Surabaya)",
                        text: $authViewModel.locationInput,
                        isSecure: false
                    )
                }

                // ADDED: The Category Selection UI
                VStack(alignment: .leading, spacing: 8) {
                    Menu {
                        Picker("", selection: $authViewModel.selectedCategory) {
                            ForEach(availableCategories, id: \.self) {
                                category in
                                Text(category).tag(category)
                            }
                        }
                    } label: {
                        HStack {
                            Text(authViewModel.selectedCategory)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.up.chevron.down")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .font(.body)
                    }

                    if authViewModel.selectedCategory == "Custom" {
                        AuthTextField(
                            placeholder: "Enter custom category",
                            text: $authViewModel.customCategoryInput,
                            isSecure: false
                        )
                    }
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                AuthTextField(
                    placeholder: "Create Access Code",
                    text: $authViewModel.accessCodeInput,
                    isSecure: true
                )
            }

            if !authViewModel.errorMessage.isEmpty {
                Text(authViewModel.errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    @ViewBuilder
    func renderActionButtons() -> some View {
        let isRegisterDisabled =
            authViewModel.isLoading || !authViewModel.isRegisterFormValid

        Button(action: {
            Task {
                await authViewModel.register()
            }
        }) {
            ZStack {
                if authViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle(tint: .black)
                        )
                } else {
                    Text("Register")
                        .font(.headline)
                }
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 50.0)
            .background(Color.white)
            .cornerRadius(12.0)
        }
        .padding(.top, 16.0)
        .disabled(isRegisterDisabled)
        .opacity(isRegisterDisabled ? 0.5 : 1.0)
    }
}

#Preview {
    RegisterView(authViewModel: AuthViewModel())
}
