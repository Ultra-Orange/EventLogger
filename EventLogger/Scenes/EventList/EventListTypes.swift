//
//  EventListTypes.swift
//  EventLogger
//
//  Created by 김우성 on 8/25/25.
//

import Foundation

/// EventList에 사용되는 공통 타입과 유틸
public enum SortOrder: Equatable {
    case newestFirst
    case oldestFirst
    
    mutating func toggle() {
        self = (self == .newestFirst) ? .oldestFirst : .newestFirst
    }
}

public enum EventFilter: Equatable {
    case all        // 전체
    case upcoming   // 참여예정
    case completed  // 참여완료
}

// oooo년 oo월 섹션 정렬용
public struct YearMonth: Hashable, Comparable {
    public let year: Int
    public let month: Int
    
    public static func < (lhs: YearMonth, rhs: YearMonth) -> Bool {
        if lhs.year != rhs.year { return lhs.year < rhs.year }
        return lhs.month < rhs.month
    }
}

public enum EventListSection: Hashable {
    case nextUp             // '다음 일정' 섹션
    case month(YearMonth)   // 전체 섹션
}

// Diffable에서 동일 아이템을 섹션별로 중복 추가하기 위한 래퍼
public enum EventListDSItem: Hashable {
    case nextUp(UUID)
    case monthEvent(UUID)
}

public extension Calendar {
    func yearMonth(for date: Date) -> YearMonth {
        let components = dateComponents([.year, .month], from: date)
        return YearMonth(year: components.year ?? 0, month: components.month ?? 0)
    }
}
