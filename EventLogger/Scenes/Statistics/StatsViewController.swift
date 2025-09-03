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

    // 컬렉션뷰는 화면에 그려질 "목록" 컴포넌트
    // 레이아웃은 아래 makeLayout()에서 정의
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout()).then {
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = true
    }

    // MARK: Diffable (스냅샷 기반의 안전한 데이터 갱신)
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
    }

    override func bind(reactor: StatsReactor) {
        // MARK: Input 바인딩 (사용자 입력 → Action)
        // 세그먼트 변경
        segmentedControl.rx.controlEvent(.valueChanged)
            .compactMap { [weak self] in Scope(rawValue: self?.segmentedControl.selectedIndex ?? 0) }
            .map { StatsReactor.Action.setScope($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 최초 진입
        Observable.just(())
            .map { StatsReactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // MARK: Output 바인딩 (State → UI 스냅샷)
        // 상태가 바뀌면 스냅샷을 다시 그린다.
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

    // Parent/Child(접고펼침) 공통 (UIKit 의존: 색상 포함 → VC에서만 사용)
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

// MARK: - 선택 델리게이트 (펼침/접힘)
extension StatsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        defer { collectionView.deselectItem(at: indexPath, animated: true) }
        guard let item = dataSource.itemIdentifier(for: indexPath),
              let reactor = reactor else { return }
        if case let .rollupParent(parent) = item {
            reactor.action.onNext(.toggleParent(parent.id))
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
