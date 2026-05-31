//
//  PhotographerCardView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 28/05/26.
//

import SwiftUI

struct PhotographerCardView: View {
    let photographer: Photographer

    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            Rectangle()
                .fill(Color(UIColor.secondarySystemBackground))
                .aspectRatio(1.0, contentMode: .fill)
                .cornerRadius(12.0)

            Text("\(photographer.firstName) \(photographer.lastName)")
                .font(.headline)
                .foregroundColor(.primary)

            HStack {

                Text(photographer.category)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)

                Text(String(format: "%.1f", photographer.rating))
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
    }
}

#Preview {
    PhotographerCardView(
        photographer: Photographer(
            id: "photo_001",
            firstName: "Alia",
            lastName: "Rahman",
            email: "alia@example.com",
            access_code: "auth_token_1x2y3z",
            stripeAccountId: "acct_889900",
            rating: 4.8,
            location: "Surabaya",
            category: "Wedding",
            profileImageUrl: "person.crop.circle"
        )
    )
}
