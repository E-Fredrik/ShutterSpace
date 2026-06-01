//
//  Booking.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 29/05/26.
//

import Foundation

struct Booking: Identifiable, Codable {
    var id: String { bookingId }
    let bookingId: String
    let photographerId: String
    let clientId: String
    let packageId: String
    let status: String
    let totalCost: Double
    let xenditToken: String
    
    var date: String?
    var timeSlot: String?
    var resultsLink: String?
}
