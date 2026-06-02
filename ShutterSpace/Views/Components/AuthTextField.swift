//
//  AuthTextField.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 29/05/26.
//

import SwiftUI

struct AuthTextField: View {
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .font(.body)
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .keyboardType(keyboardType)
    }
}

#Preview {
    AuthTextField(placeholder: "Email", text: .constant(""), isSecure: false, keyboardType: .emailAddress)
}
