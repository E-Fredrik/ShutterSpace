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
    let isBooked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(time)
                    .font(.caption)
                    .fontWeight(.medium)
                    .strikethrough(isBooked, color: .red)
                    .foregroundColor(
                        isBooked ? .secondary :
                        isSelected ? .black : .primary
                    )
                if isBooked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.red.opacity(0.7))
                }
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                isBooked ? Color.red.opacity(0.08) :
                isSelected ? Color.white : Color(UIColor.secondarySystemBackground)
            )
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isBooked ? Color.red.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .disabled(isBooked)
    }
}

