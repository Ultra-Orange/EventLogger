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
    var colorId: Int
    
    var color: UIColor{
        CategoryColor(rawValue: colorId)?.uiColor ?? .systemGray
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Category {
    func toPersistent() -> CategoryStore {
        CategoryStore(
            id: id,
            name: name,
            position: position,
            colorId: colorId
        )
    }
}


enum CategoryColor: Int, CaseIterable {
    case red = 0
    case orange = 1
    case blue = 2
    case green = 3
    case yellow = 4
    case cyan = 5
    
    var uiColor: UIColor {
        switch self {
        case .red: return UIColor.systemRed
        case .orange: return UIColor.systemOrange
        case .blue: return UIColor.systemBlue
        case .green: return UIColor.systemGreen
        case .yellow: return UIColor.systemYellow
        case .cyan: return UIColor.systemCyan
        }
    }
}
