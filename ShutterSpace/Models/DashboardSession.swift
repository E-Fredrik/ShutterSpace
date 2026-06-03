//
//  DashboardSession.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 03/06/26.
//

import Foundation

struct DashboardSession: Identifiable {
    let id: String
    let bookingId: String
    let clientName: String
    let packageTitle: String
    let totalCost: Double
    let date: String
    let timeSlot: String
    let status: String
    let duration: Int
    var isOverlapping: Bool = false
}
