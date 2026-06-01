//
//  PaymentView.swift
//  ShutterSpace
//
//  Created by Sean tandjaja on 01/06/26.
//

import SwiftUI

struct PaymentURLWrapper: Identifiable {
    let id = UUID()
    let url: URL
}

struct PaymentView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: BookingViewModel
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""

    @State private var snapUrlWrapper: PaymentURLWrapper? = nil
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Customer Details"), footer: Text("You will be redirected to Midtrans to securely complete your payment.")) {
                    TextField("First Name", text: $firstName)
                        .textContentType(.givenName)
                    TextField("Last Name", text: $lastName)
                        .textContentType(.familyName)
                    TextField("Email Address", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
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
                                // Generate the URL and trigger the WebView
                                let url = try await viewModel.setupMidtransPayment(
                                    firstName: firstName,
                                    lastName: lastName,
                                    email: email
                                )
                                self.snapUrlWrapper = PaymentURLWrapper(url: url)
                            } catch {}
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if viewModel.isBookingInProgress {
                                ProgressView()
                            } else {
                                Text("Proceed to Payment (Rp \(String(format: "%.0f", viewModel.calculateFinalTotal())))")
                                    .fontWeight(.bold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(viewModel.isBookingInProgress || firstName.isEmpty || lastName.isEmpty || email.isEmpty)
                }
            }
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .preferredColorScheme(.dark)
            .fullScreenCover(item: $snapUrlWrapper, onDismiss: {
                viewModel.markBookingAsPaid()
                dismiss()
            }) { wrapper in
                MidtransSafariView(url: wrapper.url, onDismiss: {
                    self.snapUrlWrapper = nil
                })
                .ignoresSafeArea()
            }
        }
    }
}
