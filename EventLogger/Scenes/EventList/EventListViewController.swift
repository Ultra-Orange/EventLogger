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
import CoreData

final class EventListViewController: BaseViewController<EventListReactor> {
    private let backgroundGradientView = GradientBackgroundView()
    
    private let titleLabel = UILabel().then {
        $0.text = "Event Logger"
        $0.textColor = .primary500
        $0.font = .font17Semibold
    }
    
    private let segmentedControl = PillSegmentedControl(items: ["전체", "참여예정", "참여완료"]).then {
        $0.capsuleBackgroundColor = .appBackground
        $0.capsuleBorderColor = .primary500
        $0.capsuleShadowColor = .primary500
        $0.capsuleBorderWidth = 1
        $0.borderColor = .clear
        $0.normalTextColor = .neutral50
        $0.normalFont = .font17Regular
        $0.selectedTextColor = .primary200
        $0.selectedFont = .font17Semibold
        $0.selectedTextShadowColor = UIColor.primary500
        $0.textShadowOpacity = 1
        $0.textShadowRadius = 7
        $0.textShadowOffset = CGSize(width: 0, height: 0)
        $0.segmentSpacing = 6
        $0.contentInsets = .init(top: 3, leading: 3, bottom: 3, trailing: 3)
    }
    
    private let addButton = UIButton.makeAddButton()
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: Self.makeLayout()).then {
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = true
    }
    
    private lazy var dataSource = EventListDataSource(collectionView: collectionView)
    private var currentItemsByID: [UUID: EventItem] = [:]
    
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
    
    let cloudKitChanged = NSPersistentCloudKitContainer.eventChangedNotification
    
    override func setupUI() {
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
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        view.addSubview(addButton)
        addButton.snp.makeConstraints {
            $0.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.size.equalTo(59)
        }
        
        navigationItem.backButtonDisplayMode = .minimal
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        navigationItem.rightBarButtonItems = [menuButton, statisticsButton]
    }
    
    override func bind(reactor: EventListReactor) {
        bindActions(reactor)
        bindNavigation(reactor)
        bindStateToUI(reactor)
    }
    
    private func bindActions(_ reactor: EventListReactor) {
        // 최초 로드, CloudKit 동기화 시 리로드
        let triggerReload = Observable.merge(
            rx.viewWillAppear.map{ _ in },
            NotificationCenter.default.rx.notification(cloudKitChanged).map{ _ in }
        )
        .flatMap { _ in
            Observable.from([
                EventListReactor.Action.reloadEventItems,
                EventListReactor.Action.reloadCategories
            ])
        }
        
        // 세그먼트 변경 -> 필터 변경
        let filterChange = segmentedControl.rx.selectedSegmentIndex
            .map { index -> EventListReactor.Action in
                switch index {
                case 1: return .setFilter(.upcoming)
                case 2: return .setFilter(.completed)
                default: return .setFilter(.all)
                }
            }
        
        Observable.merge(triggerReload, filterChange)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindNavigation(_ reactor: EventListReactor) {
        addButton.rx.tap
            .map { AppStep.createSchedule }
            .bind(to: reactor.steps)
            .disposed(by: disposeBag)
        
        statisticsButton.rx.tap
            .map { AppStep.statistics }
            .bind(to: reactor.steps)
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .compactMap { [weak self] indexPath in
                self?.collectionView.deselectItem(at: indexPath, animated: true)
                return self?.dataSource.eventItem(at: indexPath)
            }
            .map { AppStep.eventDetail($0) }
            .bind(to: reactor.steps)
            .disposed(by: disposeBag)
    }
    
    private func bindStateToUI(_ reactor: EventListReactor) {
        // Snapshot 빌드 & 적용
        Observable
            .combineLatest(
                reactor.state.map(\.eventItems),
                reactor.state.map(\.filter).distinctUntilChanged(),
                reactor.state.map(\.sortOrder).distinctUntilChanged(),
                reactor.state.map(\.yearFilter).distinctUntilChanged()
            )
            .map { items, filter, sortOrder, yearFilter in
                EventListSnapshotBuilder.build(input: .init(
                    allItems: items,
                    sortOrder: sortOrder,
                    filter: filter,
                    yearFilter: yearFilter,
                    calendar: .current,
                    today: Date()
                ))
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] output in
                guard let self else { return }
                self.currentItemsByID = output.itemsByID
                self.dataSource.updateItemsMap(output.itemsByID)
                self.dataSource.apply(output.snapshot, animated: true)
            })
            .disposed(by: disposeBag)
        
        // 메뉴 업데이트
        Observable
            .combineLatest(
                reactor.state.map(\.eventItems).distinctUntilChanged(),
                reactor.state.map(\.sortOrder).distinctUntilChanged(),
                reactor.state.map(\.yearFilter).distinctUntilChanged()
            )
            .subscribe(onNext: {
                [weak self] items, sortOrder, yearFilter in
                guard let self, let reactor = self.reactor else { return }
                self.menuButton.menu = Self.makeMenu(
                    items: items,
                    currentSort: sortOrder,
                    currentYear: yearFilter,
                    dispatcher: reactor.action
                )
            })
            .disposed(by: disposeBag)
    }
}

// MARK: 메뉴 생성 (위에서부터 설정 / 정렬 / 연도)
private extension EventListViewController {
    static func makeMenu(
        items: [EventItem],
        currentSort: EventListSortOrder,
        currentYear: Int?,
        dispatcher: ActionSubject<EventListReactor.Action>
    ) -> UIMenu {
        // 설정
        let goSettings = UIAction(title: "설정", image: UIImage(systemName: "gearshape.fill")) { _ in
            dispatcher.onNext(.goSettings)
        }
        
        // 정렬
        let newest = UIAction(title: "최신 순", image: UIImage(systemName: "arrow.down.to.line")) { _ in
            dispatcher.onNext(.setSortOrder(.newestFirst))
        }.toggled(currentSort == .newestFirst)
        
        let oldest = UIAction(title: "오래된 순", image: UIImage(systemName: "arrow.up.to.line")) { _ in
            dispatcher.onNext(.setSortOrder(.oldestFirst))
        }.toggled(currentSort == .oldestFirst)
        
        let sortMenu = UIMenu(title: "", options: .displayInline, children: [newest, oldest])
        
        // 연도
        let years = Set(items.map { Calendar.current.component(.year, from: $0.startTime) })
            .sorted(by: >)
        
        let allYears = UIAction(title: "모든 연도", image: UIImage(systemName: "tray.full")) { _ in
            dispatcher.onNext(.setYearFilter(nil))
        }.toggled(currentYear == nil)
        
        let yearActions = years.map { y in
            UIAction(title: "\(y)년") { _ in
                dispatcher.onNext(.setYearFilter(y))
            }.toggled(currentYear == y)
        }
        
        let yearMenu = UIMenu(title: "", options: .displayInline, children: [allYears] + yearActions)
        
        return UIMenu(title: "", children: [goSettings, sortMenu, yearMenu])
    }
}

private extension UIAction {
    func toggled(_ on: Bool) -> UIAction {
        self.state = on ? .on : .off
        return self
    }
}

private extension EventListDSItem {
    var eventID: UUID? {
        switch self {
        case let .nextUp(id): return id
        case let .monthEvent(id): return id
        }
    }
}

#Preview {
    let vc = EventListViewController()
    vc.reactor = EventListReactor()
    return vc
}
