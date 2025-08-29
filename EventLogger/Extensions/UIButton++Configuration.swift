
import UIKit

extension UIButton {
    /// DateRangeField 버튼들 생김새 통합 설정
    static func makeDateButton() -> UIButton {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.bordered()
        config.contentInsets = .init(top: 2, leading: 8, bottom: 2, trailing: 8)
        config.background.cornerRadius = 6
        config.baseForegroundColor = .white
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
            config.baseForegroundColor = isOn ? .primary500 : .white
            button.configuration = config
        }
        return button
    }
}

extension UIButton.Configuration {
   
    //     사용부
    //    private let button = UIButton(configuration: .closed)
    
    // 기본 버튼
    static var defaultButton: UIButton.Configuration {
        var config = filled()
        config.baseBackgroundColor = .systemBlue
        config.titleTextAttributesTransformer = .init { attr in
            var newAttr = attr
            newAttr.font = UIFont.font16Regular
            newAttr.foregroundColor = .systemBackground
            return newAttr
        }
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
