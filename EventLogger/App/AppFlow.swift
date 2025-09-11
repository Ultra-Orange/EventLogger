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
        case .categoryList:
            return navigateToCategoryList()
        case .createCategory:
            return navigateToCategoryDetail(mode: .create)
        case let .updateCategory(item):
            return navigateToCategoryDetail(mode: .update(item))
        case .backToCategoryList:
            return backToCategoryList()
        case .statistics:
            return navigateToStatistics()
        case let .queryToGoogleMap(keyword):
            return openInGoogleMaps(keyword: keyword)

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
    
    private func navigateToCategoryList() -> FlowContributors {
        let vc = CategoryListViewController()
        let reactor = CategoryListReactor()
        vc.reactor = reactor
        rootNav.pushViewController(vc, animated: true)
        return .one(
            flowContributor: .contribute(
                withNextPresentable: vc,
                withNextStepper: reactor
            )
        )
    }
    
    private func navigateToCategoryDetail(mode: CategoryDetailReactor.Mode) -> FlowContributors {
        let reactor = CategoryDetailReactor(mode: mode)
        let vc = CategoryDetailViewController()
        vc.reactor = reactor
        rootNav.pushViewController(vc, animated: true)
        return .one(
            flowContributor: .contribute(
                withNextPresentable: vc,
                withNextStepper: reactor
            )
        )
    }
    
    private func backToCategoryList() -> FlowContributors {
        
        rootNav.popViewController(animated: true)
        return .none
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

    private func openInGoogleMaps(keyword: String) -> FlowContributors {
        // URL은 공백이나 한글 같은 특수문자를 직접 포함할 수 없기 때문에 addingPercentEncoding으로 변환
        let encoded = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? keyword

        // 1) 구글맵 앱으로 열기
        if let appURL = URL(string: "comgooglemaps://?q=\(encoded)"),
           UIApplication.shared.canOpenURL(appURL)
        {
            UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            return .none
        }

        // 2) 앱이 없으면 웹으로 열기
        if let webURL = URL(string: "https://www.google.com/maps/search/?api=1&query=\(encoded)") {
            UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
        }
        return .none
    }
}
