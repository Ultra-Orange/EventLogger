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
    
    lazy var statisticsService = StatisticsService(manager: swiftDataManager)
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
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout()).then {
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = true
    }
    
    // MARK: - View State
    
    var currentScope: Scope = .year     // 기본: 연도별
    var selectedYear: Int?              // year / month scope에서 사용
    var selectedMonth: Int?             // month scope에서 사용 (1~12)
    
    var expandedParents: Set<UUID> = [] // 폴딩 리스트 상태
    
    // MARK: Diffable
    
    enum StatsSection: Hashable {
        case menuBar                    // UIMenu 버튼 (연/월 선택)
        case heatmap                    // 참여 캘린더 (전체에서만)
        case total                      // 총 카운트
        case categoryCount              // 카테고리별 참여 횟수
        case categoryExpense            // 카테고리별 지출
        case artistCount                // 아티스트별 참여 횟수
        case artistExpense              // 아티스트별 지출
    }
    
    enum StatsItem: Hashable {
        case menu(UUID)                 // 내용은 셀에서 구성
        case heatmap(HeatmapModel)
        case total(TotalModel)
        case rollupParent(RollupParent)
        case rollupChild(RollupChild)   // parent 아래 상세
    }
    
    var dataSource: UICollectionViewDiffableDataSource<StatsSection, StatsItem>!
    
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
        
    }
}

// MARK: - Models

extension StatsViewController {
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

// 히트맵 생성
extension StatsViewController {
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

final class KRWFormatter {
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
extension StatsViewController {
    func headerTitle(for section: StatsSection) -> String? {
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
