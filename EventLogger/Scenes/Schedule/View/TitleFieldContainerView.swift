//
//  TitleFieldContainerView.swift
//  EventLogger
//
//  Created by Yoon on 8/24/25.
//

import SnapKit
import Then
import UIKit

final class TitleFieldContainerView: UIView {
    private let label = UILabel().then {
        $0.text = "제목"
        $0.font = .font13Regular
    }

    let textField = AppTextField().then {
        $0.placeholder = "이벤트 제목을 입력하세요"
    }

    init() {
        super.init(frame: .zero)

        textField.rightViewMode = .always

        addSubview(label)
        addSubview(textField)

        label.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }

        textField.snp.makeConstraints {
            $0.top.equalTo(label.snp.bottom).offset(8)
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(45)
        }
    }

    func configureUI(text: String) {
        textField.text = text
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
