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
        
    func insertCategory(caetgory: CategoryItem) {
        let storeCategory = caetgory.toPersistent()
        modelContext.insert(storeCategory)
        saveContext()
    }

    // READ
    func fetchAllCategories() -> [CategoryItem] {
        let descriptor = FetchDescriptor<CategoryStore>(
            sortBy: [SortDescriptor(\.position, order: .forward)]
        )
        do {
            let stores = try modelContext.fetch(descriptor)
            return stores.map{ $0.toDomain() }
        } catch {
            assertionFailure("카테고리 fetch 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchOneCategory(id: UUID) -> CategoryItem? {
        let predicate = #Predicate<CategoryStore> { $0.id == id }
        let descriptor = FetchDescriptor<CategoryStore>(predicate: predicate)
        do {
            return try modelContext.fetch(descriptor).first?.toDomain()
        } catch {
            assertionFailure("카테고리 fetchOne 실패: \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchOneCategoryStore(id: UUID) -> CategoryStore? {
        let predicate = #Predicate<CategoryStore> { $0.id == id }
        let descriptor = FetchDescriptor<CategoryStore>(predicate: predicate)
        do {
            return try modelContext.fetch(descriptor).first
        } catch {
            assertionFailure("fetchOneCategoryStore 실패: \(error.localizedDescription)")
            return nil
        }
    }

    // UPDATE
    func updateCategory(id: UUID, category: CategoryItem) {
        if let store = fetchOneCategoryStore(id: id) {
            let new = category.toPersistent()
            store.name = new.name
            store.position = new.position
            store.colorId = new.colorId
            saveContext()
        } else {
            assertionFailure("해당 id에 일치하는 카테고리가 존재하지 않습니다.")
        }
    }

    // Delete
    func deleteCategory(id: UUID) {
        if let target = fetchOneEvent(id: id){
            modelContext.delete(target)
            saveContext()
        } else {
            assertionFailure("해당 id에 일치하는 카테고리가 존재하지 않습니다.")
        }
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
        if let store = fetchOneEvent(id: id) {
            let new = event.toPersistent()
            store.title = new.title
            store.categoryId = new.categoryId
            store.imageData = new.imageData
            store.startTime = new.startTime
            store.endTime = new.endTime
            store.location = new.location
            store.artists = new.artists
            store.expense = new.expense
            store.currency = new.currency
            store.memo = new.memo
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
    func colorForCategory(_ id: UUID) -> Color {
        guard let store = fetchOneCategory(id: id),
              let color = CategoryColor(rawValue: store.colorId)
        else {
            return .gray
        }
        return Color(color.uiColor)
    }
}
