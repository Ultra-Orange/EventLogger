//
//  EventListViewController.swift
//  EventLogger
//
//  Created by 김우성 on 8/20/25.
//

import ReactorKit
import RxSwift
import RxCocoa
import UIKit
import SwiftUI

private enum SortOrder { case newestFirst, oldestFirst }

private enum Filter { case all, upcoming, completed }

private struct YearMonth: Hashable, Comparable {
    let year: Int
    let month: Int
    static func < (lhs: YearMonth, rhs: YearMonth) -> Bool {
        if lhs.year != rhs.year {
            return lhs.year < rhs.year
        }
        return lhs.month < rhs.month
    }
}

private enum Section: Hashable {
    case nextUp
    case month(YearMonth)
}

// Diffable에서 동일 아이템을 두 섹션에 중복으로 넣기 위해 역할별로 분리
private enum DSItem: Hashable {
    case nextUp(UUID)
    case monthEvent(UUID)
}

private extension Calendar {
    func yearMonth(for date: Date) -> YearMonth {
        let components = dateComponents([.year, .month], from: date)
        return YearMonth(year: components.year ?? 0, month: components.month ?? 0)
    }
}

final class EventListViewController: BaseViewController<EventListReactor> {
    
    private let segmentedControl = PillSegmentedControl(items: ["전체", "참여예정", "참여완료"]).then {
        $0.font = UIFont.preferredFont(forTextStyle: .body)
        $0.capsuleBackgroundColor = .black
        $0.capsuleBorderColor = .gray.withAlphaComponent(0.6)
        $0.capsuleBorderWidth = 1
        $0.normalTextColor = .white
        $0.selectedTextColor = .white
        $0.borderColor = .gray.withAlphaComponent(0.6)
        $0.borderWidth = 1
        $0.segmentSpacing = 6
        $0.contentInsets = .init(top: 3, leading: 3, bottom: 3, trailing: 3 )
        $0.selectedSegmentIndex = 0
        $0.addTarget(nil, action: #selector(handleValueChanged), for: .valueChanged)
    }
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout()).then {
        $0.backgroundColor = .clear
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.clipsToBounds = true
        $0.showsVerticalScrollIndicator = true
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, DSItem>!
    
    // Local State
    private var sortOrder: SortOrder = .newestFirst {
        didSet { rebuildSnapshot(animated: true) }
    }
    private var filter: Filter = .all {
        didSet { rebuildSnapshot(animated: true) }
    }
    private var itemsByID: [UUID: EventItem] = [:]
    private var currentItems: [EventItem] = [] // Reactor State 반영
    
    // 정렬 토글 나중에 변경
    private lazy var sortButton = UIBarButtonItem(
        image: UIImage(systemName: "arrow.up.arrow.down"), style: .plain, target: self, action: #selector(toggleSort)
    )
    
    override func setupUI() {
        self.title = "Event Logger"
        view.backgroundColor = .black
        
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
        
        navigationItem.rightBarButtonItem = sortButton
        
        makeDataSource()
    }
    
    private func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(162))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(162))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 30 // 같은 섹션 셀 간 간격
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0) // 헤더의
            
            section.boundarySupplementaryItems = [header]
            
            return section
        }
    }
    
    private func makeDataSource() {
        // Cell: SwiftUI EventCell를 iOS 17의 UIHostingConfiguration으로 올림
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, DSItem> { [weak self] cell, _, item in
            guard let self else { return }
            let event: EventItem? =
            {
                switch item {
                case .nextUp(let id), .monthEvent(let id): return self.itemsByID[id]
                }
            }()
            guard let event else { return }
            
            cell.contentConfiguration = UIHostingConfiguration {
                EventCell(item: event)
            }
            .margins(.all, 0) // 내부에서 패딩 처리
            
            cell.backgroundConfiguration = nil
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionReusableView>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] header, _, indexPath in
            guard let self else { return }
            let tag = 1001
            let label: UILabel
            if let l = header.viewWithTag(tag) as? UILabel {
                label = l
            } else {
                label = UILabel()
                label.tag = tag
                label.textColor = .white
                label.font = UIFont.preferredFont(forTextStyle: .headline)
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
            case .month(let yearMonth): label.text = "\(yearMonth.year)년 \(yearMonth.month)월"
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, DSItem>(collectionView: collectionView) {
            collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
    }
    
    private func rebuildSnapshot(animated: Bool) {
        guard let dataSource = dataSource else { return }
        
        // 리액터에서 가져온 items -> 필터/정렬/그룹핑
        let all = currentItems
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // 필터
        let filtered: [EventItem] = {
            switch filter {
            case .all:
                all
            case .upcoming:
                all.filter { $0.startTime >= today }
            case .completed:
                all.filter { $0.startTime < today }
            }
        }()
        
        itemsByID = Dictionary(uniqueKeysWithValues: filtered.map { ($0.id, $0)})
        
        // NextUp: 현재 필터링 결과에서 "가장 가까운 미래 1개" (일반 전체 그룹과 중복 허용)
        let nextUp: EventItem? = filtered.filter { $0.startTime >= today }
            .min(by: { $0.startTime < $1.startTime })
        
        // 월 그룹
        let grouped = Dictionary (grouping: filtered, by: { calendar.yearMonth(for: $0.startTime) })
        let monthOrder = (sortOrder == .newestFirst) ? grouped.keys.sorted().reversed() : grouped.keys.sorted()
        
        // Sections & Items
        var sections: [Section] = []
        var itemsForSection: [Section: [DSItem]] = [:]
        
        if let next = nextUp {
            sections.append(.nextUp)
            itemsForSection[.nextUp] = [.nextUp(next.id)]
        }
        
        for yearMonth in monthOrder {
            let section: Section = .month(yearMonth)
            sections.append(section)
            let monthItems = grouped[yearMonth]!.sorted { a, b in
                    sortOrder == .newestFirst ? (a.startTime > b.startTime) : (a.startTime < b.startTime)
            }
            itemsForSection[section] = monthItems.map { .monthEvent($0.id) } // NextUp과 중복 가능
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, DSItem>()
        snapshot.appendSections(sections)
        for section in sections {
            snapshot.appendItems(itemsForSection[section] ?? [], toSection: section)
        }
        dataSource.apply(snapshot, animatingDifferences: animated)
        
    }
    
    override func bind(reactor: EventListReactor) {
        loadViewIfNeeded()
        
        // 최초 로드
        rx.viewWillAppear.map { _ in .reloadEventItems }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 리액터 -> 뷰컨트롤러 상태 반영
        reactor.state
            .map(\.eventItems)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] items in
                guard let self else { return }
                self.currentItems = items
                self.rebuildSnapshot(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func handleValueChanged() {
        let index = segmentedControl.selectedSegmentIndex
        let title = segmentedControl.titleForSegment(at: index) ?? "알 수 없음"
        print("선택됨: index=\(index), title=\(title)")
        
        switch segmentedControl.selectedSegmentIndex {
        case 1: filter = .upcoming
        case 2: filter = .completed
        default: filter = .all
        }
    }
    
    @objc private func toggleSort() {
        sortOrder = (sortOrder == .newestFirst) ? .oldestFirst : .newestFirst
        let symbol = (sortOrder == .newestFirst) ? "arrow.down" : "arrow.up"
        sortButton.image = UIImage(systemName: "arrow.up.arrow.down.circle") ?? UIImage(systemName: symbol)
    }
}

#Preview {
    let vc = EventListViewController()
    vc.reactor = EventListReactor()
    return vc
}
