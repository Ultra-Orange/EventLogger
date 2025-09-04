//
//  CloudKitStatus.swift
//  EventLogger
//
//  Created by Yoon on 9/4/25.
//

import Foundation

enum SeedKVS {
    private static let key = "seedVersion"   // 버전 올리면 시드 내용 바뀔 때도 재실행 가능

    /// 현재 iCloud KVS의 시드 버전(없으면 0)
    static func version() -> Int {
        let kvs = NSUbiquitousKeyValueStore.default
        kvs.synchronize() // 최신값 당겨오기
        return Int(kvs.longLong(forKey: key))
    }

    /// 시드 완료 표시
    static func markSeeded(version: Int = 1) {
        let kvs = NSUbiquitousKeyValueStore.default
        kvs.set(Int64(version), forKey: key)
        kvs.synchronize()
    }
    
    // 개발단계에서는 KVS키도 지워야함
    #if DEBUG
    static func resetSeedFlags() {
        let kvs = NSUbiquitousKeyValueStore.default
        kvs.removeObject(forKey: SeedKVS.key)
        kvs.synchronize()
    }
    #endif
}
