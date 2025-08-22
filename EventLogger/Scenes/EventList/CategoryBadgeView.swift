//
//  CategoryBadgeView.swift
//  EventLogger
//
//  Created by 김우성 on 8/22/25.
//

import SwiftUI

struct CategoryBadgeView: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.white) // 지정 흰색으로 바꿔야 함
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                color
//                LinearGradient(
//                    gradient: Gradient(colors: [color, .clear]),
//                    startPoint: .leading,
//                    endPoint: .trailing
//                )
            )
            .cornerRadius(999)
            .shadow(color: color, radius: 10, x: 0, y: 0)
            .overlay(
                RoundedRectangle(cornerRadius: 999)
                    .stroke(Color.gray.opacity(0.70), lineWidth: 1)
            )
        
    }
}

#Preview {
    HStack(spacing: 16) {
        CategoryBadgeView(text: "팬미팅", color: .green)
        CategoryBadgeView(text: "뮤지컬", color: .purple)
        CategoryBadgeView(text: "연극", color: .yellow)
        CategoryBadgeView(text: "페스티벌", color: .blue)
        CategoryBadgeView(text: "콘서트", color: .pink)
    }
}
