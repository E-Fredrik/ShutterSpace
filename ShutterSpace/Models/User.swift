//
//  User.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 29/05/26.
//

import Foundation

class User: Identifiable, Codable {
    var id: String
    var firstName: String
    var lastName: String
    var email: String
    var role: String

    init(
        id: String,
        firstName: String,
        lastName: String,
        email: String,
        role: String
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.role = role
    }
}
