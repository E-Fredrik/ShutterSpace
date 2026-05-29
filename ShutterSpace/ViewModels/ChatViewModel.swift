//
//  ChatViewModel.swift
//  ShutterSpace
//
//  Created by Stevanus Santoso on 28/05/26.
//

import Foundation
import Combine
import FirebaseFirestore

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var newMessageText: String = ""
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    let currentUserId = "current_user" // In real app, use Auth.auth().currentUser?.uid
    let recipientId: String
    
    init(recipientId: String) {
        self.recipientId = recipientId
        observeMessages()
    }
    
    deinit {
        listener?.remove()
    }
    
    func observeMessages() {
        // Query messages for this conversation
        listener = db.collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                let allMessages = documents.compactMap { doc -> Message? in
                    try? doc.data(as: Message.self)
                }
                
                // Filter for this specific conversation (Sender <-> Receiver)
                self?.messages = allMessages.filter { msg in
                    (msg.senderId == self?.currentUserId && msg.receiverId == self?.recipientId) ||
                    (msg.senderId == self?.recipientId && msg.receiverId == self?.currentUserId)
                }
            }
    }
    
    func sendMessage() {
        guard !newMessageText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        // PDF UC07: Regex check for platform leakage
        let isBlocked = containsContactInfo(newMessageText)
        let content = isBlocked ? "Direct contact info is hidden to protect platform integrity." : newMessageText
        
        if isBlocked {
            self.alertMessage = "Sharing contact information is against ShutterSpace policy. Please keep communication on the platform."
            self.showAlert = true
        }
        
        let message = Message(
            id: UUID().uuidString,
            senderId: currentUserId,
            receiverId: recipientId,
            content: content,
            timestamp: Date(),
            status: .sending,
            isBlocked: isBlocked
        )
        
        saveToFirestore(message)
        newMessageText = ""
    }
    
    private func saveToFirestore(_ message: Message) {
        do {
            try db.collection("messages").document(message.id).setData(from: message)
            
            // Simulate delivery status update after a short delay
            Task {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                try? await db.collection("messages").document(message.id).updateData(["status": MessageStatus.delivered.rawValue])
            }
        } catch {
            print("Error saving message: \(error)")
        }
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
