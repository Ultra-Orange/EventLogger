//
//  AppFlow.swift
//  RxFlowPractice
//
//  Created by Yoon on 8/19/25.
//

import RxCocoa
import RxFlow
import RxSwift
import UIKit

final class AppFlow: Flow {
    private let window: UIWindow
    private let rootNav = UINavigationController()
    var root: Presentable { rootNav }

    init(windowScene: UIWindowScene) {
        window = UIWindow(windowScene: windowScene)
        window.rootViewController = rootNav
        window.makeKeyAndVisible()
    }

    func navigate(to step: any Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        switch step {
        case .eventList:
            return navigateToEventList()
        case let .eventDetail(item):
            return navigateToEventDetail(item)
        }
    }

    func navigateToEventList() -> FlowContributors {
        let vc = EventListViewController()
        let reactor = EventListReactor()
        vc.reactor = reactor
        rootNav.pushViewController(vc, animated: false)
        return .one(
            flowContributor: .contribute(
                withNextPresentable: vc,
                withNextStepper: reactor
            )
        )
    }

    func navigateToEventDetail(_ eventItem: EventItem) -> FlowContributors {
        let vc = EventDetailViewController()
        let reactor = EventDetailReactor(eventItem: eventItem)
        vc.reactor = reactor
        rootNav.pushViewController(vc, animated: true)
        return .one(
            flowContributor: .contribute(
                withNextPresentable: vc,
                withNextStepper: reactor
            )
        )
    }
}
