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
        VStack(alignment: .leading, spacing: 12.0) {
            ZStack {
                if photographerDetails.profileImageUrl.isEmpty {
                    Rectangle()
                        .fill(Color(UIColor.secondarySystemBackground))
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(40)
                        .foregroundColor(.secondary)
                } else {
                    AsyncImage(url: URL(string: photographerDetails.profileImageUrl)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color(UIColor.secondarySystemBackground))
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            Rectangle()
                                .fill(Color(UIColor.secondarySystemBackground))
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .padding(40)
                                .foregroundColor(.secondary)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
            }
            .aspectRatio(1.0, contentMode: .fill)
            .clipShape(RoundedRectangle(cornerRadius: 12.0))

            VStack(alignment: .leading, spacing: 4.0) {
                Text("\(photographerDetails.firstName) \(photographerDetails.lastName)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(photographerDetails.category)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack(spacing: 4.0) {
                    if photographerDetails.reviewCount == 0 {
                        Image(systemName: "star")
                            .foregroundColor(.gray)
                            .font(.caption)
                        Text("No reviews yet")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text(String(format: "%.1f", photographerDetails.rating))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        Text("(\(photographerDetails.reviewCount))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 2.0)

                HStack(spacing: 4.0) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    Text(photographerDetails.location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 4.0)
        }
        .padding(.bottom, 8.0)
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
            rating: 0.0,
            reviewCount: 0,
            location: "Surabaya",
            category: "Wedding",
            profileImageUrl: ""
        )
    )
}
