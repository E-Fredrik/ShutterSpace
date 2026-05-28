//
//  CategoryPillView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 28/05/26.
//

import SwiftUI

struct CategoryPillView: View {
    let categoryTitle: String
    let isCategorySelected: Bool
    let tapAction: () -> Void

    var body: some View {
        Button(action: tapAction) {
            Text(categoryTitle)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16.0)
                .padding(.vertical, 8.0)
                .background(isCategorySelected ? Color.white : Color.clear)
                .foregroundColor(isCategorySelected ? Color.black : Color.white)
                .cornerRadius(20.0)
                .overlay(
                    RoundedRectangle(cornerRadius: 20.0)
                        .stroke(Color(UIColor.separator), lineWidth: 1.0)
                )
        }
    }
}

#Preview {
    CategoryPillView(categoryTitle: "Wedding", isCategorySelected: true) {
        print("Category tapped")
    }
}
