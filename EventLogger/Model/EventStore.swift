//
//  EventStore.swift
//  EventLogger
//
//  Created by Yoon on 8/29/25.
//

import SwiftData
import UIKit

@Model
final class EventStore {
    
    @Attribute(.unique) var id: UUID
    var title: String
    var categoryId: UUID
    var imageData: Data?
    var startTime: Date
    var endTime: Date
    var location: String?
    
    // DB에는 Data로 저장
    @Relationship var artists: [ArtistStore] = []
    
    // 순서 정보
    var artistsOrderData: Data?

    var artistsOrder: [String] {
        get {
            guard let data = artistsOrderData else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            artistsOrderData = try? JSONEncoder().encode(newValue)
        }
    }
    
    var expense: Double
    var currency: String
    var memo: String
    var calendarEventId: String?
    
    init(
        id: UUID = UUID(),
        title: String,
        categoryId: UUID,
        imageData: Data? = nil,
        startTime: Date,
        endTime: Date,
        location: String? = nil,
        artists: [String] = [],
        expense: Double = 0,
        currency: String,
        memo: String,
        calendarEventId: String? = nil
    ) {
        self.id = id
        self.title = title
        self.categoryId = categoryId
        self.imageData = imageData
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.expense = expense
        self.currency = currency
        self.memo = memo
        self.calendarEventId = calendarEventId
    }
    

}

extension EventStore {
    func toDomain() -> EventItem {
        // ✅ 저장된 순서대로 반환
        let orderedNames = artistsOrder.isEmpty ? artists.map { $0.name } : artistsOrder

        return EventItem(
            id: id,
            title: title,
            categoryId: categoryId,
            image: imageData.flatMap { UIImage(data: $0) },
            startTime: startTime,
            endTime: endTime,
            location: location,
            artists: orderedNames,
            expense: expense,
            currency: Currency(rawValue: currency) ?? .KRW,
            memo: memo,
            calendarEventId: calendarEventId
        )
    }
}

