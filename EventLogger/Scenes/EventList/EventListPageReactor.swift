//
//  EventListPageReactor.swift
//  EventLogger
//
//  Created by 김우성 on 9/15/25.
//

import ReactorKit
import RxFlow
import RxRelay
import RxSwift

final class EventListPageReactor: BaseReactor {
    enum Action {
        case setIndex(Int)
        case tapAdd
        case tapStatistics
        case tapSettings
    }

    enum Mutation {
        case setIndex(Int)
    }

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
        var state = state
        switch mutation {
        case let .setIndex(i):
            state.selectedIndex = i
        }
        return state
    }
}
