//
//  UIFont++.swift
//  EventLogger
//
//  Created by 김우성 on 8/21/25.
//

import UIKit

extension UIFont {
    
    static var caption1Medium: UIFont {
        let baseSize = UIFont.preferredFont(forTextStyle: .caption1).pointSize
        let systemFont = UIFont.systemFont(ofSize: baseSize, weight: .medium)
        return UIFontMetrics(forTextStyle: .caption1).scaledFont(for: systemFont)
    }
    
    static var title3Bold: UIFont {
        let baseSize = UIFont.preferredFont(forTextStyle: .title3).pointSize
        let systemFont = UIFont.systemFont(ofSize: baseSize, weight: .bold)
        return UIFontMetrics(forTextStyle: .caption1).scaledFont(for: systemFont)
    }
    
    /*  사용법
    let label = UILabel()
    label.font = .caption1Medium
    label.adjustsFontForContentSizeCategory = true
    */
    
    /* 다이나믹 타입쓰면 안씀
    // 타이틀 1, 2, 3
    static let largeTitle = UIFont.systemFont(ofSize: 28, weight: .regular)
    static let mediumTitle = UIFont.systemFont(ofSize: 22, weight: .regular)
    static let smallTitle = UIFont.systemFont(ofSize: 20, weight: .regular)
    
    // 본문 등 용도
    static let headline = UIFont.systemFont(ofSize: 17, weight: .semibold)
    static let body = UIFont.systemFont(ofSize: 17, weight: .regular)
    static let callout = UIFont.systemFont(ofSize: 16, weight: .regular)
    static let subhead = UIFont.systemFont(ofSize: 15, weight: .regular)
    static let footnote = UIFont.systemFont(ofSize: 13, weight: .regular)
    */
}


