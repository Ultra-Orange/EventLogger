//
//  ExpenseFieldContainerView.swift
//  EventLogger
//
//  Created by 김우성 on 8/28/25.
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
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(label)
        label.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        textField.delegate = self

        addSubview(textField)
        textField.snp.makeConstraints {
            $0.top.equalTo(label.snp.bottom).offset(8)
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
    }
}

extension ExpenseFieldContainerView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        if updatedText.isEmpty { return true } // 백스페이스 허용

        if Int(updatedText) != nil {
            return true // 정수
        } else if Double(updatedText) != nil {
            return true // 실수
        } else {
            return false // 숫자 아님
        }
    }
}
