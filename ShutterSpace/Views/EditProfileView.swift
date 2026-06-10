//
//  EditProfileView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 29/05/26.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismissView
    @StateObject private var editViewModel: EditProfileViewModel

    init(userId: String, userRole: String) {
        _editViewModel = StateObject(
            wrappedValue: EditProfileViewModel(
                userId: userId,
                userRole: userRole
            )
        )
    }
    
    var body: some View {
        NavigationStack {
            Form {
                renderPhotoSection()
                renderPersonalInfoSection()
                renderRoleSpecificSection()
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismissView()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            let success = await editViewModel.saveProfile()
                            if success {
                                dismissView()
                            }
                        }
                    }
                    .disabled(editViewModel.isLoading || editViewModel.firstName.isEmpty || editViewModel.lastName.isEmpty || (editViewModel.userRole == "Photographer" && editViewModel.category.isEmpty))
                }
            }
            .task {
                await editViewModel.fetchUserData()
            }
            .overlay {
                if editViewModel.isLoading {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                }
            }
            .preferredColorScheme(.dark)
            .animation(.easeInOut, value: editViewModel.category)
        }
    }
}

extension EditProfileView {
    func renderPhotoSection() -> some View {
        Section {
            HStack {
                Spacer()
                PhotosPicker(selection: $editViewModel.selectedPhotoItem, matching: .images) {
                    ZStack {
                        if let displayImage = editViewModel.profileImageDisplay {
                            displayImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100.0, height: 100.0)
                                .clipShape(Circle())
                        } else if !editViewModel.currentImageUrl.isEmpty {
                            AsyncImage(url: URL(string: editViewModel.currentImageUrl)) { phase in
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
                            .frame(width: 100.0, height: 100.0)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100.0, height: 100.0)
                                .foregroundColor(.secondary)
                        }
                        
                        Circle()
                            .fill(Color.black.opacity(0.4))
                            .frame(width: 100.0, height: 100.0)
                        
                        Image(systemName: "camera.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .onChange(of: editViewModel.selectedPhotoItem) { newlySelectedItem in
                    editViewModel.processImageSelection(item: newlySelectedItem)
                }
                
                Spacer()
            }
            .listRowBackground(Color.clear)
        }
    }
    
    func renderPersonalInfoSection() -> some View {
        Section(header: Text("Personal Information")) {
            TextField("First Name", text: $editViewModel.firstName)
            TextField("Last Name", text: $editViewModel.lastName)
        }
    }
    
    func renderRoleSpecificSection() -> some View {
        Section {
            if editViewModel.userRole == "Photographer" {
                TextField("Location", text: $editViewModel.location)
                
                Picker("Category", selection: $editViewModel.category) {
                    ForEach(editViewModel.availableCategories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                
                if editViewModel.category == "Custom" {
                    TextField("Enter custom category", text: $editViewModel.customCategoryInput)
                }
                
            } else {
                TextField("Aesthetic Preferences", text: $editViewModel.preferences, axis: .vertical)
                    .lineLimit(3...6)
            }
        } header: {
            Text(editViewModel.userRole == "Photographer" ? "Professional Details" : "Client Preferences")
        }
    }
}

#Preview {
    EditProfileView(userId: "USER-001", userRole: "Photographer")
}
