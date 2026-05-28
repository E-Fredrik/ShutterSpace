//
//  Photographer.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 28/05/26.
//

import SwiftUI

struct Photographer: Identifiable, Hashable {
    let id: String
    let firstName: String
    let lastName: String
    let startingPrice: Double
    let rating: Double
    let location: String
    let category: String
    let profileImageURL: String
}
