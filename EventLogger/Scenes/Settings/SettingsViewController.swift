//
//  SettingsViewController.swift
//  EventLogger
//
//  Created by Yoon on 8/31/25.
//

import Dependencies
import ReactorKit
import RxCocoa
import RxGesture
import RxSwift
import SnapKit
import SwiftUI
import Then

class SettingsViewController: BaseViewController<SettingsReactor> {
    // MARK: UI Component

    let categoryControlBackground = UIView().then {
        $0.backgroundColor = .neutral800
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
        $0.backgroundColor = .neutral800
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
        $0.backgroundColor = .neutral800
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

    let calendarNoticeLabel = UILabel().then {
        $0.text = "동기화가 꺼져 있을 때 만든 일정은 iCloud를 다시 켜도 연결되지 않을 수 있습니다."
        $0.font = .font12Regular
        $0.textColor = .label
        $0.numberOfLines = 0
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
        view.addSubview(calendarNoticeLabel)

        // 오토 레이아웃
        categoryControlBackground.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(44)
        }

        categoryControlLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(11)
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
            $0.height.equalTo(44)
        }

        pushNoticeLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.equalToSuperview().inset(16)
        }

        pushNoticeSwitch.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
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
            $0.height.equalTo(44)
        }

        calendarAutoLinkLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.equalToSuperview().inset(16)
        }

        calendarLinkSwitch.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }

        calendarNoticeLabel.snp.makeConstraints {
            $0.top.equalTo(calaendarLinkBackground.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(calaendarLinkBackground).inset(16)
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

        // 스위치 -> 액션
        pushNoticeSwitch.rx.isOn
            .skip(1) // 초기 값 바인딩 무시
            .map { SettingsReactor.Action.togglePushNotification($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 상태 → 스위치
        reactor.state.map { $0.pushEnabled }
            .bind(to: pushNoticeSwitch.rx.isOn)
            .disposed(by: disposeBag)

        // 캘린더 자동등록 토글 → 액션
        calendarLinkSwitch.rx.isOn
            .skip(1)
            .map { SettingsReactor.Action.toggleCalendarAutoSave($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 상태 → 스위치
        reactor.state.map { $0.calendarEnabled }
            .bind(to: calendarLinkSwitch.rx.isOn)
            .disposed(by: disposeBag)

        // 권한 요청 Alert
        reactor.pulse(\.$alertMessage)
            .compactMap{ $0 }
            .withUnretained(self)
            .flatMap { `self`, message in
                UIAlertController.rx.alert(on: self, title: "권한 필요", message: message, actions: [
                    .cancel("확인"),
                    .action("설정으로 이동", payload: .openSystemSettings),
                ])
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 뷰 로드 시 푸쉬버튼 상태 리프레쉬
        Observable
            .merge(
                rx.viewWillAppear.map { _ in },
                NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification).map { _ in }
            )
            .map { _ in .refreshPushStatus }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 캘린더 오토세이브 버튼 상태 리프레쉬
        Observable
            .merge(
                rx.viewWillAppear.map { _ in SettingsReactor.Action.refreshCalendarStatus },
                NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification)
                    .map { _ in SettingsReactor.Action.refreshCalendarStatus }
            )
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}
