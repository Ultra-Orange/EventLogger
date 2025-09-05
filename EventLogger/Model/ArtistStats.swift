//
//  ArtistStats.swift
//  EventLogger
//
//  Created by Yoon on 8/31/25.
//

import Foundation

// 아티스트 통계용 서브 엔트리
struct CategoryCountEntry: Hashable {
    let category: CategoryItem
    let count: Int
}

struct CategoryExpenseEntry: Hashable {
    let category: CategoryItem
    let expense: Double
}

// 아티스트 통계용 모델 (상위 + 하위 포함)
struct ArtistStats: Hashable {
    let name: String

    // 상위(총합) — 기존 코드 호환용
    let count: Int                // 참가 횟수(이벤트 수)
    let totalExpense: Double      // 총 비용

    // 하위(정렬된 목록)
    /// 카테고리별 참여 횟수(내림차순)
    let topCategoriesByCount: [CategoryCountEntry]
    /// 카테고리별 지출 합계(내림차순)
    let topCategoriesByExpense: [CategoryExpenseEntry]
}
