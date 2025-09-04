//
//  StatsTotalCountCell.swift
//  EventLogger
//
//  Created by 김우성 on 9/3/25.
//

import SnapKit
import Then
import UIKit

// 3) 총 카운트 셀
final class StatsTotalCountCell: UICollectionViewCell {
    private let countBox = StatBoxView(title: "총 참여 횟수").then {
        $0.layer.cornerRadius = 10
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        contentView.addSubview(countBox)
        countBox.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.greaterThanOrEqualTo(50)
        }
    }
    
    func configure(totalCount: Int) {
        countBox.setValue("\(totalCount)")
    }
}
