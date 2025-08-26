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
    }

    let inputField = UIView().then {
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 10
    }
    
    private let mapPinIcon = UIImageView(image: UIImage.SFSymbol(named: "mappin.and.ellipse", config: .font16Regular))

    init() {
        super.init(frame: .zero)

        addSubview(nameLabel)
        addSubview(inputField)

        nameLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }

        inputField.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(8)
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        inputField.addSubview(textLabel)
//        inputField.addSubview(mapPinIcon)
        
        textLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.top.bottom.equalToSuperview().inset(10)
//            $0.trailing.lessThanOrEqualTo(mapPinIcon.snp.leading).offset(-10)
        }
        
//        mapPinIcon.snp.makeConstraints {
//            $0.centerY.equalToSuperview()
//            $0.trailing.equalToSuperview().inset(16)
//        }
        
    }
    

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
