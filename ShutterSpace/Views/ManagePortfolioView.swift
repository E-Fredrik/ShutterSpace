//
//  ManagePortfolioView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 28/05/26.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct ManagePortfolioView: View {

    @StateObject private var portfolioViewModel: ManagePortfolioViewModel =
        ManagePortfolioViewModel()
    @State private var selectedTabDisplay: Int = 0
    @State private var isShowingAddPackageSheet: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                Picker("", selection: $selectedTabDisplay) {
                    Text("Portfolio").tag(0)
                    Text("Packages").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if selectedTabDisplay == 0 {
                    renderPortfolioGrid()
                } else {
                    renderPackagesList()
                }
            }
            .navigationTitle(Text("Manage"))
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await portfolioViewModel.loadPortfolioData()
            }
            .sheet(isPresented: $isShowingAddPackageSheet) {
                AddPackageView(portfolioViewModel: portfolioViewModel)
            }
            .preferredColorScheme(.dark)
        }
    }
}

extension ManagePortfolioView {
    func renderPortfolioGrid() -> some View {

        ScrollView {

            LazyVGrid(
                columns: [
                    GridItem(.flexible()), GridItem(.flexible()),
                    GridItem(.flexible()),
                ],
                spacing: 2.0
            ) {

                PhotosPicker(
                    selection: $portfolioViewModel.selectedPhotoItem,
                    matching: .images
                ) {
                    ZStack {
                        Rectangle()
                            .fill(Color(UIColor.secondarySystemBackground))
                            .aspectRatio(1.0, contentMode: .fit)

                        if portfolioViewModel.isDataLoading {
                            ProgressView()
                        } else {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .disabled(portfolioViewModel.isDataLoading)
                .onChange(of: portfolioViewModel.selectedPhotoItem) {
                    newlySelectedItem in
                    portfolioViewModel.processImageSelection(
                        pickerItem: newlySelectedItem
                    )
                }

                ForEach(portfolioViewModel.portfolioImageUrls, id: \.self) {
                    imageUrl in
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
        }
    }

    func renderPackagesList() -> some View {
        List {
            ForEach(portfolioViewModel.servicePackage) { servicePackage in
                PackageRowView(activeServicePackage: servicePackage)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(PlainListStyle())
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                isShowingAddPackageSheet = true
            }) {
                Text("Add New Package")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
            }
            .padding()
        }
    }
}

#Preview {
    ManagePortfolioView()
}
