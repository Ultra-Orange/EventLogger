//
//  StatsRollupParentCell.swift
//  EventLogger
//
//  Created by 김우성 on 9/3/25.
//

import UIKit
import SnapKit

final class StatsRollupParentCell: UICollectionViewListCell {
    
    private let dotView = UIView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        var config = defaultContentConfiguration()
        config.text = nil
        contentConfiguration = config
        accessories = []
        
        dotView.snp.makeConstraints { $0.size.equalTo(10) }
        dotView.layer.cornerRadius = 5
        
        titleLabel.font = .font17Regular
        titleLabel.textColor = .neutral50
        
        valueLabel.font = .font17Regular
        valueLabel.textColor = .neutral50
        valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        let horizontalStack = UIStackView(arrangedSubviews: [dotView, titleLabel, UIView(), valueLabel]).then {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.spacing = 10
        }
        
        contentView.addSubview(horizontalStack)
        horizontalStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(12) }
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
