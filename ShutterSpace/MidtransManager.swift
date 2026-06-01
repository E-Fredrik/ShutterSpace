//
//  MidtransManager.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 01/06/26.
//

import Foundation

enum MidtransError: Error, LocalizedError {
    case failed(String)

    var errorDescription: String? {
        switch self {
        case .failed(let message): return message
        }
    }
}

struct MidtransSnapResponse: Codable {
    let token: String
    let redirect_url: String
}

@MainActor
class MidtransManager {
    static let shared = MidtransManager()

    // Safely pulls the key from your xcconfig -> Info.plist
    private var serverKey: String {
        return Bundle.main.object(forInfoDictionaryKey: "MIDTRANS_SERVER_KEY")
        as? String ?? ""
    }

    func fetchSnapUrl(
        orderId: String,
        amount: Double,
        firstName: String,
        lastName: String,
        email: String
    ) async throws -> String {
        let url = URL(
            string: "https://app.sandbox.midtrans.com/snap/v1/transactions"
        )!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let authData = "\(serverKey):".data(using: .utf8) else {
            throw MidtransError.failed("Failed to encode Server Key.")
        }
        let base64AuthString = authData.base64EncodedString()
        request.setValue(
            "Basic \(base64AuthString)",
            forHTTPHeaderField: "Authorization"
        )

    
        let parameters: [String: Any] = [
            "transaction_details": [
                "order_id": orderId,
                "gross_amount": Int(amount),
            ],
            "customer_details": [
                "first_name": firstName,
                "last_name": lastName,
                "email": email,
            ],
            "credit_card": [
                "secure": true 
            ],
        ]

        request.httpBody = try JSONSerialization.data(
            withJSONObject: parameters
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MidtransError.failed("Invalid network response.")
        }

        if httpResponse.statusCode == 201 {
            let json = try JSONDecoder().decode(
                MidtransSnapResponse.self,
                from: data
            )
            return json.redirect_url
        } else {
            // Extracts the specific error Midtrans returns if something goes wrong
            if let errorJson = try? JSONSerialization.jsonObject(with: data)
                as? [String: Any],
                let errorMessages = errorJson["error_messages"] as? [String]
            {
                throw MidtransError.failed(
                    errorMessages.joined(separator: ", ")
                )
            }
            throw MidtransError.failed(
                "Server returned status code \(httpResponse.statusCode)"
            )
        }
    }
}
