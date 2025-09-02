//
//  CategoryEditReactor.swift
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

final class CategoryEditReactor: BaseReactor {
    // 사용자 액션 정의 (사용자의 의도)
    enum Action {
        case reloadCategories
        case reorderCategories([CategoryItem])
        case deleteCategory(CategoryItem)
    }

    // 상태변경 이벤트 정의 (상태를 어떻게 바꿀 것인가)
    enum Mutation {
        case setCategories([CategoryItem])
        case setAlertMessage(String)
    }

    // View의 상태 정의 (현재 View의 상태값)
    struct State {
        var categories: [CategoryItem] = []
        @Pulse var alertMessage: String?
    }

    // 생성자에서 초기 상태 설정
    let initialState: State

    init() {
        initialState = State()
    }

    // Action이 들어왔을 때 어떤 Mutation으로 바뀔지 정의
    // 사용자 입력 → 상태 변화 신호로 변환
    func mutate(action: Action) -> Observable<Mutation> {
        @Dependency(\.swiftDataManager) var swiftDataManager
        switch action {
        case .reloadCategories:
            let categories = swiftDataManager.fetchAllCategories()
            return .just(.setCategories(categories))
        case let .reorderCategories(items):
            swiftDataManager.updateCategoriesPosition(items)
            return .just(.setCategories(items))
        case let .deleteCategory(item):
            let categories = currentState.categories.filter { $0.id != item.id }
            do {
                try swiftDataManager.deleteCategory(id: item.id)
                return .just(.setCategories(categories))
            } catch SwiftDataMangerError.cannotDeleteUsedCategory {
                return .just(.setAlertMessage("일정에서 사용하고 있는 \n 카테고리는 삭제할 수 없습니다."))
            } catch SwiftDataMangerError.cannotDeleteLastCategory {
                return .just(.setAlertMessage("최소 1개의 카테고리는 존재해야 합니다."))
            } catch {
                return .just(.setAlertMessage("알 수 없는 오류가 발생했습니다."))
            }
        }
    }

    // Mutation이 발생했을 때 상태(State)를 실제로 바꿈
    // 상태 변화 신호 → 실제 상태 반영
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setCategories(categories):
            newState.categories = categories
        case let .setAlertMessage(message):
            newState.alertMessage = message
        }
        return newState
    }
}
