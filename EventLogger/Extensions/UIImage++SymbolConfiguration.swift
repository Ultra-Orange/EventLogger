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
/*
 사용 예제
 private let mapPinIcon = UIImageView(image: UIImage.SFSymbol(named: "mappin.and.ellipse", config: .font16Regular))
 */

// 색이랑 함께 넣을 수 있는 static 함수
extension UIImage {
    // SF심볼 디폴트
    static func symbolDefault(
        named name: String,
        config: UIImage.SymbolConfiguration,
        color: UIColor = .neutral50 // TODO: App Primary
    ) -> UIImage? {
        return UIImage(systemName: name)?
            .withConfiguration(config)
            .withTintColor(color, renderingMode: .alwaysOriginal)
    }
    
    // 취소버튼 용 config
    static func symbolXCircleFill(
        config: UIImage.SymbolConfiguration,
        color: UIColor = .secondaryLabel // TODO: color조정
    ) -> UIImage? {
        return UIImage(systemName: "x.circle.fill")?
            .withConfiguration(config)
            .withTintColor(color, renderingMode: .alwaysOriginal)
    }
    
    // 카테고리 색 점 아이콘 생성 유틸
    static func circle(diameter: CGFloat, color: UIColor) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: .init(width: diameter, height: diameter), format: format)
        return renderer.image { _ in
            let rect = CGRect(origin: .zero, size: .init(width: diameter, height: diameter))
            color.setFill()
            UIBezierPath(ovalIn: rect).fill()
        }.withRenderingMode(.alwaysOriginal)
    }
}
