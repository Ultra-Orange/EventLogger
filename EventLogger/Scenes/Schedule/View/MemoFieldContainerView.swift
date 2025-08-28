//
//  MemoFieldContainerView.swift
//  EventLogger
//
//  Created by 김우성 on 8/28/25.
//

import SnapKit
import Then
import UIKit

final class MemoFieldContainerView: UIView {
    let label = UILabel().then {
        $0.text = "메모"
        $0.font = .font13Regular
    }

    // TODO: PlaceHolder 처리?
//    private let placeholderLabel = UILabel().then {
//        $0.text = "메모를 입력하세요"
//        $0.textColor = .placeholderText
//        $0.font = UIFont.preferredFont(forTextStyle: .body)
//    }

    let textView = UITextView().then {
        $0.backgroundColor = .systemGray5
        $0.font = .font17Regular
        $0.layer.cornerRadius = 10
        $0.textContainerInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    }
    
    private var textViewHeightConstraint: Constraint?

    init() {
        super.init(frame: .zero)
        setupUI()
        textView.inputAccessoryView = makeDoneToolbar(target: self, action: #selector(dismissKeyboard))
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(label)
        addSubview(textView)

        label.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        textView.snp.makeConstraints {
            $0.top.equalTo(label.snp.bottom).offset(8)
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(206)
        }
    }

    @objc private func dismissKeyboard() {
        textView.endEditing(true)
    }
}
