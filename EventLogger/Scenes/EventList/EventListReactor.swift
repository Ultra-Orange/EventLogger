//
//  EventListReactor.swift
//  EventLogger
//
//  Created by Yoon on 8/20/25.
//

import SwiftData

import Dependencies
import ReactorKit
import RxFlow
import RxRelay
import RxSwift

final class EventListReactor: BaseReactor {
    // 사용자 액션 정의 (사용자의 의도)
    enum Action {
        case reloadEventItems
        case reloadCategories
        case setFilter(EventListFilter)
        case toggleSort
    }

    // 상태변경 이벤트 정의 (상태를 어떻게 바꿀 것인가)
    enum Mutation {
        case setEventItems([EventItem])
        case setFilter(EventListFilter)
        case setSortOrder(EventListSortOrder)
        case setCategories([CategoryItem])
    }

    // View의 상태 정의 (현재 View의 상태값)
    struct State {
        var eventItems: [EventItem]
        var filter: EventListFilter
        var sortOrder: EventListSortOrder
        var categories: [CategoryItem] = []
    }

    // 생성자에서 초기 상태 설정
    let initialState: State
    @Dependency(\.modelContext) var modelContext
    @Dependency(\.swiftDataManager) var swiftDataManager

    init() {
        @Dependency(\.eventItems) var fetchItems
        initialState = State(
            eventItems: fetchItems,
            filter: .all,
            sortOrder: .newestFirst
        )
    }

    // Action이 들어왔을 때 어떤 Mutation으로 바뀔지 정의
    // 사용자 입력 → 상태 변화 신호로 변환
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .reloadEventItems:
            @Dependency(\.eventItems) var fetchItems
            return .just(.setEventItems(fetchItems))

        case let .setFilter(filter):
            return .just(.setFilter(filter))

        case .toggleSort:
            return .just(
                .setSortOrder(
                    currentState.sortOrder == .newestFirst ? .oldestFirst : .newestFirst
                )
            )

        case .reloadCategories:
            let fetched = swiftDataManager.fetchAllCategories()
            let categoryItems = fetched.compactMap { $0.toDomain() }
            return .just(.setCategories(categoryItems))
        }
    }

    // Mutation이 발생했을 때 상태(State)를 실제로 바꿈
    // 상태 변화 신호 → 실제 상태 반영
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setEventItems(eventItems):
            newState.eventItems = eventItems

        case let .setFilter(filter):
            newState.filter = filter

        case let .setSortOrder(order):
            newState.sortOrder = order

        case let .setCategories(categories):
            newState.categories = categories
        }

        return newState
    }
}
