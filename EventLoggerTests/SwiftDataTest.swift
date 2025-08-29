//
//  SwiftDataTest.swift
//  EventLogger
//
//  Created by Yoon on 8/28/25.
//
import Dependencies
import SwiftData
import Testing
import UIKit

@testable import EventLogger

struct CategoryMappingTests {
    @Test("Category → CategoryStore → Category 매핑이 일관성 있는지 검증")
    func categoryRoundTrip() throws {
        // Given: 도메인 Category 생성
        let original = CategoryItem(
            name: "콘서트",
            position: 1,
            colorId: CategoryColor.red.rawValue
        )

        // When: Persistent로 변환 후 다시 Domain으로 복원
        let store = original.toPersistent()
        let restored = store.toDomain()

        // Then: 값 검증
        #expect(restored != nil)
        #expect(restored?.name == original.name)
        #expect(restored?.position == original.position)
        #expect(restored?.colorId == original.colorId)

        // UI 컬러도 일관성 검증
        #expect(restored?.color == original.color)
    }

    @Test("기본 카테고리 5개 저장 후 복원 검증")
    func defaultCategoriesPersistence() throws {
        // Given: 기본 카테고리 이름들
        let names = ["콘서트", "페스티벌", "연극", "뮤지컬", "팬미팅"]
        let categories: [CategoryItem] = names.enumerated().map { index, name in
            CategoryItem(
                name: name,
                position: index,
                colorId: CategoryColor.allCases[index % CategoryColor.allCases.count].rawValue
            )
        }

        // When: Persistent 변환 후 다시 Domain으로 복원
        let stores = categories.map { $0.toPersistent() }
        let restored = stores.compactMap { $0.toDomain() }

        // Then: 개수 검증
        #expect(restored.count == categories.count)

        // 이름들이 그대로 보존되는지 확인
        let restoredNames = restored.map { $0.name }
        #expect(restoredNames == names)
    }

    @Test("Category CRUD 테스트")
    func categoryCRUD() throws {
        @Dependency(\.swiftDataManager) var swiftData

        // CREATE
        swiftData.insertCategory(name: "테스트0", position: 0, colorId: 0)
        swiftData.insertCategory(name: "테스트1", position: 1, colorId: 1)
        var all = swiftData.fetchAllCategories()
        #expect(all.count == 2)
        #expect(all[0].name == "테스트0")
        #expect(all[1].colorId == 1)

        // READ (fetchOne)
        let fetched = swiftData.fetchOneCategory(name: "테스트0")
        #expect(fetched != nil)
        #expect(fetched?.name == "테스트0")
        #expect(fetched?.position == 0)
        #expect(fetched?.colorId == 0)

        let fetched2 = swiftData.fetchOneCategory(name: "테스트1")
        #expect(fetched2 != nil)
        #expect(fetched2?.name == "테스트1")
        #expect(fetched2?.position == 1)
        #expect(fetched2?.colorId == 1)

        // UPDATE
        if let category = fetched {
            swiftData.updateCategory(categoryStore: category, name: "수정됨", position: 1)
        }
        all = swiftData.fetchAllCategories()
        #expect(all[0].name == "수정됨")
        #expect(all[0].position == 1)

        // DELETE
        if let category = fetched {
            swiftData.deleteCategory(categoryStore: category)
        }
        all = swiftData.fetchAllCategories()
        #expect(!all.isEmpty)

        if let category2 = fetched2 {
            swiftData.deleteCategory(categoryStore: category2)
        }

        all = swiftData.fetchAllCategories()
        #expect(all.isEmpty)
    }
}
