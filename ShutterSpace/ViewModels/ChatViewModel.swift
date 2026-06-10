//
//  ChatViewModel.swift
//  ShutterSpace
//
//  Created by Rocky (AI) on 28/05/26.
//

import Combine
import FirebaseDatabase
import Foundation

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var newMessageText: String = ""
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""

    private let messagesRef = Database.database().reference().child("messages")
    private let rootRef = Database.database().reference()
    private var handle: DatabaseHandle?

    // FIXED: Dynamically fetch the real logged-in User ID instead of "current_user"
    var currentUserId: String {
        return UserDefaults.standard.string(forKey: "currentUserId") ?? ""
    }

    let recipientId: String

    init(recipientId: String) {
        self.recipientId = recipientId
        observeMessages()
    }

    deinit {
        if let handle = handle {
            messagesRef.removeObserver(withHandle: handle)
        }
    }

    func observeMessages() {
        guard !currentUserId.isEmpty else { return }

        handle = messagesRef.observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            guard let value = snapshot.value as? [String: [String: Any]] else {
                DispatchQueue.main.async { self.messages = [] }
                return
            }

            var allMessages: [Message] = []

            for (id, data) in value {
                if let msg = self.mapDictionaryToMessage(id: id, data: data) {
                    allMessages.append(msg)
                }
            }

            let sortedFiltered =
                allMessages
                .sorted(by: { $0.timestamp < $1.timestamp })
                .filter { msg in
                    (msg.senderId == self.currentUserId
                        && msg.receiverId == self.recipientId)
                        || (msg.senderId == self.recipientId
                            && msg.receiverId == self.currentUserId)
                }

            DispatchQueue.main.async {
                self.messages = sortedFiltered
            }
        }
    }

    func sendMessage() {
        guard !newMessageText.trimmingCharacters(in: .whitespaces).isEmpty
        else { return }
        guard !currentUserId.isEmpty else { return }

        let isBlocked = containsContactInfo(newMessageText)
        let content =
            isBlocked
            ? "Direct contact info is hidden to protect platform integrity."
            : newMessageText

        if isBlocked {
            self.alertMessage =
                "Sharing contact information is against ShutterSpace policy. Please keep communication on the platform."
            self.showAlert = true
        }

        let messageId = UUID().uuidString
        let messageData: [String: Any] = [
            "id": messageId,
            "senderId": currentUserId,
            "receiverId": recipientId,
            "content": content,
            "timestamp": Date().timeIntervalSince1970 * 1000,  // Firebase standard milliseconds
            "status": MessageStatus.sending.rawValue,
            "isBlocked": isBlocked,
        ]

        messagesRef.child(messageId).setValue(messageData) {
            [weak self] error, _ in
            guard let self = self else { return }
            if let error = error {
                print("Error saving to RTDB: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.messagesRef.child(messageId).updateChildValues([
                        "status": MessageStatus.delivered.rawValue
                    ])
                }

                // ADDED: Synchronize the Inbox (recentChats) for both the Sender and Receiver
                Task {
                    await self.updateRecentChat(lastMessage: content)
                }
            }
        }

        newMessageText = ""
    }

    // NEW: Method to update the Inbox view
    private func updateRecentChat(lastMessage: String) async {
        do {
            // 1. Fetch Current User Details
            let currentUserSnapshot = try await rootRef.child("users").child(
                currentUserId
            ).getData()
            let currentDict = currentUserSnapshot.value as? [String: Any]
            let currentFirstName =
                currentDict?["firstName"] as? String ?? "User"
            let currentLastName = currentDict?["lastName"] as? String ?? ""
            let currentName = "\(currentFirstName) \(currentLastName)"
                .trimmingCharacters(in: .whitespaces)
            let currentImageUrl =
                currentDict?["profileImageUrl"] as? String ?? ""

            // 2. Fetch Recipient Details
            let recipientSnapshot = try await rootRef.child("users").child(
                recipientId
            ).getData()
            let recipientDict = recipientSnapshot.value as? [String: Any]
            let recipientFirstName =
                recipientDict?["firstName"] as? String ?? "User"
            let recipientLastName = recipientDict?["lastName"] as? String ?? ""
            let recipientName = "\(recipientFirstName) \(recipientLastName)"
                .trimmingCharacters(in: .whitespaces)
            let recipientImageUrl =
                recipientDict?["profileImageUrl"] as? String ?? ""

            let timestamp = Date().timeIntervalSince1970 * 1000

            // 3. Atomically update both Inboxes
            let updates: [String: Any] = [
                "recentChats/\(currentUserId)/\(recipientId)": [
                    "partnerId": recipientId,
                    "partnerName": recipientName,
                    "partnerImageUrl": recipientImageUrl,
                    "lastMessage": lastMessage,
                    "timestamp": timestamp,
                ],
                "recentChats/\(recipientId)/\(currentUserId)": [
                    "partnerId": currentUserId,
                    "partnerName": currentName,
                    "partnerImageUrl": currentImageUrl,
                    "lastMessage": lastMessage,
                    "timestamp": timestamp,
                ],
            ]

            try await rootRef.updateChildValues(updates)

        } catch {
            print(
                "Failed to update recent chats: \(error.localizedDescription)"
            )
        }
    }

    private func mapDictionaryToMessage(id: String, data: [String: Any])
        -> Message?
    {
        guard let senderId = data["senderId"] as? String,
            let receiverId = data["receiverId"] as? String,
            let content = data["content"] as? String,
            let timestampInterval = data["timestamp"] as? TimeInterval,
            let statusString = data["status"] as? String,
            let status = MessageStatus(rawValue: statusString)
        else {
            return nil
        }

        // Safety check to handle both old reference dates and new 1970 epoch milliseconds
        let date =
            timestampInterval > 9_999_999_999
            ? Date(timeIntervalSince1970: timestampInterval / 1000)
            : Date(timeIntervalSinceReferenceDate: timestampInterval)

        return Message(
            id: id,
            senderId: senderId,
            receiverId: receiverId,
            content: content,
            timestamp: date,
            status: status,
            isBlocked: data["isBlocked"] as? Bool ?? false
        )
    }

    private func containsContactInfo(_ text: String) -> Bool { //Regex check to detect if the message contains email or phone number patterns
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let phoneRegex =
            "(?:\\+?(\\d{1,3}))?([-. (]*(\\d{3})[-. )]*)?((\\d{3})[-. ]*(\\d{2,4})(?:[-. ]*(\\d{2,4}))?)"

        let words = text.components(separatedBy: .whitespacesAndNewlines)
        for word in words {
            if word.range(of: emailRegex, options: .regularExpression) != nil
                || word.range(of: phoneRegex, options: .regularExpression)
                    != nil
            {
                return true
            }
        }
        return false
    }
}
