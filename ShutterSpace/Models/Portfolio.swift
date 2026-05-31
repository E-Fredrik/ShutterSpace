//
//  Portfolio.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 28/05/26.
//

import Foundation

struct Portfolio: Identifiable, Codable {
    var id: String { portfolioId }
    let portfolioId: String
    let imageUrls: [String]
}
