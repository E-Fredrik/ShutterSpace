//
//  AcceptedSessionRowView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 01/06/26.
//

import SwiftUI

struct AcceptedSessionRowView: View {
    let session: AcceptedSession
    let onMarkCompleted: () -> Void

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

            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                    .font(.footnote)
                Text("\(session.date) · \(session.timeSlot)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            Button(action: onMarkCompleted) {
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
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}
