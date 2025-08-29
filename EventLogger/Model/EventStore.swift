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
    var artistsData: Data?
    
    var expense: Double
    var currency: String
    var memo: String
    
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
        memo: String
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
        
        self.artistsData = try? JSONEncoder().encode(artists)
    }
    
    //  computed property로 [String] 다루기
    var artists: [String] {
        get {
            guard let data = artistsData else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            artistsData = try? JSONEncoder().encode(newValue)
        }
    }
}

extension EventStore {
    func toDomain() -> EventItem {
        return EventItem(
            id: id,
            title: title,
            categoryId: categoryId,
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
