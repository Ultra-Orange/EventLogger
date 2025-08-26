//
//  UIImage++SymbolConfiguration.swift
//  EventLogger
//
//  Created by Yoon on 8/21/25.
//

import UIKit

// SF Symbol Config용 폰트 사이즈
extension UIImage.Configuration {
    static let font16Regular = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 16))
    static let font32Regular = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 32))
}

// 색이랑 함께 넣을 수 있는 static 함수
extension UIImage {
    static func SFSymbol(
        named name: String,
        config: UIImage.SymbolConfiguration,
        color: UIColor = .white
    ) -> UIImage? {
        return UIImage(systemName: name)?
            .withConfiguration(config)
            .withTintColor(color, renderingMode: .alwaysOriginal)
    }
    
    /*
     사용 예제
     private let mapPinIcon = UIImageView(image: UIImage.SFSymbol(named: "mappin.and.ellipse", config: .font16Regular))
     */
}
