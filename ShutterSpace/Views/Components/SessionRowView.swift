//
//  SessionRowView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 01/06/26.
//

import SwiftUI

struct SessionRowView: View {
    let session: SessionItem
    let onLeaveReview: (() -> Void)?

    private var statusColor: Color {
        switch session.status {
        case "Accepted": return .green
        case "Completed": return .blue
        default: return .orange
        }
    }

    private var statusLabel: String {
        switch session.status {
        case "Accepted": return "Accepted"
        case "Completed": return "Completed"
        default: return "Pending"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.photographerName)
                        .font(.headline)
                    Text(session.packageTitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(String(format: "%.0f", session.totalCost))")
                        .font(.headline)
                    Text(statusLabel)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(statusColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(statusColor.opacity(0.15))
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

            if session.status == "Completed" {
                if session.hasBeenReviewed {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                            .font(.footnote)
                        Text("Review submitted")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                } else if let leaveReview = onLeaveReview {
                    Button(action: leaveReview) {
                        HStack {
                            Image(systemName: "star.fill")
                                .font(.footnote)
                            Text("Leave a Review")
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

            if let resultsLink = session.resultsLink, !resultsLink.isEmpty,
                session.status == "Completed"
            {
                HStack(spacing: 6) {
                    Image(systemName: "link")
                        .foregroundColor(.blue)
                        .font(.footnote)
                    Text(resultsLink)
                        .font(.footnote)
                        .foregroundColor(.blue)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}
