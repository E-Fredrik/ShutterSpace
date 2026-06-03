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
    @Published var recentMessages: [String] = []
    @Published var isLoadingChats: Bool = false
    @Published var currentStatus: String = "Active"

    let user: User
    private let databaseRef = Database.database().reference()

    init(user: User) {
        self.user = user
    }

    func fetchInitialData() async {
        await fetchCurrentStatus()
        await fetchRecentChats()
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
            }
        } catch {
            print("Error fetching status: \(error.localizedDescription)")
        }
    }

    func fetchRecentChats() async {
        isLoadingChats = true

        do {
            let snap = try await databaseRef.child("messages")
                .queryOrdered(byChild: "senderId")
                .queryEqual(toValue: user.id)
                .queryLimited(toLast: 20)
                .getData()

            if let children = snap.children.allObjects as? [DataSnapshot] {
                var logs: [String] = []
                for child in children {
                    if let dict = child.value as? [String: Any],
                        let text = dict["text"] as? String
                    {
                        logs.append(text)
                    }
                }
                self.recentMessages = logs.reversed()  // Show newest first
            } else {
                self.recentMessages = []  // Clear if no messages found
            }
        } catch {
            print("Error fetching chats: \(error.localizedDescription)")
        }

        isLoadingChats = false
    }
}
