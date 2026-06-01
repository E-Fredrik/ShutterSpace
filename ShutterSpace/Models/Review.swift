//
//  Review.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 01/06/26./Users/elifele/Documents/Uni/SE/ShutterSpace/ShutterSpace
//

import Foundation

struct Review: Identifiable, Codable {
    var id: String { reviewId }
    let reviewId: String
    let bookingId: String
    let clientId: String
    let photographerId: String
    let starRating: Int
    let writtenReview: String
    let createdAt: String
}
