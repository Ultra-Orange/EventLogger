//
//  StatsMenuBarCell.swift
//  EventLogger
//
//  Created by 김우성 on 9/3/25.
//

import UIKit
import SnapKit

enum Scope: Int {
    case year   // 연도별
    case month  // 월별
    case all    // 전체
}

// 1) UIMenu 버튼 섹션 셀
final class StatsMenuBarCell: UICollectionViewCell {
    private let container = UIView()
    private let yearButton = UIButton(type: .system)
    private let monthButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(container)
        container.snp.makeConstraints { $0.edges.equalToSuperview() }
        container.addSubview(yearButton)
        container.addSubview(monthButton)
        monthButton.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
            $0.height.equalTo(26)
        }
        yearButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(monthButton.snp.leading).offset(-8)
            $0.height.equalTo(26)
        }
        yearButton.setTitleColor(.neutral50, for: .normal)
        monthButton.setTitleColor(.neutral50, for: .normal)
        yearButton.backgroundColor = .neutral700
        monthButton.backgroundColor = .neutral700
        yearButton.layer.cornerRadius = 13
        monthButton.layer.cornerRadius = 13
    }
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(
        scope: Scope,
        yearProvider: () -> [String],
        selectedYear: Int?,
        selectedMonth: Int?,
        onYearPicked: @escaping (Int) -> Void,
        onMonthPicked: @escaping (Int) -> Void
    ) {
        let years = yearProvider()
        let yearTitle = (selectedYear != nil) ? "\(selectedYear!)년" : "연도"
        yearButton.setTitle(yearTitle, for: .normal)
        let yearActions = years.compactMap { Int($0) }.map { y in
            UIAction(title: "\(y)년") { _ in onYearPicked(y) }
        }
        yearButton.menu = UIMenu(children: yearActions)
        yearButton.showsMenuAsPrimaryAction = true
        
        switch scope {
        case .year:
            // 월 버튼 숨김, 연도만
            monthButton.isHidden = true
        case .month:
            monthButton.isHidden = false
            let m = selectedMonth ?? 1
            monthButton.setTitle("\(m)월", for: .normal)
            let months = (1...12).map { month in
                UIAction(title: "\(month)월") { _ in onMonthPicked(month) }
            }
            monthButton.menu = UIMenu(children: months)
            monthButton.showsMenuAsPrimaryAction = true
        case .all:
            // 이 셀 자체가 안 보이는 섹션이므로 신경 X
            monthButton.isHidden = true
        }
    }
}
