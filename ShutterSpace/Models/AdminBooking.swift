//
//  AdminBooking.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 03/06/26.
//

import Foundation

struct AdminBooking: Identifiable {
    let id: String
    let clientId: String
    let photographerId: String
    let status: String
    let price: Double
    let date: String
}
