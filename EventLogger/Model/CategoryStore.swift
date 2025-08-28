//
//  CategoryStore.swift
//  EventLogger
//
//  Created by Yoon on 8/28/25.
//

import SwiftData
import UIKit

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
    func toDomain() -> CategoryItem? {
        guard let categoryColor = CategoryColor(rawValue: colorId) else { return nil }
        return CategoryItem(
            name: name,
            position: position,
            colorId: colorId
        )
    }
}
