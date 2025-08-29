//
//  EventStore.swift
//  EventLogger
//
//  Created by Yoon on 8/29/25.
//

import SwiftData
import UIKit

// EventItem에 대응하는 SwiftData 모델
@Model
final class EventStore {
    
    @Attribute(.unique) var id: UUID
    var title: String
    var categoryName: String
    var imageData: Data?
    var startTime: Date
    var endTime: Date
    var location: String?
    var artists: [String]
    var expense: Double
    var currency: String
    var memo: String
    
    init(
        id: UUID = UUID(),
        title: String,
        categoryName: String,
        imageData: Data? = nil,
        startTime: Date,
        endTime: Date,
        location: String? = nil,
        artists: [String] = [],
        expense: Double = 0,
        currency: String,
        memo: String
    ) {
        self.id = id
        self.title = title
        self.categoryName = categoryName
        self.imageData = imageData
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.artists = artists
        self.expense = expense
        self.currency = currency
        self.memo = memo
    }
}

extension EventStore {
    func toDomain() -> EventItem {
        return EventItem(
            id: id,
            title: title,
            categoryName: categoryName,
            image: imageData.flatMap { UIImage(data: $0) },
            startTime: startTime,
            endTime: endTime,
            location: location,
            artists: artists,
            expense: expense,
            currency: Currency(rawValue: currency) ?? .KRW,
            memo: memo
        )
    }
}
