//
//  EventListViewController.swift
//  EventLogger
//
//  Created by 김우성 on 8/20/25.
//

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import SwiftUI
import Then
import UIKit

final class EventListViewController: BaseViewController<EventListReactor> {
    private let backgroundGradientView = GradientBackgroundView()
    
    private let titleLabel = UILabel().then {
        $0.text = "Event Logger"
        $0.textColor = .primary500
        $0.font = .font17Semibold
    }
    
    private let segmentedControl = PillSegmentedControl(items: ["전체", "참여예정", "참여완료"]).then {
        $0.font = .font17Regular
        $0.capsuleBackgroundColor = .black
        $0.capsuleBorderColor = .primary500
        $0.capsuleBorderWidth = 1
        $0.normalTextColor = .white
        $0.selectedTextColor = .white
        $0.borderColor = .clear
//        $0.borderWidth = 1
        $0.segmentSpacing = 6
        $0.contentInsets = .init(top: 3, leading: 3, bottom: 3, trailing: 3)
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: EventListLayout.makeLayout()).then {
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = true
    }
    
    private var dataSource: EventListDataSource!
    
    // 정렬 토글 나중에 변경
    private lazy var sortButton = UIBarButtonItem(
        image: UIImage(systemName: "arrow.up.arrow.down"),
        style: .plain,
        target: nil,
        action: nil
    ).then {
        $0.tintColor = .white
    }
    
    private lazy var addButton = UIBarButtonItem(
        barButtonSystemItem: .add,
        target: nil,
        action: nil
    ).then {
        $0.tintColor = .white
    }
    
    override func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(backgroundGradientView)
        backgroundGradientView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        view.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        
        navigationItem.rightBarButtonItems = [sortButton, addButton]
        
        dataSource = EventListDataSource(collectionView: collectionView)
    }
    
    override func bind(reactor: EventListReactor) {
        let categories = reactor.currentState.categories
        print(categories)
        
        loadViewIfNeeded()
        
        // 액션
        // 최초 로드
        rx.viewWillAppear
            .flatMap { _ in
                Observable.from([
                    EventListReactor.Action.reloadEventItems,
                    EventListReactor.Action.reloadCategories
                ])
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        segmentedControl.rx.selectedSegmentIndex
            .map { index -> EventListReactor.Action in
                switch index {
                case 1: return .setFilter(.upcoming)
                case 2: return .setFilter(.completed)
                default: return .setFilter(.all)
                }
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        sortButton.rx.tap
            .map { .toggleSort }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        addButton.rx.tap
            .map { AppStep.createSchedule }
            .bind(to: reactor.steps)
            .disposed(by: disposeBag)
        
        // State -> Snapshot
        Observable
            .combineLatest(
                reactor.state.map(\.eventItems).distinctUntilChanged(),
                reactor.state.map(\.filter).distinctUntilChanged(),
                reactor.state.map(\.sortOrder).distinctUntilChanged()
            )
            .map { items, filter, sortOrder in
                EventListSnapshotBuilder.build(input: .init(
                    allItems: items,
                    sortOrder: sortOrder,
                    filter: filter,
                    calendar: .current,
                    today: Date()
                ))
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] output in
                guard let self else { return }
                self.dataSource.updateItemsMap(output.itemsByID)
                self.dataSource.apply(output.snapshot, animated: true)
            })
            .disposed(by: disposeBag)
        
        // 버튼 아이콘 업데이터 (정렬 변화 반영)
        reactor.state.map(\.sortOrder)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] order in
                self?.sortButton.image = UIImage(systemName: order == .newestFirst ? "arrow.up" : "arrow.down")
            })
            .disposed(by: disposeBag)
    }
}

#Preview {
    let vc = EventListViewController()
    vc.reactor = EventListReactor()
    return vc
}
