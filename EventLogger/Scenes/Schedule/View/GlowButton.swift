//
//  GlowButton.swift
//  EventLogger
//
//  Created by 김우성 on 9/4/25.
//

import UIKit

/// Figma 스타일의 글로우 버튼 (cornerRadius 12, 다크배경, 오렌지 보더 + 글로우)
final class GlowButton: UIButton {

    // MARK: - Color Palette (Figma 값 그대로)
    private struct Palette {
        // Shadow & Glow (오렌지)
        static let glow = UIColor(red: 0.961, green: 0.397, blue: 0.019, alpha: 1.0)   // #F56630 정도
        // Border (밝은 오렌지)
        static let border = UIColor(red: 0.988, green: 0.631, blue: 0.392, alpha: 1.0) // #FCA168 정도
        // Background (다크)
        static let background = UIColor(red: 0.084, green: 0.084, blue: 0.084, alpha: 1.0) // 거의 #151515
        // Title
        static let title = UIColor(red: 0.992, green: 0.75, blue: 0.588, alpha: 1.0)  // #FDC09`;
        // Disabled
        static let disabledBg = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)
        static let disabledBorder = UIColor(white: 1.0, alpha: 0.15)
        static let disabledTitle = UIColor(white: 1.0, alpha: 0.35)
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    convenience init(title: String) {
        self.init(frame: .zero)
        setTitle(title, for: .normal)
    }

    private func commonInit() {
        clipsToBounds = false // 그림자 보이도록
        layer.cornerRadius = 12
        layer.borderWidth = 1
        contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)

        // 타이틀 스타일 (SF Pro 세미볼드 17, 없으면 시스템 대체)
        let font = UIFont.font17Semibold
        titleLabel?.font = font
        setTitleColor(Palette.title, for: .normal)

        applyCurrentStyle()
    }

    // 상태 변화 시 스타일 갱신
    override var isEnabled: Bool {
        didSet { applyCurrentStyle() }
    }

    override var isHighlighted: Bool {
        didSet { applyCurrentStyle() }
    }

    // MARK: - Styling
    private func applyCurrentStyle() {
        // 배경
        backgroundColor = isEnabled ? Palette.background : Palette.disabledBg

        // 보더
        layer.borderColor = (isEnabled ? Palette.border : Palette.disabledBorder).cgColor

        // 텍스트 컬러
        setTitleColor(isEnabled ? Palette.title : Palette.disabledTitle, for: .normal)

        // 그림자(글로우)
        if isEnabled {
            // Highlight 시 살짝 강하게
            let strength: CGFloat = isHighlighted ? 1.15 : 1.0
            layer.shadowColor = Palette.glow.cgColor
            layer.shadowOpacity = Float(1.0 * strength)
            layer.shadowRadius = 15 * strength
            layer.shadowOffset = .zero
            layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
        } else {
            // Disabled: 글로우 제거
            layer.shadowOpacity = 0
            layer.shadowRadius = 0
            layer.shadowPath = nil
        }
    }

    // 오토레이아웃으로 크기 변경 시 shadowPath 갱신
    override func layoutSubviews() {
        super.layoutSubviews()
        if isEnabled {
            layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
        }
    }
}
