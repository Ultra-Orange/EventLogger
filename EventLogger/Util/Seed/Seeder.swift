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
    
    /// 시드 스키마를 바꾸면 이 숫자만 +1 하면 됩니다.
    static let seedVersion = 1
    
    @MainActor
    static func runIfNeeded(modelContext: ModelContext) throws {
        
        // 0) 계정 단위(iCloud KVS)로 이미 시드했다면 종료
        if SeedKVS.version() >= seedVersion {
            return
        }
        
        // 1) DB에 카테고리가 있는지 '1건만' 빠르게 확인
        var fd = FetchDescriptor<CategoryStore>()
        fd.fetchLimit = 1
        let existing = try modelContext.fetch(fd)
        guard existing.isEmpty else {
            // 이미 데이터가 있으면, 계정 플래그만 맞춰두고 종료
            SeedKVS.markSeeded(version: seedVersion)
            return
        }
        
        // 2) 시드 삽입
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
        
        // 3) 계정 단위 완료 플래그 기록
        SeedKVS.markSeeded(version: seedVersion)
    }
}
