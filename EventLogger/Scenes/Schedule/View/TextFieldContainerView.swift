//
//  TextFieldContainerView.swift
//  EventLogger
//
//  Created by Yoon on 8/24/25.
//

import UIKit
import Then
import SnapKit

final class TextFieldContainerView: UIView {
    
    let label = UILabel().then {
        $0.text = "제목"
        $0.font = UIFont.preferredFont(forTextStyle: .callout)
    }
    let textField = AppTextField().then {
        $0.placeholder = "이벤트 제목을 입력하세요"
    }
    
    // TODO: 이것에 대한 처리 문제 오른쪽 패딩주려면 뷰 하나로 더 감싸야함, 처리에 대해 생각할게 좀 있음
    let counter = UILabel().then {
        $0.text = "0/40"
        $0.font = UIFont.preferredFont(forTextStyle: .footnote)
        $0.textColor = .secondaryLabel
    }
    
    init() {
        super.init(frame: .zero)

        textField.rightView = counter
        textField.rightViewMode = .always
        
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
    
    func configureUI(text: String) {
        textField.text = text
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
