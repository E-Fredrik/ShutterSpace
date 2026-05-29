//
//  EditProfileViewModel.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 29/05/26.
//

import Foundation
import Combine
import SwiftUI
import PhotosUI
import FirebaseDatabase

@MainActor
class EditProfileViewModel: ObservableObject {
    
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var location: String = ""
    @Published var category: String = ""
    @Published var preferences: String = ""
    
    @Published var selectedPhotoItem: PhotosPickerItem? = nil
    @Published var profileImageData: Data? = nil
    @Published var profileImageDisplay: Image? = nil
    @Published var currentImageUrl: String = ""
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    
    private let databaseReference = Database.database().reference()
    let userId: String
    let userRole: String
    
    init(userId: String, userRole: String) {
        self.userId = userId
        self.userRole = userRole
    }
    
    func fetchUserData() async {
        
        isLoading = true
        
        do {
            let snapshot = try await databaseReference.child("users").child(userId).getData()
            
            if let dict = snapshot.value as? [String: Any] {
                self.firstName = dict["firstName"] as? String ?? ""
                self.lastName = dict["lastName"] as? String ?? ""
                self.currentImageUrl = dict["profileImageUrl"] as? String ?? ""
                
                if userRole == "Photographer" {
                    self.location = dict["location"] as? String ?? ""
                    self.category = dict["category"] as? String ?? ""
                } else {
                    self.preferences = dict["preferences"] as? String ?? ""
                }
            }
        } catch {
            self.errorMessage = "Failed to load profile data."
        }
        
        isLoading = false
    }
    
    func saveProfile() async -> Bool {
        
        isLoading = true
        errorMessage = ""
        
        do {
            var updatedData: [String: Any] = [
                "firstName": firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                "lastName": lastName.trimmingCharacters(in: .whitespacesAndNewlines)
            ]
            
            if let imageData = profileImageData {
                let rawUrl = try await uploadImageToCloudinary(data: imageData)
                let optimizedUrl = optimizeCloudinaryUrl(from: rawUrl, width: 400)
                updatedData["profileImageUrl"] = optimizedUrl
            }
            
            if userRole == "Photographer" {
                updatedData["location"] = location.trimmingCharacters(in: .whitespacesAndNewlines)
                updatedData["category"] = category.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                updatedData["preferences"] = preferences.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            try await databaseReference.child("users").child(userId).updateChildValues(updatedData)
            
            isLoading = false
            return true
            
        } catch {
            errorMessage = "Failed to update profile."
            isLoading = false
            return false
        }
    }
    
    func processImageSelection(item: PhotosPickerItem?) {
        
        guard let item = item else { return }
        
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                
                self.profileImageData = data
                self.profileImageDisplay = Image(uiImage: uiImage)
            }
        }
    }
    
    private func uploadImageToCloudinary(data: Data) async throws -> String {
        
        guard let cloudName = Bundle.main.object(forInfoDictionaryKey: "CloudinaryCloudName") as? String,
              let uploadPreset = Bundle.main.object(forInfoDictionaryKey: "CloudinaryUploadPreset") as? String,
              let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(uploadPreset)\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        let (responseData, response) = try await URLSession.shared.upload(for: request, from: body)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
              let jsonResponse = try JSONSerialization.jsonObject(with: responseData) as? [String: Any],
              let secureUrl = jsonResponse["secure_url"] as? String else {
            throw URLError(.badServerResponse)
        }
        
        return secureUrl
    }
    
    private func optimizeCloudinaryUrl(from originalUrl: String, width: Int) -> String {
        
        if originalUrl.contains("c_scale") { return originalUrl }
        return originalUrl.replacingOccurrences(of: "/upload/", with: "/upload/w_\(width),c_scale,q_auto,f_auto,c_fill,ar_1:1,g_face/")
    }
}
