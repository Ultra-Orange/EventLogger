//
//  Category.swift
//  EventLogger
//
//  Created by Yoon on 8/21/25.
//

import UIKit

struct Category: Hashable {
    let id: UUID
    var name: String
    var position: Int
    var color: UIColor
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.id == rhs.id
    }
}
