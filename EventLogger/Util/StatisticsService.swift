//
//  StatisticsService.swift
//  EventLogger
//
//  Created by Yoon on 9/2/25.
//

import Foundation

// MARK: - Period

enum StatsPeriod {
    case all
    case year(Int)
    case yearMonth(year: Int, month: Int)
}

// MARK: - DTOs (집계 결과)

struct StatisticsService {
    let manager: SwiftDataManager
    let calendar = Calendar(identifier: .gregorian)

    // MARK: - Core accessors

    /// 기간에 맞는 이벤트만 필터링 (테스트/재사용을 위해 internal)
    func filteredEvents(for period: StatsPeriod) -> [EventItem] {
        let events = manager.fetchAllEvents()
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

    /// 해당 기간 총합(횟수/비용)
    func total(for period: StatsPeriod) -> (count: Int, expense: Double) {
        let evts = filteredEvents(for: period)
        let totalExpense = evts.reduce(0) { $0 + $1.expense }
        return (evts.count, totalExpense)
    }
}

// MARK: - 1) 상위 집계: 카테고리 / 아티스트

extension StatisticsService {

    /// 기간별 카테고리 통계
    /// - Returns: 등록된 카테고리 중 해당 기간에 한 번이라도 등장한 항목만 반환
    func categoryStats(for period: StatsPeriod,
                       sort: (CategoryStats, CategoryStats) -> Bool = { $0.count > $1.count }) -> [CategoryStats] {
        let events = filteredEvents(for: period)
        let categories = manager.fetchAllCategories() // [CategoryItem]

        // categoryId → (count, totalExpense)
        var bucket: [UUID: (count: Int, total: Double)] = [:]
        for e in events {
            let cur = bucket[e.categoryId] ?? (0, 0)
            bucket[e.categoryId] = (cur.count + 1, cur.total + e.expense)
        }

        return categories.compactMap { cat in
            guard let v = bucket[cat.id] else { return nil }
            return CategoryStats(category: cat, count: v.count, totalExpense: v.total)
        }
        .sorted(by: sort)
    }

    /// 기간별 아티스트 통계
    func artistStats(for period: StatsPeriod,
                     sort: (ArtistStats, ArtistStats) -> Bool = { $0.count > $1.count }) -> [ArtistStats] {
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
            .sorted(by: sort)
    }
}

// MARK: - 2) 하위 집계: 펼침행(Parent → Children)

extension StatisticsService {

    /// 특정 카테고리 안에서 아티스트별 Count
    func artistCountInCategory(for period: StatsPeriod, categoryId: UUID) -> [String: Int] {
        let evts = filteredEvents(for: period)
        var m: [String: Int] = [:]
        for e in evts where e.categoryId == categoryId {
            for name in e.artists { m[name, default: 0] += 1 }
        }
        return m
    }

    /// 특정 카테고리 안에서 아티스트별 Expense
    func artistExpenseInCategory(for period: StatsPeriod, categoryId: UUID) -> [String: Double] {
        let evts = filteredEvents(for: period)
        var m: [String: Double] = [:]
        for e in evts where e.categoryId == categoryId {
            for name in e.artists { m[name, default: 0] += e.expense }
        }
        return m
    }

    /// 특정 아티스트의 카테고리별 Count
    func categoryCountForArtist(for period: StatsPeriod, artistName: String) -> [UUID: Int] {
        let evts = filteredEvents(for: period)
        var m: [UUID: Int] = [:]
        for e in evts where e.artists.contains(artistName) {
            m[e.categoryId, default: 0] += 1
        }
        return m
    }

    /// 특정 아티스트의 카테고리별 Expense
    func categoryExpenseForArtist(for period: StatsPeriod, artistName: String) -> [UUID: Double] {
        let evts = filteredEvents(for: period)
        var m: [UUID: Double] = [:]
        for e in evts where e.artists.contains(artistName) {
            m[e.categoryId, default: 0] += e.expense
        }
        return m
    }
}

// MARK: - 3) 보조

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
