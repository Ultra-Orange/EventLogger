//
//  StatsRollupParentCell.swift
//  EventLogger
//
//  Created by 김우성 on 9/3/25.
//

import UIKit
import SnapKit
import Then

final class StatsRollupParentCell: UICollectionViewListCell {
    private let dotView = UIView().then {
        $0.layer.cornerRadius = 8
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .font17Regular
        $0.textColor = .neutral50
    }
    
    private let valueLabel = UILabel().then {
        $0.font = .font17Regular
        $0.textColor = .neutral50
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private let horizontalStack = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 8
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupUI() {
        var config = defaultContentConfiguration()
        config.text = nil
        contentConfiguration = config
        accessories = []
        
        dotView.snp.makeConstraints {
            $0.size.equalTo(16)
        }
        
        horizontalStack.addArrangedSubview(dotView)
        horizontalStack.addArrangedSubview(titleLabel)
        horizontalStack.addArrangedSubview(UIView())
        horizontalStack.addArrangedSubview(valueLabel)
        
        contentView.addSubview(horizontalStack)
        horizontalStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }
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
