//
//  EventListPageContainerViewController.swift
//  EventLogger
//
//  Created by 김우성 on 9/15/25.
//

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

/// 상단 Pill 세그먼트 + 좌우 스와이프 페이징 컨테이너
final class EventListPageContainerViewController: BaseViewController<EventListPageReactor> {

    // MARK: UI
    private let backgroundGradientView = GradientBackgroundView()

    private let titleImageView = UIImageView().then {
        $0.image = UIImage(named: "MainLogo")
        $0.contentMode = .scaleAspectFit
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.widthAnchor.constraint(lessThanOrEqualToConstant: 160).isActive = true
        $0.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }

    private lazy var menuButton = UIBarButtonItem(
        image: UIImage(systemName: "ellipsis.circle"),
        style: .plain,
        target: nil,
        action: nil
    ).then { $0.tintColor = .neutral50 }

    private lazy var statisticsButton = UIBarButtonItem(
        image: UIImage(systemName: "chart.bar.xaxis"),
        style: .plain,
        target: nil,
        action: nil
    ).then { $0.tintColor = .neutral50 }

    private let addButton = UIButton.makeAddButton()

    private let segmented = PillSegmentedControl(items: ["전체", "참여예정", "참여완료"]).then {
        $0.backgroundColor = .appBackground
        $0.selectedIndex = 0
    }

    private let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal).then {
        $0.additionalSafeAreaInsets = .init(top: 62, left: 0, bottom: 0, right: 0)
    }
    private let containerView = UIView()

    // MARK: Pages (컨텐츠는 탭별 고정 필터 Reactor 주입)
    private lazy var pages: [EventListContentViewController] = [
        EventListContentViewController(reactor: .init(fixedFilter: .all)),
        EventListContentViewController(reactor: .init(fixedFilter: .upcoming)),
        EventListContentViewController(reactor: .init(fixedFilter: .completed))
    ]

    // MARK: Lifecycle
    override func setupUI() {
        view.backgroundColor = .appBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleImageView)
        navigationItem.rightBarButtonItems = [menuButton, statisticsButton]

        view.addSubview(backgroundGradientView)
        backgroundGradientView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.5)
        }

        view.addSubview(containerView)
        containerView.snp.makeConstraints {
//            $0.top.equalTo(segmented.snp.bottom).offset(12)
//            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalToSuperview()
            $0.leading.trailing.bottom.equalToSuperview()
        }

        view.addSubview(segmented)
        segmented.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }

        view.addSubview(addButton)
        addButton.snp.makeConstraints {
            $0.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.size.equalTo(59)
        }

        addChild(pageVC)
        containerView.addSubview(pageVC.view)
        pageVC.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        pageVC.didMove(toParent: self)


    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageVC()
    }

    private func setupPageVC() {
        pageVC.dataSource = self
        pageVC.setViewControllers([pages[0]], direction: .forward, animated: false)
    }

    // MARK: Bind
    override func bind(reactor: EventListPageReactor) {
        // 1) 입력: 세그 탭
        segmented.rx.indexChangedByUser
            .map { EventListPageReactor.Action.setIndex($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 2) 입력: 스와이프 종료 -> 보이는 VC index
        pageVC.rx.currentIndex(pages: pages)
            .map { EventListPageReactor.Action.setIndex($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 3) 상태 → 세그 표시
        reactor.state.map(\.selectedIndex)
            .distinctUntilChanged()
            .bind(to: segmented.rx.selectedSegmentIndex)
            .disposed(by: disposeBag)

        // 4) 상태 → 페이지 전환
        reactor.state.map(\.selectedIndex)
            .distinctUntilChanged()
            .bind(to: pageVC.rx.setIndex(pages: pages, animated: true))
            .disposed(by: disposeBag)

        // 5) 메뉴 갱신 (현재 탭의 리스트 상태를 구독해 동적으로 생성)
        reactor.state.map(\.selectedIndex)
            .distinctUntilChanged()
            .flatMapLatest { [weak self] idx -> Observable<(items: [EventItem], sort: EventListSortOrder, year: Int?, listDispatcher: ActionSubject<EventListReactor.Action>)> in
                guard let self, let childReactor = self.pages[safe: idx]?.reactor else { return .empty() }
                return Observable
                    .combineLatest(
                        childReactor.state.map(\.eventItems).distinctUntilChanged(),
                        childReactor.state.map(\.sortOrder).distinctUntilChanged(),
                        childReactor.state.map(\.yearFilter).distinctUntilChanged()
                    )
                    .map { (items, sort, year) in (items, sort, year, childReactor.action) }
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self, weak reactor] payload in
                guard let self, let reactor else { return }
                // UIBarButtonItem는 showsMenuAsPrimaryAction 없음. menu만 세팅하면 탭 시 표시됨(iOS 14+)
                self.menuButton.menu = Self.makeMenu(
                    items: payload.items,
                    currentSort: payload.sort,
                    currentYear: payload.year,
                    listDispatcher: payload.listDispatcher,
                    pageDispatcher: reactor.action // Settings는 컨테이너에서 처리
                )
            })
            .disposed(by: disposeBag)

        // 6) 버튼 바인딩 (컨테이너 리액터로 처리)
        statisticsButton.rx.tap
            .map { EventListPageReactor.Action.tapStatistics }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        addButton.rx.tap
            .map { EventListPageReactor.Action.tapAdd }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 모든 자식 steps를 컨테이너 리액터로 forward
            pages.compactMap { $0.reactor }.forEach { childReactor in
                childReactor.steps
                    .bind(to: reactor.steps)
                    .disposed(by: disposeBag)
            }

        // 7) 초기 인덱스 주입
        reactor.action.onNext(.setIndex(0))
    }

    // MARK: 메뉴 생성 (정렬/연도는 "현재 탭"으로 디스패치, 설정은 컨테이너로 디스패치)
    static func makeMenu(
        items: [EventItem],
        currentSort: EventListSortOrder,
        currentYear: Int?,
        listDispatcher: ActionSubject<EventListReactor.Action>,
        pageDispatcher: ActionSubject<EventListPageReactor.Action>
    ) -> UIMenu {
        // 설정 (컨테이너가 네비게이션 스텝 처리)
        let goSettings = UIAction(title: "설정", image: UIImage(systemName: "gearshape.fill")) { _ in
            pageDispatcher.onNext(.tapSettings)
        }

        // 정렬 (리스트 탭 전용 상태)
        let newest = UIAction(title: "최신 순", image: UIImage(systemName: "arrow.down.to.line")) { _ in
            listDispatcher.onNext(.setSortOrder(.newestFirst))
        }.toggled(currentSort == .newestFirst)

        let oldest = UIAction(title: "오래된 순", image: UIImage(systemName: "arrow.up.to.line")) { _ in
            listDispatcher.onNext(.setSortOrder(.oldestFirst))
        }.toggled(currentSort == .oldestFirst)

        let sortMenu = UIMenu(title: "", options: .displayInline, children: [newest, oldest])

        // 연도
        let years = Set(items.map { Calendar.current.component(.year, from: $0.startTime) }).sorted(by: >)

        let allYears = UIAction(title: "모든 연도", image: UIImage(systemName: "tray.full")) { _ in
            listDispatcher.onNext(.setYearFilter(nil))
        }.toggled(currentYear == nil)

        let yearActions = years.map { y in
            UIAction(title: "\(y)년") { _ in
                listDispatcher.onNext(.setYearFilter(y))
            }.toggled(currentYear == y)
        }

        let yearMenu = UIMenu(title: "", options: .displayInline, children: [allYears] + yearActions)
        return UIMenu(title: "", children: [goSettings, sortMenu, yearMenu])
    }
}

// MARK: - Page DataSource
extension EventListPageContainerViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? EventListContentViewController,
              let idx = pages.firstIndex(of: vc), idx > 0 else { return nil }
        return pages[idx - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? EventListContentViewController,
              let idx = pages.firstIndex(of: vc), idx + 1 < pages.count else { return nil }
        return pages[idx + 1]
    }
}

// MARK: - Helpers
private extension Array {
    subscript(safe index: Index) -> Element? { indices.contains(index) ? self[index] : nil }
}

private extension UIAction {
    func toggled(_ on: Bool) -> UIAction { state = on ? .on : .off; return self }
}
