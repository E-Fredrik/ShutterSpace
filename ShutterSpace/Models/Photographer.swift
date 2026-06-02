//
//  Photographer.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 28/05/26.
//

import Foundation

class Photographer: User {
    var stripeAccountId: String
    var rating: Double
    var location: String
    var category: String
    var profileImageUrl: String

    init(
        id: String,
        firstName: String,
        lastName: String,
        email: String,
        stripeAccountId: String,
        rating: Double,
        location: String,
        category: String,
        profileImageUrl: String
    ) {
        self.stripeAccountId = stripeAccountId
        self.rating = rating
        self.location = location
        self.category = category
        self.profileImageUrl = profileImageUrl
        
        super.init(
            id: id,
            firstName: firstName,
            lastName: lastName,
            email: email,
            role: "Photographer"
        )
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.stripeAccountId = try container.decode(
            String.self,
            forKey: .stripeAccountId
        )
        self.rating = try container.decode(Double.self, forKey: .rating)
        self.location =
            try container.decodeIfPresent(String.self, forKey: .location)
            ?? "Unknown"
        self.category =
            try container.decodeIfPresent(String.self, forKey: .category)
            ?? "General"
        self.profileImageUrl =
            try container.decodeIfPresent(String.self, forKey: .profileImageUrl)
            ?? ""
        try super.init(from: decoder)
    }

    private enum CodingKeys: String, CodingKey {
        case stripeAccountId, rating, location, category, profileImageUrl
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(stripeAccountId, forKey: .stripeAccountId)
        try container.encode(rating, forKey: .rating)
        try container.encode(location, forKey: .location)
        try container.encode(category, forKey: .category)
        try container.encode(profileImageUrl, forKey: .profileImageUrl)
        try super.encode(to: encoder)
    }
}
