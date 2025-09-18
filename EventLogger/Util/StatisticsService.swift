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

struct StatisticsService {
    let manager: SwiftDataManager
    let calendar = Calendar(identifier: .gregorian)

    /// 기간에 맞는 이벤트만 필터링
    func filteredEvents(for period: StatsPeriod) -> [EventItem] {
        let events = manager.fetchAllEvents()
        switch period {
        case .all:
            return events
        case let .year(y):
            return events.filter { calendar.component(.year, from: $0.startTime) == y }
        case let .yearMonth(y, m):
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

extension StatisticsService {
    /// 기간별 카테고리 통계 (하위 상세 포함)
    /// - 반환 배열 - 카운트 내림차순 정렬
    /// - 내부의 하위 목록 - 각각 카운트/지출 내림차순 정렬
    func categoryStats(for period: StatsPeriod) -> [CategoryStats] {
        let events = filteredEvents(for: period)
        let categories = manager.fetchAllCategories()
        let catById: [UUID: CategoryItem] = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0) })

        // categoryId → (count, totalExpense, artistCount[name], artistExpense[name])
        struct CatAgg {
            var count: Int = 0
            var totalExpense: Double = 0
            var artistCount: [String: Int] = [:]
            var artistExpense: [String: Double] = [:]
        }
        var bucket: [UUID: CatAgg] = [:]

        for event in events {
            let categoryId = event.categoryId
            var agg = bucket[categoryId] ?? CatAgg()
            agg.count += 1
            agg.totalExpense += event.expense

            // 아티스트별: 비용은 "각 아티스트에 동일하게"
            for name in event.artists {
                agg.artistCount[name, default: 0] += 1
                agg.artistExpense[name, default: 0] += event.expense
            }
            bucket[categoryId] = agg
        }

        // 모델 변환 + 정렬
        var results: [CategoryStats] = []
        results.reserveCapacity(bucket.count)

        for (cid, agg) in bucket {
            guard let cat = catById[cid] else { continue }

            let byCount = agg.artistCount
                .sorted { lhs, rhs in
                    if lhs.value == rhs.value { return lhs.key < rhs.key }
                    return lhs.value > rhs.value
                }
                .map { ArtistCountEntry(name: $0.key, count: $0.value) }

            let byExpense = agg.artistExpense
                .sorted { lhs, rhs in
                    if lhs.value == rhs.value { return lhs.key < rhs.key }
                    return lhs.value > rhs.value
                }
                .map { ArtistExpenseEntry(name: $0.key, expense: $0.value) }

            results.append(
                CategoryStats(
                    category: cat,
                    count: agg.count,
                    totalExpense: agg.totalExpense,
                    topArtistsByCount: byCount,
                    topArtistsByExpense: byExpense
                )
            )
        }

        // 상위 정렬: 카운트 desc, 동률이면 지출 desc, 그 다음 이름
        results.sort {
            if $0.count != $1.count { return $0.count > $1.count }
            if $0.totalExpense != $1.totalExpense { return $0.totalExpense > $1.totalExpense }
            return $0.category.name < $1.category.name
        }
        return results
    }

    /// 기간별 아티스트 통계 (하위 상세 포함)
    /// - 반환 배열 - 카운트 내림차순 정렬.
    /// - 내부의 하위 목록 - 각각 카운트/지출 내림차순 정렬.
    func artistStats(for period: StatsPeriod) -> [ArtistStats] {
        let events = filteredEvents(for: period)
        let categories = manager.fetchAllCategories()
        let catById: [UUID: CategoryItem] = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0) })

        // artistName → (count, totalExpense, catCount[catId], catExpense[catId])
        struct ArtAgg {
            var count: Int = 0
            var totalExpense: Double = 0
            var catCount: [UUID: Int] = [:]
            var catExpense: [UUID: Double] = [:]
        }
        var bucket: [String: ArtAgg] = [:]

        for e in events {
            for name in e.artists {
                var agg = bucket[name] ?? ArtAgg()
                agg.count += 1
                agg.totalExpense += e.expense
                agg.catCount[e.categoryId, default: 0] += 1
                agg.catExpense[e.categoryId, default: 0] += e.expense
                bucket[name] = agg
            }
        }

        // 모델 변환 + 정렬
        var results: [ArtistStats] = []
        results.reserveCapacity(bucket.count)

        for (name, agg) in bucket {
            let byCount = agg.catCount
                .sorted { lhs, rhs in
                    if lhs.value == rhs.value {
                        let lName = catById[lhs.key]?.name ?? ""
                        let rName = catById[rhs.key]?.name ?? ""
                        return lName < rName
                    }
                    return lhs.value > rhs.value
                }
                .compactMap { categoryId, count -> CategoryCountEntry? in
                    guard let category = catById[categoryId] else { return nil }
                    return CategoryCountEntry(category: category, count: count)
                }

            let byExpense = agg.catExpense
                .sorted { lhs, rhs in
                    if lhs.value == rhs.value {
                        let lName = catById[lhs.key]?.name ?? ""
                        let rName = catById[rhs.key]?.name ?? ""
                        return lName < rName
                    }
                    return lhs.value > rhs.value
                }
                .compactMap { categoryId, expense -> CategoryExpenseEntry? in
                    guard let category = catById[categoryId] else { return nil }
                    return CategoryExpenseEntry(category: category, expense: expense)
                }

            results.append(
                ArtistStats(
                    name: name,
                    count: agg.count,
                    totalExpense: agg.totalExpense,
                    topCategoriesByCount: byCount,
                    topCategoriesByExpense: byExpense
                )
            )
        }

        // 상위 정렬: 카운트 desc, 동률이면 지출 desc, 그 다음 이름
        results.sort {
            if $0.count != $1.count { return $0.count > $1.count }
            if $0.totalExpense != $1.totalExpense { return $0.totalExpense > $1.totalExpense }
            return $0.name < $1.name
        }
        return results
    }
}

// MARK: - 보조

extension StatisticsService {
    /// 이벤트가 존재하는 연도를 문자열 배열로 반환 ("2025", "2024", ...)
    func activeYears(descending: Bool = true) -> [String] {
        let years = Set(manager.fetchAllEvents().map {
            calendar.component(.year, from: $0.startTime)
        })
        let sorted = descending ? years.sorted(by: >) : years.sorted()
        return sorted.map(String.init)
    }

    /// 해당 연도에 이벤트가 존재하는 월(1~12)을 오름차순으로 반환
    func activeMonths(in year: Int) -> [Int] {
        let events = manager.fetchAllEvents()
        let months = events.compactMap { e -> Int? in
            let comps = calendar.dateComponents([.year, .month], from: e.startTime)
            return comps.year == year ? comps.month : nil
        }
        return Array(Set(months)).sorted() // [1, 3, 9] ...
    }
}

// MARK: - 잔디용 모델 생성

extension StatisticsService {
    /// 전체 데이터로 HeatmapModel 생성 (연도 desc, 12개월)
    func buildHeatmapAll() -> HeatmapModel {
        let calendar = Calendar(identifier: .gregorian)
        let all = manager.fetchAllEvents()
        var month: [Int: [Int: Int]] = [:] // year → [month: count]

        for event in all {
            let y = calendar.component(.year, from: event.startTime)
            let mon = calendar.component(.month, from: event.startTime)
            var ym = month[y] ?? [:]
            ym[mon, default: 0] += 1
            month[y] = ym
        }

        let years = month.keys.sorted(by: >)
        let rows: [HeatmapModel.Row] = years.map { y in
            let counts = (1 ... 12).map { month[y]?[$0] ?? 0 }
            let yearLabel = "`" + String(y % 100) // 디자인 예시처럼 `25
            return .init(yearLabel: yearLabel, monthCounts: counts)
        }
        return .init(rows: rows)
    }
}
