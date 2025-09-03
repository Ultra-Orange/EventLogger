//
//  StatsFooterView.swift
//  EventLogger
//
//  Created by 김우성 on 9/3/25.
//
//
import SnapKit
import UIKit

// 섹션 헤더 뷰
final class HeatmapFooterView: UICollectionReusableView {
    static let elementKind = UICollectionView.elementKindSectionFooter

    private let trailingContainer = UIView() // Heatmap에서만 사용

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(trailingContainer)

        trailingContainer.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        buildLegend()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, showLegend: Bool) {
//        trailingContainer.subviews.forEach { $0.removeFromSuperview() }
//        trailingContainer.isHidden = !showLegend
//        if showLegend {
//            buildLegend(in: trailingContainer)
//        }
    }

    private func buildLegend() {
        let colors: [UIColor] = [
            UIColor.neutral700, // 0회
            UIColor.primary200, // 1~4
            UIColor.primary300, // 5~8
            UIColor.primary500 // 9+
        ]
        
        let stack = UIStackView().then {
            $0.axis = .horizontal
            $0.alignment = .fill
            $0.distribution = .fillEqually
            $0.spacing = 6
        }
        
        trailingContainer.addSubview(stack)
        stack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        for color in colors {
            let view = UIView()
            view.backgroundColor = color
            view.layer.cornerRadius = 2
            stack.addArrangedSubview(view)
        }
    }
}
