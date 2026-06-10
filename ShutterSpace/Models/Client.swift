//
//  Client.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 29/05/26.
//

import Foundation

class Client: User {
    var preferences: String

    init(
        id: String,
        firstName: String,
        lastName: String,
        email: String,
        preferences: String,
        status: String = "Active"  // Added status here
    ) {
        self.preferences = preferences
        super.init(
            id: id,
            firstName: firstName,
            lastName: lastName,
            email: email,
            role: "Client",
            status: status  // Passed it to the parent class here
        )
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.preferences = try container.decode(
            String.self,
            forKey: .preferences
        )
        try super.init(from: decoder)
    }

    private enum CodingKeys: String, CodingKey {
        case preferences
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(preferences, forKey: .preferences)
        try super.encode(to: encoder)
    }
}
