//
//  XenditManager.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 29/05/26.
//

import Foundation
import Xendit
import UIKit

// A safe custom error to bridge Xendit's error into Swift
enum SafePaymentError: Error, LocalizedError {
    case failed(String)
    
    var errorDescription: String? {
        switch self {
        case .failed(let message):
            return message
        }
    }
}

@MainActor
class XenditManager {
    static let shared = XenditManager()
    
    private init() {
        Xendit.publishableKey = "xnd_public_development_KtoIjyfCoJTNPsEx0LezIfjb7cEy9sXYj3E69oY2DHpL94NrultGQ9_jItVpSUQ"
    }
    
    // Recursive helper to find the topmost view controller
    private func getTopViewController(base: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap({ $0 as? UIWindowScene })
        .flatMap({ $0.windows })
        .first(where: { $0.isKeyWindow })?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
    
    func createToken(firstName: String, lastName: String, cardNumber: String, expMonth: String, expYear: String, cvv: String, amount: Double) async throws -> String {
        
        guard let topVC = getTopViewController() else {
            throw URLError(.cannotFindHost)
        }
        
        var cardData = CardData()
        cardData.cardNumber = cardNumber
        cardData.cardExpMonth = expMonth
        
        var formattedYear = expYear
        if formattedYear.count == 2 {
            formattedYear = "20" + formattedYear
        }
        cardData.cardExpYear = formattedYear
        
        cardData.cardCvn = cvv
        cardData.amount = NSNumber(value: amount)

        return try await withCheckedThrowingContinuation { continuation in
            Xendit.createToken(fromViewController: topVC, cardData: cardData, shouldAuthenticate: true, onBehalfOf: "") { (token, error) in
                
                if let error = error {
                    let errorMessage = error.message ?? "Unknown payment error occurred."
                    continuation.resume(throwing: SafePaymentError.failed(errorMessage))
                } else if let token = token?.id {
                    continuation.resume(returning: token)
                } else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                }
            }
        }
    }
}
