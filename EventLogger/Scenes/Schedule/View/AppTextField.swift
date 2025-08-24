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
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureDefault() {
        self.font = UIFont.preferredFont(forTextStyle: .footnote) // 폰트사이즈 14가 없음
        self.borderStyle = .roundedRect
        self.layer.borderColor = UIColor.systemGray6.cgColor
        self.layer.cornerRadius = 10
        self.autocapitalizationType = .none // 자동 대문자 변환 무시
        self.autocorrectionType = .no // 자동 수정 무시
        self.smartQuotesType = .no // 스마트 구두점 무시
    }
}
