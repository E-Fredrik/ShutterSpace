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
    }
}

#Preview {
    AuthTextField(placeholder: "", text: .constant(""), isSecure: true)
}
