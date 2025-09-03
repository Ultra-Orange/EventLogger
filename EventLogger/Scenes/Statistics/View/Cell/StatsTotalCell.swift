//
//  StatsTotalCell.swift
//  EventLogger
//
//  Created by 김우성 on 9/3/25.
//

import UIKit
import SnapKit
import Then

// 3) 총 카운트 셀
final class StatsTotalCell: UICollectionViewCell {
    private let container = UIView()
    private let countBox = StatBoxView(title: "총 참여 횟수")
    private let expenseBox = StatBoxView(title: "총액")
    private let vStack = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(container)
        container.snp.makeConstraints { $0.edges.equalToSuperview() }
        vStack.axis = .vertical
        vStack.spacing = 12
        
        [countBox, expenseBox].forEach {
            $0.layer.cornerRadius = 12
            $0.backgroundColor = .neutral700
            $0.snp.makeConstraints { $0.height.greaterThanOrEqualTo(64) }
        }
        
        container.addSubview(vStack)
        vStack.snp.makeConstraints { $0.edges.equalToSuperview() }
        vStack.addArrangedSubview(countBox)
        vStack.addArrangedSubview(expenseBox)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(totalCount: Int, totalExpense: Double) {
        countBox.setValue("\(totalCount)")
        expenseBox.setValue(KRWFormatter.shared.string(totalExpense))
    }
}
