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
    var modelContext: ModelContext {
        get { self[ModelContextKey.self] }
        set { self[ModelContextKey.self] = newValue }
    }

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
}

// MARK: ModelContext

private enum ModelContextKey: DependencyKey {
    static var liveValue: ModelContext {
        ModelContext(Persistence.container)
    }

    static var testValue: ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let schema = Schema([CategoryStore.self, EventStore.self])
        let container = try! ModelContainer(for: schema, configurations: config)
        return ModelContext(container)
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

extension ModelContext: @unchecked @retroactive Sendable {}



// 사용법
// struct MyCounter {
//    var getValue: () -> Int
// }
//
// private enum CounterKey: DependencyKey {
//    // 실제 서비스 (SwiftData에서 가져오기)
//    static let liveValue: MyCounter = .init {
//        let context = ModelContext(Persistence.container)
//        let items = try! context.fetch(FetchDescriptor<Counter>())
//        return items.first?.value ?? 0
//    }
//    // 테스트 / 디버그 환경에서만 사용할 값
//    static let testValue: MyCounter = .init {
//        return 100
//    }
//    // 프리뷰에서 보여줄 값
//    static let previewValue: MyCounter = .init {
//        return 42
//    }
// }
//
// extension DependencyValues {
//    var myCounter: MyCounter {
//        get { self[CounterKey.self] }
//        set { self[CounterKey.self] = newValue }
//    }
// }
