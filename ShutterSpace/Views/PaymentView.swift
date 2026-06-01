//
//  PaymentView.swift
//  ShutterSpace
//
//  Created by Sean tandjaja on 01/06/26.
//

import SwiftUI

struct PaymentView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: BookingViewModel
    
    @State private var cardName: String = ""
    @State private var cardNumber: String = ""
    @State private var expMonth: String = ""
    @State private var expYear: String = ""
    @State private var cvv: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Card Details"), footer: Text("Secure payment processing powered by Xendit.")) {
                    TextField("Cardholder Name", text: $cardName)
                        .textContentType(.name)
                    
                    TextField("Card Number", text: $cardNumber)
                        .keyboardType(.numberPad)
                        .textContentType(.creditCardNumber)
                    
                    HStack {
                        TextField("MM", text: $expMonth)
                            .keyboardType(.numberPad)
                            .frame(maxWidth: 60)
                        
                        Divider()
                        
                        TextField("YY", text: $expYear)
                            .keyboardType(.numberPad)
                            .frame(maxWidth: 60)
                        
                        Divider()
                        
                        TextField("CVV", text: $cvv)
                            .keyboardType(.numberPad)
                    }
                }
                
                if let errorMessage = viewModel.paymentErrorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.callout)
                    }
                }
                
                Section {
                    Button {
                        Task {
                            do {
                                try await viewModel.processPaymentAndBook(
                                    cardName: cardName,
                                    cardNumber: cardNumber,
                                    expMonth: expMonth,
                                    expYear: expYear,
                                    cvv: cvv
                                )
                                dismiss()
                            } catch {
                                // Error handled via publisher
                            }
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if viewModel.isBookingInProgress {
                                ProgressView()
                            } else {
                                Text("Pay Rp \(String(format: "%.0f", viewModel.calculateFinalTotal()))")
                                    .fontWeight(.bold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(viewModel.isBookingInProgress || cardName.isEmpty || cardNumber.isEmpty || expMonth.isEmpty || expYear.isEmpty || cvv.isEmpty)
                }
            }
            .navigationTitle("Secure Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}
