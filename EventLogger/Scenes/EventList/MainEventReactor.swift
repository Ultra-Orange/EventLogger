//
//  MainEventReactor.swift
//  EventLogger
//
//  Created by 김우성 on 9/11/25.
//

import ReactorKit
import RxSwift
import UIKit

final class MainEventReactor: BaseReactor {
    enum Action {
        case openStatistics
        case openMenu
        case tapAddButton
    }

    enum Mutation {
        case setMenu(UIMenu?)
    }

    struct State {
        var menu: UIMenu?
    }

    let initialState: State = .init(menu: nil)

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .openStatistics:
            steps.accept(AppStep.statistics)
            return .empty()
        case .openMenu:
            // 필요 시 전역 메뉴 구성
            let settings = UIAction(title: "설정", image: UIImage(systemName: "gearshape.fill")) { [weak self] _ in
                self?.steps.accept(AppStep.settings)
            }
            let menu = UIMenu(title: "", children: [settings])
            return .just(.setMenu(menu))
        case .tapAddButton:
            steps.accept(AppStep.createSchedule)
            return .empty()
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var new = state
        switch mutation {
        case .setMenu(let m): new.menu = m
        }
        return new
    }
}
