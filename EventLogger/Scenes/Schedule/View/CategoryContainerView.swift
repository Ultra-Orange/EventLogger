//
//  CategoryContainerView.swift
//  EventLogger
//
//  Created by 김우성 on 8/27/25.
//

import SnapKit
import Then
import UIKit
import RxSwift
import RxCocoa

final class CategoryContainerView: UIView {
    
    let sectionHeader = UILabel().then {
        $0.text = "카테고리"
        $0.font = .font13Regular
        $0.textColor = .white
    }

    // TODO: UIControl 상속으로 입력필드 변경
    let textField = AppTextField()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(sectionHeader)
        addSubview(textField)

        sectionHeader.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        textField.snp.makeConstraints {
            $0.top.equalTo(sectionHeader.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

#Preview {
    CategoryContainerView()
}
