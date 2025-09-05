//
//  HeatmapHeaderCell.swift
//  EventLogger
//
//  Created by 김우성 on 9/4/25.
//

import SnapKit
import UIKit
import Then

// 섹션 헤더 뷰
final class HeatmapHeaderCell: UICollectionViewCell {

    private let titleLabel = UILabel().then {
        $0.font = .font17Semibold
        $0.textColor = .neutral50
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String) {
        titleLabel.text = title
    }
}
