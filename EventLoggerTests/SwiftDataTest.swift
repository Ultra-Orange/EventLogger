//
//  SwiftDataTest.swift
//  EventLogger
//
//  Created by Yoon on 8/28/25.
//
import UIKit
import Testing
@testable import EventLogger


import Testing
@testable import EventLogger

struct CategoryMappingTests {
    @Test("Category → CategoryStore → Category 매핑이 일관성 있는지 검증")
    func testCategoryRoundTrip() throws {
        // Given: 도메인 Category 생성
        let original = CategoryItem(
            id: UUID(),
            name: "콘서트",
            position: 1,
            colorId: CategoryColor.red.rawValue
        )
        
        // When: Persistent로 변환 후 다시 Domain으로 복원
        let store = original.toPersistent()
        let restored = store.toDomain()
        
        // Then: 값 검증
        #expect(restored != nil)
        #expect(restored?.id == original.id)
        #expect(restored?.name == original.name)
        #expect(restored?.position == original.position)
        #expect(restored?.colorId == original.colorId)
        
        // UI 컬러도 일관성 검증
        #expect(restored?.color == original.color)
    }
    @Test("기본 카테고리 5개 저장 후 복원 검증")
    func testDefaultCategoriesPersistence() throws {
        // Given: 기본 카테고리 이름들
        let names = ["콘서트", "페스티벌", "연극", "뮤지컬", "팬미팅"]
        let categories: [CategoryItem] = names.enumerated().map { index, name in
            CategoryItem(
                id: UUID(),
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
}


