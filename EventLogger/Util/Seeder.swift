//
//  Seeder.swift
//  EventLogger
//
//  Created by Yoon on 8/28/25.
//

import Foundation
import SwiftData

// 앱 최초실행시 카테고리 부여

enum UDKey: String {
    case didSetupDefaultCategories
}

enum CategorySeeder {
    static func runIfNeeded(modelContext: ModelContext) throws {
        let didSetup = UserDefaults.standard.bool(forKey: UDKey.didSetupDefaultCategories.rawValue)

        // UserDefaults에 실행기록이 없으면
        guard !didSetup else { return }

        let names = ["콘서트", "페스티벌", "연극", "뮤지컬", "팬미팅"]

        for (index, name) in names.enumerated() {
            let store = CategoryStore(
                id: UUID(),
                name: name,
                position: index,
                colorId: index // 0~4
            )
            modelContext.insert(store)
        }

        try modelContext.save()

        UserDefaults.standard.set(true, forKey: UDKey.didSetupDefaultCategories.rawValue)
    }
}
