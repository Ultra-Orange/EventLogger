//
//  StatsTotalExpenseCell.swift
//  EventLogger
//
//  Created by 김우성 on 9/4/25.
//

import SnapKit
import Then
import UIKit

// 3) 총 카운트 셀
final class StatsTotalExpenseCell: UICollectionViewCell {
    private let expenseBox = StatBoxView(title: "총액").then {
        $0.layer.cornerRadius = 10
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        contentView.addSubview(expenseBox)
        
        expenseBox.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(50)
        }
    }
    
    func configure(totalCount: Int, totalExpense: Double) {
        expenseBox.setValue(KRWFormatter.shared.string(totalExpense))
    }
}
