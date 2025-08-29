//
//  CategoryItem.swift
//  EventLogger
//
//  Created by Yoon on 8/21/25.
//

import UIKit

// 앱에서 사용하는 카테고리용 도메인 모델
struct CategoryItem: Hashable {
    var id: UUID
    var name: String
    var position: Int
    var colorId: Int

    var color: UIColor {
        CategoryColor(rawValue: colorId)?.uiColor ?? .systemGray
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: CategoryItem, rhs: CategoryItem) -> Bool {
        return lhs.id == rhs.id
    }
}

// 도메인 to SwiftData모델
extension CategoryItem {
    func toPersistent() -> CategoryStore {
        CategoryStore(
            id: id,
            name: name,
            position: position,
            colorId: colorId
        )
    }
}

// TODO: 컬러코드 완성되면 수정
enum CategoryColor: Int, CaseIterable {
    case red = 0
    case blue = 1
    case yellow = 2
    case purple = 3
    case green = 4

    var uiColor: UIColor {
        switch self {
        case .red: return UIColor.systemRed
        case .blue: return UIColor.systemBlue
        case .yellow: return UIColor.systemYellow
        case .purple: return UIColor.systemOrange
        case .green: return UIColor.systemGreen
        }
    }
}
