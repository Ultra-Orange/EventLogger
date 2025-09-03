//
//  StatsFooterView.swift
//  EventLogger
//
//  Created by 김우성 on 9/3/25.
//
//
//import SnapKit
//import UIKit
//
//// 섹션 헤더 뷰
//final class StatsHeaderView: UICollectionReusableView {
//    static let elementKind = UICollectionView.elementKindSectionHeader
//
//    private let titleLabel = UILabel()
////    private let trailingContainer = UIView() // Heatmap에서만 사용
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        titleLabel.font = .font13Regular
//        titleLabel.textColor = .neutral50
//
//        addSubview(titleLabel)
//        titleLabel.snp.makeConstraints {
//            $0.top.equalToSuperview().inset(8)
//            $0.leading.trailing.equalToSuperview().inset(16)
//        }
//        
////        addSubview(trailingContainer)
////
////        trailingContainer.snp.makeConstraints {
////            $0.centerY.equalTo(titleLabel)
////            $0.trailing.equalToSuperview().inset(8)
////            $0.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(8)
////            $0.height.equalTo(12)
////        }
//    }
//
//    @available(*, unavailable)
//    required init?(coder: NSCoder) { fatalError() }
//
//    func configure(title: String, showLegend: Bool) {
//        titleLabel.text = title
////        trailingContainer.subviews.forEach { $0.removeFromSuperview() }
////        trailingContainer.isHidden = !showLegend
////        if showLegend {
////            buildLegend(in: trailingContainer)
////        }
//    }
//
//    private func buildLegend(in container: UIView) {
//        let colors: [UIColor] = [.neutral600, .primary700, .primary600, .primary400]
//        let stack = UIStackView()
//        stack.axis = .horizontal
//        stack.alignment = .fill
//        stack.distribution = .fillEqually
//        stack.spacing = 6
//        container.addSubview(stack)
//        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
//        for c in colors {
//            let v = UIView(); v.backgroundColor = c; v.layer.cornerRadius = 2
//            stack.addArrangedSubview(v)
//        }
//    }
//}
