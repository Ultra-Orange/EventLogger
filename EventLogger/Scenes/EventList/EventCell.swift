//
//  EventCell.swift
//  EventLogger
//
//  Created by 김우성 on 8/21/25.
//

import SwiftUI

struct EventCategory {
    let name: String
    let color: Color
}

struct EventCardStyle {
    let cornerRadius: CGFloat = 16
    let innerPadding: CGFloat = 16
    let imageSize: CGFloat = 60
}

struct EventCell: View {
    let title: String
    let image: UIImage?
    let startTime: Date
    let location: String
    let category: EventCategory
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 0) {
                CategoryBadgeView(text: category.name, color: category.color)
                    .padding(.bottom, 8)
                
                VStack {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .padding(.bottom, 12)
                    
                    Spacer(minLength: 0)
                }
                .frame(height: 61)
                
                Text("\(DateFormatter.toDateString(startTime)) ∙ 시작 \(DateFormatter.toTimeString(startTime))")
                    .font(.footnote)
                    .foregroundStyle(.white)
                    .padding(.bottom, 4)
                
                Text(location)
                    .font(.footnote)
                    .foregroundStyle(.white)
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
        .background(Color.black)
        .cornerRadius(16)
        .shadow(color: category.color, radius: 10, x: 0, y: 0)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.50), lineWidth: 1)
        )
    }
}

#Preview {
    EventCell(title: "2025 HAN SEON HWA FANMEETING 〈어트랙티브 선화log〉", image: nil, startTime: DateFormatter.toDate("2025년 8월 23일 19:00")!, location: "잠실종합운동장", category: EventCategory(name: "팬미팅", color: .orange))
        .padding(20)
}
