//
//  CategoryBadgeView.swift
//  EventLogger
//
//  Created by 김우성 on 8/22/25.
//

import SwiftUI

struct CategoryBadgeView: View {
    let category: CategoryItem

    var body: some View {
        Text(category.name)
            .font(Font(UIFont.font12Medium))
            .foregroundStyle(.white) // 지정 흰색으로 바꿔야 함
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Color(category.color)
//                LinearGradient(
//                    gradient: Gradient(colors: [color, .clear]),
//                    startPoint: .leading,
//                    endPoint: .trailing
//                )
            )
            .cornerRadius(999)
            .shadow(color: Color( category.color), radius: 10, x: 0, y: 0)
            .overlay(
                RoundedRectangle(cornerRadius: 999)
                    .stroke(Color.gray.opacity(0.70), lineWidth: 1)
            )
    }
}

//#Preview {
//    HStack(spacing: 16) {
//        CategoryBadgeView(category: Category(id: UUID(), name: "팬미팅", position: 0, colorId: .green))
//        CategoryBadgeView(category: Category(id: UUID(), name: "뮤지컬", position: 1, colorId: .purple))
//        CategoryBadgeView(category: Category(id: UUID(), name: "연극", position: 2, colorId: .yellow))
//        CategoryBadgeView(category: Category(id: UUID(), name: "페스티벌", position: 3, colorId: .blue))
//        CategoryBadgeView(category: Category(id: UUID(), name: "콘서트", position: 4, colorId: .cyan))
//    }
//}
