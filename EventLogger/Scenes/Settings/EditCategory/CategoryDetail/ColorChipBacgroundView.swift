//
//  ColorChipBacgroundView.swift
//  EventLogger
//
//  Created by Yoon on 9/3/25.
//

import UIKit

class ColorChipBacgroundView: UICollectionReusableView {
    static let identifier = "ColorChipBacgroundView"

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        backgroundColor = .neutral800
        layer.cornerRadius = 12
    }
}
