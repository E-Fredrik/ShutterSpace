//
//  PaymentResult.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 03/06/26.
//


import SwiftUI
import WebKit

enum PaymentResult {
    case success
    case failed
    case cancelled
}

// A wrapper view that adds a navigation bar and "Cancel" button to our WebView
struct MidtransPaymentSheet: View {
    let url: URL
    let onResult: (PaymentResult) -> Void

    var body: some View {
        NavigationStack {
            MidtransWebView(url: url, onResult: onResult)
                .navigationTitle("Secure Payment")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            onResult(.cancelled)
                        }
                    }
                }
        }
    }
}

// The core WebView that intercepts Midtrans redirects
struct MidtransWebView: UIViewRepresentable {
    let url: URL
    let onResult: (PaymentResult) -> Void

    func makeUIView(context: Context) -> WKWebView {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onResult: onResult)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let onResult: (PaymentResult) -> Void
        var hasFinished = false

        init(onResult: @escaping (PaymentResult) -> Void) {
            self.onResult = onResult
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            let urlString = url.absoluteString

            // Prevent multiple triggers
            guard !hasFinished else {
                decisionHandler(.cancel)
                return
            }

            // Intercept the redirect AFTER the 5 second countdown (or if they click 'Back to Merchant')
            if urlString.contains("transaction_status=settlement") ||
               urlString.contains("transaction_status=capture") ||
               urlString.contains("transaction_status=pending") {
                
                hasFinished = true
                decisionHandler(.cancel) // Block the dummy redirect page from loading
                onResult(.success) // Trigger success
                return
                
            } else if urlString.contains("transaction_status=deny") ||
                      urlString.contains("transaction_status=cancel") ||
                      urlString.contains("transaction_status=expire") {
                
                hasFinished = true
                decisionHandler(.cancel)
                onResult(.failed)
                return
            }

            // Allow normal navigation within the Midtrans Snap UI
            decisionHandler(.allow)
        }
    }
}
