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
            ]
            let schema = Schema(models)
            return try ModelContainer(for: schema)
        } catch {
            fatalError(error.localizedDescription)
        }
    }()
}
