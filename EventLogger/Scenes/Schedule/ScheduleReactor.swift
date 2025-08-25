//
//  ScheduleReactor.swift
//  EventLogger
//
//  Created by Yoon on 8/22/25.
//

import ReactorKit
import RxFlow
import RxRelay

final class ScheduleReactor: BaseReactor {
    // 사용자 액션 정의 (사용자의 의도)
    enum Action {}

    // 상태변경 이벤트 정의 (상태를 어떻게 바꿀 것인가)
    enum Mutation {}

    // View의 상태 정의 (현재 View의 상태값)
    struct State {
        let eventItem: EventItem?
        let navTitle: String
        let buttonTitle: String
    }
    
    enum Mode {
        case create
        case update(EventItem)
    }
    
    let initialState: State
    private let mode: Mode
    
    init(mode: Mode) {
        self.mode = mode
        switch mode {
        case .create:
            self.initialState = State(
                eventItem: nil,
                navTitle: "새 일정 등록",
                buttonTitle: "등록하기"
            )
        case let .update(item):
            self.initialState = State(
                eventItem: item,
                navTitle: "일정 수정",
                buttonTitle: "수정하기",
            )
        }
    }
    
    // Action이 들어왔을 때 어떤 Mutation으로 바뀔지 정의
    // 사용자 입력 → 상태 변화 신호로 변환
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {}
    }

    // Mutation이 발생했을 때 상태(State)를 실제로 바꿈
    // 상태 변화 신호 → 실제 상태 반영
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {}
        return newState
    }
}
