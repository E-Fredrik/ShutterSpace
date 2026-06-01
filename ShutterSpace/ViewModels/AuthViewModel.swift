//
//  AuthViewModel.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 29/05/26.
//

import Combine
import FirebaseDatabase
import Foundation
import PhotosUI
import SwiftUI
import _PhotosUI_SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var emailInput: String = ""
    @Published var accessCodeInput: String = ""
    @Published var firstNameInput: String = ""
    @Published var lastNameInput: String = ""
    @Published var selectedRole: String = "Client"
    @Published var selectedPhotoItem: PhotosPickerItem? = nil
    @Published var profileImageData: Data? = nil
    @Published var profileImageDisplay: Image? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var isAuthenticated: Bool = false

    private let databaseRef = Database.database().reference()

    func login() async {
        isLoading = true
        errorMessage = ""

        do {
            let snapshot = try await databaseRef.child("users")
                .queryOrdered(byChild: "email")
                .queryEqual(toValue: emailInput)
                .getData()

            guard
                let children = snapshot.children.allObjects as? [DataSnapshot],
                !children.isEmpty
            else {
                throw URLError(.userAuthenticationRequired)
            }

            var userFound = false

            for child in children {
                if let dict = child.value as? [String: Any],
                    let storedAccessCode = dict["access_code"] as? String,
                    storedAccessCode == accessCodeInput
                {
                    let fetchedId = dict["id"] as? String ?? ""
                    let fetchedRole = dict["role"] as? String ?? "Client"
                    UserDefaults.standard.set(
                        fetchedId,
                        forKey: "currentUserId"
                    )
                    UserDefaults.standard.set(
                        fetchedRole,
                        forKey: "currentUserRole"
                    )
                    userFound = true
                    break
                }
            }

            if userFound {
                isAuthenticated = true
            } else {
                errorMessage = "Invalid access code"
            }

        } catch {
            errorMessage = "Login failed. Please check your credentials."
        }

        isLoading = false
    }

    func register() async {
        isLoading = true
        errorMessage = ""

        let formattedEmail = emailInput.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).lowercased()
        let formattedAccessCode = accessCodeInput.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        do {
            let snapshot = try await databaseRef.child("users")
                .queryOrdered(byChild: "email")
                .queryEqual(toValue: formattedEmail)
                .getData()

            if let children = snapshot.children.allObjects as? [DataSnapshot],
                !children.isEmpty
            {
                errorMessage =
                    "This email is already registered. Please log in."
                isLoading = false
                return
            }

            let newUserId = UUID().uuidString
            var uploadedImageUrl = ""

            if let imageData = profileImageData {
                let rawUrl = try await uploadImageToCloudinary(data: imageData)
                uploadedImageUrl = optimizeCloudinaryUrl(
                    from: rawUrl,
                    width: 400
                )
            }

            var userData: [String: Any] = [
                "id": newUserId,
                "firstName": firstNameInput.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
                "lastName": lastNameInput.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
                "email": formattedEmail,
                "role": selectedRole,
                "access_code": formattedAccessCode,
            ]

            if selectedRole == "Photographer" {
                userData["stripeAccountId"] = ""
                userData["rating"] = 5.0
                userData["location"] = "Unspecified"
                userData["category"] = "General"
                userData["profileImageUrl"] = uploadedImageUrl
            } else {
                userData["preferences"] = ""
                userData["profileImageUrl"] = uploadedImageUrl
            }

            try await databaseRef.child("users").child(newUserId)
                .setValue(userData)

            UserDefaults.standard.set(newUserId, forKey: "currentUserId")
            UserDefaults.standard.set(selectedRole, forKey: "currentUserRole")

        } catch {
            errorMessage = "Registration failed. Please try again."
        }

        isLoading = false
    }
    func logout() {
        UserDefaults.standard.removeObject(forKey: "currentUserId")
        UserDefaults.standard.removeObject(forKey: "currentUserRole")
        
        self.isAuthenticated = false
        self.emailInput = ""
        self.accessCodeInput = ""
    }

    func processImageSelection(item: PhotosPickerItem?) {
        guard let item = item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
                let uiImage = UIImage(data: data)
            {
                self.profileImageData = data
                self.profileImageDisplay = Image(uiImage: uiImage)
            }
        }
    }

    private func uploadImageToCloudinary(data: Data) async throws -> String {
        guard
            let cloudName = Bundle.main.object(
                forInfoDictionaryKey: "CloudinaryCloudName"
            ) as? String,
            let uploadPreset = Bundle.main.object(
                forInfoDictionaryKey: "CloudinaryUploadPreset"
            ) as? String,
            let url = URL(
                string:
                    "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload"
            )
        else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append(
            "Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n"
                .data(using: .utf8)!
        )
        body.append("\(uploadPreset)\r\n".data(using: .utf8)!)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append(
            "Content-Disposition: form-data; name=\"file\"; filename=\"profile.jpg\"\r\n"
                .data(using: .utf8)!
        )
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        let (responseData, response) = try await URLSession.shared.upload(
            for: request,
            from: body
        )

        guard let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200,
            let jsonResponse = try JSONSerialization.jsonObject(
                with: responseData
            ) as? [String: Any],
            let secureUrl = jsonResponse["secure_url"] as? String
        else {
            throw URLError(.badServerResponse)
        }

        return secureUrl
    }

    private func optimizeCloudinaryUrl(from originalUrl: String, width: Int)
        -> String
    {
        if originalUrl.contains("c_scale") {
            return originalUrl
        }
        return originalUrl.replacingOccurrences(
            of: "/upload/",
            with:
                "/upload/w_\(width),c_scale,q_auto,f_auto,c_fill,ar_1:1,g_face/"
        )
    }
}
