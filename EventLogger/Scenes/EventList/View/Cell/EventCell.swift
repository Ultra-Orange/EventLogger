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
                .padding(.bottom, 14)
                
                VStack {
                    Text(item.title)
                        .font(Font(UIFont.font20Bold))
                        .foregroundStyle(Color(UIColor.neutral50))
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, 12)
                    
                    Spacer(minLength: 0)
                }
                .frame(height: 61)
                
                Text("\(DateFormatter.toDateString(item.startTime)) ∙ 시작 \(DateFormatter.toTimeString(item.startTime))")
                    .font(Font(UIFont.font13Regular))
                    .foregroundStyle(Color(UIColor.neutral50))
                    .padding(.bottom, 4)
                
                if let location = item.location, !location.isEmpty {
                    Text(location)
                        .font(Font(UIFont.font13Regular))
                        .foregroundStyle(Color(UIColor.neutral50))
                }
                
            }
            
            Spacer(minLength: 0)
            
            if let uiImage = item.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .cornerRadius(10)
                    .clipped()
            } else {
                Image("DefaultImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit) // placeholder는 보통 fit
                    .frame(width: 60, height: 60)
                    .foregroundStyle(.gray)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .background(Color.clear)
//        .background(Color(UIColor.primary100).opacity(0.08))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(UIColor.neutral50).opacity(0.40), lineWidth: 1)
        )
    }
}
