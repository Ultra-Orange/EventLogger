//
//  CategoryBadgeView.swift
//  EventLogger
//
//  Created by 김우성 on 8/22/25.
//

import SwiftUI

struct CategoryBadgeView: View {
    let category: Category
    
    var body: some View {
        Text(category.name)
            .font(.caption)
            .fontWeight(.medium)
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
            .shadow(color: Color(category.color), radius: 10, x: 0, y: 0)
            .overlay(
                RoundedRectangle(cornerRadius: 999)
                    .stroke(Color.gray.opacity(0.70), lineWidth: 1)
            )
        
    }
}

#Preview {
    HStack(spacing: 16) {
        CategoryBadgeView(category: Category(id: UUID.init(), name: "팬미팅", position: 0, color: .green))
        CategoryBadgeView(category: Category(id: UUID.init(), name: "뮤지컬", position: 1, color: .purple))
        CategoryBadgeView(category: Category(id: UUID.init(), name: "연극", position: 2, color: .yellow))
        CategoryBadgeView(category: Category(id: UUID.init(), name: "페스티벌", position: 3, color: .blue))
        CategoryBadgeView(category: Category(id: UUID.init(), name: "콘서트", position: 4, color: .cyan))
    }
}
