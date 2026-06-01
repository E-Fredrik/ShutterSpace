//
//  PendingRequestRowView.swift
//  ShutterSpace
//
//  Created by Sean tandjaja on 31/05/26.
//

import SwiftUI

struct PendingRequestRowView: View {
    let request: PendingRequest
    let onAccept: () -> Void
    let onDecline: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(request.clientName)
                        .font(.headline)
                    Text(request.packageTitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("Rp\(String(format: "%.0f", request.totalCost))")
                    .font(.headline)
            }
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                Text("\(request.date) • \(request.timeSlot)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 12) {
                Button(action: onAccept) {
                    Text("Accept Booking")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .cornerRadius(8)
                }
                
                Button(action: onDecline) {
                    Text("Decline")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(UIColor.tertiarySystemBackground))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}
