//
//  ProfileDetailView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 29/05/26.
//

import SwiftUI

struct ProfileDetailView: View {
    let photographerDetails: Photographer
    @StateObject private var profileViewModel: ProfileDetailViewModel
    @State private var selectedTabDisplay: Int = 0

    init(photographerDetails: Photographer) {
        self.photographerDetails = photographerDetails
        self._profileViewModel = StateObject(
            wrappedValue: ProfileDetailViewModel(
                photographerId: photographerDetails.id
            )
        )
    }

    var body: some View {
        VStack(spacing: 0.0) {
            ScrollView {
                VStack(spacing: 24.0) {
                    renderProfileHeader()
                    Picker("", selection: $selectedTabDisplay) {
                        Text("Portfolio").tag(0)
                        Text("Packages").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    if selectedTabDisplay == 0 {
                        renderPortfolioGrid()
                    } else {
                        renderPackagesList()
                    }
                }
                .padding(.bottom, 100.0)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await profileViewModel.fetchProfileData()
        }
        .overlay(alignment: .bottom) {
            renderBottomActionArea()
        }
        .preferredColorScheme(.dark)
    }
}

extension ProfileDetailView {
    func renderProfileHeader() -> some View {
        VStack(spacing: 16.0) {
            AsyncImage(url: URL(string: photographerDetails.profileImageUrl)) {
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
            .frame(width: 100.0, height: 100.0)
            .clipShape(Circle())
            .padding(.top, 16.0)
            VStack(spacing: 8.0) {
                Text(
                    "\(photographerDetails.firstName) \(photographerDetails.lastName)"
                )
                .font(.title)
                .fontWeight(.bold)
                Text(photographerDetails.category)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack(spacing: 16.0) {
                    HStack(spacing: 4.0) {
                        Image(systemName: "star.fill").foregroundColor(.yellow)
                        Text(String(format: "%.1f", photographerDetails.rating))
                            .fontWeight(.medium)
                    }
                    HStack(spacing: 4.0) {
                        Image(systemName: "mappin.and.ellipse").foregroundColor(
                            .secondary
                        )
                        Text(photographerDetails.location)
                            .foregroundColor(.secondary)
                    }
                }
                .font(.subheadline)
            }
        }
    }
    
    func renderPortfolioGrid() -> some View {
        if profileViewModel.isLoading {
            AnyView(
                ProgressView()
                    .padding(.top, 40.0)
            )
        } else if profileViewModel.portfolioImageUrls.isEmpty {
            AnyView(
                Text("No portfolio images available.")
                    .foregroundColor(.secondary)
                    .padding(.top, 40.0)
            )
        } else {
            AnyView(
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 2.0
                ) {
                    ForEach(profileViewModel.portfolioImageUrls, id: \.self) { imageUrl in
                        AsyncImage(url: URL(string: imageUrl)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(
                                        maxWidth: .infinity,
                                        maxHeight: .infinity
                                    )
                                    .background(Color(UIColor.tertiarySystemFill))
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(1.0, contentMode: .fill)
                            case .failure(_):
                                VStack(spacing: 4.0) {
                                    Image(systemName: "photo.badge.exclamationmark")
                                        .foregroundColor(.gray)
                                    Text("Error")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color(UIColor.tertiarySystemFill))
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .aspectRatio(1.0, contentMode: .fill)
                        .clipped()
                    }
                }
                .padding(.horizontal, 2.0)
            )
        }
    }

    func renderPackagesList() -> some View {
        if profileViewModel.isLoading {
            AnyView(
                ProgressView()
                    .padding(.top, 40.0)
            )
        } else if profileViewModel.servicePackages.isEmpty {
            AnyView(
                Text("No service packages available.")
                    .foregroundColor(.secondary)
                    .padding(.top, 40.0)
            )
        } else {
            AnyView(
                VStack(spacing: 0.0) {
                    ForEach(profileViewModel.servicePackages) { currentPackage in
                        PackageRowView(activeServicePackage: currentPackage)
                            .padding(.horizontal)
                            .padding(.vertical, 8.0)
                        Divider()
                            .padding(.leading)
                    }
                }
            )
        }
    }

    func renderBottomActionArea() -> some View {
        VStack {
            Divider()
            HStack(spacing: 16.0) {
                Button(action: {
                    
                }) {
                    Image(systemName: "message.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 50.0, height: 50.0)
                        .background(Color(UIColor.darkGray))
                        .clipShape(Circle())
                }
                Button(action: {

                }) {
                    Text("Book Session")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50.0)
                        .background(Color.white)
                        .cornerRadius(25.0)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12.0)
            .background(
                Color(UIColor.systemBackground).ignoresSafeArea(edges: .bottom)
            )
        }
    }
}

#Preview {
    ProfileDetailView(
        photographerDetails: Photographer(
            id: "photo_001",
            firstName: "Alia",
            lastName: "Rahman",
            email: "alia.rahman@example.com",
            access_code: "DEMO-ACCESS",
            stripeAccountId: "acct_123TEST",
            rating: 4.7,
            location: "San Francisco, CA",
            category: "Portrait",
            profileImageUrl: "person.circle.fill"
        )
    )
}
