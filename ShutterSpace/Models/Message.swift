//
//  Message.swift
//  ShutterSpace
//
//  Created by Stevanus Santoso on 28/05/26.
//

import Foundation

enum MessageStatus: String, Codable {
    case sending = "Sending..."
    case delivered = "delivered"
    case read = "Read"
}

struct Message: Identifiable, Codable, Hashable {
    let id: String
    let senderId: String
    let receiverId: String
    let content: String
    let timestamp: Date
    var status: MessageStatus
    var isBlocked: Bool = false
    
    var isFromCurrentUser: Bool {
        return senderId == "current_user"
    }
}
