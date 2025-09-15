//
//  UIPageViewController+Rx.swift
//  EventLogger
//
//  Created by 김우성 on 9/12/25.
//

import UIKit
import RxSwift
import RxCocoa

public extension Reactive where Base: UIPageViewController {

    /// 스와이프 종료 후 실제 보이는 VC의 index를 방출
    func currentIndex(pages: [UIViewController]) -> Observable<Int> {
        guard let scrollView = base.view.subviews.compactMap({ $0 as? UIScrollView }).first else {
            return .empty()
        }

        let endDrag  = scrollView.rx.didEndDragging.filter { !$0 }.map { _ in () }
        let endDecel = scrollView.rx.didEndDecelerating.map { _ in () }

        return Observable.merge(endDrag, endDecel)
            .compactMap { [weak base] _ -> Int? in
                guard
                    let pageVC = base,
                    let vc = pageVC.viewControllers?.first,
                    let idx = pages.firstIndex(of: vc)
                else { return nil }
                print("🔹[swipeEnd] idx=\(idx)")
                return idx
            }
            .observe(on: MainScheduler.asyncInstance)
    }

    /// 지정 index로 전환 (방향 자동)
    func setIndex(pages: [UIViewController], animated: Bool = true) -> Binder<Int> {
        return Binder(base) { pageVC, newIndex in
            guard pages.indices.contains(newIndex) else { return }

            let currentIndex: Int = {
                guard let currentVC = pageVC.viewControllers?.first,
                      let idx = pages.firstIndex(of: currentVC) else { return 0 }
                return idx
            }()

            let direction: UIPageViewController.NavigationDirection =
                (newIndex >= currentIndex) ? .forward : .reverse

            pageVC.setViewControllers([pages[newIndex]], direction: direction, animated: animated) { finished in
                print("📦[setIndex finished] \(currentIndex) -> \(newIndex), finished=\(finished)")
            }
        }
    }
}
