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

    func insertCategory(name: String, colorId: Int) {
        // 1) 현재 저장된 카테고리의 position 중 최대값 찾기
        let categories = fetchAllCategories()
        let maxPosition = categories.map { $0.position }.max() ?? -1

        // 2) 새로운 CategoryItem 생성
        let newCategory = CategoryItem(
            id: UUID(),
            name: name,
            position: maxPosition + 1,
            colorId: colorId
        )

        // 3) Persistent 모델로 변환 후 저장
        let storeCategory = newCategory.toPersistent()
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
            return stores.map { $0.toDomain() }
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
    func updateCategory(id: UUID, name: String, colorId: Int) {
        if let store = fetchOneCategoryStore(id: id) {
            store.name = name
            store.colorId = colorId
            saveContext()
        } else {
            print("해당 id에 일치하는 카테고리가 존재하지 않습니다.")
        }
    }

    // 카테고리 포지션 값 변경
    func updateCategoriesPosition(_ items: [CategoryItem]) {
        for (index, item) in items.enumerated() {
            if let store = fetchOneCategoryStore(id: item.id) {
                store.position = index
            }
        }
        saveContext()
    }

    // Delete
    func deleteCategory(id: UUID) throws {
        let allCategories = fetchAllCategories()

        // 조건 1) 카테고리가 하나만 남아있으면 삭제 불가
        guard allCategories.count > 1 else {
            throw SwiftDataMangerError.cannotDeleteLastCategory
        }

        // 조건 2) 등록된 이벤트가 존재하는 카테고리는 삭제 불가
        let stats = fetchCategoryStatistics()
        if stats.contains(where: { $0.category.id == id && $0.count > 0 }) {
            throw SwiftDataMangerError.cannotDeleteUsedCategory
        }

        // 위 두 조건을 모두 통과해야 삭제진행
        if let target = fetchOneCategoryStore(id: id) {
            modelContext.delete(target)
            saveContext()

            // 삭제 직후 포지션 재정렬 (오동작 방지)
            let updated = fetchAllCategories()
            updateCategoriesPosition(updated)
        } else {
            print("해당 id에 일치하는 카테고리가 존재하지 않습니다.")
        }
    }

    // MARK: EventItem

    // CREATE
    func insertEventItem(_ item: EventItem) {
        let eventStore = item.toPersistent()

        // [String] → [ArtistStore]
        var artistStores: [ArtistStore] = []
        for name in item.artists {
            let predicate = #Predicate<ArtistStore> { $0.name == name }
            let descriptor = FetchDescriptor<ArtistStore>(predicate: predicate)
            do {
                if let existing = try modelContext.fetch(descriptor).first {
                    artistStores.append(existing)
                } else {
                    let newArtist = ArtistStore(name: name)
                    modelContext.insert(newArtist)
                    artistStores.append(newArtist)
                }
            } catch {
                print("아티스트 fetch 실패: \(error.localizedDescription)")
            }
        }
        eventStore.artists = artistStores
        eventStore.artistsOrder = item.artists

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
        guard let store = fetchOneEventStore(id: id) else {
            print("해당 id에 일치하는 일정이 존재하지 않습니다.")
            return
        }

        store.title = event.title
        store.categoryId = event.categoryId
        store.imageData = event.image?.jpegData(compressionQuality: 0.8)
        store.startTime = event.startTime
        store.endTime = event.endTime
        store.location = event.location

        // [String] → [ArtistStore]
        var artistStores: [ArtistStore] = []
        for name in event.artists {
            let predicate = #Predicate<ArtistStore> { $0.name == name }
            let descriptor = FetchDescriptor<ArtistStore>(predicate: predicate)
            do {
                if let existing = try modelContext.fetch(descriptor).first {
                    artistStores.append(existing)
                } else {
                    let newArtist = ArtistStore(name: name)
                    modelContext.insert(newArtist)
                    artistStores.append(newArtist)
                }
            } catch {
                print("아티스트 fetch 실패: \(error.localizedDescription)")
            }
        }
        store.artists = artistStores
        store.artistsOrder = event.artists

        store.expense = event.expense
        store.currency = event.currency.rawValue
        store.memo = event.memo

        saveContext()
    }

    func deleteEvent(id: UUID) {
        if let target = fetchOneEventStore(id: id) {
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

    // 아티스트 통계용 데이터 리턴
    func fetchArtistStatistics() -> [ArtistStats] {
        let events = fetchAllEvents() // [EventItem]

        // 아티스트별 데이터 집계
        var stats: [String: (count: Int, totalExpense: Double)] = [:]

        for event in events {
            for artist in event.artists {
                if var current = stats[artist] {
                    current.count += 1
                    current.totalExpense += event.expense
                    stats[artist] = current
                } else {
                    stats[artist] = (count: 1, totalExpense: event.expense)
                }
            }
        }

        // 결과 변환
        return stats.map { ArtistStats(name: $0.key, count: $0.value.count, totalExpense: $0.value.totalExpense) }
            .sorted { $0.count > $1.count } // 예시: 많이 참가한 순으로 정렬
    }

    // 카테고리 통계용 데이터 리턴
    func fetchCategoryStatistics() -> [CategoryStats] {
        let events = fetchAllEvents() // [EventItem]
        let categories = fetchAllCategories() // [CategoryItem]

        // categoryId → (count, totalExpense) 집계
        var stats: [UUID: (count: Int, totalExpense: Double)] = [:]

        for event in events {
            if var current = stats[event.categoryId] {
                current.count += 1
                current.totalExpense += event.expense
                stats[event.categoryId] = current
            } else {
                stats[event.categoryId] = (count: 1, totalExpense: event.expense)
            }
        }

        // 결과 CategoryItem과 매핑
        return categories.compactMap { category in
            guard let value = stats[category.id] else { return nil }
            return CategoryStats(category: category, count: value.count, totalExpense: value.totalExpense)
        }
        .sorted { $0.count > $1.count } // 이벤트 수 많은 순 정렬 (옵션)
    }
}

enum SwiftDataMangerError: Error {
    case cannotDeleteUsedCategory
    case cannotDeleteLastCategory
}
