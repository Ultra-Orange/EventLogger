//
//  StatsViewController.swift
//  EventLogger
//
//  Created by 김우성 on 9/2/25.
//

import UIKit
import RxSwift
import RxCocoa
import Then
import SnapKit
import Dependencies

// MARK: - StatsViewController

final class StatsViewController: BaseViewController<StatsReactor> {
    @Dependency(\.swiftDataManager) var swiftDataManager
    
    private lazy var statisticsService = StatisticsService(manager: swiftDataManager)
    
    private let backgroundGradientView = GradientBackgroundView()
    
    // EventList와 동일한 스타일의 커스텀 컨트롤 (외부 컴포넌트)
    private let segmentedControl = PillSegmentedControl(items: ["연도별", "월별", "전체"]).then {
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
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout()).then {
        $0.backgroundColor = .neutral800
        $0.showsVerticalScrollIndicator = true
    }
    
    // MARK: - View State
    
    private var currentScope: Scope = .year     // 기본: 연도별
    private var selectedYear: Int?              // year / month scope에서 사용
    private var selectedMonth: Int?             // month scope에서 사용 (1~12)
    
    private var expandedParents: Set<UUID> = [] // 폴딩 리스트 상태
    
    // MARK: Diffable
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    // MARK: - Lifecycle
    
    override func setupUI() {
        view.backgroundColor = .appBackground
        title = "통계"
        
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
            $0.top.equalTo(segmentedControl.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        collectionView.delegate = self
        
        configureDataSource()
        bindUI()
        
        // 최초 값 설정
        currentScope = .year
        if let firstYearString = statisticsService.activeYears().first,
           let y = Int(firstYearString) { selectedYear = y }
        applySnapshot(animated: false)
    }
    
    override func bind(reactor: StatsReactor) {
        // ReactorKit 사용 없이도 동작하도록 구성.
        // (필요 시 여기서 reactor와 바인딩 추가 가능)
    }
}

// MARK: - Scope & Period

private extension StatsViewController {
    enum Scope: Int {
        case year   // 연도별
        case month  // 월별
        case all    // 전체
    }
    
    enum Section: Hashable {
        case menuBar                    // UIMenu 버튼 (연/월 선택)
        case heatmap                    // 참여 캘린더 (전체에서만)
        case total                      // 총 카운트
        case categoryCount              // 카테고리별 참여 횟수
        case categoryExpense            // 카테고리별 지출
        case artistCount                // 아티스트별 참여 횟수
        case artistExpense              // 아티스트별 지출
    }
    
    enum Item: Hashable {
        case menu(UUID)                 // 내용은 셀에서 구성
        case heatmap(HeatmapModel)
        case total(TotalModel)
        case rollupParent(RollupParent)
        case rollupChild(RollupChild)   // parent 아래 상세
    }
}

// MARK: - Models

private extension StatsViewController {
    struct TotalModel: Hashable {
        let totalCount: Int
        let totalExpense: Double
    }
    
    // Parent/Child(접고펼침) 공통
    struct RollupParent: Hashable {
        let id: UUID
        let title: String
        let leftDotColor: UIColor? // 카테고리면 색 점, 아티스트면 nil
        let valueText: String
        let type: RollupType
    }
    struct RollupChild: Hashable {
        let id: UUID
        let parentId: UUID
        let leftDotColor: UIColor? // 카테고리면 색 점
        let title: String
        let valueText: String
    }
    enum RollupType: Hashable {
        case categoryCount
        case categoryExpense
        case artistCount
        case artistExpense
    }
    
    // Heatmap: rows = years(desc), columns = 1~12
    struct HeatmapModel: Hashable {
        struct Row: Hashable {
            let yearLabel: String   // `25 처럼 포맷 포함 또는 단순 "2025"
            let monthCounts: [Int]  // length 12
        }
        let rows: [Row]
    }
}

// MARK: - Bindings

private extension StatsViewController {
    func bindUI() {
        segmentedControl.rx.controlEvent(.valueChanged)
            .map { [weak self] in self?.segmentedControl.selectedIndex ?? 0 }
            .startWith(segmentedControl.selectedIndex) // 최초 상태 반영
            .subscribe(onNext: { [weak self] idx in
                guard let self else { return }
                self.currentScope = Scope(rawValue: idx) ?? .year
                // 기본 선택 보정
                if self.currentScope == .year || self.currentScope == .month {
                    if self.selectedYear == nil,
                       let first = self.statisticsService.activeYears().first,
                       let y = Int(first) { self.selectedYear = y }
                }
                if self.currentScope == .month && self.selectedMonth == nil {
                    self.selectedMonth = 1
                }
                self.applySnapshot(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Snapshot

private extension StatsViewController {
    func applySnapshot(animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        // 어떤 섹션을 보여줄지 결정
        if currentScope == .year {
            snapshot.appendSections([.menuBar, .total, .categoryCount, .categoryExpense, .artistCount, .artistExpense])
        } else if currentScope == .month {
            snapshot.appendSections([.menuBar, .total, .categoryCount, .categoryExpense, .artistCount, .artistExpense])
        } else { // .all
            snapshot.appendSections([.heatmap, .total, .categoryCount, .categoryExpense, .artistCount, .artistExpense])
        }
        
        // 1) 메뉴바
        if snapshot.sectionIdentifiers.contains(.menuBar) {
            snapshot.appendItems([.menu(UUID())], toSection: .menuBar)
        }
        
        // 2) 히트맵 (전체에서만)
        if snapshot.sectionIdentifiers.contains(.heatmap) {
            snapshot.appendItems([.heatmap(buildHeatmap())], toSection: .heatmap)
        }
        
        // 선택된 기간
        let period: StatsPeriod = {
            switch currentScope {
            case .all: return .all
            case .year: return .year(selectedYear ?? Calendar.current.component(.year, from: Date()))
            case .month: return .yearMonth(year: selectedYear ?? Calendar.current.component(.year, from: Date()),
                                           month: selectedMonth ?? 1)
            }
        }()
        
        // 원본 이벤트
        let events = filteredEvents(for: period)
        
        // 3) 총 카운트
        let totalModel = TotalModel(totalCount: events.count, totalExpense: events.reduce(0) { $0 + $1.expense })
        snapshot.appendItems([.total(totalModel)], toSection: .total)
        
        // 4) 롤업 리스트들
        let categoryBucket = aggregateByCategory(events: events)
        let artistBucket   = aggregateByArtist(events: events)
        
        // 카테고리 Count
        let ccParents = categoryBucket.sorted(by: { $0.value.count > $1.value.count })
            .map { (cid, val) -> RollupParent in
                let color = (swiftDataManager.fetchOneCategory(id: cid)?.color) ?? .systemGray
                return RollupParent(id: UUID(), title: swiftDataManager.fetchOneCategory(id: cid)?.name ?? "Unknown",
                                    leftDotColor: color, valueText: "\(val.count)회", type: .categoryCount)
            }
        appendRollup(parents: ccParents, makeChildren: { parent in
            // parent.title이 카테고리명
            let cid = swiftDataManager.fetchAllCategories().first { $0.name == parent.title }?.id
            let byArtist = aggregateArtistInCategory(events: events, categoryId: cid)
            return byArtist.sorted(by: { $0.value > $1.value }).map {
                RollupChild(id: UUID(), parentId: parent.id, leftDotColor: nil, title: $0.key, valueText: "\($0.value)회")
            }
        }, into: &snapshot, section: .categoryCount)
        
        // 카테고리 Expense
        let ceParents = categoryBucket.sorted(by: { $0.value.expense > $1.value.expense })
            .map { (cid, val) -> RollupParent in
                let color = (swiftDataManager.fetchOneCategory(id: cid)?.color) ?? .systemGray
                return RollupParent(id: UUID(), title: swiftDataManager.fetchOneCategory(id: cid)?.name ?? "Unknown",
                                    leftDotColor: color, valueText: KRWFormatter.shared.string(val.expense), type: .categoryExpense)
            }
        appendRollup(parents: ceParents, makeChildren: { parent in
            let cid = swiftDataManager.fetchAllCategories().first { $0.name == parent.title }?.id
            let byArtist = aggregateArtistExpenseInCategory(events: events, categoryId: cid)
            return byArtist.sorted(by: { $0.value > $1.value }).map {
                RollupChild(id: UUID(), parentId: parent.id, leftDotColor: nil, title: $0.key, valueText: KRWFormatter.shared.string($0.value))
            }
        }, into: &snapshot, section: .categoryExpense)
        
        // 아티스트 Count
        let acParents = artistBucket.sorted(by: { $0.value.count > $1.value.count })
            .map { (name, val) -> RollupParent in
                RollupParent(id: UUID(), title: name, leftDotColor: nil, valueText: "\(val.count)회", type: .artistCount)
            }
        appendRollup(parents: acParents, makeChildren: { parent in
            let byCategory = aggregateCategoryForArtist(events: events, artistName: parent.title)
            return byCategory.sorted(by: { $0.value > $1.value }).map {
                let color = swiftDataManager.fetchOneCategory(id: $0.key)?.color ?? .systemGray
                return RollupChild(id: UUID(), parentId: parent.id, leftDotColor: color, title: swiftDataManager.fetchOneCategory(id: $0.key)?.name ?? "Unknown", valueText: "\($0.value)회")
            }
        }, into: &snapshot, section: .artistCount)
        
        // 아티스트 Expense
        let aeParents = artistBucket.sorted(by: { $0.value.expense > $1.value.expense })
            .map { (name, val) -> RollupParent in
                RollupParent(id: UUID(), title: name, leftDotColor: nil, valueText: KRWFormatter.shared.string(val.expense), type: .artistExpense)
            }
        appendRollup(parents: aeParents, makeChildren: { parent in
            let byCategory = aggregateCategoryExpenseForArtist(events: events, artistName: parent.title)
            return byCategory.sorted(by: { $0.value > $1.value }).map {
                let color = swiftDataManager.fetchOneCategory(id: $0.key)?.color ?? .systemGray
                return RollupChild(id: UUID(), parentId: parent.id, leftDotColor: color, title: swiftDataManager.fetchOneCategory(id: $0.key)?.name ?? "Unknown", valueText: KRWFormatter.shared.string($0.value))
            }
        }, into: &snapshot, section: .artistExpense)
        
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    func appendRollup(
        parents: [RollupParent],
        makeChildren: (RollupParent) -> [RollupChild],
        into snapshot: inout NSDiffableDataSourceSnapshot<Section, Item>,
        section: Section
    ) {
        var items: [Item] = []
        for p in parents {
            items.append(.rollupParent(p))
            if expandedParents.contains(p.id) {
                let children = makeChildren(p).map { Item.rollupChild($0) }
                items.append(contentsOf: children)
            }
        }
        snapshot.appendItems(items, toSection: section)
    }
}

// MARK: - Data Aggregations

private extension StatsViewController {
    func filteredEvents(for period: StatsPeriod) -> [EventItem] {
        // StatisticsService.filteredEvents(for:)는 private이라 VC에서 직접 동일 로직 수행
        let all = swiftDataManager.fetchAllEvents()
        let cal = Calendar(identifier: .gregorian)
        switch period {
        case .all:
            return all
        case .year(let y):
            return all.filter { cal.component(.year, from: $0.startTime) == y }
        case .yearMonth(let y, let m):
            return all.filter {
                let comps = cal.dateComponents([.year, .month], from: $0.startTime)
                return comps.year == y && comps.month == m
            }
        }
    }
    
    // 카테고리 단위 집계 (count/expense)
    func aggregateByCategory(events: [EventItem]) -> [UUID: (count: Int, expense: Double)] {
        var bucket: [UUID: (Int, Double)] = [:]
        for e in events {
            let cur = bucket[e.categoryId] ?? (0, 0)
            bucket[e.categoryId] = (cur.0 + 1, cur.1 + e.expense)
        }
        return bucket
    }
    // 해당 카테고리 안에서 아티스트별 count
    func aggregateArtistInCategory(events: [EventItem], categoryId: UUID?) -> [String: Int] {
        guard let cid = categoryId else { return [:] }
        var m: [String: Int] = [:]
        for e in events where e.categoryId == cid {
            for name in e.artists { m[name, default: 0] += 1 }
        }
        return m
    }
    // 해당 카테고리 안에서 아티스트별 expense
    func aggregateArtistExpenseInCategory(events: [EventItem], categoryId: UUID?) -> [String: Double] {
        guard let cid = categoryId else { return [:] }
        var m: [String: Double] = [:]
        for e in events where e.categoryId == cid {
            for name in e.artists { m[name, default: 0] += e.expense }
        }
        return m
    }
    // 아티스트 단위 집계 (count/expense)
    func aggregateByArtist(events: [EventItem]) -> [String: (count: Int, expense: Double)] {
        var m: [String: (Int, Double)] = [:]
        for e in events {
            for name in e.artists {
                let cur = m[name] ?? (0, 0)
                m[name] = (cur.0 + 1, cur.1 + e.expense)
            }
        }
        return m
    }
    // 특정 아티스트의 카테고리별 count
    func aggregateCategoryForArtist(events: [EventItem], artistName: String) -> [UUID: Int] {
        var m: [UUID: Int] = [:]
        for e in events where e.artists.contains(artistName) {
            m[e.categoryId, default: 0] += 1
        }
        return m
    }
    // 특정 아티스트의 카테고리별 expense
    func aggregateCategoryExpenseForArtist(events: [EventItem], artistName: String) -> [UUID: Double] {
        var m: [UUID: Double] = [:]
        for e in events where e.artists.contains(artistName) {
            m[e.categoryId, default: 0] += e.expense
        }
        return m
    }
    
    // 전체 데이터로 heatmap 구성 (연도 desc, 12개월)
    func buildHeatmap() -> HeatmapModel {
        let cal = Calendar(identifier: .gregorian)
        let all = swiftDataManager.fetchAllEvents()
        // 연도 → [month: count]
        var m: [Int: [Int: Int]] = [:]
        for e in all {
            let y = cal.component(.year, from: e.startTime)
            let mon = cal.component(.month, from: e.startTime)
            var ym = m[y] ?? [:]
            ym[mon, default: 0] += 1
            m[y] = ym
        }
        let years = m.keys.sorted(by: >)
        let rows: [HeatmapModel.Row] = years.map { y in
            let counts = (1...12).map { m[y]?[$0] ?? 0 }
            let yearLabel = "`" + String(y % 100) // 디자인 예시처럼 `25
            return .init(yearLabel: yearLabel, monthCounts: counts)
        }
        return .init(rows: rows)
    }
}

// MARK: - Layout

private extension StatsViewController {
    func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, env in
            guard let self, let section = self.dataSource?.snapshot().sectionIdentifiers[safe: sectionIndex] else { return nil }
            switch section {
            case .menuBar:
                // 얇은 한 줄
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                                    heightDimension: .estimated(44)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                                                 heightDimension: .estimated(44)),
                                                               subitems: [item])
                let sec = NSCollectionLayoutSection(group: group)
                sec.contentInsets = .init(top: 0, leading: 20, bottom: 4, trailing: 20)
                return sec
            case .heatmap:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                                    heightDimension: .estimated(180)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                                               heightDimension: .estimated(220)),
                                                             subitems: [item])
                let sec = NSCollectionLayoutSection(group: group)
                sec.contentInsets = .init(top: 0, leading: 20, bottom: 8, trailing: 20)
                // 헤더 추가
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .estimated(32)),
                    elementKind: StatsHeaderView.elementKind,
                    alignment: .top)
                sec.boundarySupplementaryItems = [header]
                return sec
            case .total:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                                    heightDimension: .estimated(120)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                                               heightDimension: .estimated(140)),
                                                             subitems: [item])
                let sec = NSCollectionLayoutSection(group: group)
                sec.contentInsets = .init(top: 8, leading: 20, bottom: 8, trailing: 20)
                return sec
            case .categoryCount, .categoryExpense, .artistCount, .artistExpense:
                var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                config.backgroundColor = .clear
                config.showsSeparators = true
                config.headerMode = .supplementary
                return NSCollectionLayoutSection.list(using: config, layoutEnvironment: env)
            }
        }
        return layout
    }
}

// MARK: - DataSource

private extension StatsViewController {
    func configureDataSource() {
        // Cell registrations
        let menuReg = UICollectionView.CellRegistration<MenuBarCell, UUID> { [weak self] cell, _, _ in
            guard let self else { return }
            cell.configure(
                scope: self.currentScope,
                yearProvider: { [weak self] in self?.statisticsService.activeYears() ?? [] },
                selectedYear: self.selectedYear,
                selectedMonth: self.selectedMonth,
                onYearPicked: { [weak self] y in
                    self?.selectedYear = y
                    self?.applySnapshot(animated: true)
                },
                onMonthPicked: { [weak self] m in
                    self?.selectedMonth = m
                    self?.applySnapshot(animated: true)
                }
            )
        }
        
        let heatmapReg = UICollectionView.CellRegistration<HeatmapCell, HeatmapModel> { cell, _, model in
            cell.configure(model: model)
        }
        
        let totalReg = UICollectionView.CellRegistration<TotalCell, TotalModel> { cell, _, model in
            cell.configure(totalCount: model.totalCount, totalExpense: model.totalExpense)
        }
        
        let parentReg = UICollectionView.CellRegistration<RollupParentCell, RollupParent> { [weak self] cell, _, model in
            guard let self else { return }
            cell.configure(title: model.title,
                           valueText: model.valueText,
                           leftDotColor: model.leftDotColor,
                           expanded: self.expandedParents.contains(model.id))
        }
        
        let childReg = UICollectionView.CellRegistration<RollupChildCell, RollupChild> { cell, _, model in
            cell.configure(title: model.title, valueText: model.valueText, leftDotColor: model.leftDotColor)
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .menu(let id):
                return collectionView.dequeueConfiguredReusableCell(using: menuReg, for: indexPath, item: id)
            case .heatmap(let model):
                return collectionView.dequeueConfiguredReusableCell(using: heatmapReg, for: indexPath, item: model)
            case .total(let model):
                return collectionView.dequeueConfiguredReusableCell(using: totalReg, for: indexPath, item: model)
            case .rollupParent(let model):
                return collectionView.dequeueConfiguredReusableCell(using: parentReg, for: indexPath, item: model)
            case .rollupChild(let model):
                return collectionView.dequeueConfiguredReusableCell(using: childReg, for: indexPath, item: model)
            }
        }
        
        // 1) Supplementary Registration
        let headerReg = UICollectionView.SupplementaryRegistration<StatsHeaderView>(
            elementKind: StatsHeaderView.elementKind
        ) { [weak self] header, _, indexPath in
            guard let self,
                  let section = self.dataSource?.snapshot().sectionIdentifiers[safe: indexPath.section]
            else { return }
            let title = self.headerTitle(for: section) ?? ""
            header.configure(title: title, showLegend: section == .heatmap)
        }

        // 2) Provider
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard kind == StatsHeaderView.elementKind else { return nil }
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerReg, for: indexPath)
        }
    }
}

// MARK: - Cells

// 1) UIMenu 버튼 섹션 셀
private final class MenuBarCell: UICollectionViewCell {
    private let container = UIView()
    private let yearButton = UIButton(type: .system)
    private let monthButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(container)
        container.snp.makeConstraints { $0.edges.equalToSuperview() }
        container.addSubview(yearButton)
        container.addSubview(monthButton)
        monthButton.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
            $0.height.equalTo(36)
        }
        yearButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(monthButton.snp.leading).offset(-8)
            $0.height.equalTo(36)
        }
        yearButton.setTitleColor(.neutral50, for: .normal)
        monthButton.setTitleColor(.neutral50, for: .normal)
        yearButton.backgroundColor = .neutral700
        monthButton.backgroundColor = .neutral700
        yearButton.layer.cornerRadius = 8
        monthButton.layer.cornerRadius = 8
    }
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(
        scope: StatsViewController.Scope,
        yearProvider: () -> [String],
        selectedYear: Int?,
        selectedMonth: Int?,
        onYearPicked: @escaping (Int) -> Void,
        onMonthPicked: @escaping (Int) -> Void
    ) {
        let years = yearProvider()
        let yearTitle = (selectedYear != nil) ? "\(selectedYear!)년" : "연도"
        yearButton.setTitle(yearTitle, for: .normal)
        let yearActions = years.compactMap { Int($0) }.map { y in
            UIAction(title: "\(y)년") { _ in onYearPicked(y) }
        }
        yearButton.menu = UIMenu(children: yearActions)
        yearButton.showsMenuAsPrimaryAction = true
        
        switch scope {
        case .year:
            // 월 버튼 숨김, 연도만
            monthButton.isHidden = true
        case .month:
            monthButton.isHidden = false
            let m = selectedMonth ?? 1
            monthButton.setTitle("\(m)월", for: .normal)
            let months = (1...12).map { month in
                UIAction(title: "\(month)월") { _ in onMonthPicked(month) }
            }
            monthButton.menu = UIMenu(children: months)
            monthButton.showsMenuAsPrimaryAction = true
        case .all:
            // 이 셀 자체가 안 보이는 섹션이므로 신경 X
            monthButton.isHidden = true
        }
    }
}

// 2) Heatmap 셀
private final class HeatmapCell: UICollectionViewCell {
    private let heatmapView = HeatmapView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(heatmapView)
        heatmapView.snp.makeConstraints { $0.edges.equalToSuperview() }
        heatmapView.layer.cornerRadius = 12
        heatmapView.backgroundColor = .neutral700
    }
    required init?(coder: NSCoder) { fatalError() }
    func configure(model: StatsViewController.HeatmapModel) {
        heatmapView.model = model
    }
}

// 실제 그리드 그리는 뷰
private final class HeatmapView: UIView {
    var model: StatsViewController.HeatmapModel? { didSet { setNeedsLayout(); setNeedsDisplay() } }

    private let legend = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(legend)

        legend.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(160)
            $0.height.equalTo(12)
        }
        buildLegend()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func buildLegend() {
        let colors: [UIColor] = [
            UIColor.neutral600, // 0회
            UIColor.primary700, // 1~4
            UIColor.primary600, // 5~8
            UIColor.primary400  // 9+
        ]
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 6
        legend.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
        for c in colors {
            let v = UIView()
            v.backgroundColor = c
            v.layer.cornerRadius = 2
            stack.addArrangedSubview(v)
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let model else { return }
        
        let topPadding: CGFloat = 12   // 헤더가 있으니 여유만
        let leftYearWidth: CGFloat = 36
        let hSpacing: CGFloat = 6
        let vSpacing: CGFloat = 6
        
        let rows = model.rows.count
        guard rows > 0 else { return }
        
        // 셀 사이즈 계산 (12개 월 고정)
        let availableWidth = rect.width - leftYearWidth - 24  // 좌측 연도 + 패딩
        let cellW = (availableWidth - 11 * hSpacing) / 12.0
        let cellH = max(cellW, 18)
        
        // 연도 라벨
        for (idx, row) in model.rows.enumerated() {
            let y = topPadding + CGFloat(idx) * (cellH + vSpacing)
            let label = UILabel(frame: .init(x: 12, y: y, width: leftYearWidth - 6, height: cellH))
            label.text = row.yearLabel
            label.textColor = .neutral200
            label.font = .systemFont(ofSize: 13, weight: .medium)
            addSubview(label)
            
            for month in 0..<12 {
                let x = 12 + leftYearWidth + CGFloat(month) * (cellW + hSpacing)
                let r = CGRect(x: x, y: y, width: cellW, height: cellH)
                let c = colorForCount(row.monthCounts[month])
                let path = UIBezierPath(roundedRect: r, cornerRadius: 4)
                c.setFill()
                path.fill()
            }
        }
    }
    
    private func colorForCount(_ count: Int) -> UIColor {
        switch count {
        case 0: return .neutral600
        case 1...4: return .primary700
        case 5...8: return .primary600
        default: return .primary400
        }
    }
}

// 3) 총 카운트 셀
private final class TotalCell: UICollectionViewCell {
    private let container = UIView()
    private let countBox = StatBoxView(title: "총 참여 횟수")
    private let expenseBox = StatBoxView(title: "총액")
    private let vStack = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(container)
        container.snp.makeConstraints { $0.edges.equalToSuperview() }
        vStack.axis = .vertical
        vStack.spacing = 12
        
        [countBox, expenseBox].forEach {
            $0.layer.cornerRadius = 12
            $0.backgroundColor = .neutral700
            $0.snp.makeConstraints { $0.height.greaterThanOrEqualTo(64) }
        }
        
        container.addSubview(vStack)
        vStack.snp.makeConstraints { $0.edges.equalToSuperview() }
        vStack.addArrangedSubview(countBox)
        vStack.addArrangedSubview(expenseBox)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(totalCount: Int, totalExpense: Double) {
        countBox.setValue("\(totalCount)")
        expenseBox.setValue(KRWFormatter.shared.string(totalExpense))
    }
}

private final class StatBoxView: UIView {
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        titleLabel.textColor = .neutral200
        valueLabel.font = .systemFont(ofSize: 28, weight: .bold)
        valueLabel.textColor = .neutral50
        
        addSubview(titleLabel)
        addSubview(valueLabel)
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(14)
        }
        valueLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.leading.trailing.bottom.equalToSuperview().inset(14)
        }
    }
    required init?(coder: NSCoder) { fatalError() }
    func setValue(_ text: String) { valueLabel.text = text }
}

// 4) Parent/Child 리스트 셀들

private final class RollupParentCell: UICollectionViewListCell {
    var onTap: (() -> Void)?
    private let dotView = UIView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setup() {
        var config = defaultContentConfiguration()
        config.text = nil
        contentConfiguration = config
        accessories = []
        
        let container = UIStackView()
        container.axis = .horizontal
        container.spacing = 12
        container.alignment = .center
        
        dotView.snp.makeConstraints { $0.size.equalTo(10) }
        dotView.layer.cornerRadius = 5
        
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .neutral50
        
        valueLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        valueLabel.textColor = .neutral50
        valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        chevron.tintColor = .neutral300
        chevron.snp.makeConstraints { $0.size.equalTo(14) }
        
        let h = UIStackView(arrangedSubviews: [dotView, titleLabel, UIView(), valueLabel, chevron])
        h.axis = .horizontal
        h.alignment = .center
        h.spacing = 10
        
        contentView.addSubview(h)
        h.snp.makeConstraints { $0.edges.equalToSuperview().inset(12) }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        contentView.addGestureRecognizer(tap)
    }
    
    func configure(title: String, valueText: String, leftDotColor: UIColor?, expanded: Bool) {
        titleLabel.text = title
        valueLabel.text = valueText
        if let c = leftDotColor {
            dotView.isHidden = false
            dotView.backgroundColor = c
        } else {
            dotView.isHidden = true
        }
        chevron.transform = expanded ? CGAffineTransform(rotationAngle: .pi) : .identity
    }
    
    @objc private func tapped() { onTap?() }
}

private final class RollupChildCell: UICollectionViewListCell {
    private let dotView = UIView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setup() {
        let h = UIStackView()
        h.axis = .horizontal
        h.spacing = 10
        h.alignment = .center
        
        dotView.snp.makeConstraints { $0.size.equalTo(8) }
        dotView.layer.cornerRadius = 4
        
        titleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        titleLabel.textColor = .neutral100
        
        valueLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        valueLabel.textColor = .neutral50
        
        [dotView, titleLabel, UIView(), valueLabel].forEach { h.addArrangedSubview($0) }
        contentView.addSubview(h)
        h.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 24, bottom: 6, right: 12)) }
        backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
    }
    
    func configure(title: String, valueText: String, leftDotColor: UIColor?) {
        titleLabel.text = title
        valueLabel.text = valueText
        if let c = leftDotColor {
            dotView.isHidden = false
            dotView.backgroundColor = c
        } else {
            dotView.isHidden = true
        }
    }
}

// 섹션 헤더 뷰
private final class StatsHeaderView: UICollectionReusableView {
    static let elementKind = UICollectionView.elementKindSectionHeader

    private let titleLabel = UILabel()
    private let trailingContainer = UIView() // Heatmap에서만 사용(레전드)

    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.font = .font17Semibold
        titleLabel.textColor = .neutral50

        addSubview(titleLabel)
        addSubview(trailingContainer)
        titleLabel.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview().inset(8)
        }
        trailingContainer.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(8)
            $0.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(8)
            $0.height.equalTo(12)
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, showLegend: Bool) {
        titleLabel.text = title
        trailingContainer.subviews.forEach { $0.removeFromSuperview() }
        trailingContainer.isHidden = !showLegend
        if showLegend {
            buildLegend(in: trailingContainer)
        }
    }

    private func buildLegend(in container: UIView) {
        let colors: [UIColor] = [.neutral600, .primary700, .primary600, .primary400]
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 6
        container.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
        colors.forEach { c in
            let v = UIView(); v.backgroundColor = c; v.layer.cornerRadius = 2
            stack.addArrangedSubview(v)
        }
    }
}

// 선택 델리게이트
extension StatsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        defer { collectionView.deselectItem(at: indexPath, animated: true) }
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        if case let .rollupParent(parent) = item {
            if expandedParents.contains(parent.id) {
                expandedParents.remove(parent.id)
            } else {
                expandedParents.insert(parent.id)
            }
            applySnapshot(animated: true)
        }
    }
}

// MARK: - Utilities

private final class KRWFormatter {
    static let shared = KRWFormatter()
    private let nf: NumberFormatter
    private init() {
        nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.groupingSeparator = ","
        nf.maximumFractionDigits = 0
    }
    func string(_ value: Double) -> String {
        let v = Int((value).rounded())
        return (nf.string(from: NSNumber(value: v)) ?? "\(v)") + " 원"
    }
}

private extension Array {
    subscript (safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// 헤더 타이틀 매핑
private extension StatsViewController {
    func headerTitle(for section: Section) -> String? {
        switch section {
        case .menuBar: return nil
        case .heatmap: return "참여 캘린더"
        case .total:   return nil
        case .categoryCount:   return "카테고리별 참여 횟수"
        case .categoryExpense: return "카테고리별 지출"
        case .artistCount:     return "아티스트별 참여 횟수"
        case .artistExpense:   return "아티스트별 지출"
        }
    }
}
