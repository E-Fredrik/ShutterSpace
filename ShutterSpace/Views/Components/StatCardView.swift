//
//  StatCardVuew.swift
//  ShutterSpace
//
//  Created by Sean tandjaja on 31/05/26.
//

import SwiftUI

struct StatCardView: View {
    let iconName: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.title)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}
