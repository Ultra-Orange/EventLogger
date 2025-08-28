//
//  Artist.swift
//  EventLogger
//
//  Created by Yoon on 8/22/25.
//

import UIKit

struct Artist: Hashable {
    let id: UUID
    let name: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Artist, rhs: Artist) -> Bool {
        return lhs.id == rhs.id
    }
}
