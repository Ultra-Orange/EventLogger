//
//  ExpenseFieldContainerView.swift
//  EventLogger
//
//  Created by Yoon on 8/24/25.
//

import RxCocoa
import RxSwift
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

    let alertlabel = UILabel().then {
        $0.text = "* 비용은 최대 15자리까지만 입력할 수 있어요"
        $0.textColor = .appRed
        $0.font = .font12Regular
    }

    private let disposeBag = DisposeBag()

    init() {
        super.init(frame: .zero)

        addSubview(label)
        addSubview(textField)
        addSubview(alertlabel)

        label.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        textField.snp.makeConstraints {
            $0.top.equalTo(label.snp.bottom).offset(8)
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        alertlabel.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        textField.rx.controlEvent(.editingDidEnd)
            .withLatestFrom(textField.rx.text.orEmpty)
            .compactMap { Double($0) }
            .map { $0.formatted(.number) }
            .bind(to: textField.rx.text)
            .disposed(by: disposeBag)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
