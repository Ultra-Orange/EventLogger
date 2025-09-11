//
//  MainEventViewController.swift
//  EventLogger
//
//  Created by 김우성 on 9/11/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then
import ReactorKit

/// 상단 PillSegmentedControl + 하단 UIPageViewController
final class MainEventViewController: BaseViewController<MainEventReactor> {

    // MARK: UI
    private let backgroundGradientView = GradientBackgroundView()

    private let titleView = UIImageView().then {
        $0.image = UIImage(named: "MainLogo")
    }

    private lazy var menuButton = UIBarButtonItem(
        image: UIImage(systemName: "ellipsis.circle"),
        style: .plain,
        target: nil,
        action: nil
    ).then {
        $0.tintColor = .neutral50
        $0.isSpringLoaded = true
    }

    private lazy var statisticsButton = UIBarButtonItem(
        image: UIImage(systemName: "chart.bar.xaxis"),
        style: .plain,
        target: nil,
        action: nil
    ).then {
        $0.tintColor = .neutral50
    }

    private let segmentedControl = PillSegmentedControl(items: ["전체", "참여예정", "참여완료"])

    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal,
        options: [.interPageSpacing: 8]
    )
    private let addButton = UIButton.makeAddButton()

    // Child VCs (각각 독립)
    private lazy var allVC: EventListViewController = makeListVC(filter: .all)
    private lazy var upcomingVC: EventListViewController = makeListVC(filter: .upcoming)
    private lazy var completedVC: EventListViewController = makeListVC(filter: .completed)

    private lazy var pages: [EventListViewController] = [allVC, upcomingVC, completedVC]

    // MARK: Lifecycle
    override func setupUI() {
        navigationItem.backButtonDisplayMode = .minimal
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleView)
        navigationItem.rightBarButtonItems = [menuButton, statisticsButton]

        view.backgroundColor = .appBackground

        view.addSubview(backgroundGradientView)
        backgroundGradientView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.5)
        }

        view.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }

        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        pageViewController.didMove(toParent: self)
        pageViewController.dataSource = self
        pageViewController.delegate = self

        // 초기 페이지: 전체
        setPage(index: 0, animated: false)

        view.addSubview(addButton)
        addButton.snp.makeConstraints {
            $0.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.size.equalTo(59)
        }
    }

    override func bind(reactor: MainEventReactor) {
        bindActions(reactor)
        bindState(reactor)
    }

    // MARK: Reactor Bindings
    private func bindActions(_ reactor: MainEventReactor) {
        // PillSegmentedControl 탭 → 해당 페이지로 이동
        segmentedControl.rx.selectedSegmentIndex
            .skip(1) // 초기값 방지
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe(onNext: { owner, index in
                owner.setPage(index: index, animated: true)
            })
            .disposed(by: disposeBag)

        // 상단 버튼 액션 넘기기
        statisticsButton.rx.tap
            .map { MainEventReactor.Action.openStatistics }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        menuButton.rx.tap
            .map { MainEventReactor.Action.openMenu }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        addButton.rx.tap
            .map { AppStep.createSchedule }
            .bind(to: reactor.steps)
            .disposed(by: disposeBag)
    }

    private func bindState(_ reactor: MainEventReactor) {
        // 필요 시 상단 메뉴 구성 (예: 글로벌 설정 등)
        reactor.state.map(\.menu)
            .distinctUntilChanged { $0?.identifier == $1?.identifier }
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] menu in
                self?.menuButton.menu = menu
            })
            .disposed(by: disposeBag)
    }

    // MARK: Helpers
    private func makeListVC(filter: EventListFilter) -> EventListViewController {
        let vc = EventListViewController(fixedFilter: filter)
        let r = EventListReactor(fixedFilter: filter)
        vc.reactor = r
        return vc
    }

    private func setPage(index: Int, animated: Bool) {
        guard pages.indices.contains(index) else { return }
        guard let currentVC = pageViewController.viewControllers?.first as? EventListViewController else {
            // 최초 세팅
            pageViewController.setViewControllers([pages[index]], direction: .forward, animated: false)
            segmentedControl.selectedIndex = index
            return
        }
        let currentIndex = pages.firstIndex(of: currentVC) ?? 0
        let direction: UIPageViewController.NavigationDirection = (index >= currentIndex) ? .forward : .reverse
        pageViewController.setViewControllers([pages[index]], direction: direction, animated: animated)
        // 양방향 동기화
        segmentedControl.selectedIndex = index
    }
}

// MARK: - UIPageViewControllerDataSource & Delegate
extension MainEventViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? EventListViewController,
              let idx = pages.firstIndex(of: vc) else { return nil }
        let prev = idx - 1
        return pages.indices.contains(prev) ? pages[prev] : nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? EventListViewController,
              let idx = pages.firstIndex(of: vc) else { return nil }
        let next = idx + 1
        return pages.indices.contains(next) ? pages[next] : nil
    }

    // 스와이프 완료 시 PillSegmentedControl 동기화
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let current = pageViewController.viewControllers?.first as? EventListViewController,
              let index = pages.firstIndex(of: current) else { return }
        segmentedControl.selectedIndex = index
    }
}
