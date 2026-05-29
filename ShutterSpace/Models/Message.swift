//
//  Message.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 29/05/26.
//


import Foundation

struct Message: Identifiable, Codable {
    var id: String { messageId }
    let messageId: String
    let senderId: String
    let text: String
    let timestamp: Date
    let receiverId: String
    let bookingId: String
}