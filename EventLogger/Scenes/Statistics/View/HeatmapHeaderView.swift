//
//  HeatmapHeaderView.swift
//  EventLogger
//
//  Created by 김우성 on 9/4/25.
//

import SnapKit
import UIKit
import Then

// 섹션 헤더 뷰
final class HeatmapHeaderView: UICollectionReusableView {
    static let elementKind = "HeatmapHeaderElementKind"

    private let titleLabel = UILabel().then {
        $0.font = .font17Semibold
        $0.textColor = .neutral50
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.trailing.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, showLegend: Bool) {
        titleLabel.text = title
    }
}
