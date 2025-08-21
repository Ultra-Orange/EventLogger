//
//  DateFormatter++eventItem.swift
//  EventLogger
//
//  Created by Yoon on 8/21/25.
//

import Foundation

extension DateFormatter {
    // 전체 날짜+시간 포맷터 (캐싱) (예: "2025년 8월 2일 3:05")
    static let eventItemFullFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "yyyy년 M월 d일 H:mm"
        return formatter
    }()

    // 날짜만 (yyyy년 M월 d일) (예: "2025년 8월 2일")
    static let eventItemDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter
    }()

    // 시간만 (H:mm) (예: "3:05")
    static let eventItemTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "H:mm"
        return formatter
    }()

    // MARK: - Date → String

    static func toFullString(_ date: Date) -> String {
        return eventItemFullFormatter.string(from: date)
    }

    static func toDateString(_ date: Date) -> String {
        return eventItemDateFormatter.string(from: date)
    }

    static func toTimeString(_ date: Date) -> String {
        return eventItemTimeFormatter.string(from: date)
    }

    // MARK: - String → Date
    
    // 전체 포맷("yyyy년 M월 d일 H:mm") 문자열만 파싱합니다.
    static func toDate(_ string: String) -> Date? {
        return eventItemFullFormatter.date(from: string)
    }
}
