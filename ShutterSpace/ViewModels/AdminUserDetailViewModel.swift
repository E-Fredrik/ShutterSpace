//
//  AdminDashboardViewModel.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 03/06/26.
//

import Combine
import FirebaseDatabase
import Foundation

@MainActor
class AdminUserDetailViewModel: ObservableObject {

    // Status Properties
    @Published var currentStatus: String = "Active"

    // Chat Log Properties
    @Published var chatLogs: [Message] = []
    @Published var isLoadingLogs: Bool = false

    let user: User
    private let databaseRef = Database.database().reference()
    private var messagesHandle: DatabaseHandle?

    init(user: User) {
        self.user = user
    }

    // MARK: - Status Management

    func fetchInitialData() async {
        await fetchCurrentStatus()
        fetchChatLogs(forUserId: user.id)
    }

    func changeStatus(to newStatus: String) async {
        // Optimistically update the UI immediately
        self.currentStatus = newStatus

        do {
            try await databaseRef.child("users").child(user.id)
                .updateChildValues([
                    "status": newStatus
                ])
        } catch {
            print("Error updating user status: \(error.localizedDescription)")
            await fetchCurrentStatus()
        }
    }

    private func fetchCurrentStatus() async {
        do {
            let snap = try await databaseRef.child("users").child(user.id)
                .child("status").getData()
            if let status = snap.value as? String {
                self.currentStatus = status
            } else {
                // Fallback to the user model's status if database fetch fails initially
                self.currentStatus = user.status
            }
        } catch {
            print("Error fetching status: \(error.localizedDescription)")
        }
    }

    // MARK: - Chat Log Management

    func fetchChatLogs(forUserId userId: String) {
        isLoadingLogs = true

        // Use .observe to stream past AND future messages in real-time
        messagesHandle = databaseRef.child("messages").observe(.value) {
            [weak self] snapshot in
            guard let self = self else { return }

            var fetchedLogs: [Message] = []

            if let children = snapshot.children.allObjects as? [DataSnapshot] {
                for child in children {
                    guard let dict = child.value as? [String: Any],
                        let senderId = dict["senderId"] as? String,
                        let receiverId = dict["receiverId"] as? String
                    else {
                        continue
                    }

                    // Filter messages where this specific user is either the sender or receiver
                    if senderId == userId || receiverId == userId {
                        let id = dict["id"] as? String ?? child.key
                        let content = dict["content"] as? String ?? ""
                        let timestamp = dict["timestamp"] as? Double ?? 0
                        let isBlocked = dict["isBlocked"] as? Bool ?? false

                        // Handle epoch milliseconds
                        let date =
                            timestamp > 9_999_999_999
                            ? Date(timeIntervalSince1970: timestamp / 1000)
                            : Date(timeIntervalSinceReferenceDate: timestamp)

                        let statusRaw = dict["status"] as? String ?? "delivered"
                        let status =
                            MessageStatus(rawValue: statusRaw) ?? .delivered

                        let message = Message(
                            id: id,
                            senderId: senderId,
                            receiverId: receiverId,
                            content: content,
                            timestamp: date,
                            status: status,
                            isBlocked: isBlocked
                        )
                        fetchedLogs.append(message)
                    }
                }
            }

            DispatchQueue.main.async {
                // Sort by newest first
                self.chatLogs = fetchedLogs.sorted(by: {
                    $0.timestamp > $1.timestamp
                })
                self.isLoadingLogs = false
            }
        }
    }

    func blockMessage(message: Message) async {
        do {
            let updates: [String: Any] = [
                "isBlocked": true,
                "content": "Message blocked by Admin",
            ]
            // Update the main message
            try await databaseRef.child("messages").child(message.id)
                .updateChildValues(updates)

            // Update the caches in Inboxes to include the isBlocked flag
            let chatUpdates: [String: Any] = [
                "lastMessage": "Message blocked by Admin",
                "isBlocked": true,  // ADD THIS FIELD
            ]

            try await databaseRef.child("recentChats").child(message.senderId)
                .child(message.receiverId).updateChildValues(chatUpdates)
            try await databaseRef.child("recentChats").child(message.receiverId)
                .child(message.senderId).updateChildValues(chatUpdates)

        } catch {
            print("Failed to block message: \(error.localizedDescription)")
        }
    }

    func stopObservingLogs() {
        if let handle = messagesHandle {
            databaseRef.child("messages").removeObserver(withHandle: handle)
        }
    }
}
