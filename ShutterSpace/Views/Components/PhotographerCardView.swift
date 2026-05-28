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
                Text(String(format: "$%.2f", photographer.startingPrice))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                
                Text(String(format: "%.1f", photographer.rating))
                    .font(.caption)
                    .foregroundColor(.secondary)

            }
        }
    }
}

#Preview {
    PhotographerCardView(photographer: Photographer(id: "1", firstName: "John", lastName: "Doe", startingPrice: 150.0, rating: 4.5, location: "New York", category: "Wedding", profileImageURL: ""))
}
