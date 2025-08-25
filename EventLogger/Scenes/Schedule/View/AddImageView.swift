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
    
    private let photoBadgeIcon = UIImageView(image: UIImage(systemName: "photo.badge.plus", withConfiguration: .addImageIcon))
    
    private let textLabel = UILabel().then {
        $0.text = "클릭하여 이미지 업로드"
        $0.font = UIFont.preferredFont(forTextStyle: .callout)
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
        
        // TODO: SF Symbol 넣으면서 레이아웃 숫자 구체화 필요
        photoBadgeIcon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(119)
            $0.centerX.equalToSuperview()
        }
        
        textLabel.snp.makeConstraints {
            $0.top.equalTo(photoBadgeIcon.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
