//
//  CategoryEditCell.swift
//  EventLogger
//
//  Created by Yoon on 9/2/25.
//

import UIKit

import Then
import SnapKit

class CategoryEditCell: UICollectionViewListCell {
    private let colorMark = UIView().then {
        $0.layer.cornerRadius = 6
    }
    
    private let nameLabel = UILabel().then {
        $0.font = .font17Regular
        $0.textColor = .neutral50
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(colorMark)
        colorMark.snp.makeConstraints {
          $0.leading.equalToSuperview().inset(16)
          $0.centerY.equalToSuperview()
          $0.size.equalTo(12)
        }
        
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
          $0.leading.equalTo(colorMark.snp.trailing).offset(10)
          $0.trailing.equalToSuperview().inset(10)
          $0.top.bottom.equalToSuperview().inset(11)
        }
    }
    
    func configureCell(item: CategoryItem) {
        backgroundColor = .neutral800
        colorMark.backgroundColor = item.color
        nameLabel.text = item.name
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
