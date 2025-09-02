//
//  StatsReactor.swift
//  EventLogger
//
//  Created by 김우성 on 9/2/25.
//

import RxSwift

final class StatsReactor: BaseReactor {
    enum Action {
        
    }

    // 상태변경 이벤트 정의 (상태를 어떻게 바꿀 것인가)
    enum Mutation {
    }

    // View의 상태 정의 (현재 View의 상태값)
    struct State {
    }

    // 생성자에서 초기 상태 설정
    let initialState: State

    init() {
        initialState = State()
    }
    
    // Action이 들어왔을 때 어떤 Mutation으로 바뀔지 정의
    // 사용자 입력 → 상태 변화 신호로 변환
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        
        }
    }

    // Mutation이 발생했을 때 상태(State)를 실제로 바꿈
    // 상태 변화 신호 → 실제 상태 반영
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {}
        return newState
    }
}
