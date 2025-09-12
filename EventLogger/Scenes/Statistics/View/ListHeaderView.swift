//
//  ListHeaderView.swift
//  EventLogger
//
//  Created by 김우성 on 9/3/25.
//

import SnapKit
import Then
import UIKit

// 섹션 헤더 뷰
final class ListHeaderView: UICollectionReusableView {
    static let elementKind = UICollectionView.elementKindSectionHeader

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
    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, showLegend: Bool) {
        titleLabel.text = title
    }
}
