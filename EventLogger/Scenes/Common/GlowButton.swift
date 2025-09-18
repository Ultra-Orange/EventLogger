//
//  GlowButton.swift
//  EventLogger
//
//  Created by 김우성 on 9/4/25.
//

import UIKit

final class GlowButton: UIButton {
    // MARK: - Color Palette (Figma 값 그대로)

    private enum Palette {
        static let glow = UIColor(red: 0.961, green: 0.397, blue: 0.019, alpha: 1.0)
        static let border = UIColor(red: 0.988, green: 0.631, blue: 0.392, alpha: 1.0)
        static let background = UIColor(red: 0.084, green: 0.084, blue: 0.084, alpha: 1.0)
        static let title = UIColor(red: 0.992, green: 0.75, blue: 0.588, alpha: 1.0)
        static let disabledBg = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)
        static let disabledBorder = UIColor(white: 1.0, alpha: 0.15)
        static let disabledTitle = UIColor(white: 1.0, alpha: 0.35)
    }

    // MARK: - Init

    convenience init(title: String? = nil) {
        self.init(frame: .zero)
        setTitle(title, for: .normal)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        clipsToBounds = false
        layer.cornerRadius = 12

        // UIButton.Configuration을 사용한 스타일 설정
        var config = UIButton.Configuration.filled()
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
        config.background.cornerRadius = 12

        // 타이틀 스타일
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.font17Semibold // 기존 폰트 사용
            return outgoing
        }

        configuration = config

        // 상태 변화에 따라 스타일을 업데이트하는 핸들러
        configurationUpdateHandler = { [weak self] button in
            guard let self = self else { return }
            var updatedConfig = button.configuration

            let isEnabled = button.state.contains(.disabled) == false

            // 배경색, 보더
            updatedConfig?.baseBackgroundColor = isEnabled ? Palette.background : Palette.disabledBg
            updatedConfig?.background.strokeColor = isEnabled ? Palette.border : Palette.disabledBorder
            updatedConfig?.background.strokeWidth = 1.0

            // 타이틀 색상
            updatedConfig?.baseForegroundColor = isEnabled ? Palette.title : Palette.disabledTitle

            button.configuration = updatedConfig

            // 그림자(글로우) 로직
            self.updateGlow(isEnabled: isEnabled, isHighlighted: button.isHighlighted)
        }
    }

    private func updateGlow(isEnabled: Bool, isHighlighted: Bool) {
        if isEnabled {
            let strength: CGFloat = isHighlighted ? 1.15 : 1.0
            layer.shadowColor = Palette.glow.cgColor
            layer.shadowOpacity = Float(1.0 * strength)
            layer.shadowRadius = 15 * strength
            layer.shadowOffset = .zero
            layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
        } else {
            layer.shadowOpacity = 0
            layer.shadowRadius = 0
            layer.shadowPath = nil
        }
    }

    // 오토레이아웃으로 크기 변경 시 shadowPath 갱신
    override func layoutSubviews() {
        super.layoutSubviews()
        if isEnabled {
            updateGlow(isEnabled: true, isHighlighted: isHighlighted)
        }
    }
}
