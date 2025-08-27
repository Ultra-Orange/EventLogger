
import UIKit

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
