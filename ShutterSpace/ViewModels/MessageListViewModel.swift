//
//  MessageListViewModel.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 04/06/26.
//


import Foundation
import FirebaseDatabase
import SwiftUI
import Combine

@MainActor
class MessageListViewModel: ObservableObject {
    
    @Published var recentChats: [RecentChat] = []
    @Published var isLoading: Bool = true
    
    private let databaseRef = Database.database().reference()
    
    func fetchRecentChats() {
        guard let currentUserId = UserDefaults.standard.string(forKey: "currentUserId") else { return }
        
        // Use .observe to listen for real-time updates when new messages arrive
        databaseRef.child("recentChats").child(currentUserId).observe(.value) { snapshot in
            var fetchedChats: [RecentChat] = []
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let dict = child.value as? [String: Any],
                      let partnerId = dict["partnerId"] as? String,
                      let partnerName = dict["partnerName"] as? String,
                      let lastMessage = dict["lastMessage"] as? String,
                      let timestamp = dict["timestamp"] as? Double else { continue }
                
                let partnerImageUrl = dict["partnerImageUrl"] as? String ?? ""
                
                let chat = RecentChat(
                    id: partnerId,
                    partnerName: partnerName,
                    partnerImageUrl: partnerImageUrl,
                    lastMessage: lastMessage,
                    timestamp: timestamp
                )
                fetchedChats.append(chat)
            }
            
            // Sort by the most recent message timestamp
            self.recentChats = fetchedChats.sorted(by: { $0.timestamp > $1.timestamp })
            self.isLoading = false
        }
    }
    
    func stopListening() {
        guard let currentUserId = UserDefaults.standard.string(forKey: "currentUserId") else { return }
        databaseRef.child("recentChats").child(currentUserId).removeAllObservers()
    }
}
