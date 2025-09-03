//
//  StatsRollupParentCell.swift
//  EventLogger
//
//  Created by 김우성 on 9/3/25.
//

import UIKit
import SnapKit

final class StatsRollupParentCell: UICollectionViewListCell {
    var onTap: (() -> Void)?
    private let dotView = UIView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setup() {
        var config = defaultContentConfiguration()
        config.text = nil
        contentConfiguration = config
        accessories = []
        
        let container = UIStackView()
        container.axis = .horizontal
        container.spacing = 12
        container.alignment = .center
        
        dotView.snp.makeConstraints { $0.size.equalTo(10) }
        dotView.layer.cornerRadius = 5
        
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .neutral50
        
        valueLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        valueLabel.textColor = .neutral50
        valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        chevron.tintColor = .neutral300
        chevron.snp.makeConstraints { $0.size.equalTo(14) }
        
        let h = UIStackView(arrangedSubviews: [dotView, titleLabel, UIView(), valueLabel, chevron])
        h.axis = .horizontal
        h.alignment = .center
        h.spacing = 10
        
        contentView.addSubview(h)
        h.snp.makeConstraints { $0.edges.equalToSuperview().inset(12) }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        contentView.addGestureRecognizer(tap)
    }
    
    func configure(title: String, valueText: String, leftDotColor: UIColor?, expanded: Bool) {
        titleLabel.text = title
        valueLabel.text = valueText
        if let c = leftDotColor {
            dotView.isHidden = false
            dotView.backgroundColor = c
        } else {
            dotView.isHidden = true
        }
        chevron.transform = expanded ? CGAffineTransform(rotationAngle: .pi) : .identity
    }
    
    @objc private func tapped() { onTap?() }
}
