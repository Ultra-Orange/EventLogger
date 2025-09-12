//
//  StatsTitleCell.swift
//  EventLogger
//
//  Created by 정재성 on 9/4/25.
//

import SnapKit
import Then
import UIKit

// 섹션 헤더 뷰
final class StatsTitleCell: UICollectionViewCell {
    private let titleLabel = UILabel().then {
        $0.font = .font13Regular
        $0.textColor = .neutral50
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError() }

    func configure(title: String) {
        titleLabel.text = title
    }
}
