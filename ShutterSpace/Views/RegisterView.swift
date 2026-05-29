//
//  RegisterView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 29/05/26.
//

import PhotosUI
import SwiftUI

struct RegisterView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismissView

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
    }
}

extension RegisterView {
    func renderPhotoSelector() -> some View {
        PhotosPicker(selection: $authViewModel.selectedPhotoItem, matching: .images) {
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
        .onChange(of: authViewModel.selectedPhotoItem) { newlySelectedItem in
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
            HStack(spacing: 16.0) {
                AuthTextField(placeholder: "First Name", text: $authViewModel.firstNameInput, isSecure: false)
                AuthTextField(placeholder: "Last Name", text: $authViewModel.lastNameInput, isSecure: false)
            }
            AuthTextField(placeholder: "Email Address", text: $authViewModel.emailInput, isSecure: false)
            AuthTextField(placeholder: "Create Access Code", text: $authViewModel.accessCodeInput, isSecure: true)
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
        Button(action: {
            Task {
                await authViewModel.register()
            }
        }) {
            ZStack {
                if authViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
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
        .disabled(authViewModel.isLoading || authViewModel.emailInput.isEmpty || authViewModel.accessCodeInput.isEmpty || authViewModel.firstNameInput.isEmpty)
    }
}

#Preview {
    RegisterView(authViewModel: AuthViewModel())
}
