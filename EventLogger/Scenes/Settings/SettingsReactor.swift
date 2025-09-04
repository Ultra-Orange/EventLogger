//
//  SettingsReactor.swift
//  EventLogger
//
//  Created by Yoon on 8/31/25.
//

import SwiftData

import Dependencies
import Foundation
import ReactorKit
import RxFlow
import RxRelay
import RxSwift
import UIKit
import UserNotifications

final class SettingsReactor: BaseReactor {
    // 사용자 액션 정의 (사용자의 의도)
    enum Action {
        case tapCategoryControl
        case togglePushNotification(Bool)
        case refreshPushStatus
        case openSystemSettings
    }

    // 상태변경 이벤트 정의 (상태를 어떻게 바꿀 것인가)
    enum Mutation {
        case setPushEnabled(Bool)
        case showDeniedAlert(String)
    }

    // View의 상태 정의 (현재 View의 상태값)
    struct State {
        var pushEnabled: Bool
        @Pulse var alertMessage: String?
    }

    // TODO: 리팩토링 요소 있음, notificationService 관련
    @Dependency(\.settingsService) var settingsService
    @Dependency(\.notificationService) var notificationService

    // 생성자에서 초기 상태 설정
    let initialState: State

    init() {
        @Dependency(\.settingsService) var settingsService
        initialState = State(
            pushEnabled: settingsService.pushNotificationEnabled
        )
    }

    // Action이 들어왔을 때 어떤 Mutation으로 바뀔지 정의
    // 사용자 입력 → 상태 변화 신호로 변환
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapCategoryControl:
            steps.accept(AppStep.categoryList)
            return .empty()
        case let .togglePushNotification(isOn):
            if isOn {
                // 스위치 ON
                return Observable.create { [weak self] observer in
                    guard let self else { return Disposables.create() }
                    self.notificationService.requestAuthorization { granted in
                        if granted {
                            self.settingsService.pushNotificationEnabled = true
                            observer.onNext(.setPushEnabled(true))
                            self.setNotificationAll()
                        } else {
                            self.settingsService.pushNotificationEnabled = false
                            observer.onNext(.setPushEnabled(false))
                            observer.onNext(.showDeniedAlert("알림 권한이 꺼져 있습니다.\n설정 > 알림에서 허용해주세요."))
                        }
                        observer.onCompleted()
                    }
                    return Disposables.create()
                }
            } else {
                // 스위치 OFF
                settingsService.pushNotificationEnabled = false
                notificationService.cancelAll()
                return .just(.setPushEnabled(false))
            }
        case .refreshPushStatus:
            return Observable.create { observer in
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    let isGranted = (settings.authorizationStatus == .authorized
                        || settings.authorizationStatus == .provisional
                        || settings.authorizationStatus == .ephemeral)
                    observer.onNext(.setPushEnabled(isGranted && self.settingsService.pushNotificationEnabled))
                    observer.onCompleted()
                }
                return Disposables.create()
            }
        case .openSystemSettings:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
            return .empty()
        }
    }

    // Mutation이 발생했을 때 상태(State)를 실제로 바꿈
    // 상태 변화 신호 → 실제 상태 반영
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setPushEnabled(isAble):
            newState.pushEnabled = isAble
        case let .showDeniedAlert(message):
            newState.alertMessage = message
        }
        return newState
    }
}

extension SettingsReactor {
    // 기존 알림 푸쉬알림 재설정
    func setNotificationAll() {
        @Dependency(\.swiftDataManager) var swiftDataManager
        let events = swiftDataManager.fetchAllEvents()
        let futureEvents = events.filter { $0.startTime > Date() }
        for event in futureEvents {
            notificationService.cancelNotification(id: event.id.uuidString)
            notificationService.scheduleNotification(
                id: event.id.uuidString,
                title: event.title,
                body: "내일은 이벤트에 참가하는 날입니다!",
                date: event.startTime
            )
        }
    }
}
