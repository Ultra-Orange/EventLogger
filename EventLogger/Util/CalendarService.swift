//
//  CalendarService.swift
//  EventLogger
//
//  Created by 김우성 on 8/31/25.
//

import EventKit
import Foundation
import RxSwift

// MARK: 인터페이스

protocol CalendarServicing {
    /// 캘린더 접근 권한 요청 (결정된 상태라면 즉시 리턴)
    func requestAccess() -> Single<Bool>
    /// EventItem을 기본 캘린더에 저장
    func save(eventItem: EventItem) -> Single<String>
}

// MARK: 구현

final class CalendarService: CalendarServicing {
    private let store = EKEventStore()

    // 권한 요청
    func requestAccess() -> Single<Bool> {
        return Single<Bool>.create { single in
            let status = EKEventStore.authorizationStatus(for: .event)
            switch status {
            case .fullAccess:
                // 읽기/쓰기 모두 가능
                single(.success(true))

            case .writeOnly:
                // "쓰기 전용" 권한. 이벤트 저장에는 충분하지만
                // 읽기가 필요한 기능이 있다면 false를 반환하도록 정책 변경 필요
                single(.success(true))

            case .denied, .restricted:
                single(.success(false))

            case .notDetermined:
                Task {
                    do {
                        // 최소권한: 쓰기 권한만 요청
                        let granted = try await self.store.requestWriteOnlyAccessToEvents()
                        single(.success(granted))
                    } catch {
                        single(.failure(error))
                    }
                }

            @unknown default:
                single(.success(false))
            }
            return Disposables.create()
        }
    }

    func save(eventItem: EventItem) -> Single<String> {
        return Single.create { [store] single in
            // 캘린더(기본 캘린더)에 이벤트 생성
            let event = EKEvent(eventStore: store)
            // TODO: identifer 활용한 리팩토링
//            print(event.eventIdentifier)
            event.calendar = store.defaultCalendarForNewEvents

            event.title = eventItem.title
            event.startDate = eventItem.startTime
            event.endDate = eventItem.endTime
            event.location = eventItem.location
            event.notes = eventItem.memo

            // 이미지/아티스트/통화 등은 EventKit에 직접 매핑할 필드가 없으므로 메모에 보조정보를 남기는 식으로
            if !eventItem.artists.isEmpty {
                let artistsLine = "\n\n[출연자] " + eventItem.artists.joined(separator: ", ")
                event.notes = (event.notes ?? "") + artistsLine
            }
            if eventItem.expense > 0 {
                let expenseLine = "\n[비용] \(eventItem.currency.rawValue) \(eventItem.expense)"
                event.notes = (event.notes ?? "") + expenseLine
            }

            do {
                try store.save(event, span: .thisEvent, commit: true)
                single(.success(event.eventIdentifier))
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }
}
