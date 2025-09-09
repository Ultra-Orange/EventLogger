//
//  EventListSnapshotBuilder.swift
//  EventLogger
//
//  Created by 김우성 on 8/25/25.
//

import UIKit

/// 정렬/필터/그룹핑 로직을 순수 함수로. (기존 rebuildSnapshot)
enum EventListSnapshotBuilder {
    struct Input {
        let allItems: [EventItem]
        let sortOrder: EventListSortOrder
        let filter: EventListFilter
        let yearFilter: Int? // nil = 모든 연도
        let calendar: Calendar
        let today: Date
    }
    
    struct Output {
        let itemsByID: [UUID: EventItem]
        let sections: [EventListSection]
        let itemsForSection: [EventListSection: [EventListDSItem]]
        let snapshot: NSDiffableDataSourceSnapshot<EventListSection, EventListDSItem>
    }
    
    static func build(input: Input) -> Output {
        let calendar = input.calendar
        let now = input.today
        
        // 1) 상태 필터 (전체 / 참여예정 / 참여완료)
        let stateFiltered: [EventItem] = {
            switch input.filter {
            case .all:
                input.allItems
            case .upcoming:
                input.allItems.filter { $0.startTime >= now }
            case .completed:
                input.allItems.filter { $0.startTime < now }
            }
        }()
        
        // 2) 연도 필터
        let filtered: [EventItem] = {
            guard let year = input.yearFilter else { return stateFiltered }
            return stateFiltered.filter { calendar.component(.year, from: $0.startTime) == year }
        }()
        
        let itemsByID = Dictionary(uniqueKeysWithValues: filtered.map { ($0.id, $0) })
        
        // 3) 다음 일정: 현재 필터링 결과에서 "가장 가까운 미래 1개" (일반 전체 그룹과 중복 허용)
        let nextUp: EventItem? = filtered
            .filter { $0.startTime >= now }
            .min(by: { $0.startTime < $1.startTime })
        
        // 4) 월 그룹
        let grouped = Dictionary(grouping: filtered, by: { calendar.yearMonth(for: $0.startTime) })
        let monthKeysSorted = (input.sortOrder == .newestFirst)
            ? grouped.keys.sorted().reversed() : grouped.keys.sorted()
        
        // 5) 섹션/아이템
        var sections: [EventListSection] = []
        var itemsForSection: [EventListSection: [EventListDSItem]] = [:]
        
        if let next = nextUp {
            sections.append(.nextUp)
            itemsForSection[.nextUp] = [.nextUp(next.id)]
        }
        
        for key in monthKeysSorted {
            let section: EventListSection = .month(key)
            sections.append(section)
            let monthItems = (grouped[key] ?? []).sorted { a, b in
                input.sortOrder == .newestFirst ? (a.startTime > b.startTime) : (a.startTime < b.startTime)
            }
            itemsForSection[section] = monthItems.map { .monthEvent($0.id) }
        }
        
        // 6) 스냅샷
        var snapshot = NSDiffableDataSourceSnapshot<EventListSection, EventListDSItem>()
        snapshot.appendSections(sections)
        for s in sections {
            snapshot.appendItems(itemsForSection[s] ?? [], toSection: s)
            snapshot.reconfigureItems(itemsForSection[s] ?? [])
        }
        
        return Output(
            itemsByID: itemsByID,
            sections: sections,
            itemsForSection: itemsForSection,
            snapshot: snapshot
        )
    }
}
