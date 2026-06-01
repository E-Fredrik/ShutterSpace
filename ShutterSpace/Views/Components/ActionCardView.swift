//
//  ActionCardView.swift
//  ShutterSpace
//
//  Created by Sean tandjaja on 31/05/26.
//

import SwiftUI

struct ActionCardView: View {
    let title: String
    let iconName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: iconName)
                    .font(.title2)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .leading)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}
