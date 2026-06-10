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
        clearanceLevel: String,
        status: String = "Active" // Added status here
    ) {
        self.clearanceLevel = clearanceLevel
        super.init(
            id: id,
            firstName: firstName,
            lastName: lastName,
            email: email,
            role: "Admin",
            status: status // Passed it to the parent class here
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
