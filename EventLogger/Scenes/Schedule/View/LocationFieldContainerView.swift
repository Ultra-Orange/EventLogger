//
//  LocationFieldContainerView.swift
//  EventLogger
//
//  Created by Yoon on 8/24/25.
//

import SnapKit
import Then
import UIKit

final class LocationFieldContainerView: UIView {
    private let nameLabel = UILabel().then {
        $0.text = "장소"
        $0.font = .font13Regular
    }

    var textLabel = UILabel().then {
        $0.font = .font17Regular
        $0.textColor = .label
        $0.text = "장소를 입력하세요"
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    let inputField = UIView().then {
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .systemGray5
    }

    let closeIcon = UIImageView(image: UIImage.symbolXCircleFill(config: .font16Regular)).then {
        $0.contentMode = .center
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    init() {
        super.init(frame: .zero)

        addSubview(nameLabel)
        addSubview(inputField)

        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        inputField.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(8)
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(42)
        }

        inputField.addSubview(textLabel)
        addSubview(closeIcon)

        textLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalTo(closeIcon.snp.leading)
            $0.top.bottom.equalToSuperview().inset(10)
        }

        closeIcon.snp.makeConstraints {
            $0.trailing.top.bottom.equalTo(inputField)
            $0.width.equalTo(40)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
