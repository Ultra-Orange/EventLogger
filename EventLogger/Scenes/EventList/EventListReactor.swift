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
    // 사용자 액션
    enum Action {
        case reloadEventItems
        case reloadCategories
        case setSortOrder(EventListSortOrder)
        case setYearFilter(Int?)
        case goSettings
        case applyFixedFilter // 내부 고정 필터를 초기 1회 보장
    }

    // 상태변경 이벤트
    enum Mutation {
        case setEventItems([EventItem])
        case setSortOrder(EventListSortOrder)
        case setCategories([CategoryItem])
        case setYearFilter(Int?)
        case setFilter(EventListFilter)
    }

    // View 상태
    struct State {
        var eventItems: [EventItem]
        var filter: EventListFilter          // 항상 고정된 필터로 사용
        var sortOrder: EventListSortOrder
        var categories: [CategoryItem] = []
        var yearFilter: Int? = nil
    }

    let initialState: State
    private let fixedFilter: EventListFilter
    @Dependency(\.swiftDataManager) var swiftDataManager

    init(fixedFilter: EventListFilter) {
        self.fixedFilter = fixedFilter
        self.initialState = State(
            eventItems: [],
            filter: fixedFilter,
            sortOrder: .newestFirst
        )
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .reloadEventItems:
            let fetchItems = swiftDataManager.fetchAllEvents()
            return .just(.setEventItems(fetchItems))

        case let .setSortOrder(order):
            return .just(.setSortOrder(order))

        case .reloadCategories:
            let categoryItems = swiftDataManager.fetchAllCategories()
            return .just(.setCategories(categoryItems))

        case let .setYearFilter(year):
            return .just(.setYearFilter(year))

        case .goSettings:
            steps.accept(AppStep.settings)
            return .empty()

        case .applyFixedFilter:
            return .just(.setFilter(fixedFilter))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setEventItems(eventItems):
            newState.eventItems = eventItems

        case let .setSortOrder(order):
            newState.sortOrder = order

        case let .setCategories(categories):
            newState.categories = categories

        case let .setYearFilter(year):
            newState.yearFilter = year

        case let .setFilter(filter):
            newState.filter = filter
        }
        return newState
    }
}
