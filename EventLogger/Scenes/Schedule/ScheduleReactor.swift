//
//  ScheduleReactor.swift
//  EventLogger
//
//  Created by Yoon on 8/22/25.
//

import Dependencies
import Foundation
import ReactorKit
import RxFlow
import RxRelay
import RxSwift

final class ScheduleReactor: BaseReactor {
    // 사용자 액션 정의 (사용자의 의도)
    enum Action {
        case reloadCategories
        case selectLocation(String)
        case sendEventPayload(EventPayload)
        case newCategory
    }

    // 상태변경 이벤트 정의 (상태를 어떻게 바꿀 것인가)
    enum Mutation {
        case setLocation(String)
        case setCategories([CategoryItem])
    }

    // View의 상태 정의 (현재 View의 상태값)
    struct State {
        let eventItem: EventItem?
        let navTitle: String
        let buttonTitle: String
        var selectedLocation: String
        var categories: [CategoryItem]
        let mode: Mode
    }

    enum Mode {
        case create
        case update(EventItem)

        var navTitle: String {
            switch self {
            case .create: return "새 일정 등록"
            case .update: return "일정 수정"
            }
        }

        var buttonTitle: String {
            switch self {
            case .create: return "등록하기"
            case .update: return "수정하기"
            }
        }

        var eventItem: EventItem? {
            switch self {
            case .create: return nil
            case let .update(item): return item
            }
        }
    }

    let initialState: State

    @Dependency(\.settingsService) private var settingsService
    @Dependency(\.calendarService) private var calendarService
    @Dependency(\.notificationService) private var notificationService

    private let disposeBag = DisposeBag()

    init(mode: Mode) {
        @Dependency(\.swiftDataManager) var swiftDataManager
        let categories = swiftDataManager.fetchAllCategories()

        initialState = State(
            eventItem: mode.eventItem,
            navTitle: mode.navTitle,
            buttonTitle: mode.buttonTitle,
            selectedLocation: mode.eventItem?.location ?? "",
            categories: categories,
            mode: mode
        )
    }

    // Action이 들어왔을 때 어떤 Mutation으로 바뀔지 정의
    // 사용자 입력 → 상태 변화 신호로 변환
    func mutate(action: Action) -> Observable<Mutation> {
        @Dependency(\.swiftDataManager) var swiftDataManager
        switch action {
        case .reloadCategories:
            let categories = swiftDataManager.fetchAllCategories()
            return .just(.setCategories(categories))
        case let .selectLocation(location):
            return .just(.setLocation(location))
        case let .sendEventPayload(payload):
            switch currentState.mode {
            case .create:
                let item = EventItem(
                    id: UUID(), //  새 id 생성
                    title: payload.title,
                    categoryId: payload.categoryId,
                    image: payload.image,
                    startTime: payload.startTime,
                    endTime: payload.endTime,
                    location: payload.location,
                    artists: payload.artists,
                    expense: payload.expense,
                    currency: payload.currency,
                    memo: payload.memo
                )
                swiftDataManager.insertEventItem(item)
                autoSaveToCalendarIfNeeded(item)
                schedulePushNotificationIfNeeded(item)
                steps.accept(AppStep.eventList)
                return .empty()

            case let .update(oldItem):
                let updated = EventItem(
                    id: oldItem.id, // 기존 id 유지
                    title: payload.title,
                    categoryId: payload.categoryId,
                    image: payload.image,
                    startTime: payload.startTime,
                    endTime: payload.endTime,
                    location: payload.location,
                    artists: payload.artists,
                    expense: payload.expense,
                    currency: payload.currency,
                    memo: payload.memo,
                    calendarEventId: oldItem.calendarEventId // 캘린더이벤트 id는 유지
                )
                swiftDataManager.updateEvent(id: updated.id, event: updated)

                if settingsService.autoSaveToCalendar {
                    if updated.calendarEventId == nil {
                        // 🔧 변경: 캘린더 이벤트가 없으면 새로 추가
                        calendarService.save(eventItem: updated)
                            .subscribe(onSuccess: { tag in
                                @Dependency(\.swiftDataManager) var swiftDataManager
                                var refreshed = updated
                                refreshed.calendarEventId = tag
                                swiftDataManager.updateEvent(id: refreshed.id, event: refreshed)
                            })
                            .disposed(by: disposeBag)
                    } else {
                        // 기존 이벤트가 있으면 업데이트
                        calendarService.update(eventItem: updated)
                            .subscribe(onSuccess: { tag in
                                @Dependency(\.swiftDataManager) var swiftDataManager
                                var refreshed = updated
                                refreshed.calendarEventId = tag
                                swiftDataManager.updateEvent(id: refreshed.id, event: refreshed)
                            })
                            .disposed(by: disposeBag)
                    }
                }

                schedulePushNotificationIfNeeded(updated)
                steps.accept(AppStep.eventList)
                return .empty()
            }
        case .newCategory:
            steps.accept(AppStep.createCategory)
            return .empty()
        }
    }

    // Mutation이 발생했을 때 상태(State)를 실제로 바꿈
    // 상태 변화 신호 → 실제 상태 반영
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setLocation(location):
            newState.selectedLocation = location

        case let .setCategories(categories):
            newState.categories = categories
        }
        return newState
    }
}

// MARK: - Private helpers

private extension ScheduleReactor {
    func autoSaveToCalendarIfNeeded(_ item: EventItem) {
        guard settingsService.autoSaveToCalendar else { return }

        calendarService.requestAccess()
            .flatMap { [calendarService] granted -> Single<String> in
                granted ? calendarService.save(eventItem: item) : .never()
            }
            .subscribe(onSuccess: { tag in
                @Dependency(\.swiftDataManager) var swiftDataManager
                var updated = item
                updated.calendarEventId = tag
                swiftDataManager.updateEvent(id: updated.id, event: updated)
            })
            .disposed(by: disposeBag)
    }

    func schedulePushNotificationIfNeeded(_ item: EventItem) {
        // 스위치 off -> 알림 없음
        guard settingsService.pushNotificationEnabled else { return }
        // 기존 예약 삭제
        notificationService.cancelNotification(id: item.id.uuidString)

        notificationService.scheduleNotification(
            id: item.id.uuidString,
            title: "\(item.title)+✨",
            body: "내일은 기다리고 기다리던 이벤트 D-DAY 🎉",
            date: item.startTime
        )
    }
}
