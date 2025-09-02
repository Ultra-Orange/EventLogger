//
//  StatisticsService.swift
//  EventLogger
//
//  Created by Yoon on 9/2/25.
//

// StatisticsService.swift
import Foundation

enum StatsPeriod {
    case all
    case year(Int)
    case yearMonth(year: Int, month: Int)
}

struct StatisticsService {
    let manager: SwiftDataManager
    private let calendar = Calendar(identifier: .gregorian)

    // 공통: 기간에 맞는 이벤트만 필터링
    private func filteredEvents(for period: StatsPeriod) -> [EventItem] {
        let events = manager.fetchAllEvents() // SwiftData → Domain 변환 재사용
        switch period {
        case .all:
            return events
        case .year(let y):
            return events.filter { calendar.component(.year, from: $0.startTime) == y }
        case .yearMonth(let y, let m):
            return events.filter {
                let d = calendar.dateComponents([.year, .month], from: $0.startTime)
                return d.year == y && d.month == m
            }
        }
    }
}


extension StatisticsService {
    /// 2-1) 기간별 카테고리 통계
    func categoryStats(for period: StatsPeriod) -> [CategoryStats] {
        let events = filteredEvents(for: period)
        let categories = manager.fetchAllCategories() // [CategoryItem]

        // categoryId → (count, totalExpense)
        var bucket: [UUID: (count: Int, total: Double)] = [:]
        for e in events {
            let cur = bucket[e.categoryId] ?? (0, 0)
            bucket[e.categoryId] = (cur.count + 1, cur.total + e.expense)
        }

        // 결과를 CategoryItem과 매핑 (등록된 카테고리 중 집계가 있는 것만)
        return categories.compactMap { cat in
            guard let v = bucket[cat.id] else { return nil }
            return CategoryStats(category: cat, count: v.count, totalExpense: v.total)
        }
        .sorted { $0.count > $1.count } // 필요시 정렬 기준 변경 가능
    }

    /// 2-2) 기간별 아티스트 통계
    func artistStats(for period: StatsPeriod) -> [ArtistStats] {
        let events = filteredEvents(for: period)

        // artistName → (count, totalExpense)
        var bucket: [String: (count: Int, total: Double)] = [:]
        for e in events {
            for name in e.artists {
                let cur = bucket[name] ?? (0, 0)
                bucket[name] = (cur.count + 1, cur.total + e.expense)
            }
        }

        return bucket
            .map { ArtistStats(name: $0.key, count: $0.value.count, totalExpense: $0.value.total) }
            .sorted { $0.count > $1.count }
    }
}


extension StatisticsService {
    /// 이벤트가 존재하는 연도를 문자열 배열로 반환 (예: ["2025", "2024", ...])
    func activeYears(descending: Bool = true) -> [String] {
        let years = Set(manager.fetchAllEvents().map {
            calendar.component(.year, from: $0.startTime)
        })
        let sorted = descending ? years.sorted(by: >) : years.sorted()
        return sorted.map(String.init)
    }
}
