//
//  Dependencies.swift
//  EventLogger
//
//  Created by Yoon on 8/20/25.
//

import Dependencies
import Foundation
import SwiftData

// 실제 사용할 의존성 주입된 변수
extension DependencyValues {
    var modelContext: ModelContext {
        get { self[ModelContextKey.self] }
        set { self[ModelContextKey.self] = newValue }
    }

    var eventItems: [EventItem] {
        get { self[eventItemsKey.self] }
        set { self[eventItemsKey.self] = newValue }
    }

    var swiftDataManager: SwiftDataManager {
        get { self[SwiftDataManagerKey.self] }
        set { self[SwiftDataManagerKey.self] = newValue }
    }
}

// MARK: ModelContext

private enum ModelContextKey: DependencyKey {
    static var liveValue: ModelContext {
        ModelContext(Persistence.container)
    }

    static var testValue: ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let schema = Schema([CategoryStore.self])
        let container = try! ModelContainer(for: schema, configurations: config)
        return ModelContext(container)
    }
}

// MARK: SwiftData Manager

private enum SwiftDataManagerKey: DependencyKey {
    static var liveValue = SwiftDataManager()
    static var testValue: SwiftDataManager {
        SwiftDataManager()
    }
}

extension ModelContext: @unchecked @retroactive Sendable {}

// MARK: EventItem

private enum eventItemsKey: DependencyKey {
    static var liveValue = [
        EventItem(
            id: UUID(),
            title: "YOASOBI ZEPP TOUR 2024 POP OUT 東京公演 2日目",
            category: CategoryItem(
                name: "콘서트",
                position: 0,
                colorId: 0
            ),
            startTime: DateFormatter.toDate("2024년 01월 26일 19:00") ?? Date.now,
            endTime: DateFormatter.toDate("2024년 01월 26일 21:00") ?? Date.now,
            location: "Zepp Haneda TOKYO",
            artists:
            ["YOASOBI"],
            expense: 75000,
            currency: Currency.KRW.rawValue,
            memo:
            """
            [YOASOBI ZEPP TOUR 2024 "POP OUT"]
            1月25日（木）東京 Zepp Haneda(TOKYO)
            1月26日（金）東京 Zepp Haneda(TOKYO)
            2月1日（木）北海道 Zepp Sapporo
            2月2日（金）北海道 Zepp Sapporo
            2月8日（木）神奈川 KT Zepp Yokohama
            2月9日（金）神奈川 KT Zepp Yokohama
            2月15日（木）福岡 Zepp Fukuoka
            2月16日（金）福岡 Zepp Fukuoka
            2月22日（木）大阪 Zepp Osaka Bayside
            2月23日（金・祝）大阪 Zepp Osaka Bayside
            3月8日（金）愛知 Zepp Nagoya
            3月9日（土）愛知 Zepp Nagoya
            """
        ),
        EventItem(
            id: UUID(),
            title: "THE IDOLM@STER CINDERELLA GIRLS UNIT LIVE TOUR ConnecTrip! @TOKYO",
            category: CategoryItem(
                name: "콘서트",
                position: 0,
                colorId: 0
            ),
            startTime: DateFormatter.toDate("2024년 06월 1일 14:00") ?? Date.now,
            endTime: DateFormatter.toDate("2024년 6월 1일 16:00") ?? Date.now,
            artists:
            ["アイドルマスターシンデレラガールズ", "原紗友里", "赤﨑千夏", "金子有希", "M・A・O(市道真央)", "森下来奈", "梅澤めぐ", "富田美憂", "星希成奏"],
            expense: 90000,
            currency: Currency.KRW.rawValue,
            memo:
            """
            開催場所
            東京都 Zepp DiverCity Tokyo
            ASOBI STAGE（ASOBI STORE）
            """
        ),
        EventItem(
            id: UUID(),
            title: "(X) 2025 HAN SEON HWA FANMEETING 〈어트랙티브 선화log〉",
            category: CategoryItem(
                name: "팬미팅",
                position: 1,
                colorId: 1
            ),
            startTime: DateFormatter.toDate("2025년 09월 20일 14:00") ?? Date.now,
            endTime: DateFormatter.toDate("2025년 09월 20일 15:30") ?? Date.now,
            artists:
            ["한선화"],
            expense: 88000,
            currency: Currency.KRW.rawValue,
            memo:
            """
            ■ 변경 일정
            2025년 9월 21일(일) 오후 2시 / 오후 6시

            ■ 변경 장소
            H-stage (서울시 마포구 와우산로 97)

            ■ 예매 취소 및 선예매 혜택 안내
            - 기존 예매 건은 전액 환불되며, 예스24 티켓을 통해 순차적으로 개별 안내드릴 예정입니다.
            - 기존 예매자 분들께는 선예매 혜택이 제공되며, 하기 안내된 일정 내에 동일 아이디로 접속해야 선예매가 가능합니다.

            ■ 티켓 재오픈 일정
            - 선예매(기존 예매자 한정): 2025년 8월 21일(목) 오후 8시 ~ 2025년 8월 24일(일) 오후 11시 59분(KST)

            - 일반 예매: 2025년 8월 25일(월) 오후 8시(KST)
            """
        ),
        EventItem(
            id: UUID(),
            title: "2025 부산국제록페스티벌 1일차",
            category: CategoryItem(
                name: "페스티벌",
                position: 2,
                colorId: 2
            ),

            startTime: DateFormatter.toDate("2025년 09월 26일 12:00") ?? Date.now,
            endTime: DateFormatter.toDate("2025년 09월 26일 22:00") ?? Date.now,
            location: "광안리 해수욕장",
            artists:
            ["SUEDETHE", "SMASHING", "PUMPKINSBABYMETALMIKAPORTER", "ROBINSON", "자우림", "국카스텐"],
            expense: 110_000,
            currency: Currency.KRW.rawValue,
            memo:
            """
            ※ 티켓 예매 시 본 예매페이지에 기재된 안내사항에 동의한 것으로 간주하며,

            입장 · 관람 등 행사 안내 수칙 미숙지로 인해 발생하는 피해에 대한 책임은 관람자 본인에게 있습니다.
            공연 관람에 지장이나 불이익을 받지 않도록 사전에 반드시 안내사항을 확인하시기 바랍니다.

            ＊본 행사는 일자별 출연 아티스트가 상이하며, 추가 라인업 및 타임테이블이 순차적으로 공개됩니다.
            입장 절차, 부스 운영시간 등 행사장 이용과 관련된 내용은 추후 공지되며, 안내사항은 사정에 따라 추가되거나 변경될 수 있습니다.

            ※ 상기 공지사항에 관한 자세한 내용은 예매처 상세페이지와 부산국제록페스티벌 공식 홈페이지 및 SNS를 통해 업데이트될 예정이오니,

            지속적으로 내용을 확인해 주시기 바랍니다.
            """
        ),
    ]
}

// 사용법
// struct MyCounter {
//    var getValue: () -> Int
// }
//
// private enum CounterKey: DependencyKey {
//    // 실제 서비스 (SwiftData에서 가져오기)
//    static let liveValue: MyCounter = .init {
//        let context = ModelContext(Persistence.container)
//        let items = try! context.fetch(FetchDescriptor<Counter>())
//        return items.first?.value ?? 0
//    }
//    // 테스트 / 디버그 환경에서만 사용할 값
//    static let testValue: MyCounter = .init {
//        return 100
//    }
//    // 프리뷰에서 보여줄 값
//    static let previewValue: MyCounter = .init {
//        return 42
//    }
// }
//
// extension DependencyValues {
//    var myCounter: MyCounter {
//        get { self[CounterKey.self] }
//        set { self[CounterKey.self] = newValue }
//    }
// }
