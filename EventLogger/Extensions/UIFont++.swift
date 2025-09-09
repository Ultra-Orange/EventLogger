//
//  UIFont++.swift
//  EventLogger
//
//  Created by 김우성 on 8/21/25.
//

import UIKit

/// UIFont 확장 사용법
/// let label = UILabel()
/// label.font = .font16Regular

extension UIFont {
    static let font28Bold = UIFont.systemFont(ofSize: 28, weight: .bold)
    
    static let font20Bold = UIFont.systemFont(ofSize: 20, weight: .bold)
    static let font20Semibold = UIFont.systemFont(ofSize: 20, weight: .semibold)
    
    static let font17Bold = UIFont.systemFont(ofSize: 17, weight: .bold)
    static let font17Semibold = UIFont.systemFont(ofSize: 17, weight: .semibold)
    static let font17Regular = UIFont.systemFont(ofSize: 17, weight: .regular)
    
    static let font16Regular = UIFont.systemFont(ofSize: 16, weight: .regular)
    
    static let font14Regular = UIFont.systemFont(ofSize: 14, weight: .regular)
    
    static let font13Regular = UIFont.systemFont(ofSize: 13, weight: .regular)
    
    static let font12Medium = UIFont.systemFont(ofSize: 12, weight: .medium)
    static let font12Regular = UIFont.systemFont(ofSize: 12, weight: .regular)
    
    static let font11Regular = UIFont.systemFont(ofSize: 11, weight: .regular)
}
