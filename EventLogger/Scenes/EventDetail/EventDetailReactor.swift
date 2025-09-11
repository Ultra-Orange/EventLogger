//
//  EventDetailReactor.swift
//  EventLogger
//
//  Created by Yoon on 8/21/25.
//

import SwiftData
import Foundation

import Dependencies
import ReactorKit
import RxFlow
import RxRelay
import RxSwift


// 결과를 VC에서 알럿으로 보여주기 위한 단발 이벤트
enum SaveCalendarResult {
    case success
    case denied
    case failure(message: String)
}

final class EventDetailReactor: BaseReactor {
    // 사용자 액션 정의 (사용자의 의도)
    enum Action {
        case moveToEdit(EventItem)
        case deleteEvent(EventItem)
        case addToCalendarTapped
        case queryToGoogleMap(String)
    }
    
    // 상태변경 이벤트 정의 (상태를 어떻게 바꿀 것인가)
    enum Mutation {
        case setEvent(EventItem)
    }
    
    // View의 상태 정의 (현재 View의 상태값)
    struct State {
        var eventItem: EventItem
    }
    
    // 생성자에서 초기 상태 설정
    let initialState: State
    
    // 외부로 노출할 단발 이벤트 스트림
    let saveOutcome = PublishRelay<SaveCalendarResult>()
    
    // DI
    @Dependency(\.calendarService) private var calendarService
    @Dependency(\.notificationService) var notificationService
    @Dependency(\.swiftDataManager) var swiftDataManager

    private let disposeBag = DisposeBag()
    
    init(eventItem: EventItem) {
        initialState = State(eventItem: eventItem)
    }

    // Action이 들어왔을 때 어떤 Mutation으로 바뀔지 정의
    // 사용자 입력 → 상태 변화 신호로 변환
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .moveToEdit(item):
            steps.accept(AppStep.updateSchedule(item))
            return .empty()
        case let .deleteEvent(eventItem):
            swiftDataManager.deleteEvent(id: eventItem.id)
            
            // 캘린더에도 삭제 반영
            calendarService.delete(eventItem: eventItem)
                .subscribe()
                .disposed(by: disposeBag)
            
            // 알림도 취소
            notificationService.cancelNotification(id: eventItem.id.uuidString)
            
            steps.accept(AppStep.eventList)
            return .empty()
        case .addToCalendarTapped:
            // 권한 요청 -> 저장 -> 결과 알림
            let item = currentState.eventItem
            calendarService.requestAccess()
                .flatMap { [calendarService] granted -> Single<String> in
                    if granted {
                        return calendarService.save(eventItem: item)
                    } else {
                        // 접근 거부
                        self.saveOutcome.accept(.denied)
                        return .never() // TODO: 리액터킷에서는 never 안쓰고 empty, 쓸수있게 + 리액터킷에 맞게 리팩토링
                    }
                }
                .subscribe(
                    onSuccess: { [weak self] tag in
                        guard let self else {return}
                        var updated = item
                        updated.calendarEventId = tag
                        self.swiftDataManager.updateEvent(id: updated.id, event: updated)
                        self.saveOutcome.accept(.success)
                    },
                    onFailure: { [weak self] error in
                        guard let self else {return}
                        self.saveOutcome.accept(.failure(message: error.localizedDescription))
                    }
                )
                .disposed(by: disposeBag)
            
            return .just(.setEvent(item))
        case let .queryToGoogleMap(keyword):
            steps.accept(AppStep.queryToGoogleMap(keyword))
            return .empty()
        }
    }
    
    // Mutation이 발생했을 때 상태(State)를 실제로 바꿈
    // 상태 변화 신호 → 실제 상태 반영
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setEvent(item):
            newState.eventItem = item
        }
        return newState
    }
}
