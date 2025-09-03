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
            id: UUID(),
            name: "콘서트",
            position: 1,
            colorId: 1
        )

        // When: Persistent로 변환 후 다시 Domain으로 복원
        let store = original.toPersistent()
        let restored = store.toDomain()

        // Then: 값 검증
        #expect(restored.id == original.id)
        #expect(restored.name == original.name)
        #expect(restored.position == original.position)
        #expect(restored.colorId == original.colorId)

    }

    @Test("기본 카테고리 5개 저장 후 복원 검증")
    func defaultCategoriesPersistence() throws {
        // Given: 기본 카테고리 이름들
        let names = ["콘서트", "페스티벌", "연극", "뮤지컬", "팬미팅"]
        let categories: [CategoryItem] = names.enumerated().map { index, name in
            CategoryItem(
                id: UUID(),
                name: name,
                position: index,
                colorId: index,
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
        @Dependency(\.swiftDataManager) var swiftDataManager
        
        let dummyItem1 = CategoryItem(
            id: UUID(),
            name: "테스트1",
            position: 0,
            colorId: 0
        )
        let dummyItem2 = CategoryItem(
            id: UUID(),
            name: "테스트2",
            position: 1,
            colorId: 1
        )
        
        // CREATE
        swiftDataManager.insertCategory(title: "테스트1", colorId: 0)
        swiftDataManager.insertCategory(title: "테스트2", colorId: 1)
        
        // READ
        let fetchAll = swiftDataManager.fetchAllCategories()
        
        #expect(fetchAll.count == 2)
        
        let data1 = fetchAll[0]
        #expect(data1.name == "테스트1")
        #expect(data1.position == 0)
        #expect(data1.colorId == 0)
        
        //UPDATE
        
        let modify = CategoryItem(
            id: data1.id,
            name: "변경",
            position: 2,
            colorId: 2)
        
        swiftDataManager.updateCategory(id: data1.id, category: modify)
        
        let check = swiftDataManager.fetchOneCategory(id: data1.id)
        #expect(check?.name == "변경")
        #expect(check?.position == 2)
        #expect(check?.colorId == 2)
        
        try swiftDataManager.deleteCategory(id: data1.id)
        #expect(swiftDataManager.fetchAllCategories().count == 1)
    }
    
    @Test("EventItem CRUD TEST")
    func EventItemCRUDTests() throws {
        @Dependency(\.swiftDataManager) var swiftDataManager
        
        let dummyCategory1 = CategoryItem(
            id: UUID(),
            name: "테스트용 카테고리1",
            position: 0,
            colorId: 0
        )
        
        
        let dummyEventItem1 = EventItem(
            id: UUID(),
            title: "이벤트 아이템",
            categoryId: dummyCategory1.id,
            startTime: DateFormatter.toDate("2025년 09월 26일 12:00") ?? Date.now,
            endTime: DateFormatter.toDate("2025년 09월 26일 22:00") ?? Date.now,
            artists: ["아티스트1","아티스트2"],
            expense: 10000,
            currency: Currency.KRW,
            memo: "메모메모"
        )
        
        let dummyEventItem2 = EventItem(
            id: UUID(),
            title: "이벤트 아이템2",
            categoryId: dummyCategory1.id,
            startTime: DateFormatter.toDate("2025년 10월 26일 12:00") ?? Date.now,
            endTime: DateFormatter.toDate("2025년 10월 26일 14:00") ?? Date.now,
            artists: ["아티스트3"],
            expense: 12000,
            currency: Currency.KRW,
            memo: "메모메모alpha"
        )
        
        // CREATE
        swiftDataManager.insertEventItem(dummyEventItem1)
        swiftDataManager.insertEventItem(dummyEventItem2)
        
        // READ
        let fetchAll = swiftDataManager.fetchAllEvents()
        #expect(fetchAll.count == 2)
        
        let fetchOne = swiftDataManager.fetchOneEvent(id: dummyEventItem1.id)
        #expect(fetchOne?.title == "이벤트 아이템")
        #expect(fetchOne?.expense == 10000)
        #expect(fetchOne?.memo == "메모메모")
        #expect(fetchOne?.artists[0] == "아티스트1")
        
        //UPDATE
        
        let modify = EventItem(
            id: dummyEventItem2.id,
            title: "이벤트 아이템20",
            categoryId: dummyCategory1.id,
            startTime: DateFormatter.toDate("2025년 10월 26일 12:00") ?? Date.now,
            endTime: DateFormatter.toDate("2025년 10월 26일 14:00") ?? Date.now,
            artists: ["아티스트3"],
            expense: 12000,
            currency: Currency.KRW,
            memo: "수정함"
        )
        
        swiftDataManager.updateEvent(id: dummyEventItem2.id, event: modify)
        
        let target = swiftDataManager.fetchOneEvent(id: dummyEventItem2.id)
        #expect(target?.title == "이벤트 아이템20")
        #expect(target?.memo == "수정함")
        
        // DELETE
        
        swiftDataManager.deleteEvent(id: dummyEventItem2.id)
        #expect(swiftDataManager.fetchAllEvents().count == 1)
    }
}
