//
//  PhotographerCardView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 28/05/26.
//

import SwiftUI

struct PhotographerCardView: View {
    let photographerDetails: Photographer

    var body: some View {

        VStack(alignment: .leading, spacing: 8.0) {
            if photographerDetails.profileImageUrl.isEmpty
                || !photographerDetails.profileImageUrl.starts(with: "http")
            {

                ZStack {
                    Rectangle()
                        .fill(Color(UIColor.secondarySystemBackground))
                        .aspectRatio(1.0, contentMode: .fill)

                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(30.0)
                        .foregroundColor(Color(UIColor.systemGray3))
                }
                .cornerRadius(12.0)

            } else {
                AsyncImage(
                    url: URL(string: photographerDetails.profileImageUrl)
                ) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Rectangle()
                                .fill(Color(UIColor.secondarySystemBackground))
                                .aspectRatio(1.0, contentMode: .fill)
                            ProgressView()
                        }
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(1.0, contentMode: .fill)
                    case .failure(_):
                        ZStack {
                            Rectangle()
                                .fill(Color(UIColor.secondarySystemBackground))
                                .aspectRatio(1.0, contentMode: .fill)

                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .padding(30.0)
                                .foregroundColor(Color(UIColor.systemGray3))
                        }
                    @unknown default:
                        EmptyView()
                    }
                }
                .cornerRadius(12.0)
                .clipped()
            }

            Text(
                "\(photographerDetails.firstName) \(photographerDetails.lastName)"
            )
            .font(.headline)
            .foregroundColor(.primary)

            HStack {

                Text(photographerDetails.category)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)

                Text(String(format: "%.1f", photographerDetails.rating))
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
    }
}

#Preview {
    PhotographerCardView(
        photographerDetails: Photographer(
            id: "photo_001",
            firstName: "Alia",
            lastName: "Rahman",
            email: "alia@example.com",
            stripeAccountId: "acct_889900",
            rating: 4.8,
            location: "Surabaya",
            category: "Wedding",
            profileImageUrl: "person.crop.circle"
        )
    )
}
