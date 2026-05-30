//
//  XenditManager.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 29/05/26.
//

import Foundation
import Xendit
import UIKit

@MainActor
class XenditManager {
    static let shared = XenditManager()
    
    private init() {
        Xendit.publishableKey = "xnd_public_development_KtoIjyfCoJTNPsEx0LezIfjb7cEy9sXYj3E69oY2DHpL94NrultGQ9_jItVpSUQ"
    }
    
    func createToken(cardNumber: String, expMonth: String, expYear: String, cvv: String) async throws -> String {
        
        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController else {
            
            throw URLError(.cannotFindHost)
        }
        
        var cardData = CardData()
        cardData.cardNumber = cardNumber
        cardData.cardExpMonth = expMonth
        cardData.cardExpYear = expYear
        cardData.cardCvn = cvv

        return try await withCheckedThrowingContinuation { continuation in
            Xendit
                .createToken(fromViewController: rootVC, cardData: cardData, shouldAuthenticate: true, onBehalfOf: "") { (
                    token,
                    error
                ) in
                
                if let error = error {
                    continuation.resume(throwing: error as! any Error)
                } else if let token = token?.id {
                    continuation.resume(returning: token)
                } else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                }
            }
        }
    }
}

