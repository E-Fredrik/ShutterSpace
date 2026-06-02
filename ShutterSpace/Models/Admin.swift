//
//  Admin.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 29/05/26.
//

import Foundation

class Admin: User {
    var clearanceLevel: String

    init(
        id: String,
        firstName: String,
        lastName: String,
        email: String,
        access_code: String,
        clearanceLevel: String
    ) {
        self.clearanceLevel = clearanceLevel
        super.init(
            id: id,
            firstName: firstName,
            lastName: lastName,
            email: email,
            role: "Admin"
        )
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.clearanceLevel = try container.decode(
            String.self,
            forKey: .clearanceLevel
        )
        try super.init(from: decoder)
    }

    private enum CodingKeys: String, CodingKey {
        case clearanceLevel
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(clearanceLevel, forKey: .clearanceLevel)
        try super.encode(to: encoder)
    }
}
