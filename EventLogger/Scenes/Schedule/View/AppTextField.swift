//
//  AppTextField.swift
//  EventLogger
//
//  Created by Yoon on 8/24/25.
//

import UIKit

final class AppTextField: UITextField {
    // 기본 패딩
    private let padding = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureDefault()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureDefault() {
        font = .font17Regular
        borderStyle = .roundedRect
        backgroundColor = .systemGray5
        layer.cornerRadius = 10
        autocapitalizationType = .none // 자동 대문자 변환 무시
        autocorrectionType = .no // 자동 수정 무시
        smartQuotesType = .no // 스마트 구두점 무시
    }
}
