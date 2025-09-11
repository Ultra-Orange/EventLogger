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
import Dependencies

// MARK: - 공통 타입 (동일)
enum EventListSortOrder: Equatable { case newestFirst, oldestFirst
    mutating func toggle() { self = (self == .newestFirst) ? .oldestFirst : .newestFirst }
}
enum EventListFilter: Equatable { case all, upcoming, completed }
struct EventListYearMonth: Hashable, Comparable {
    let year: Int; let month: Int
    static func < (l: Self, r: Self) -> Bool { l.year != r.year ? l.year < r.year : l.month < r.month }
}
enum EventListSection: Hashable { case nextUp; case month(EventListYearMonth) }
enum EventListDSItem: Hashable {
    case nextUp(UUID); case monthEvent(UUID)
    var eventID: UUID { switch self { case .nextUp(let id), .monthEvent(let id): return id } }
}
extension Calendar {
    func yearMonth(for date: Date) -> EventListYearMonth {
        let c = dateComponents([.year, .month], from: date)
        return .init(year: c.year ?? 0, month: c.month ?? 0)
    }
}

// MARK: - ViewController
final class EventListViewController: BaseViewController<EventListReactor> {

    // 고정 필터로 동작하도록 생성자 제공
    private let fixedFilter: EventListFilter

    init(fixedFilter: EventListFilter) {
        self.fixedFilter = fixedFilter
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
//
//    // MARK: UI
//    private let backgroundGradientView = GradientBackgroundView()

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

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: Self.makeLayout()).then {
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = true
    }

    private let emptyView = UIView().then { $0.backgroundColor = .clear }
    private let emptyStackView = UIStackView().then {
        $0.axis = .vertical; $0.alignment = .center; $0.distribution = .fill; $0.spacing = 10; $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let emptyTitleLabel = UILabel().then {
        $0.text = "보여드릴 이벤트가 없어요"
        $0.textColor = .neutral50
        $0.font = .font20Bold
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    private let emptyValueLabel = UILabel().then {
        $0.text = "일정을 등록하면 전체 일정을 한눈에 확인할 수 있어요\n참여 하루 전, 놓치지 않도록 알림도 챙겨드려요"
        $0.textColor = .neutral50
        $0.font = .font14Regular
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }


    // MARK: Diffable
    private typealias DS = UICollectionViewDiffableDataSource<EventListSection, EventListDSItem>
    private lazy var dataSource: DS = configureDataSource()
    private var currentItemsByID: [UUID: EventItem] = [:]

    // MARK: System
    let cloudKitChanged = NSPersistentCloudKitContainer.eventChangedNotification

    // MARK: Lifecycle
    override func setupUI() {
        navigationItem.backButtonDisplayMode = .minimal
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleView)
        navigationItem.rightBarButtonItems = [menuButton, statisticsButton]

        view.backgroundColor = .clear

//        view.addSubview(backgroundGradientView)
//        backgroundGradientView.snp.makeConstraints {
//            $0.leading.trailing.bottom.equalToSuperview()
//            $0.height.equalToSuperview().multipliedBy(0.5)
//        }

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        collectionView.backgroundView = emptyView
        emptyView.addSubview(emptyStackView)
        emptyStackView.addArrangedSubview(emptyTitleLabel)
        emptyStackView.addArrangedSubview(emptyValueLabel)
        emptyStackView.snp.makeConstraints { $0.center.equalTo(view.safeAreaLayoutGuide) }
        emptyView.isHidden = true


    }

    override func bind(reactor: EventListReactor) {
        bindActions(reactor)
        bindNavigation(reactor)
        bindStateToUI(reactor)
    }

    // MARK: Bind - Actions
    private func bindActions(_ reactor: EventListReactor) {
        // 최초 로드, CloudKit 동기화 시 리로드
        let triggerReload = Observable.merge(
            rx.viewWillAppear.map { _ in },
            NotificationCenter.default.rx.notification(cloudKitChanged).map { _ in }
        )
        .flatMap { _ in
            Observable.from([
                EventListReactor.Action.reloadEventItems,
                EventListReactor.Action.reloadCategories,
                // 고정 필터를 초기 1회 반영 (혹시 state 초기값과 다를 수 있으니 안전하게)
                EventListReactor.Action.applyFixedFilter
            ])
        }

        triggerReload
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }

    // MARK: Bind - Navigation
    private func bindNavigation(_ reactor: EventListReactor) {
        statisticsButton.rx.tap
            .map { AppStep.statistics }
            .bind(to: reactor.steps)
            .disposed(by: disposeBag)

        collectionView.rx.itemSelected
            .compactMap { [weak self] indexPath in
                self?.collectionView.deselectItem(at: indexPath, animated: true)
                return self?.eventItem(at: indexPath)
            }
            .map { AppStep.eventDetail($0) }
            .bind(to: reactor.steps)
            .disposed(by: disposeBag)
    }

    // MARK: Bind - State → UI
    private func bindStateToUI(_ reactor: EventListReactor) {
        Observable
            .combineLatest(
                reactor.state.map(\.eventItems),
                reactor.state.map(\.filter).distinctUntilChanged(),
                reactor.state.map(\.sortOrder).distinctUntilChanged(),
                reactor.state.map(\.yearFilter).distinctUntilChanged()
            )
            .map { [weak self] items, filter, sortOrder, yearFilter -> (snapshot: NSDiffableDataSourceSnapshot<EventListSection, EventListDSItem>, itemsByID: [UUID: EventItem]) in
                guard let self else { return (NSDiffableDataSourceSnapshot(), [:]) }
                return self.buildSnapshot(
                    allItems: items,
                    sortOrder: sortOrder,
                    filter: filter,
                    yearFilter: yearFilter,
                    calendar: .current,
                    today: Date()
                )
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] output in
                self?.applySnapshot(output.snapshot, itemsByID: output.itemsByID, animated: true)
            })
            .disposed(by: disposeBag)

        // 메뉴 업데이트
        Observable
            .combineLatest(
                reactor.state.map(\.eventItems).distinctUntilChanged(),
                reactor.state.map(\.sortOrder).distinctUntilChanged(),
                reactor.state.map(\.yearFilter).distinctUntilChanged()
            )
            .subscribe(onNext: { [weak self] items, sortOrder, yearFilter in
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

    // MARK: - DataSource (Cell/Header 등록 포함)
    private func configureDataSource() -> DS {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, EventListDSItem> { [weak self] cell, _, item in
            @Dependency(\.swiftDataManager) var swiftDataManager
            guard let self else { return }
            let eventID = item.eventID
            guard let event = self.currentItemsByID[eventID] else { return }
            let fetchedCategory = swiftDataManager.fetchOneCategory(id: event.categoryId)

            cell.contentConfiguration = UIHostingConfiguration {
                if let fetchedCategory {
                    EventCell(item: event, category: fetchedCategory).id(UUID()) // 항상 새로 그리기
                }
            }.margins(.all, 0)
            cell.backgroundConfiguration = nil
        }

        // Header
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionReusableView>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] header, _, indexPath in
            guard let self else { return }
            let tag = 1001
            let label: UILabel
            if let l = header.viewWithTag(tag) as? UILabel {
                label = l
            } else {
                label = UILabel()
                label.tag = tag
                label.textColor = .neutral50
                label.font = .font17Bold
                header.addSubview(label)
                label.snp.makeConstraints {
                    $0.top.equalToSuperview().inset(25)
                    $0.bottom.equalToSuperview().inset(20)
                    $0.leading.trailing.equalToSuperview()
                }
            }

            let snapshot = self.dataSource.snapshot()
            let section = snapshot.sectionIdentifiers[indexPath.section]
            switch section {
            case .nextUp: label.text = "다음 일정"
            case .month(let ym): label.text = "\(ym.year)년 \(ym.month)월"
            }
        }

        let ds = DS(collectionView: collectionView) { cv, indexPath, item in
            return cv.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        ds.supplementaryViewProvider = { cv, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            return cv.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
        return ds
    }

    // MARK: - Snapshot (build/apply)
    private func buildSnapshot(
        allItems: [EventItem],
        sortOrder: EventListSortOrder,
        filter: EventListFilter,
        yearFilter: Int?,
        calendar: Calendar,
        today: Date
    ) -> (snapshot: NSDiffableDataSourceSnapshot<EventListSection, EventListDSItem>, itemsByID: [UUID: EventItem]) {

        // 1) 상태 필터 (고정 필터 사용)
        let stateFiltered: [EventItem] = {
            switch filter {
            case .all: allItems
            case .upcoming: allItems.filter { $0.startTime >= today }
            case .completed: allItems.filter { $0.startTime < today }
            }
        }()

        // 2) 연도 필터
        let filtered: [EventItem] = {
            guard let year = yearFilter else { return stateFiltered }
            return stateFiltered.filter { calendar.component(.year, from: $0.startTime) == year }
        }()

        let itemsByID = Dictionary(uniqueKeysWithValues: filtered.map { ($0.id, $0) })

        // 3) 다음 일정
        let nextUp: EventItem? = filtered
            .filter { $0.startTime >= today }
            .min(by: { $0.startTime < $1.startTime })

        // 4) 월 그룹
        let grouped = Dictionary(grouping: filtered, by: { calendar.yearMonth(for: $0.startTime) })
        let monthKeysSorted = (sortOrder == .newestFirst) ? grouped.keys.sorted().reversed()
                                                          : grouped.keys.sorted()

        // 5) 섹션/아이템
        var sections: [EventListSection] = []
        var itemsForSection: [EventListSection: [EventListDSItem]] = [:]

        if let next = nextUp {
            sections.append(.nextUp)
            itemsForSection[.nextUp] = [.nextUp(next.id)]
        }

        for key in monthKeysSorted {
            let section: EventListSection = .month(key)
            sections.append(section)
            let monthItems = (grouped[key] ?? []).sorted { a, b in
                sortOrder == .newestFirst ? (a.startTime > b.startTime) : (a.startTime < b.startTime)
            }
            itemsForSection[section] = monthItems.map { .monthEvent($0.id) }
        }

        var snapshot = NSDiffableDataSourceSnapshot<EventListSection, EventListDSItem>()
        snapshot.appendSections(sections)
        for s in sections {
            let items = itemsForSection[s] ?? []
            snapshot.appendItems(items, toSection: s)
            snapshot.reconfigureItems(items)
        }

        return (snapshot, itemsByID)
    }

    private func applySnapshot(
        _ snapshot: NSDiffableDataSourceSnapshot<EventListSection, EventListDSItem>,
        itemsByID: [UUID: EventItem],
        animated: Bool
    ) {
        currentItemsByID = itemsByID
        dataSource.apply(snapshot, animatingDifferences: animated)
        let isEmpty = snapshot.itemIdentifiers.isEmpty
        collectionView.backgroundView?.isHidden = !isEmpty
    }

    // MARK: - Helpers
    private func eventItem(at indexPath: IndexPath) -> EventItem? {
        guard let idItem = dataSource.itemIdentifier(for: indexPath) else { return nil }
        return currentItemsByID[idItem.eventID]
    }

    // MARK: - 메뉴 생성 (동일)
    static func makeMenu(
        items: [EventItem],
        currentSort: EventListSortOrder,
        currentYear: Int?,
        dispatcher: ActionSubject<EventListReactor.Action>
    ) -> UIMenu {
        let goSettings = UIAction(title: "설정", image: UIImage(systemName: "gearshape.fill")) { _ in
            dispatcher.onNext(.goSettings)
        }

        let newest = UIAction(title: "최신 순", image: UIImage(systemName: "arrow.down.to.line")) { _ in
            dispatcher.onNext(.setSortOrder(.newestFirst))
        }.toggled(currentSort == .newestFirst)

        let oldest = UIAction(title: "오래된 순", image: UIImage(systemName: "arrow.up.to.line")) { _ in
            dispatcher.onNext(.setSortOrder(.oldestFirst))
        }.toggled(currentSort == .oldestFirst)

        let sortMenu = UIMenu(title: "", options: .displayInline, children: [newest, oldest])

        let years = Set(items.map { Calendar.current.component(.year, from: $0.startTime) }).sorted(by: >)

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

    // MARK: - 레이아웃 (동일)
    static func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(162)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(162)
            )
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 30
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)

            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(66)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]
            return section
        }
    }
}

// MARK: - UIAction 편의
private extension UIAction {
    func toggled(_ on: Bool) -> UIAction {
        self.state = on ? .on : .off
        return self
    }
}
