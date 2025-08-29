//
//  ExpenseFieldContainerView.swift
//  EventLogger
//
//  Created by Yoon on 8/24/25.
//

import SnapKit
import Then
import UIKit

final class ExpenseFieldContainerView: UIView {
    let label = UILabel().then {
        $0.text = "비용"
        $0.font = .font13Regular
    }

    let textField = AppTextField().then {
        $0.placeholder = "비용을 입력하세요"
        $0.keyboardType = .decimalPad
    }

    init() {
        super.init(frame: .zero)

        addSubview(label)
        addSubview(textField)

        label.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        textField.snp.makeConstraints {
            $0.top.equalTo(label.snp.bottom).offset(8)
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
