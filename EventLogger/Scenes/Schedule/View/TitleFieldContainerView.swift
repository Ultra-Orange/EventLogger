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
    private let nameLabel = UILabel().then {
        $0.text = "제목"
        $0.font = .font13Regular
    }

    let textField = AppTextField().then {
        $0.placeholder = "이벤트 제목을 입력하세요"
    }

    let alertlabel = UILabel().then {
        $0.text = "제목을 입력해 주세요"
        $0.textColor = .appRed
        $0.font = .font12Regular
    }

    init() {
        super.init(frame: .zero)

        textField.rightViewMode = .always

        addSubview(nameLabel)
        addSubview(textField)
        addSubview(alertlabel)

        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        textField.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(8)
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        alertlabel.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
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
