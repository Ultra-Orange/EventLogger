//
//  MemoView.swift
//  EventLogger
//
//  Created by Yoon on 8/22/25.
//

import SnapKit
import Then
import UIKit

class MemoView: UIView {
    // 메모 영역 컨테이너 뷰
    private let memoCardView = UIView().then {
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 12
    }

    // 라벨
    private let memoTitleLabel = UILabel().then {
        $0.font = .font16Regular
        $0.text = "메모"
    }

    private let memoTextLabel = UILabel().then {
        $0.font = .font16Regular
        $0.numberOfLines = 0
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        // 뷰 주입
        addSubview(memoCardView)
        memoCardView.addSubview(memoTitleLabel)
        memoCardView.addSubview(memoTextLabel)

        // 오토 레이아웃
        memoCardView.snp.makeConstraints {
            $0.directionalEdges.equalToSuperview()
        }

        memoTitleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(20)
        }

        memoTextLabel.snp.makeConstraints {
            $0.top.equalTo(memoTitleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-20)
        }
    }

    // 리액터에 바인딩되는 값 주입
    func configureView(_ text: String) {
        memoTextLabel.text = text
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
