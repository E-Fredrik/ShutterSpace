//
//  TimeSlotButton.swift
//  ShutterSpace
//
//  Created by Sean tandjaja on 31/05/26.
//

import SwiftUI

struct TimeSlotButton: View {
    let time: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(time)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.white : Color(UIColor.secondarySystemBackground))
                .foregroundColor(isSelected ? .black : .primary)
                .cornerRadius(8)
        }
    }
}
