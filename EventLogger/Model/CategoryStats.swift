//
//  CategoryStats.swift
//  EventLogger
//
//  Created by Yoon on 9/1/25.
//

import Foundation

// 카테고리 통계용 서브 엔트리
struct ArtistCountEntry: Hashable {
    let name: String
    let count: Int
}

struct ArtistExpenseEntry: Hashable {
    let name: String
    let expense: Double
}

// 카테고리 통계용 모델 (상위 + 하위 포함)
struct CategoryStats: Hashable {
    let category: CategoryItem

    // 상위(총합) — 기존 코드 호환용
    let count: Int                // 카테고리 내 이벤트 수
    let totalExpense: Double      // 총 비용

    // 하위(정렬된 목록)
    /// 아티스트별 참여 횟수(내림차순)
    let topArtistsByCount: [ArtistCountEntry]
    /// 아티스트별 지출 합계(내림차순)
    let topArtistsByExpense: [ArtistExpenseEntry]
}
