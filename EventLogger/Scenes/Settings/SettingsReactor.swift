//
//  SettingsReactor.swift
//  EventLogger
//
//  Created by Yoon on 8/31/25.
//

import SwiftData

import Dependencies
import ReactorKit
import RxFlow
import RxRelay
import RxSwift

final class SettingsReactor: BaseReactor {
    // 사용자 액션 정의 (사용자의 의도)
    enum Action {
        case tapCategoryControl
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
        case .tapCategoryControl:
            steps.accept(AppStep.categoryEdit)
            return .empty()
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
