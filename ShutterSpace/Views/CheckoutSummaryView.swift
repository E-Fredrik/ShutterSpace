//
//  CheckoutSummaryView.swift
//  ShutterSpace
//
//  Created by Sean tandjaja on 31/05/26.
//

import SwiftUI

struct CheckoutSummaryView: View {
    let packageTitle: String
    let packagePrice: Double
    let platformFee: Double
    let totalCost: Double
    let isProcessing: Bool
    let payAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Divider()
                .padding(.vertical, 8)
            
            HStack {
                Text(packageTitle)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Rp \(String(format: "%.0f", packagePrice))")
            }
            
            HStack {
                Text("Platform Fee")
                    .foregroundColor(.secondary)
                Spacer()
                Text("Rp \(String(format: "%.0f", platformFee))")
            }
            
            HStack {
                Text("Total")
                    .font(.headline)
                Spacer()
                Text("Rp \(String(format: "%.0f", totalCost))")
                    .font(.headline)
            }
            .padding(.top, 4)
            
            Button(action: payAction) {
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                } else {
                    Text("Proceed to Payment")
                        .font(.headline)
                        .foregroundColor(.black)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .disabled(isProcessing)
            .padding(.top, 8)
        }
    }
}
