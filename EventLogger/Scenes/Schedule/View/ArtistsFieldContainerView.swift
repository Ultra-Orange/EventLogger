//
//  ArtistsFieldContainerView.swift
//  EventLogger
//
//  Created by Yoon on 8/24/25.
//

import Dependencies
import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit
import WSTagsField

final class ArtistsFieldContainerView: UIView {
    let label = UILabel().then {
        $0.text = "아티스트"
        $0.font = .font13Regular
    }

    let tagsField = WSTagsField().then {
        $0.backgroundColor = .systemGray5
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
        $0.textField.returnKeyType = .done

        $0.placeholder = "아티스트를 입력하세요"
        $0.placeholderFont = .font16Regular
        $0.placeholderColor = .neutral50
        $0.cornerRadius = 8

        $0.tintColor = .primary500
        $0.textColor = .neutral50
        $0.selectedColor = UIColor(red: 145.0 / 255.0, green: 60.0 / 255.0, blue: 3.0 / 255.0, alpha: 1.0)
        $0.selectedTextColor = .neutral50
        $0.font = .font15Regular
        $0.acceptTagOption = .return

        $0.spaceBetweenTags = 10
        $0.spaceBetweenLines = 10

        // 칩 내부 마진
        $0.layoutMargins = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        // 전체 패딩
        $0.contentInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    }

    private let disposeBag = DisposeBag()

    init() {
        super.init(frame: .zero)

        addSubview(label)
        addSubview(tagsField)

        label.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        tagsField.snp.makeConstraints {
            $0.top.equalTo(label.snp.bottom).offset(8)
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.greaterThanOrEqualTo(44)
        }

        // 편집하다가 텍스트 필드를 떠나면 빈문자열로 변경
        tagsField.textField.rx.controlEvent(.editingDidEnd)
            .map { "" }
            .bind(to: tagsField.textField.rx.text)
            .disposed(by: disposeBag)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
