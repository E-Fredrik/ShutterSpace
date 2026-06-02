//
//  DashboardSessionRowView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 03/06/26.
//

import SwiftUI

struct DashboardSessionRowView: View {
    let session: DashboardSession
    
    var onAccept: (() -> Void)? = nil
    var onDecline: (() -> Void)? = nil
    var onMarkCompleted: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.clientName)
                        .font(.headline)
                    Text(session.packageTitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Rp \(String(format: "%.0f", session.totalCost))")
                        .font(.headline)
                    
                    if session.status == "Accepted" {
                        Text("Accepted")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.green.opacity(0.15))
                            .cornerRadius(6)
                    }
                }
            }

            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                    .font(.footnote)
                Text("\(session.date) · \(session.timeSlot)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            if session.status == "Pending" {
                HStack(spacing: 12) {
                    Button(action: { onAccept?() }) {
                        Text("Accept Booking")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: { onDecline?() }) {
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
            } else if session.status == "Accepted" {
                Button(action: { onMarkCompleted?() }) {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.footnote)
                        Text("Mark as Completed")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}
