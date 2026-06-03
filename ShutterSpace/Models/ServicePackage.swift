//
//  ServicePackage.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 28/05/26.
//

import Foundation

struct ServicePackage: Identifiable, Codable {
    var id: String { packageId }
    let packageId: String
    let title: String
    let price: Double
    let deliverables: String
    let duration: Int
    
    enum CodingKeys: String, CodingKey {
        case packageId, title, price, deliverables, duration
    }
    
    init(packageId: String, title: String, price: Double, deliverables: String, duration: Int) {
        self.packageId = packageId
        self.title = title
        self.price = price
        self.deliverables = deliverables
        self.duration = duration
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        packageId = try container.decode(String.self, forKey: .packageId)
        title = try container.decode(String.self, forKey: .title)
        price = try container.decode(Double.self, forKey: .price)
        deliverables = try container.decode(String.self, forKey: .deliverables)
        
        if let intDuration = try? container.decode(Int.self, forKey: .duration) {
            duration = intDuration
        }
        else if let stringDuration = try? container.decode(String.self, forKey: .duration) {
            let numbersString = stringDuration.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            if let hours = Int(numbersString) {
                duration = hours * 60
            } else {
                duration = 60
            }
        } else {
            duration = 60
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(packageId, forKey: .packageId)
        try container.encode(title, forKey: .title)
        try container.encode(price, forKey: .price)
        try container.encode(deliverables, forKey: .deliverables)
        try container.encode(duration, forKey: .duration)
    }
}
