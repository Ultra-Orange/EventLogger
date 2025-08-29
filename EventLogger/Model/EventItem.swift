//
//  EventItem.swift
//  EventLogger
//
//  Created by Yoon on 8/21/25.
//

import UIKit

struct EventItem: Hashable {
    let id: UUID // 고유 식별자
    var title: String // 제목
    var category: CategoryItem // 카테고리
    var image: UIImage? // 이미지
    var startTime: Date // 개연시간
    var endTime: Date // 종연시간
    var location: String? // 장소
    var artists: [String] // 아티스트
    var expense: Double // TODO: 토털은 원화변환
    var currency: String // TODO: MVP까지는 KRW단일
    var memo: String // 메모

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: EventItem, rhs: EventItem) -> Bool {
        return lhs.id == rhs.id
    }
}
