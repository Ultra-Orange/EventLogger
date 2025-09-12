//
//  ArtistStore.swift
//  EventLogger
//
//  Created by Yoon on 8/30/25.
//

import Foundation
import SwiftData

@Model
final class ArtistStore {
    var name: String = ""
    var id: UUID = UUID()

    // 역관계: 이 아티스트가 참여한 이벤트들
    @Relationship(inverse: \EventStore.artists)
    var events: [EventStore]? = []

    init(name: String) {
        self.name = name
    }
}
