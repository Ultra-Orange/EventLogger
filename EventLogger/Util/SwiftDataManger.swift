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
            print("SwiftData 저장 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: Category 관련
    // CREATE
        
    func insertCategory(category: CategoryItem) {
        let storeCategory = category.toPersistent()
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
            print("카테고리 fetch 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchOneCategory(id: UUID) -> CategoryItem? {
        let predicate = #Predicate<CategoryStore> { $0.id == id }
        let descriptor = FetchDescriptor<CategoryStore>(predicate: predicate)
        do {
            return try modelContext.fetch(descriptor).first?.toDomain()
        } catch {
            print("카테고리 fetchOne 실패: \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchOneCategoryStore(id: UUID) -> CategoryStore? {
        let predicate = #Predicate<CategoryStore> { $0.id == id }
        let descriptor = FetchDescriptor<CategoryStore>(predicate: predicate)
        do {
            return try modelContext.fetch(descriptor).first
        } catch {
            print("fetchOneCategoryStore 실패: \(error.localizedDescription)")
            return nil
        }
    }

    // UPDATE
    func updateCategory(id: UUID, category: CategoryItem) {
        if let store = fetchOneCategoryStore(id: id) {
            store.name = category.name
            store.position = category.position
            store.colorId = category.colorId
            saveContext()
        } else {
            print("해당 id에 일치하는 카테고리가 존재하지 않습니다.")
        }
    }

    // Delete
    func deleteCategory(id: UUID) {
        if let target = fetchOneCategoryStore(id: id){
            modelContext.delete(target)
            saveContext()
        } else {
            print("해당 id에 일치하는 카테고리가 존재하지 않습니다.")
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
    func fetchAllEvents() -> [EventItem] {
        let descriptor = FetchDescriptor<EventStore>(
            sortBy: [SortDescriptor(\.startTime, order: .forward)]
        )
        do {
            let stores = try modelContext.fetch(descriptor)
            return stores.map { $0.toDomain() }
        } catch {
            print("이벤트 일정 fetch 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchOneEvent(id: UUID) -> EventItem? {
        let predicate = #Predicate<EventStore> { $0.id == id }
        let descriptor = FetchDescriptor<EventStore>(
            predicate: predicate
        )
        do {
            return try modelContext.fetch(descriptor).first?.toDomain()
        } catch {
            print("이벤트 일정 fetch 실패: \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchOneEventStore(id: UUID) -> EventStore? {
        let predicate = #Predicate<EventStore> { $0.id == id }
        let descriptor = FetchDescriptor<EventStore>(
            predicate: predicate
        )
        do {
            return try modelContext.fetch(descriptor).first
        } catch {
            print("이벤트 일정 fetch 실패: \(error.localizedDescription)")
            return nil
        }
    }
    
    // UPDATE
    func updateEvent(id: UUID, event: EventItem) {
        if let store = fetchOneEventStore(id: id) {
            store.title = event.title
            store.categoryId = event.categoryId
            store.imageData = event.image?.jpegData(compressionQuality: 0.8)
            store.startTime = event.startTime
            store.endTime = event.endTime
            store.location = event.location
            store.artists = event.artists
            store.expense = event.expense
            store.currency = event.currency.rawValue
            store.memo = event.memo
            saveContext()
        } else {
            print("해당 id에 일치하는 일정이 존재하지 않습니다.")
        }
    }
    
    func deleteEvent(id: UUID) {
        if let target = fetchOneEventStore(id: id){
            modelContext.delete(target)
            saveContext()
        } else {
            print("해당 id에 일치하는 일정이 존재하지 않습니다.")
        }
    }
}

extension SwiftDataManager {
    // 카테고리에 해당하는 컬러 리턴
    func colorForCategory(_ id: UUID) -> Color {
        guard let item = fetchOneCategory(id: id),
              let color = CategoryColor(rawValue: item.colorId)
        else {
            return .gray
        }
        return Color(color.uiColor)
    }
}
