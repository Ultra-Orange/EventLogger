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
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: EventListLayout.makeLayout()).then {
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = true
    }
    
    private var dataSource: EventListDataSource!
    private var currentItemsByID: [UUID: EventItem] = [:]
    
    private lazy var menuButton = UIBarButtonItem(
        image: UIImage(systemName: "ellipsis.circle"),
        style: .plain,
        target: nil,
        action: nil
    ).then {
        $0.tintColor = .neutral50
        $0.isSpringLoaded = true
        $0.primaryAction = nil
        $0.menu = nil
    }
    
    private lazy var addButton = UIBarButtonItem(
        image: UIImage(systemName: "note.text.badge.plus"),
        style: .plain,
        target: nil,
        action: nil
    ).then {
        $0.tintColor = .neutral50
    }
    
    private lazy var statisticsButton = UIBarButtonItem(
        image: UIImage(systemName: "chart.bar.xaxis"),
        style: .plain,
        target: nil,
        action: nil
    ).then {
        $0.tintColor = .neutral50
    }
    
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
        
        navigationItem.backButtonDisplayMode = .minimal
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        
        navigationItem.rightBarButtonItems = [menuButton, addButton, statisticsButton]
        
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
        
        addButton.rx.tap
            .map { AppStep.createSchedule }
            .bind(to: reactor.steps)
            .disposed(by: disposeBag)
        
        statisticsButton.rx.tap
            .map { AppStep.statistics }
            .bind(to: reactor.steps)
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .compactMap { [weak self] indexPath -> EventItem? in
                self?.collectionView.deselectItem(at: indexPath, animated: true)
                return self?.dataSource.eventItem(at: indexPath)
            }
            .map { AppStep.eventDetail($0) }
            .bind(to: reactor.steps)
            .disposed(by: disposeBag)
        
        // State -> Snapshot
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
        
        Observable
            .combineLatest(
                reactor.state.map(\.eventItems).distinctUntilChanged(),
                reactor.state.map(\.sortOrder).distinctUntilChanged(),
                reactor.state.map(\.yearFilter).distinctUntilChanged()
            )
            .subscribe(onNext: {
                [weak self] items, sortOrder, yearFilter in
                guard let self, let reactor = self.reactor else { return }
                self.menuButton.menu = self.makeSortAndYearMenu(
                    items: items,
                    currentSort: sortOrder,
                    currentYear: yearFilter,
                    dispatcher: reactor.action
                )
            })
            .disposed(by: disposeBag)
    }
}

private extension EventListViewController {
    /// 정렬/연도/설정 메뉴 생성
    func makeSortAndYearMenu(
        items: [EventItem],
        currentSort: EventListSortOrder,
        currentYear: Int?,
        dispatcher: ActionSubject<EventListReactor.Action>
    ) -> UIMenu {
        // 1) 정렬 액션 (단일 선택처럼 체크)
        let newest = UIAction(title: "최신 순", image: UIImage(systemName: "arrow.down.to.line")) { [weak dispatcher] _ in
            dispatcher?.onNext(.setSortOrder(.newestFirst))
        }
        newest.state = (currentSort == .newestFirst) ? .on : .off
        
        let oldest = UIAction(title: "오래된 순", image: UIImage(systemName: "arrow.up.to.line")) { [weak dispatcher] _ in
            dispatcher?.onNext(.setSortOrder(.oldestFirst))
        }
        oldest.state = (currentSort == .oldestFirst) ? .on : .off
        
        let sortMenu = UIMenu(title: "", options: .displayInline, children: [newest, oldest])
        
        // 2) 연도 목록 (실제 존재하는 연도만, 내림차순 정렬)
        let years: [Int] = {
            let yearsSet = Set(items.map { Calendar.current.component(.year, from: $0.startTime) })
            return yearsSet.sorted(by: >)
        }()
        
        // "모든 연도"
        let allYears = UIAction(title: "모든 연도", image: UIImage(systemName: "tray.full")) { [weak dispatcher] _ in
            dispatcher?.onNext(.setYearFilter(nil))
        }
        allYears.state = (currentYear == nil) ? .on : .off
        
        // 실제 연도 액션들
        let yearActions: [UIAction] = years.map { year in
            let action = UIAction(title: "\(year)년") { [weak dispatcher] _ in
                dispatcher?.onNext(.setYearFilter(year))
            }
            action.state = (currentYear == year) ? .on : .off
            return action
        }
        
        let yearMenu = UIMenu(title: "", options: .displayInline, children: [allYears] + yearActions)
        
        // 3) 설정 화면으로
        let goSettings = UIAction(title: "설정", image: UIImage(systemName: "gearshape.fill")) { [weak dispatcher] _ in
            dispatcher?.onNext(.goSettings)
        }
        
        
        // 4) 최종 메뉴 (위에서부터 정렬 2개, 그 다음 연도들)
        return UIMenu(title: "", children: [goSettings, sortMenu, yearMenu])
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
