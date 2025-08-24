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
        $0.font = UIFont.preferredFont(forTextStyle: .callout)
    }
    
    // TODO: 레이아웃을 똑같은 버튼으로 만드느냐, 입력이 불가능한 텍스트필드로 만드느냐
    let categoryButton = UIButton(configuration: .formField(title: "콘서트"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        categoryButton.contentHorizontalAlignment = .leading // 텍스트 왼쪽 정렬
        categoryButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        addSubview(label)
        addSubview(categoryButton)
        
        label.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        
        categoryButton.snp.makeConstraints {
            $0.top.equalTo(label.snp.bottom).offset(8)
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
