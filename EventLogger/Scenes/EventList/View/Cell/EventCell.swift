//
//  EventCell.swift
//  EventLogger
//
//  Created by 김우성 on 8/21/25.
//

import SwiftUI
import Dependencies

struct EventCategory {
    let name: String
    let color: Color
}

struct EventCell: View { // EventItem 통으로 받자
    let item: EventItem
    let category: CategoryItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 0) {
                
                CategoryBadgeView(
                    name: category.name,
                    color: Color(uiColor: category.color)
                )
                .padding(.bottom, 8)
                
                VStack {
                    Text(item.title)
                        .font(Font(UIFont.font20Bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, 12)
                    
                    Spacer(minLength: 0)
                }
                .frame(height: 61)
                
                Text("\(DateFormatter.toDateString(item.startTime)) ∙ 시작 \(DateFormatter.toTimeString(item.startTime))")
                    .font(Font(UIFont.font13Regular))
                    .foregroundStyle(.white)
                    .padding(.bottom, 4)
                
                if let location = item.location, !location.isEmpty {
                    Text(location)
                        .font(Font(UIFont.font13Regular))
                        .foregroundStyle(.white)
                }
                
            }
            
            Spacer(minLength: 0)
            
            Rectangle()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 80, height: 80)
                .background {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                .cornerRadius(10)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .background(Color.clear)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.40), lineWidth: 1)
        )
    }
}
