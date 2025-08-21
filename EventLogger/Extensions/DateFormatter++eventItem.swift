//
//  DateFormatter.swift
//  EventLogger
//
//  Created by Yoon on 8/21/25.
//

import Foundation

extension DateFormatter {
    
    // 전체 날짜+시간 포맷터 (캐싱)
    static let eventItemFullFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "yyyy년 MM월 dd일 HH:mm"
        return formatter
    }()
    
    // 날짜만 (yyyy년 MM월 dd일)
    static let eventItemDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter
    }()
    
    // 시간만 (HH:mm)
    static let eventItemTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "HH:mm"
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
    static func toDate(_ string: String) -> Date? {
        return eventItemFullFormatter.date(from: string)
    }
    
}

