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
    @Dependency(\.swiftDataManager) private var swiftDataManager
    
    @State private var categoryColor: Color = .gray
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 0) {
                CategoryBadgeView(
                    name: item.categoryName,
                    color: swiftDataManager.colorForCategoryName(item.categoryName)
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
                
                // 여기 로케이션 나중에 넣어줘야 됨
//                Text(location)
//                    .font(.footnote)
//                    .foregroundStyle(.white)
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
        .shadow(color: categoryColor, radius: 10, x: 0, y: 0) // 여기 나중에 수정
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.50), lineWidth: 1)
        )
        .task {
            categoryColor = swiftDataManager.colorForCategoryName(item.categoryName)
        }
    }
}

//#Preview {
//    EventCell(
//        item: EventItem(
//            id: UUID(),
//            title: "YOASOBI ZEPP TOUR 2024 POP OUT 東京公演 2日目",
//            categoryName: CategoryItem(
//                name: "콘서트"
//            ),
//            startTime: DateFormatter.toDate("2024년 01월 26일 19:00") ?? Date.now,
//            endTime: DateFormatter.toDate("2024년 01월 26일 21:00") ?? Date.now,
//            artists:
//            ["YOASOBI"],
//            expense: 75000,
//            currency: Currency.KRW.rawValue,
//            memo:
//            """
//            [YOASOBI ZEPP TOUR 2024 "POP OUT"]
//            1月25日（木）東京 Zepp Haneda(TOKYO)
//            1月26日（金）東京 Zepp Haneda(TOKYO)
//            2月1日（木）北海道 Zepp Sapporo
//            2月2日（金）北海道 Zepp Sapporo
//            2月8日（木）神奈川 KT Zepp Yokohama
//            2月9日（金）神奈川 KT Zepp Yokohama
//            2月15日（木）福岡 Zepp Fukuoka
//            2月16日（金）福岡 Zepp Fukuoka
//            2月22日（木）大阪 Zepp Osaka Bayside
//            2月23日（金・祝）大阪 Zepp Osaka Bayside
//            3月8日（金）愛知 Zepp Nagoya
//            3月9日（土）愛知 Zepp Nagoya
//            """
//        )
//    )
//    .padding(20)
//}
