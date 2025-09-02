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

enum CategoryColor: Int, CaseIterable {
    case code0 = 0
    case code1 = 1
    case code2 = 2
    case code3 = 3
    case code4 = 4
    case code5 = 5
    case code6 = 6
    case code7 = 7
    case code8 = 8
    case code9 = 9
    case code10 = 10
    case code11 = 11
 

    var uiColor: UIColor {
        switch self {
        case .code0: return UIColor.category0
        case .code1: return UIColor.category1
        case .code2: return UIColor.category2
        case .code3: return UIColor.category3
        case .code4: return UIColor.category4
        case .code5: return UIColor.category5
        case .code6: return UIColor.category6
        case .code7: return UIColor.category7
        case .code8: return UIColor.category8
        case .code9: return UIColor.category9
        case .code10: return UIColor.category10
        case .code11: return UIColor.category11
        }
    }
}
