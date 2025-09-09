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
    func update(eventItem: EventItem) -> Single<String>
    func delete(eventItem: EventItem) -> Single<Void>
}

// MARK: 구현

final class CalendarService: CalendarServicing {
    private let store = EKEventStore()
    
    @UserSetting(key: UDKey.appCalendarName, defaultValue: "이벤트 로거")
    var appCalendarName: String
    @UserSetting(key: UDKey.appCalendarIdKey, defaultValue: "")
    var appCalendarId: String
    
    // 권한 요청
    func requestAccess() -> Single<Bool> {
        return Single<Bool>.create { single in
            let status = EKEventStore.authorizationStatus(for: .event)
            switch status {
            case .fullAccess:
                // 읽기/쓰기 모두 가능
                single(.success(true))
                
            case .writeOnly:
                single(.success(false))
                
            case .denied, .restricted:
                single(.success(false))
                
            case .notDetermined:
                Task {
                    do {
                        // 모든권한 요처
                        let granted = try await self.store.requestFullAccessToEvents()
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
    
    // iCloud 소스 찾기
    private func findICloudSource() -> EKSource? {
        return store.sources.first {
            $0.sourceType == .calDAV && $0.title.localizedCaseInsensitiveContains("iCloud")
        }
    }
    
    // 이벤트로거 캘린더 보장
    private func ensureAppCalendar() throws -> EKCalendar {
        // 1) 저장된 identifier가 있으면 우선 시도
        if !appCalendarId.isEmpty,
           let cal = store.calendar(withIdentifier: appCalendarId) {
            return cal
        }
        
        // 2) iCloud 소스 필수
        guard let icloud = findICloudSource() else {
            throw NSError(
                domain: "CalendarService",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "iCloud 캘린더를 활성화한 사용자에게만 제공되는 기능이에요. iOS 설정에서 iCloud 캘린더를 활성화해 주세요."]
            )
        }
        
        // 3) 동일 이름의 기존 캘린더가 있으면 사용
        if let existing = store.calendars(for: .event)
            .first(where: { $0.source == icloud && $0.title == appCalendarName }) {
            appCalendarId = existing.calendarIdentifier // UserDefaults에 보관
            return existing
        }
        
        // 4) 새 캘린더 생성
        let newCal = EKCalendar(for: .event, eventStore: store)
        newCal.title = appCalendarName
        newCal.source = icloud
        // newCal.cgColor = UIColor.systemBlue.cgColor // 원하면 색상 지정 가능
        
        try store.saveCalendar(newCal, commit: true)
        appCalendarId = newCal.calendarIdentifier // UserDefaults에 보관
        return newCal
    }
    
    func save(eventItem: EventItem) -> Single<String> {
        return Single.create { [store] single in
            // 1) calendarEventId가 이미 있으면 중복 저장 방지
            if let existingTag = eventItem.calendarEventId,
               let _ = self.findEvent(byTag: existingTag,
                                      near: eventItem.startTime,
                                      endDate: eventItem.endTime) {
                single(.success(existingTag))
                return Disposables.create()
            }
            
            // 캘린더에 새 이벤트 생성
            let event = EKEvent(eventStore: store)
            
            do {
                let calendar = try self.ensureAppCalendar()
                event.calendar = calendar
            } catch {
                single(.failure(error))
                return Disposables.create()
            }
            
            event.title = eventItem.title
            event.startDate = eventItem.startTime
            event.endDate = eventItem.endTime
            event.location = eventItem.location
            
            let tag = self.makeIdentifierTag(for: eventItem)
            event.notes = self.buildNotes(for: eventItem, with: tag)
            
            do {
                try store.save(event, span: .thisEvent, commit: true)
                single(.success(tag))
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    func update(eventItem: EventItem) -> Single<String> {
        return Single.create { single in
            let key = eventItem.calendarEventId ?? ""
            guard let event = self.findEvent(byTag: key,
                                             near: eventItem.startTime,
                                             endDate: eventItem.endTime) else {
                single(.success(key))
                return Disposables.create()
            }
            
            event.title = eventItem.title
            event.startDate = eventItem.startTime
            event.endDate = eventItem.endTime
            event.location = eventItem.location
            
            let tag = self.makeIdentifierTag(for: eventItem)
            event.notes = self.buildNotes(for: eventItem, with: tag)
            
            do {
                try self.store.save(event, span: .thisEvent, commit: true)
                single(.success((tag)))
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    // MARK: Delete
    func delete(eventItem: EventItem) -> Single<Void> {
        return Single.create { single in
            guard let tag = eventItem.calendarEventId,
                  let event = self.findEvent(byTag: tag,
                                             near: eventItem.startTime,
                                             endDate: eventItem.endTime) else {
                single(.success(()))
                return Disposables.create()
            }
            do {
                try self.store.remove(event, span: .thisEvent, commit: true)
                single(.success(()))
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    // 캘린더에서 이벤트 고유식별 태그 생성
    // TODO: 사용자가 지우지 않게끔 유도
    private func makeIdentifierTag(for item: EventItem) -> String {
        // UUID 앞 8자리
        let shortUUID = item.id.uuidString.replacingOccurrences(of: "-", with: "").prefix(8)
        
        // 날짜 (전화번호처럼 안 보이도록 구분자 유지)
        let df = DateFormatter()
        df.dateFormat = "yyMMdd_HHmm"
        let ts = df.string(from: item.startTime)
        
        // 제목 앞 10자 (개행/공백 제거)
//        let title10 = item.title
//            .replacingOccurrences(of: "\n", with: " ")
//            .replacingOccurrences(of: "\r", with: " ")
//            .trimmingCharacters(in: .whitespaces)
//            .prefix(10)
        
        // 두 줄 구성
//        return "EL:\(shortUUID)_\(ts)\n\(title10)"
        return "Event Id:\(shortUUID)_\(ts)"
    }
    
    // 노트 조립 태그
    private func buildNotes(for item: EventItem, with tag: String) -> String {
        var notes = tag
        let memo = (item.memo).trimmingCharacters(in: .whitespacesAndNewlines)
        if !memo.isEmpty { notes += "\n\n" + memo }
        if !item.artists.isEmpty {
            notes += "\n\n[출연자] " + item.artists.joined(separator: ", ")
        }
        if item.expense > 0 {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.maximumFractionDigits = 0  //  소수점 제거
            
            let expenseText = formatter.string(from: NSNumber(value: item.expense))
                ?? "\(item.expense)"  // 포맷 실패 시 fallback
            
            notes += "\n[비용] \(item.currency.rawValue) \(expenseText)"
        }
        return notes
    }
    
    private func findEvent(byTag tag: String, near start: Date, endDate: Date) -> EKEvent? {
        guard let calendar = try? ensureAppCalendar() else { return nil }
        let cal = Calendar.current
        
        // 1) 1차: 새 입력값 근처 (start -1일 ~ start +1일)
        let start1 = cal.date(byAdding: .day, value: -1, to: start) ?? start
        let end1   = cal.date(byAdding: .day, value:  1, to: start) ?? start
        if let hit = findEvent(byTag: tag, in: start1...end1, calendar: calendar) {
            return hit
        }
        
        // 2) 2차: 넓은 fallback (start -180일 ~ start +180일)  // 대범위 보정
        let start2 = cal.date(byAdding: .day, value: -180, to: start) ?? start
        let end2   = cal.date(byAdding: .day, value:  180, to: start) ?? start
        return findEvent(byTag: tag, in: start2...end2, calendar: calendar)
    }
    
    private func findEvent(byTag tag: String, in range: ClosedRange<Date>, calendar: EKCalendar) -> EKEvent? {
        let predicate = store.predicateForEvents(withStart: range.lowerBound, end: range.upperBound, calendars: [calendar])
        let events = store.events(matching: predicate)
        
        // start 동일 우선 → 태그 포함 순으로 매칭
        if let exact = events.first(where: {
            $0.notes?.contains(tag) == true && Calendar.current.isDate($0.startDate, inSameDayAs: range.lowerBound)
        }) {
            return exact
        }
        return events.first(where: { $0.notes?.contains(tag) == true })
    }
}
