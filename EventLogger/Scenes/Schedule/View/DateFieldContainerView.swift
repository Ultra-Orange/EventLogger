//
//  DateFieldContainerView.swift
//  EventLogger
//
//  Created by Yoon on 8/24/25.
//

import SnapKit
import Then
import UIKit

final class DateFieldContainerView: UIView {
    let label = UILabel().then {
        $0.text = "날짜"
        $0.font = .font13Regular
    }

    // TODO: UIControll 상속으로 입력필드 변경
    let textField = AppTextField()
    private let datePicker = UIDatePicker()

    init() {
        super.init(frame: .zero)

        addSubview(label)
        addSubview(textField)

        label.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
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
