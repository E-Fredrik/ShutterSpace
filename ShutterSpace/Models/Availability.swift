//
//  Availability.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 29/05/26.
//


import Foundation

struct Availability: Identifiable, Codable {
    var id: String { availabilityId }
    let availabilityId: String
    let date: Date
    let isAvailable: Bool
}