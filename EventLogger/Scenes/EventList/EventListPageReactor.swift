//
//  EventListPageReactor.swift
//  EventLogger
//
//  Created by 김우성 on 9/15/25.
//

import ReactorKit
import RxSwift
import RxRelay
import RxFlow

final class EventListPageReactor: BaseReactor {
    // 입력
    enum Action {
        case setIndex(Int)
        case tapAdd
        case tapStatistics
        case tapSettings
    }

    // 변이
    enum Mutation {
        case setIndex(Int)
    }

    // 상태
    struct State {
        var selectedIndex: Int = 0
    }

    let initialState = State()

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .setIndex(i):
            return .just(.setIndex(i))

        case .tapAdd:
            steps.accept(AppStep.createSchedule)
            return .empty()

        case .tapStatistics:
            steps.accept(AppStep.statistics)
            return .empty()

        case .tapSettings:
            steps.accept(AppStep.settings)
            return .empty()
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var s = state
        switch mutation {
        case let .setIndex(i):
            s.selectedIndex = i
        }
        return s
    }
}
