//
//  AddImageView.swift
//  EventLogger
//
//  Created by Yoon on 8/24/25.
//
import SnapKit
import Then
import UIKit

final class AddImageView: UIView {
    private let imageContainerView = UIView().then {
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 12
    }

    private let photoBadgeIcon = UIImageView(image: UIImage(systemName: "photo.badge.plus", withConfiguration: .font32Regular))

    private let textLabel = UILabel().then {
        $0.text = "클릭하여 이미지 업로드"
        $0.font = .font16Regular
    }

    private let iconAndLabelContainer = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(imageContainerView)
        imageContainerView.addSubview(iconAndLabelContainer)
        iconAndLabelContainer.addSubview(photoBadgeIcon)
        iconAndLabelContainer.addSubview(textLabel)

        imageContainerView.snp.makeConstraints {
            $0.directionalEdges.equalToSuperview()
            $0.height.equalTo(self.snp.width)
        }

        iconAndLabelContainer.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        photoBadgeIcon.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
        }

        textLabel.snp.makeConstraints {
            $0.top.equalTo(photoBadgeIcon.snp.bottom).offset(16)
            $0.centerX.bottom.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
