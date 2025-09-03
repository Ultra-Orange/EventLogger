//
//  StatsTotalCell.swift
//  EventLogger
//
//  Created by 김우성 on 9/3/25.
//

import SnapKit
import Then
import UIKit

// 3) 총 카운트 셀
final class StatsTotalCell: UICollectionViewCell {
    private let vStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 20
    }
    
    private let countBox = StatBoxView(title: "총 참여 횟수").then {
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .neutral800 // 그라데이션으로 수정 필요
    }
    
    private let expenseBox = StatBoxView(title: "총액").then {
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .neutral800 // 그라데이션으로 수정 필요
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        contentView.addSubview(vStack)
        vStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        vStack.addArrangedSubview(countBox)
        vStack.addArrangedSubview(expenseBox)
        
        countBox.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(50)
        }
        
        expenseBox.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(50)
        }
    }
    
    func configure(totalCount: Int, totalExpense: Double) {
        countBox.setValue("\(totalCount)")
        expenseBox.setValue(KRWFormatter.shared.string(totalExpense))
    }
}
