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
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
