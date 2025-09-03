//
//  ColorChipCell.swift
//  EventLogger
//
//  Created by Yoon on 9/2/25.
//

import SnapKit
import Then
import UIKit

final class ColorChipCell: UICollectionViewCell {
    private let circleView = UIView().then {
        $0.layer.borderColor = UIColor.neutral50.cgColor
        $0.layer.shadowColor = UIColor(white: 0.98, alpha: 1).cgColor
        $0.layer.shadowRadius = 8
        $0.layer.shadowOffset = .zero
    }

    override var isSelected: Bool {
        didSet {
            circleView.layer.borderWidth = isSelected ? 2 : 0
            circleView.layer.shadowOpacity = isSelected ? 1 : 0.0
        }
    }

    var color: UIColor? {
        get { circleView.backgroundColor }
        set { circleView.backgroundColor = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(circleView)
    }

    // 원형 라디우스
    override func layoutSubviews() {
        super.layoutSubviews()
        circleView.frame = contentView.bounds
        circleView.layer.cornerRadius = min(contentView.bounds.width, contentView.bounds.height) * 0.5
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
