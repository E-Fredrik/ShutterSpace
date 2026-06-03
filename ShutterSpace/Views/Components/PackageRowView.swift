//
//  PackageRowView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 28/05/26.
//

import SwiftUI

struct PackageRowView: View {
    let activeServicePackage: ServicePackage

    var body: some View {
        VStack(alignment: .leading, spacing: 6.0) {
            HStack {
                Text(activeServicePackage.title)
                    .font(.headline)

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(
                        "Rp \(String(format: "%.0f", activeServicePackage.price))"
                    )
                    .font(.subheadline)
                    .fontWeight(.semibold)

                    Text(formatDuration(activeServicePackage.duration))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Text(activeServicePackage.deliverables)
                .font(.caption)
                .foregroundColor(Color(UIColor.secondaryLabel))
                .lineLimit(2)
        }
        .padding(.vertical, 8.0)
    }

    private func formatDuration(_ totalMinutes: Int) -> String {
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
}
