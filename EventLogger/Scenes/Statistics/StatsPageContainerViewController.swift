//
//  StatsPageContainerViewController.swift
//  EventLogger
//
//  Created by 김우성 on 9/12/25.
//

import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

final class StatsPageContainerViewController: UIViewController {

    private let backgroundGradientView = GradientBackgroundView()
    private let segmented = PillSegmentedControl(items: ["연도별", "월별", "전체"]).then { $0.selectedIndex = 0 }
    private let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private let containerView = UIView()
    private let disposeBag = DisposeBag()
    private let selectedIndexRelay = BehaviorRelay<Int>(value: 0)

    private lazy var pages: [UIViewController] = [
        StatsContentViewController(reactor: .init(fixedScope: .year)),
        StatsContentViewController(reactor: .init(fixedScope: .month)),
        StatsContentViewController(reactor: .init(fixedScope: .all))
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPageVC()
        bind()
    }

    private func setupUI() {
        title = "통계"
        view.backgroundColor = .appBackground

        view.addSubview(backgroundGradientView)
        backgroundGradientView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.5)
        }

        view.addSubview(segmented)
        view.addSubview(containerView)

        segmented.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }

        containerView.snp.makeConstraints {
            $0.top.equalTo(segmented.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        addChild(pageVC)
        containerView.addSubview(pageVC.view)
        pageVC.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        pageVC.didMove(toParent: self)
    }

    private func setupPageVC() {
        pageVC.dataSource = self
        pageVC.setViewControllers([pages[0]], direction: .forward, animated: false, completion: nil)
    }

    private func bind() {
        // 1) 입력: 세그 탭
        let segmentTap = segmented.rx.indexChangedByUser
            .do(onNext: { [weak self] i in self?.log("segmentTap", idx: i) })

        // 2) 입력: 스와이프 종료
        let swipeEnd = pageVC.rx.currentIndex(pages: pages)
            .do(onNext: { [weak self] i in self?.log("swipeEnd", idx: i) })

        // 3) 병합 → 릴레이
        Observable.merge(segmentTap, swipeEnd)
            .bind(to: selectedIndexRelay)
            .disposed(by: disposeBag)

        // 4) 릴레이 변경 로그
        selectedIndexRelay
            .distinctUntilChanged()
            .do(onNext: { [weak self] v in self?.log("relay", idx: v) })
            .subscribe()
            .disposed(by: disposeBag)

        // 5) 릴레이 → 세그 표시
        selectedIndexRelay
            .distinctUntilChanged()
            .bind(to: segmented.rx.selectedSegmentIndex)
            .disposed(by: disposeBag)

        // 6) 릴레이 → 페이지 전환
        selectedIndexRelay
            .distinctUntilChanged()
            .bind(to: pageVC.rx.setIndex(pages: pages, animated: true))
            .disposed(by: disposeBag)

        // 7) 초기 주입
        selectedIndexRelay.accept(0)
    }

    private func log(_ event: String, idx: Int) {
        let seg = segmented.selectedIndex
        let relay = selectedIndexRelay.value
        let page = pageVC.viewControllers?.first.flatMap { pages.firstIndex(of: $0) } ?? -1
    }
}

extension StatsPageContainerViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let idx = pages.firstIndex(of: viewController), idx > 0 else { return nil }
        return pages[idx - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let idx = pages.firstIndex(of: viewController), idx + 1 < pages.count else { return nil }
        return pages[idx + 1]
    }
}
