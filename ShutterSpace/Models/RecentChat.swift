//
//  RecentChat.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 04/06/26.
//


import Foundation

struct RecentChat: Identifiable {
    let id: String
    let partnerName: String
    let partnerImageUrl: String
    let lastMessage: String
    let timestamp: Double
    let isBlocked: Bool // ADD THIS
}
