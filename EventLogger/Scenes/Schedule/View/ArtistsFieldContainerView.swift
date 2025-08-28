//
//  ArtistsFieldContainerView.swift
//  EventLogger
//
//  Created by Yoon on 8/24/25.
//

import SnapKit
import Then
import UIKit
import WSTagsField
import Dependencies
import RxSwift
import RxCocoa

final class ArtistsFieldContainerView: UIView {
    let label = UILabel().then {
        $0.text = "출연자"
        $0.font = .font13Regular
    }
    
  
    let tagsField = WSTagsField().then {
    
        $0.backgroundColor = .systemGray5
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
        
        $0.placeholder = "출연자를 입력하세요"
        $0.placeholderFont = .font16Regular
        $0.placeholderColor = .white
        $0.cornerRadius = 10
        
//        $0.tintColor = .systemOrange
        $0.textColor = .white
        $0.selectedColor = UIColor(red: 145.0/255.0, green: 60.0/255.0, blue: 3.0/255.0, alpha: 1.0)
        $0.selectedTextColor = .white
        $0.font = .font16Regular
        $0.acceptTagOption = .return

        $0.spaceBetweenTags = 10
        $0.spaceBetweenLines = 10
        
        // 칩 내부 마진
        $0.layoutMargins = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
        // 전체 패딩
        $0.contentInset = UIEdgeInsets(top: 11, left: 16, bottom: 9, right: 16)
        
    }
    
    private let disposeBag = DisposeBag()
    init() {
        super.init(frame: .zero)
        
        addSubview(label)
        addSubview(tagsField)
        
        label.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        
        tagsField.snp.makeConstraints {
            $0.top.equalTo(label.snp.bottom).offset(8)
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.greaterThanOrEqualTo(47)
        }
        
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

