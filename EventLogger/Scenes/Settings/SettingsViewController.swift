//
//  SettingsViewController.swift
//  EventLogger
//
//  Created by Yoon on 8/31/25.
//


import ReactorKit
import RxCocoa
import RxSwift
import RxGesture
import SnapKit
import SwiftUI
import Then

class SettingsViewController: BaseViewController<SettingsReactor> {
    // MARK: UI Component
    
    let categoryControlBackground = UIView().then {
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 12
    }
    
    let categoryControlLabel = UILabel().then {
        $0.text = "카테고리 관리"
        $0.font = .font17Regular
        $0.textColor = .label
    }

    let noticeLabel = UILabel().then {
        $0.text = "알림설정"
        $0.font = .font13Regular
        $0.textColor = .label
    }
    
    let noticeBackground = UIView().then {
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 12
    }
    
    let pushNoticeLabel = UILabel().then {
        $0.text = "푸시 알림"
        $0.font = .font17Regular
        $0.textColor = .label
    }
    
    let pushNoticeSwitch = UISwitch().then {
        $0.onTintColor = .systemOrange
    }
   
    let pushNoticeDescription = UILabel().then {
        $0.text = "알림은 이벤트 24시간 전 발송됩니다."
        $0.font = .font12Regular
        $0.textColor = .label
    }
    
    let calendarLinkLabel = UILabel().then {
        $0.text = "캘린더 연동"
        $0.font = .font13Regular
        $0.textColor = .label
    }
    
    let calaendarLinkBackground = UIView().then {
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 12
    }

    let calendarAutoLinkLabel = UILabel().then {
        $0.text = "캘린더 자동 등록"
        $0.font = .font17Regular
        $0.textColor = .label
    }
    
    let calendarLinkSwitch = UISwitch().then {
        $0.onTintColor = .systemOrange
    }
    
 
    
    
    // MARK: SetupUI

    override func setupUI() {
        view.backgroundColor = .systemBackground
        title = "설정"
        
        // 카테고리 관리 영역
        view.addSubview(categoryControlBackground)
        categoryControlBackground.addSubview(categoryControlLabel)
        
        // 알림 설정 영역
        view.addSubview(noticeLabel)
        view.addSubview(noticeBackground)
        noticeBackground.addSubview(pushNoticeLabel)
        noticeBackground.addSubview(pushNoticeSwitch)
        view.addSubview(pushNoticeDescription)
        
        // 캘린더 연동 영역
        view.addSubview(calendarLinkLabel)
        view.addSubview(calaendarLinkBackground)
        calaendarLinkBackground.addSubview(calendarAutoLinkLabel)
        calaendarLinkBackground.addSubview(calendarLinkSwitch)
        
        
        // 오토 레이아웃
        categoryControlBackground.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.greaterThanOrEqualTo(42)
        }
        
        categoryControlLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(10)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        noticeLabel.snp.makeConstraints {
            $0.top.equalTo(categoryControlBackground.snp.bottom).offset(30)
            $0.leading.trailing.equalTo(noticeBackground).inset(16)
        }
        
        noticeBackground.snp.makeConstraints {
            $0.top.equalTo(noticeLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        pushNoticeLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(10)
            $0.leading.equalToSuperview().inset(16)
        }
        
        pushNoticeSwitch.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(10)
            $0.trailing.equalToSuperview().inset(16)
            $0.width.equalTo(51)
            $0.height.equalTo(31)
        }
        
        pushNoticeDescription.snp.makeConstraints {
            $0.top.equalTo(noticeBackground.snp.bottom).offset(8)
            $0.leading.equalTo(noticeLabel)
        }
        
        calendarLinkLabel.snp.makeConstraints {
            $0.top.equalTo(pushNoticeDescription.snp.bottom).offset(30)
            $0.leading.trailing.equalTo(calaendarLinkBackground).inset(16)
        }
        
        calaendarLinkBackground.snp.makeConstraints {
            $0.top.equalTo(calendarLinkLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        calendarAutoLinkLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(10)
            $0.leading.equalToSuperview().inset(16)
        }
        
        calendarLinkSwitch.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(10)
            $0.trailing.equalToSuperview().inset(16)
            $0.width.equalTo(51)
            $0.height.equalTo(31)
        }
        
        
    }

    // MARK: Binding

    override func bind(reactor: SettingsReactor) {
        
        // 카테고리 관리 탭 제스쳐
        categoryControlBackground.rx.tapGesture()
            .when(.recognized)
            .map { _ in .tapCategoryControl }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

    }
}
