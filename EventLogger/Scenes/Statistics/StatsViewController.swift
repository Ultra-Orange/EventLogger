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

enum StatsSection: Hashable {
    
}

enum StatsItem: Hashable {
    
}

final class StatsViewController: BaseViewController<StatsReactor> {
    private let backgroundGradientView = GradientBackgroundView()
    
    // EventList뷰컨트롤러의 것과 같은 구성
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
    
//    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout()).then {
//        $0.backgroundColor = .neutral800
//        $0.showsVerticalScrollIndicator = true
//    }
    
    private var dataSource: UICollectionViewDiffableDataSource<StatsSection, StatsItem>!
        
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
    }
    
    override func bind(reactor: StatsReactor) {
        
    }
}

//private extension StatsViewController {
//    func makeLayout() -> UICollectionViewLayout {
//        }
//    }
//}
//
//private extension StatsViewController {
//    func makeDataSource() {
//        
//    }
//}
