//
//  ChatViewModel.swift
//  ShutterSpace
//
//  Created by Stevanus Santoso on 28/05/26.
//

import Foundation
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var newMessageText: String = ""
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    let currentUserId = "current_user"
    let recipientId: String
    
    init(recipientId: String) {
        self.recipientId = recipientId
        loadMockMessages()
    }
    
    func loadMockMessages() {
        self.messages = [
            Message(id: "m1", senderId: recipientId, receiverId: currentUserId, content: "Hi! I saw your portfolio. Are you available for a wedding shoot?", timestamp: Date().addingTimeInterval(-3600), status: .read),
            Message(id: "m2", senderId: currentUserId, receiverId: recipientId, content: "Hello! Yes, I am. Which date are you looking at?", timestamp: Date().addingTimeInterval(-3500), status: .read)
        ]
    }
    
    func sendMessage() {
        guard !newMessageText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        // PDF UC07: Regex check for platform leakage
        if containsContactInfo(newMessageText) {
            self.alertMessage = "Sharing contact information is against ShutterSpace policy. Please keep communication on the platform."
            self.showAlert = true
            
            // Obstruct data as per PDF Design
            let obstructedMessage = Message(
                id: UUID().uuidString,
                senderId: currentUserId,
                receiverId: recipientId,
                content: "Direct contact info is hidden to protect platform integrity.",
                timestamp: Date(),
                status: .sending,
                isBlocked: true
            )
            messages.append(obstructedMessage)
            newMessageText = ""
            return
        }
        
        let message = Message(
            id: UUID().uuidString,
            senderId: currentUserId,
            receiverId: recipientId,
            content: newMessageText,
            timestamp: Date(),
            status: .sending
        )
        
        messages.append(message)
        let sentText = newMessageText
        newMessageText = ""
        
        // Simulate real-time transit and delivery
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second "sending"
            if let index = messages.firstIndex(where: { $0.id == message.id }) {
                messages[index].status = .delivered
            }
            
            // Simulate reply
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            receiveReply(for: sentText)
        }
    }
    
    private func receiveReply(for text: String) {
        let reply = Message(
            id: UUID().uuidString,
            senderId: recipientId,
            receiverId: currentUserId,
            content: "That sounds great! I'll check my calendar.",
            timestamp: Date(),
            status: .delivered
        )
        messages.append(reply)
    }
    
    // PDF Requirement: Detect phone numbers and emails
    private func containsContactInfo(_ text: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let phoneRegex = "(?:\\+?(\\d{1,3}))?([-. (]*(\\d{3})[-. )]*)?((\\d{3})[-. ]*(\\d{2,4})(?:[-. ]*(\\d{2,4}))?)"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        let phonePred = NSPredicate(format:"SELF MATCHES %@", phoneRegex)
        
        // Check for matches in the string
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        for word in words {
            if word.range(of: emailRegex, options: .regularExpression) != nil ||
               word.range(of: phoneRegex, options: .regularExpression) != nil {
                return true
            }
        }
        return false
    }
}
