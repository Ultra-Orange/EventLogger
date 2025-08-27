//
//  LocationSearchSectionHeaderView.swift
//  EventLogger
//
//  Created by Yoon on 8/27/25.
//

import SnapKit
import Then
import UIKit

final class LocationSearchSectionHeaderView: UICollectionReusableView {
    let titleLabel = UILabel().then {
        $0.font = .font13Regular
        $0.textColor = .secondaryLabel
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }

    private func setupLayout() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.bottom.equalToSuperview()
        }
    }
}
