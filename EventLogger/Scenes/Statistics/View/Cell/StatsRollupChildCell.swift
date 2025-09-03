//
//  StatsRollupChildCell.swift
//  EventLogger
//
//  Created by 김우성 on 9/3/25.
//

import SnapKit
import UIKit

final class StatsRollupChildCell: UICollectionViewListCell {
    private let dotView = UIView().then {
        $0.layer.cornerRadius = 4
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .font13Regular
        $0.textColor = .neutral50
    }
    
    private let valueLabel = UILabel().then {
        $0.font = .font13Regular
        $0.textColor = .neutral50
    }
    
    private let horizontalStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10
        $0.alignment = .center
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupUI() {
        dotView.snp.makeConstraints {
            $0.size.equalTo(8)
        }
        contentView.addSubview(horizontalStack)
        
        horizontalStack.addArrangedSubview(dotView)
        horizontalStack.addArrangedSubview(titleLabel)
        horizontalStack.addArrangedSubview(UIView())
        horizontalStack.addArrangedSubview(valueLabel)
        
        horizontalStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 24, bottom: 6, right: 12))
        }
        
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

#Preview {
    let cell = StatsRollupChildCell()
    cell.configure(title: "페스티벌", valueText: "1회", leftDotColor: .appBlue)
    return cell
}
