//
//  CategoryBadgeView.swift
//  EventLogger
//
//  Created by 김우성 on 8/22/25.
//

import SwiftUI

struct CategoryBadgeView: View {
    let name: String
    let color: Color

    var body: some View {
        Text(name)
            .font(Font(UIFont.font12Medium))
            .foregroundStyle(.white) // 지정 흰색으로 바꿔야 함
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .clipShape(Capsule())
            .shadow(color: color, radius: 10, x: 0, y: 0)
            .overlay(
                Capsule()
                    .stroke(Color.gray.opacity(0.70), lineWidth: 1)
            )
    }
}
