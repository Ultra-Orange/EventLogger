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

    private let photoBadgeIcon = UIImageView(image: UIImage.symbolDefault(named: "photo.badge.plus", config: .font32Regular))

    private let textLabel = UILabel().then {
        $0.text = "클릭하여 이미지 업로드"
        $0.font = .font16Regular
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(imageContainerView)
        imageContainerView.addSubview(photoBadgeIcon)
        imageContainerView.addSubview(textLabel)

        imageContainerView.snp.makeConstraints {
            $0.directionalEdges.equalToSuperview()
            $0.height.equalTo(self.snp.width)
        }
        
        let layoutGuide = UILayoutGuide()
        addLayoutGuide(layoutGuide)
        
        layoutGuide.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        photoBadgeIcon.snp.makeConstraints {
            $0.top.centerX.equalTo(layoutGuide)
        }

        textLabel.snp.makeConstraints {
            $0.top.equalTo(photoBadgeIcon.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalTo(layoutGuide)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
