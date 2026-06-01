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
                    Text("$\(String(format: "%.2f", activeServicePackage.price))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(activeServicePackage.duration)
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
}

#Preview {
    PackageRowView(
        activeServicePackage: ServicePackage(
            packageId: "pkg_001",
            title: "4-Hour Wedding Shoot",
            price: 480.0,
            deliverables: "1 photographer, 200 edited photos",
            duration: "4 Hours"
        )
    )
}
