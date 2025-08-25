//
//  CateogryContainerView.swift
//  EventLogger
//
//  Created by Yoon on 8/24/25.
//

import UIKit
import Then
import SnapKit

final class CateogryContainerView: UIView {
    
    let label = UILabel().then {
        $0.text = "카테고리"
        $0.font = .font13Regular
    }
    
    // TODO: UIControll 상속으로 입력필드 변경
    let textField = AppTextField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
