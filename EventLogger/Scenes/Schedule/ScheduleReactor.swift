//
//  ScheduleReactor.swift
//  EventLogger
//
//  Created by Yoon on 8/22/25.
//

import Dependencies
import ReactorKit
import RxFlow
import RxRelay
import Foundation
import RxSwift

final class ScheduleReactor: BaseReactor {
    // 사용자 액션 정의 (사용자의 의도)
    enum Action {
        case selectLocation(String)
        case sendEventPayload(EventPayload)
    }
    
    // 상태변경 이벤트 정의 (상태를 어떻게 바꿀 것인가)
    enum Mutation {
        case setLocation(String)
    }
    
    // View의 상태 정의 (현재 View의 상태값)
    struct State {
        let eventItem: EventItem?
        let navTitle: String
        let buttonTitle: String
        var selectedLocation: String = ""
        var categories: [CategoryItem]
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
    let mode: Mode

    
    @Dependency(\.settingsService) private var settingsService
    @Dependency(\.calendarService) private var calendarService
    
    private let disposeBag = DisposeBag()
    
    init(mode: Mode) {
        @Dependency(\.swiftDataManager) var swiftDataManager
        let categories = swiftDataManager.fetchAllCategories()
        
        self.mode = mode
        initialState = State(
            eventItem: mode.eventItem,
            navTitle: mode.navTitle,
            buttonTitle: mode.buttonTitle,
            categories: categories
        )
    }
    
    // Action이 들어왔을 때 어떤 Mutation으로 바뀔지 정의
    // 사용자 입력 → 상태 변화 신호로 변환
    func mutate(action: Action) -> Observable<Mutation> {
        @Dependency(\.swiftDataManager) var swiftDataManager
        switch action {
        case let .selectLocation(location):
            return .just(.setLocation(location))
        case let .sendEventPayload(payload):
            switch mode {
            case .create:
                let item = EventItem(
                    id: UUID(),  //  새 id 생성
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
                steps.accept(AppStep.eventList)
                return .never()
                
            case let .update(oldItem):
                let updated = EventItem(
                    id: oldItem.id,   // 기존 id 유지
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
                swiftDataManager.updateEvent(id: updated.id, event: updated)
                steps.accept(AppStep.eventList)
                return .never()
            }
        }
    }
    
    // Mutation이 발생했을 때 상태(State)를 실제로 바꿈
    // 상태 변화 신호 → 실제 상태 반영
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setLocation(location):
            newState.selectedLocation = location
        }
        return newState
    }
}

// MARK: - Private helpers

private extension ScheduleReactor {
    func autoSaveToCalendarIfNeeded(_ item: EventItem) {
        guard settingsService.autoSaveToCalendar else { return }

        calendarService.requestAccess()
            .flatMap { [calendarService] granted -> Single<Void> in
                granted ? calendarService.save(eventItem: item) : .never()
            }
            .subscribe() // 저장 잘 됐는지 안됐는지 결과는 무시
            .disposed(by: disposeBag)
    }
}
