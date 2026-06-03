//
//  StatCard.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 03/06/26.
//

import SwiftUI

struct StatCard: View {
    let title: String
    let amount: Double
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Rp. \(String(format: "%.2f", amount))")
                .font(.title3)
                .fontWeight(.bold)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}
