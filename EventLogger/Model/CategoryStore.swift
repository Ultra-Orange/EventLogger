//
//  CategoryStore.swift
//  EventLogger
//
//  Created by Yoon on 8/28/25.
//

import SwiftData
import UIKit

// CategoryItem에 대응하는 SwiftData모델
@Model
final class CategoryStore {
    @Attribute(.unique) var name: String
    var position: Int
    var colorId: Int

    init(name: String, position: Int, colorId: Int) {
        self.name = name
        self.position = position
        self.colorId = colorId
    }
}

// SwiftData to 도메인
extension CategoryStore {
    func toDomain() -> CategoryItem {
        return CategoryItem(
            name: name,
            position: position,
            colorId: colorId
        )
    }
}
