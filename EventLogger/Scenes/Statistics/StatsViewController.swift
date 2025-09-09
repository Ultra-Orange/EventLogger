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
import CoreData

// MARK: - StatsViewController

final class StatsViewController: BaseViewController<StatsReactor> {

    @Dependency(\.swiftDataManager) var swiftDataManager
    lazy var statisticsService = StatisticsService(manager: swiftDataManager)

    private let backgroundGradientView = GradientBackgroundView()

    private let segmentedControl = PillSegmentedControl(items: ["연도별", "월별", "전체"])

    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout()).then {
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = true
        $0.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    private let emptyView = UIView().then {
        $0.backgroundColor = .clear
    }

    private let emptyStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = 10
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    private let emptyTitleLabel = UILabel().then {
        $0.text = "보여드릴 통계가 없어요"
        $0.textColor = .neutral50
        $0.font = .font20Bold
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }

    private let emptyValueLabel = UILabel().then {
        $0.text = "일정을 등록하면 통계를 보여드릴 수 있어요"
        $0.textColor = .neutral50
        $0.font = .font17Regular
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    let notification = NSPersistentCloudKitContainer.eventChangedNotification

    // MARK: Diffable
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

    // 어떤 부모가 펼쳐져 있는지 추적
    var expandedParentIDs = Set<UUID>()
    
    // parentId -> 자식들 캐시 (스냅샷 생성 시 계산 / 토글 시 삽입·삭제에 재사용)
    var childrenCache: [UUID: [RollupChild]] = [:]
    
    // 스냅샷 재구성 시 캐시 초기화
    func resetRollupCaches() {
        expandedParentIDs.removeAll()
        childrenCache.removeAll()
    }

    
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
        collectionView.backgroundView = emptyView
        emptyView.isHidden = true
        collectionView.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        setupEmptyView()

        configureDataSource()
        collectionView.delegate = self // 셀 탭 감지를 위해 델리게이트 설정
    }
    
    private func setupEmptyView() {
        emptyView.addSubview(emptyStackView)
        emptyStackView.addArrangedSubview(emptyTitleLabel)
        emptyStackView.addArrangedSubview(emptyValueLabel)
        
        emptyStackView.snp.makeConstraints {
            $0.center.equalTo(view.safeAreaLayoutGuide)
        }
    }

    override func bind(reactor: StatsReactor) {
        // Input
        segmentedControl.rx.selectedSegmentIndex
            .compactMap { Scope(rawValue: $0) }
            .map { .setScope($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        Observable.merge(
            rx.viewDidLoad.map{ _ in },
            NotificationCenter.default.rx.notification(notification).map{ _ in }
        )
        .map { _ in .refresh }
        .bind(to: reactor.action)
        .disposed(by: disposeBag)

        // Output
        reactor.state
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.applySnapshot(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Models (UI 전용 뷰모델)
extension StatsViewController {
    struct TotalModel: Hashable {
        let totalCount: Int
        let totalExpense: Double
    }

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
        case .heatmapHeader: return "참여 캘린더"
        case .heatmap: return nil
        case .totalCount:   return nil
        case .totalExpense:   return nil
        case .categoryCount:   return "카테고리별 참여 횟수"
        case .categoryExpense: return "카테고리별 지출"
        case .artistCount:     return "아티스트별 참여 횟수"
        case .artistExpense:   return "아티스트별 지출"
        default: return nil
        }
    }
}
