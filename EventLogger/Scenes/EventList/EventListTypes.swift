//
//  EventListTypes.swift
//  EventLogger
//
//  Created by 김우성 on 8/25/25.
//

import Foundation

/// EventList에 사용되는 공통 타입과 유틸
enum EventListSortOrder: Equatable {
    case newestFirst
    case oldestFirst

    mutating func toggle() {
        self = (self == .newestFirst) ? .oldestFirst : .newestFirst
    }
}

enum EventListFilter: Equatable {
    case all // 전체
    case upcoming // 참여예정
    case completed // 참여완료
}

// oooo년 oo월 섹션 정렬용
struct EventListYearMonth: Hashable, Comparable {
    let year: Int
    let month: Int

    static func < (lhs: EventListYearMonth, rhs: EventListYearMonth) -> Bool {
        if lhs.year != rhs.year { return lhs.year < rhs.year }
        return lhs.month < rhs.month
    }
}

enum EventListSection: Hashable {
    case nextUp // '다음 일정' 섹션
    case month(EventListYearMonth) // 전체 섹션
}

// Diffable에서 동일 아이템을 섹션별로 중복 추가하기 위한 래퍼
enum EventListDSItem: Hashable {
    case nextUp(UUID)
    case monthEvent(UUID)
}

extension Calendar {
    func yearMonth(for date: Date) -> EventListYearMonth {
        let components = dateComponents([.year, .month], from: date)
        return EventListYearMonth(year: components.year ?? 0, month: components.month ?? 0)
    }
}
