//
//  StatsContentViewController.swift
//  EventLogger
//
//  Created by 김우성 on 9/12/25.
//

import CoreData
import Dependencies
import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

final class StatsContentViewController: BaseViewController<StatsReactor> {
    @Dependency(\.swiftDataManager) var swiftDataManager
    lazy var statisticsService = StatisticsService(manager: swiftDataManager)

    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout()).then {
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = true
        $0.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }

    private let emptyView = UIView().then { $0.backgroundColor = .clear }
    private let emptyStackView = UIStackView().then {
        $0.axis = .vertical; $0.alignment = .center; $0.distribution = .fill; $0.spacing = 10
    }

    private let emptyTitleLabel = UILabel().then {
        $0.text = "보여드릴 통계가 없어요"; $0.textColor = .neutral50; $0.font = .font20Bold
        $0.textAlignment = .center; $0.numberOfLines = 0
    }

    private let emptyValueLabel = UILabel().then {
        $0.text = "이벤트를 등록하면 통계를 보여드릴 수 있어요"; $0.textColor = .neutral50; $0.font = .font17Regular
        $0.textAlignment = .center; $0.numberOfLines = 0
    }

    let notification = NSPersistentCloudKitContainer.eventChangedNotification

    enum StatsSection: Hashable {
        case menuBar
        case heatmapHeader
        case heatmap
        case heatmapFooter
        case totalCount
        case totalExpense
        case categoryCountHeader
        case categoryCount
        case categoryExpenseHeader
        case categoryExpense
        case artistCountHeader
        case artistCount
        case artistExpenseHeader
        case artistExpense
    }

    enum StatsItem: Hashable {
        case title(String)
        case menu(UUID)
        case heatmapHeaderTitle(String)
        case heatmap(HeatmapModel)
        case heatmapLegend(UUID)
        case totalCount(TotalModel)
        case totalExpense(TotalModel)
        case rollupParent(RollupParent)
        case rollupChild(RollupChild)
    }

    var dataSource: UICollectionViewDiffableDataSource<StatsSection, StatsItem>!
    var expandedParentIDs = Set<UUID>()
    var childrenCache: [UUID: [RollupChild]] = [:]

    convenience init(reactor: StatsReactor) {
        self.init()
        self.reactor = reactor
    }

    override func setupUI() {
        view.backgroundColor = .clear

        view.addSubview(collectionView)
        collectionView.backgroundView = emptyView
        emptyView.isHidden = true
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(0)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        setupEmptyView()
        configureDataSource()
    }

    private func setupEmptyView() {
        emptyView.addSubview(emptyStackView)
        emptyStackView.addArrangedSubview(emptyTitleLabel)
        emptyStackView.addArrangedSubview(emptyValueLabel)
        emptyStackView.snp.makeConstraints { $0.center.equalTo(view.safeAreaLayoutGuide) }
    }

    override func bind(reactor: StatsReactor) {
        Observable.merge(
            rx.viewDidLoad.map { _ in },
            NotificationCenter.default.rx.notification(notification).map { _ in }
        )
        .map { _ in .refresh }
        .bind(to: reactor.action)
        .disposed(by: disposeBag)

        // 접기/펼치기
        collectionView.rx.itemSelected
            .do(onNext: { [weak self] indexPath in
                self?.collectionView.deselectItem(at: indexPath, animated: true)
            })
            .compactMap { [weak self] indexPath -> StatsItem? in
                guard let self else { return nil }
                return self.dataSource.itemIdentifier(for: indexPath)
            }
            .compactMap { item -> RollupParent? in
                if case let .rollupParent(parent) = item { return parent }
                return nil
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] parent in
                self?.toggle(parent: parent)
            })
            .disposed(by: disposeBag)

        reactor.state
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.applySnapshot(animated: true)
            })
            .disposed(by: disposeBag)
    }

    /// 부모 받아서 펼쳐져 있으면 접고, 접혀 있으면 펼치는 함수
    private func toggle(parent: RollupParent) {
        guard var snapshot = dataSource?.snapshot() else { return }
        let pid = parent.id
        let children = (childrenCache[pid] ?? [])
        let childItems = children.map { StatsItem.rollupChild($0) }
        let parentItem = StatsItem.rollupParent(parent)

        if expandedParentIDs.contains(pid) {
            snapshot.deleteItems(childItems)
            expandedParentIDs.remove(pid)
        } else {
            if snapshot.indexOfItem(parentItem) != nil {
                snapshot.insertItems(childItems, afterItem: parentItem)
                expandedParentIDs.insert(pid)
            } else {
                snapshot.appendItems(childItems, toSection: sectionFor(parent: parent, in: snapshot))
                expandedParentIDs.insert(pid)
            }
        }
        snapshot.reconfigureItems([parentItem]) // chevron 갱신 (cellRegistration의 액세서리 재계산 유도)

        dataSource?.apply(snapshot, animatingDifferences: true)
    }

    /// 부모가 속한 섹션을 찾음
    private func sectionFor(parent: RollupParent,
                            in snapshot: NSDiffableDataSourceSnapshot<StatsSection, StatsItem>) -> StatsSection
    {
        let section: StatsSection

        switch parent.type {
        case .categoryCount: section = .categoryCount
        case .categoryExpense: section = .categoryExpense
        case .artistCount: section = .artistCount
        case .artistExpense: section = .artistExpense
        }
        // 섹션이 실제 스냅샷에 존재하면 그 섹션 반환, 아니면 첫 섹션
        return snapshot.sectionIdentifiers.contains(section) ? section : (snapshot.sectionIdentifiers.first ?? .categoryCount)
    }

    func resetRollupCaches() {
        expandedParentIDs.removeAll()
        childrenCache.removeAll()
    }

    struct TotalModel: Hashable {
        let totalCount: Int
        let totalExpense: Double
    }

    struct RollupParent: Hashable {
        let id: UUID
        let title: String
        let leftDotColor: UIColor?
        let valueText: String
        let type: RollupType
    }

    struct RollupChild: Hashable {
        let id: UUID
        let parentId: UUID
        let leftDotColor: UIColor?
        let title: String
        let valueText: String
    }

    enum RollupType: Hashable {
        case categoryCount
        case categoryExpense
        case artistCount
        case artistExpense
    }
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
