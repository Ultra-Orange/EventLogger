
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
            newAttr.font = UIFont.preferredFont(forTextStyle: .callout)
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
            newAttr.font = UIFont.preferredFont(forTextStyle: .title3)
            newAttr.foregroundColor = .systemBackground
            return newAttr
        }
        return config
    }
    
    // 폼 필드용 공용 구성 (텍스트필드처럼 보이는 버튼)
    static func formField(
        title: String? = nil,
        showsChevron: Bool = true
    ) -> UIButton.Configuration {
        var config: UIButton.Configuration = .plain()
        
        // 1) 콘텐츠 인셋 (상하10, 좌우16)
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)

        // 2) 제목
        config.title = title
        config.titleTextAttributesTransformer = .init { attr in
            var newAttr = attr
            newAttr.font = UIFont.preferredFont(forTextStyle: .footnote)
            newAttr.foregroundColor = .secondaryLabel
            return newAttr
        }
        
        // 4) 외곽선(1px) + 모서리(10)
        var bg = UIBackgroundConfiguration.clear()
        bg.cornerRadius = 10
        bg.strokeColor = .separator
        bg.strokeWidth = 1.0 / UIScreen.main.scale   // 1px 보장
        config.background = bg
        
        
        return config
    }

}
