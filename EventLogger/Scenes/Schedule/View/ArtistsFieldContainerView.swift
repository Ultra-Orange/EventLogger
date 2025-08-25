//
//  ArtistsFieldContainerView.swift
//  EventLogger
//
//  Created by Yoon on 8/24/25.
//

import UIKit
import Then
import SnapKit

final class ArtistsFieldContainerView: UIView {
    
    let label = UILabel().then {
        $0.text = "출연자"
        $0.font = UIFont.preferredFont(forTextStyle: .callout)
    }
    
    // TODO: WSTag라이브러리
    let textField = AppTextField().then {
        $0.placeholder = "출연자를 입력하세요"
    }
    
    init() {
        super.init(frame: .zero)
       
        addSubview(label)
        addSubview(textField)
        
        label.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        
        textField.snp.makeConstraints {
            $0.top.equalTo(label.snp.bottom).offset(8)
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
    }

    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
