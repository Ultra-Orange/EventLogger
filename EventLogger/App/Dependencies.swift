//
//  Dependencies.swift
//  EventLogger
//
//  Created by Yoon on 8/20/25.
//

import Dependencies
import SwiftData

private enum ModelContextKey: DependencyKey {
    static var liveValue: ModelContext {
        ModelContext(Persistence.container)
    }
}

extension DependencyValues {
    var modelContext: ModelContext {
        get { self[ModelContextKey.self] }
        set { self[ModelContextKey.self] = newValue }
    }
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
