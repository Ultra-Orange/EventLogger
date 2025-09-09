//
//  GradientBackgroundView.swift
//  EventLogger
//
//  Created by 김우성 on 8/29/25.
//

import UIKit

final class GradientBackgroundView: UIView {
    private let gradient = CAGradientLayer()
    
    var colors: [UIColor] = [
        UIColor(white: 0.084, alpha: 0.0),
        UIColor(red: 0.569, green: 0.235, blue: 0.011, alpha: 1.0)
    ] {
        didSet { updateGradient() }
    }
    
    /// 0.0~1.0
    var locations: [NSNumber] = [0, 1] {
        didSet { gradient.locations = locations }
    }
    
    /// 그라데이션 방향 (기본: 위→아래)
    var direction: (start: CGPoint, end: CGPoint) = (CGPoint(x: 0.5, y: 0.0),
                                                     CGPoint(x: 0.5, y: 1.0))
    {
        didSet {
            gradient.startPoint = direction.start
            gradient.endPoint = direction.end
        }
    }
    
    override class var layerClass: AnyClass { CAGradientLayer.self }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // 만약 layerClass를 쓰면 gradient = self.layer as! CAGradientLayer 로 바로 접근 가능
        if let g = layer as? CAGradientLayer {
            gradient.colors = nil // dummy, 곧 updateGradient에서 세팅
        } else {
            layer.addSublayer(gradient)
        }
        isUserInteractionEnabled = false // 배경이므로 이벤트 막지 않게
        updateGradient()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // layerClass를 썼으면 frame 세팅 불필요. 하위 레이어일 경우에만 필요.
        if gradient.superlayer == layer { return } // layerClass 사용 중
        gradient.frame = bounds.insetBy(dx: -bounds.width * 0.5, dy: -bounds.height * 0.5) // 피그마식 확장 필요 시
        gradient.position = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    private func updateGradient() {
        let cgColors = colors.map { $0.cgColor }
        if let gradientLayer = layer as? CAGradientLayer {
            gradientLayer.colors = cgColors
            gradientLayer.locations = locations
            gradientLayer.startPoint = direction.start
            gradientLayer.endPoint = direction.end
        } else {
            gradient.colors = cgColors
            gradient.locations = locations
            gradient.startPoint = direction.start
            gradient.endPoint = direction.end
        }
        // 다크/라이트 전환에 대비
        setNeedsDisplay()
    }
}
