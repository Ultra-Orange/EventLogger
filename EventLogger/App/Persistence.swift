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
                // 컨테이너에 올릴 스위프트 데이터 모델 추가
            ]
            let schema = Schema(models)
            return try ModelContainer(for: schema)
        } catch {
            fatalError(error.localizedDescription)
        }
    }()
}
