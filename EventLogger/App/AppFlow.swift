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
    private let selectedLocationRelay = PublishRelay<String>()
    
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
        case .createSchedule:
            return navigateToSchedule(mode: .create)
        case let .updateSchedule(item):
            return navigateToSchedule(mode: .update(item))
        case let .locationSearch(string):
            return navigateToLocationSearch(query: string)
        case .settings:
            return navigateToSettings()
        case .categoryEdit:
            return navigateToCategoryEdit()
        case .statistics:
            return navigateToStatistics()
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
    
    func navigateToSchedule(mode: ScheduleReactor.Mode) -> FlowContributors {
        let reactor = ScheduleReactor(mode: mode)
        let vc = ScheduleViewController(selectedLocationRelay: selectedLocationRelay)
        vc.reactor = reactor
        rootNav.pushViewController(vc, animated: true)
        return .one(
            flowContributor: .contribute(
                withNextPresentable: vc,
                withNextStepper: reactor
            )
        )
    }
    
    private func navigateToLocationSearch(query: String) -> FlowContributors {
        let vc = LocationSearchViewController(
            selectedLocationRelay: selectedLocationRelay,
            initialQuery: query
        )
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = false
        }
        rootNav.present(nav, animated: true)
        return .none
    }
    
    private func navigateToSettings() -> FlowContributors {
        let vc = SettingsViewController()
        let reactor = SettingsReactor()
        vc.reactor = reactor
        rootNav.pushViewController(vc, animated: true)
        return .one(
            flowContributor: .contribute(
                withNextPresentable: vc,
                withNextStepper: reactor
            )
        )
    }
    
    private func navigateToCategoryEdit() -> FlowContributors {
        let vc = CategoryEditViewController()
        let reactor = CategoryEditReactor()
        vc.reactor = reactor
        rootNav.pushViewController(vc, animated: true)
        return .one(
            flowContributor: .contribute(
                withNextPresentable: vc,
                withNextStepper: reactor
            )
        )
        
    }
    
    private func navigateToStatistics() -> FlowContributors {
        let vc = StatsViewController()
        let reactor = StatsReactor()
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
