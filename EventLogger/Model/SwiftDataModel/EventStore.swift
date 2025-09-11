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
    
    var id: UUID = UUID()
    var title: String = ""
    var categoryId: UUID? = nil
    var imageData: Data?
    var startTime: Date = Date.now
    var endTime: Date = Date.now
    var location: String?
    
    // DB에는 Data로 저장
    @Relationship var artists: [ArtistStore]? = []
    
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
    
    var expense: Double = 0.0
    var currency: String = "KRW"
    var memo: String = ""
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
     
    func toDomain() ->  EventItem {
        // 저장된 된 순서대로 반환
        // 1) 관계가 옵셔널이므로 안전하게 꺼냅니다.
        let storeArtists: [ArtistStore] = artists ?? []
        // 2) 관계에서 가져온 이름들
        let fetchedNames: [String] = storeArtists.map(\.name)
        // 3) 순서 보존: artistsOrder(예: [String])가 있으면 그 순서로 정리,
               //  없으면 관계의 순서를 사용합니다.
               let orderedNames: [String] = {
                   let order = artistsOrder         
                   guard !order.isEmpty else { return fetchedNames }
                   let nameSet = Set(fetchedNames)         // 삭제/누락 대비 교집합만 유지
                   return order.filter { nameSet.contains($0) }
               }()
        
       
        return EventItem(
            id: id,
            title: title,
            categoryId: categoryId ?? UUID(),
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

