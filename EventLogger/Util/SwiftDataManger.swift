//
//  SwiftDataManger.swift
//  EventLogger
//
//  Created by Yoon on 8/28/25.
//

import Dependencies
import Foundation
import SwiftData

struct SwiftDataManager {
    @Dependency(\.modelContext) var modelContext

    // MARK: SaveContext

    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            assertionFailure("🚨 SwiftData 저장 실패: \(error.localizedDescription)")
        }
    }

    // MARK: CREATE

    func insertCategory(name: String, position: Int, colorId: Int) {
        let category = CategoryStore(
            name: name,
            position: position,
            colorId: colorId
        )
        modelContext.insert(category)
        saveContext()
    }

    // MARK: READ

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

    // MARK: UPDATE

    func updateCategory(_ category: CategoryStore,
                        name: String? = nil,
                        position: Int? = nil,
                        colorId: Int? = nil)
    {
        if let name { category.name = name }
        if let position { category.position = position }
        if let colorId { category.colorId = colorId }
        saveContext()
    }

    // MARK: Delete

    func deleteCategory(_ category: CategoryStore) {
        modelContext.delete(category)
        saveContext()
    }
}
