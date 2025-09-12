//
//  Dependencies.swift
//  EventLogger
//
//  Created by Yoon on 8/20/25.
//

import Dependencies
import Foundation
import SwiftData

// 실제 사용할 의존성 주입된 변수
extension DependencyValues {
    var swiftDataManager: SwiftDataManager {
        get { self[SwiftDataManagerKey.self] }
        set { self[SwiftDataManagerKey.self] = newValue }
    }

    var calendarService: CalendarServicing {
        get { self[CalendarServiceKey.self] }
        set { self[CalendarServiceKey.self] = newValue }
    }

    var settingsService: SettingsServicing {
        get { self[SettingsServiceKey.self] }
        set { self[SettingsServiceKey.self] = newValue }
    }

    var notificationService: NotificationServicing {
        get { self[NotificationServiceKey.self] }
        set { self[NotificationServiceKey.self] = newValue }
    }
}

// MARK: SwiftData Manager

private enum SwiftDataManagerKey: DependencyKey {
    static var liveValue = SwiftDataManager()
    static var testValue: SwiftDataManager {
        SwiftDataManager()
    }
}

// MARK: Calendar Service

private enum CalendarServiceKey: DependencyKey {
    static var liveValue: CalendarServicing = CalendarService()
    static var testValue: CalendarServicing = CalendarService() // 테스트용 만들 필요
}

// MARK: Settings Service

private enum SettingsServiceKey: DependencyKey {
    static var liveValue: SettingsServicing = SettingsService()
    static var testValue: SettingsServicing = SettingsService() // 테스트용 만들 필요
}

// MARK: Notification Service

private enum NotificationServiceKey: DependencyKey {
    static var liveValue: NotificationServicing = NotificationService()
    static var testValue: NotificationServicing = NotificationService() // 테스트용
}

