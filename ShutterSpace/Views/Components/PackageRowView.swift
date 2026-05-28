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
                
                Text("$\(String(format: "%.2f", activeServicePackage.price))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
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
    PackageRowView(activeServicePackage: ServicePackage(id: "1", title: "Basic Package", price: 500.0, deliverables: "4 hours of coverage, 100 edited photos"))

}
