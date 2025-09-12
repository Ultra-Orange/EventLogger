
import UIKit

extension UIButton {
    /// DateRangeField 버튼들 생김새 통합 설정
    static func makeDateButton() -> UIButton {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.bordered()
        config.contentInsets = .init(top: 2, leading: 8, bottom: 2, trailing: 8)
        config.background.cornerRadius = 6
        config.baseForegroundColor = .neutral50
        config.background.backgroundColor = .systemGray3
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .font17Regular
            return outgoing
        }
        button.configuration = config
        button.configurationUpdateHandler = { button in
            var config = button.configuration ?? .bordered()
            let isOn = button.isSelected
            config.baseForegroundColor = isOn ? .primary500 : .neutral50
            button.configuration = config
        }
        return button
    }

    // EventList용 우하단 추가 버튼 메이커
    static func makeAddButton() -> UIButton {
        let button = UIButton(configuration: .addButton)
        button.layer.shadowColor = UIColor.primary500.cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 10
        button.layer.shadowOffset = .zero
        button.layer.masksToBounds = false
        button.clipsToBounds = false
        return button
    }
}

extension UIButton.Configuration {
    //     사용부
    //    private let button = UIButton(configuration: .closed)

    // 기본 버튼
    static var defaultButton: UIButton.Configuration {
        var config = filled()
        config.baseBackgroundColor = .accent
        config.titleTextAttributesTransformer = .init { attr in
            var newAttr = attr
            newAttr.font = UIFont.font16Regular
            newAttr.foregroundColor = .white
            return newAttr
        }
        return config
    }

    static var defaultColorReversed: UIButton.Configuration {
        var config = filled()
        config.baseBackgroundColor = .systemGray5
        config.baseForegroundColor = .accent
        config.background.strokeColor = .accent
        config.background.strokeWidth = 1
        config.titleTextAttributesTransformer = .init { attr in
            var newAttr = attr
            newAttr.font = UIFont.font16Regular
            newAttr.foregroundColor = .accent

            return newAttr
        }
        return config
    }

    static var removeImgButton: UIButton.Configuration {
        var config = plain()
        config.titleTextAttributesTransformer = .init { attr in
            var newAttr = attr
            newAttr.font = UIFont.font15Regular
            newAttr.foregroundColor = .neutral50
            return newAttr
        }
        return config
    }

    static var addButton: UIButton.Configuration {
        var config = filled()
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .primary500
        config.baseForegroundColor = .neutral50
        config.image = UIImage(systemName: "plus")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 24, weight: .bold))

        return config
    }

    // 하단 버튼
    static var bottomButton: UIButton.Configuration {
        var config = filled()
        config.baseBackgroundColor = .systemGray2
        config.titleTextAttributesTransformer = .init { attr in
            var newAttr = attr
            newAttr.font = UIFont.font17Regular
            newAttr.foregroundColor = .systemBackground
            return newAttr
        }
        return config
    }

    // 네비게이션 닫기 버튼
    static var navCancel: UIButton.Configuration {
        var config = plain()
        config.titleTextAttributesTransformer = .init { attr in
            var newAttr = attr
            newAttr.font = UIFont.font16Regular
            newAttr.foregroundColor = .systemRed
            return newAttr
        }
        return config
    }
}
