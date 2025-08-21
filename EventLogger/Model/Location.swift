//
//  Location.swift
//  EventLogger
//
//  Created by Yoon on 8/21/25.
//

import Foundation

struct Location: Hashable {
    let id: UUID
    var latitude: Double
    var longitude: Double
    var displayName: String
    var formattedAddress: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.id == rhs.id
    }
}
