//
//  UIImage++SymbolConfiguration.swift
//  EventLogger
//
//  Created by Yoon on 8/21/25.
//

import UIKit

extension UIImage.Configuration {
    // SF Symbol Callout에 맞추기
    static let callout = UIImage.SymbolConfiguration(font: .preferredFont(forTextStyle: .callout))
    static let footnote = UIImage.SymbolConfiguration(font: .preferredFont(forTextStyle: .footnote))
    static let addImageIcon = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 32))
}
