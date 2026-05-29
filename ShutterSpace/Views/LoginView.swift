//
//  LoginView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 29/05/26.
//

import SwiftUI

struct LoginView: View {

    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {

        NavigationStack {

            VStack(spacing: 32.0) {
                renderHeader()
                renderForm()
                renderActionButtons()
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
            .preferredColorScheme(.dark)
        }
    }
}

extension LoginView {
    func renderHeader() -> some View {
        VStack(spacing: 8.0) {
            Image(systemName: "camera.aperture")
                .resizable()
                .scaledToFit()
                .frame(width: 80.0, height: 80.0)
                .foregroundColor(.white)
                .padding(.top, 60.0)
            Text("ShutterSpace")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Connecting freelance photographers")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    func renderForm() -> some View {
        VStack(spacing: 16.0) {
            AuthTextField(
                placeholder: "Email Address",
                text: $authViewModel.emailInput,
                isSecure: false
            )
            AuthTextField(
                placeholder: "Access Code",
                text: $authViewModel.accessCodeInput,
                isSecure: true
            )
            if !authViewModel.errorMessage.isEmpty {
                Text(authViewModel.errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    func renderActionButtons() -> some View {
        VStack(spacing: 16.0) {
            Button(action: {
                Task {
                    await authViewModel.login()
                }
            }) {
                ZStack {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(
                                CircularProgressViewStyle(tint: .black)
                            )
                    } else {
                        Text("Log In")
                            .font(.headline)
                    }
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 50.0)
                .background(Color.white)
                .cornerRadius(12.0)
            }
            .disabled(
                authViewModel.isLoading || authViewModel.emailInput.isEmpty
                    || authViewModel.accessCodeInput.isEmpty
            )
            NavigationLink(
                destination: RegisterView(authViewModel: authViewModel)
            ) {
                Text("Don't have an account? Sign Up")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    LoginView()
}
