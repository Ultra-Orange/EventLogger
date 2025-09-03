//
//  StatsRollupChildCell.swift
//  EventLogger
//
//  Created by 김우성 on 9/3/25.
//

import UIKit
import SnapKit

final class StatsRollupChildCell: UICollectionViewListCell {
    private let dotView = UIView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setup() {
        let horizontalStack = UIStackView().then {
            $0.axis = .horizontal
            $0.spacing = 10
            $0.alignment = .center
        }
        
        dotView.snp.makeConstraints { $0.size.equalTo(8) }
        dotView.layer.cornerRadius = 4
        
        titleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        titleLabel.textColor = .neutral100
        
        valueLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        valueLabel.textColor = .neutral50
        
        [dotView, titleLabel, UIView(), valueLabel].forEach { horizontalStack.addArrangedSubview($0) }
        contentView.addSubview(horizontalStack)
        horizontalStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 24, bottom: 6, right: 12)) }
        backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
    }
    
    func configure(title: String, valueText: String, leftDotColor: UIColor?) {
        titleLabel.text = title
        valueLabel.text = valueText
        if let color = leftDotColor {
            dotView.isHidden = false
            dotView.backgroundColor = color
        } else {
            dotView.isHidden = true
        }
    }
}
