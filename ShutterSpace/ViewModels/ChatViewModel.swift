//
//  ChatViewModel.swift
//  ShutterSpace
//
//  Created by Rocky (AI) on 28/05/26.
//

import Foundation
import Combine
import FirebaseDatabase

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var newMessageText: String = ""
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private let ref = Database.database().reference().child("messages")
    private var handle: DatabaseHandle?
    
    let currentUserId = "current_user" // In real app, use Auth.auth().currentUser?.uid
    let recipientId: String
    
    init(recipientId: String) {
        self.recipientId = recipientId
        observeMessages()
    }
    
    deinit {
        if let handle = handle {
            ref.removeObserver(withHandle: handle)
        }
    }
    
    func observeMessages() {
        // Realtime Database .value listener
        handle = ref.observe(.value) { [weak self] snapshot in
            guard let value = snapshot.value as? [String: [String: Any]] else {
                print("No messages or wrong format")
                DispatchQueue.main.async {
                    self?.messages = []
                }
                return
            }
            
            var allMessages: [Message] = []
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .deferredToDate // Default for Date() in Codable
            
            for (id, data) in value {
                // Convert dictionary to Message object
                // Note: Since RTDB data is often just a dictionary, we manually map or use JSON serialization
                if let msg = self?.mapDictionaryToMessage(id: id, data: data) {
                    allMessages.append(msg)
                }
            }
            
            // Sort by timestamp and filter for this conversation
            let sortedFiltered = allMessages
                .sorted(by: { $0.timestamp < $1.timestamp })
                .filter { msg in
                    (msg.senderId == self?.currentUserId && msg.receiverId == self?.recipientId) ||
                    (msg.senderId == self?.recipientId && msg.receiverId == self?.currentUserId)
                }
            
            DispatchQueue.main.async {
                self?.messages = sortedFiltered
            }
        }
    }
    
    func sendMessage() {
        guard !newMessageText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let isBlocked = containsContactInfo(newMessageText)
        let content = isBlocked ? "Direct contact info is hidden to protect platform integrity." : newMessageText
        
        if isBlocked {
            self.alertMessage = "Sharing contact information is against ShutterSpace policy. Please keep communication on the platform."
            self.showAlert = true
        }
        
        let messageId = UUID().uuidString
        let messageData: [String: Any] = [
            "id": messageId,
            "senderId": currentUserId,
            "receiverId": recipientId,
            "content": content,
            "timestamp": Date().timeIntervalSinceReferenceDate, // RTDB preferred double
            "status": MessageStatus.sending.rawValue,
            "isBlocked": isBlocked
        ]
        
        ref.child(messageId).setValue(messageData) { error, _ in
            if let error = error {
                print("Error saving to RTDB: \(error.localizedDescription)")
            } else {
                // Update status to delivered after write
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.ref.child(messageId).updateChildValues(["status": MessageStatus.delivered.rawValue])
                }
            }
        }
        
        newMessageText = ""
    }
    
    private func mapDictionaryToMessage(id: String, data: [String: Any]) -> Message? {
        guard let senderId = data["senderId"] as? String,
              let receiverId = data["receiverId"] as? String,
              let content = data["content"] as? String,
              let timestampInterval = data["timestamp"] as? TimeInterval,
              let statusString = data["status"] as? String,
              let status = MessageStatus(rawValue: statusString) else {
            return nil
        }
        
        return Message(
            id: id,
            senderId: senderId,
            receiverId: receiverId,
            content: content,
            timestamp: Date(timeIntervalSinceReferenceDate: timestampInterval),
            status: status,
            isBlocked: data["isBlocked"] as? Bool ?? false
        )
    }
    
    private func containsContactInfo(_ text: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let phoneRegex = "(?:\\+?(\\d{1,3}))?([-. (]*(\\d{3})[-. )]*)?((\\d{3})[-. ]*(\\d{2,4})(?:[-. ]*(\\d{2,4}))?)"
        
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
