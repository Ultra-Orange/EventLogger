//
//  Seeder.swift
//  EventLogger
//
//  Created by Yoon on 8/28/25.
//

import Foundation
import SwiftData
import UIKit

// 앱 최초실행시 카테고리 부여

enum CategorySeeder {
    
    static func runIfNeeded(modelContext: ModelContext) throws {
        
        let names = ["콘서트", "페스티벌", "연극", "뮤지컬", "팬미팅"]
        
        for (index, name) in names.enumerated() {
            let store = CategoryStore(
                id: UUID(),
                name: name,
                position: index,
                colorId: {
                    switch name {
                    case "콘서트": 2
                    case "페스티벌": 7
                    case "연극": 9
                    case "뮤지컬": 4
                    case "팬미팅": 5
                    default: 11
                    }
                }()
            )
            modelContext.insert(store)
        }
        
        try modelContext.save()
        
        @UserSetting(key: UDKey.didSetupDefaultCategories, defaultValue: false)
        var didSetupDefaultCategories: Bool
        didSetupDefaultCategories = true
    }
}
