//
//  CategoryDetailReactor.swift
//  EventLogger
//
//  Created by Yoon on 9/2/25.
//

import Dependencies
import Foundation
import ReactorKit
import RxFlow

final class CategoryDetailReactor: BaseReactor {
    // 사용자 액션 정의 (사용자의 의도)
    enum Action {
        case tapBottomButton(String?, Int)
    }

    // 상태변경 이벤트 정의 (상태를 어떻게 바꿀 것인가)
    enum Mutation {
        case setAlertMessage(String)
    }

    // View의 상태 정의 (현재 View의 상태값)
    struct State {
        let categoryItem: CategoryItem?
        let navTitle: String
        let buttonTitle: String
        var selectedColorId: Int
        @Pulse var alertMessage: String?
    }

    enum Mode {
        case create
        case update(CategoryItem)

        var navTitle: String {
            switch self {
            case .create: return "새 카테고리"
            case .update: return "카테고리 수정"
            }
        }

        var buttonTitle: String {
            switch self {
            case .create: return "추가하기"
            case .update: return "수정하기"
            }
        }

        var cateogryItem: CategoryItem? {
            switch self {
            case .create: return nil
            case let .update(item): return item
            }
        }

        var selectedColorId: Int {
            switch self {
            case .create: return 0
            case let .update(item): return item.colorId
            }
        }
    }

    let initialState: State
    let mode: Mode

    init(mode: Mode) {
        self.mode = mode
        initialState = State(
            categoryItem: mode.cateogryItem,
            navTitle: mode.navTitle,
            buttonTitle: mode.buttonTitle,
            selectedColorId: mode.selectedColorId
        )
    }

    // Action이 들어왔을 때 어떤 Mutation으로 바뀔지 정의
    // 사용자 입력 → 상태 변화 신호로 변환
    func mutate(action: Action) -> Observable<Mutation> {
        @Dependency(\.swiftDataManager) var swiftDataManager
        switch action {
        case let .tapBottomButton(name, colorId):
            guard let name, !name.trimmingCharacters(in: .whitespaces).isEmpty else {
                return .just(.setAlertMessage("카테고리 이름을 입력하세요"))
            }
            switch mode {
            case .create:
                swiftDataManager.insertCategory(name: name, colorId: colorId)
                steps.accept(AppStep.backToCategoryList)
                return .empty()
            case let .update(item):
                swiftDataManager.updateCategory(id: item.id, name: name, colorId: colorId)
                steps.accept(AppStep.backToCategoryList)
                return .empty()
            }
        }
    }

    // Mutation이 발생했을 때 상태(State)를 실제로 바꿈
    // 상태 변화 신호 → 실제 상태 반영
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case let .setAlertMessage(message):
            newState.alertMessage = message
        }

        return newState
    }
}
