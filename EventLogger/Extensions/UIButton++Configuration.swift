
import UIKit

extension UIButton.Configuration {
   
    //     사용부
    //    private let button = UIButton(configuration: .closed)
    
    // 기본 버튼
    static var defaultButton: UIButton.Configuration {
        var config = filled()
        config.baseBackgroundColor = .systemGray2
        config.titleTextAttributesTransformer = .init { attr in
            var newAttr = attr
            newAttr.font = UIFont.systemFont(ofSize: 16)
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
            newAttr.font = UIFont.systemFont(ofSize: 20)
            newAttr.foregroundColor = .systemBackground
            return newAttr
        }
        return config
    }

}
