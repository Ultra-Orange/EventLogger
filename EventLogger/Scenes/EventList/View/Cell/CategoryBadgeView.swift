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
            .foregroundStyle(Color(UIColor.neutral50))
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.gray.opacity(0.70), lineWidth: 1)
            )
    }
}
