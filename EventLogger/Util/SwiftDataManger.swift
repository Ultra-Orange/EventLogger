//
//  SwiftDataManger.swift
//  EventLogger
//
//  Created by Yoon on 8/28/25.
//

import Dependencies
import Foundation
import SwiftData
import SwiftUI

struct SwiftDataManager {
    @Dependency(\.modelContext) var modelContext

    // MARK: SaveContext

    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            assertionFailure("SwiftData 저장 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: Category 관련
    // CREATE
    
    func tmp(category: CategoryItem){
        
    }
    
    func insertCategory(name: String, position: Int, colorId: Int) {
        let category = CategoryStore(
            name: name,
            position: position,
            colorId: colorId
        )
        modelContext.insert(category)
        saveContext()
    }

    // READ
    func fetchAllCategories() -> [CategoryStore] {
        let descriptor = FetchDescriptor<CategoryStore>(
            sortBy: [SortDescriptor(\.position, order: .forward)]
        )
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            assertionFailure("카테고리 fetch 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchOneCategory(name: String) -> CategoryStore? {
        let predicate = #Predicate<CategoryStore> { $0.name == name }
        let descriptor = FetchDescriptor<CategoryStore>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.position, order: .forward)]
        )
        do {
            return try modelContext.fetch(descriptor).first
        } catch {
            assertionFailure("카테고리 fetchOne 실패: \(error.localizedDescription)")
            return nil
        }
    }

    // UPDATE
    func updateCategory(categoryStore: CategoryStore,
                        name: String? = nil,
                        position: Int? = nil,
                        colorId: Int? = nil)
    {
        if let name { categoryStore.name = name }
        if let position { categoryStore.position = position }
        if let colorId { categoryStore.colorId = colorId }
        saveContext()
    }

    // Delete
    func deleteCategory(categoryStore: CategoryStore) {
        modelContext.delete(categoryStore)
        saveContext()
    }
    
    // MARK: EventItem
    // CREATE
    func insertEventItem(_ item: EventItem) {
        let eventStore = item.toPersistent()
        modelContext.insert(eventStore)
        saveContext()
    }
    
    // READ
    func fetchAllEvents() -> [EventStore] {
        let descriptor = FetchDescriptor<EventStore>(
            sortBy: [SortDescriptor(\.startTime, order: .forward)]
        )
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            assertionFailure("이벤트 일정 fetch 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchOneEvent(id: UUID) -> EventStore? {
        let predicate = #Predicate<EventStore> { $0.id == id }
        let descriptor = FetchDescriptor<EventStore>(
            predicate: predicate
        )
        do {
            return try modelContext.fetch(descriptor).first
        } catch {
            assertionFailure("이벤트 일정 fetch 실패: \(error.localizedDescription)")
            return nil
        }
    }
    
    // UPDATE
    func updateEvent(id: UUID, event: EventItem) {
        if let past = fetchOneEvent(id: id) {
            let income = event.toPersistent()
            past.title = income.title
            past.categoryName = income.categoryName
            past.imageData = income.imageData
            past.startTime = income.startTime
            past.endTime = income.endTime
            past.location = income.location
            past.artists = income.artists
            past.expense = income.expense
            past.currency = income.currency
            past.memo = income.memo
            saveContext()
        } else {
            assertionFailure("해당 id에 일치하는 일정이 존재하지 않습니다.")
        }
    }
    
    func deleteEvent(id: UUID) {
        if let target = fetchOneEvent(id: id){
            modelContext.delete(target)
            saveContext()
        } else {
            assertionFailure("해당 id에 일치하는 일정이 존재하지 않습니다.")
        }
    }
}

extension SwiftDataManager {
    // 카테고리에 해당하는 컬러 리턴
    func colorForCategoryName(_ name: String) -> Color {
        guard let store = fetchOneCategory(name: name),
              let color = CategoryColor(rawValue: store.colorId)
        else {
            return .gray
        }
        return Color(color.uiColor)
    }
}
