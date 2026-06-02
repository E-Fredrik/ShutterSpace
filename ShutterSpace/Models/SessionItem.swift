//
//  SessionItem.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 03/06/26.
//

import Foundation

struct SessionItem: Identifiable {
    let id: String
    let bookingId: String
    let photographerId: String
    let photographerName: String
    let packageTitle: String
    let totalCost: Double
    let date: String
    let timeSlot: String
    let status: String
    let resultsLink: String?
    let hasBeenReviewed: Bool
}
