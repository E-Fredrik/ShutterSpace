//
//  CheckoutSummaryView.swift
//  ShutterSpace
//
//  Created by Sean tandjaja on 31/05/26.
//

import SwiftUI

struct CheckoutSummaryView: View {
    
    // MARK: - Properties
    let packageTitle: String
    let packagePrice: Double
    let platformFee: Double
    let totalCost: Double
    let isProcessing: Bool
    let payAction: () -> Void
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 16) {
            Divider()
                .padding(.vertical, 8)
            
            HStack {
                Text(packageTitle)
                    .foregroundColor(.secondary)
                Spacer()
                Text("$\(String(format: "%.2f", packagePrice))")
            }
            
            HStack {
                Text("Platform Fee")
                    .foregroundColor(.secondary)
                Spacer()
                Text("$\(String(format: "%.2f", platformFee))")
            }
            
            HStack {
                Text("Total")
                    .font(.headline)
                Spacer()
                Text("$\(String(format: "%.2f", totalCost))")
                    .font(.headline)
            }
            .padding(.top, 4)
            
            Button(action: payAction) {
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                } else {
                    Text("Pay")
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
