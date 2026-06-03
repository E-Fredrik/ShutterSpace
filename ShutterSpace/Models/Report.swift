//
//  Report.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 03/06/26.
//

import Foundation

struct Report: Identifiable, Codable {
    var id: String { reportId }
    let reportId: String
    let bookingId: String
    let reporterId: String
    let reportedUserId: String
    let reason: String
    let description: String
    var status: String // e.g., "Pending", "Resolved", "Dismissed"
    let timestamp: TimeInterval
}
