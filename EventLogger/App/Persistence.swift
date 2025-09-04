//
//  Persistence.swift
//  EventLogger
//
//  Created by Yoon on 8/20/25.
//

import SwiftData

enum Persistence {
    static let container: ModelContainer = {
        do {
            let models: [any PersistentModel.Type] = [
                CategoryStore.self,
                EventStore.self,
                ArtistStore.self,
            ]
            let schema = Schema(models)
            
            let config = ModelConfiguration(
                "Default",
                cloudKitDatabase: .automatic // CloudKit 자동 동기화
            )
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            let pretty = "\(error) | \(String(reflecting: error))"
              assertionFailure("❌ ModelContainer init failed: \(pretty)")
              fatalError(pretty) // 임시
//            fatalError(error.localizedDescription)
        }
    }()
}
