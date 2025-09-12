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
import EventKit

final class SettingsReactor: BaseReactor {
    // 사용자 액션 정의 (사용자의 의도)
    enum Action {
        case tapCategoryControl
        case togglePushNotification(Bool)
        case refreshPushStatus
        case openSystemSettings
        case toggleCalendarAutoSave(Bool)
        case refreshCalendarStatus
    }

    // 상태변경 이벤트 정의 (상태를 어떻게 바꿀 것인가)
    enum Mutation {
        case setPushEnabled(Bool)
        case showDeniedAlert(String)
        case setCalendarEnabled(Bool)
    }

    // View의 상태 정의 (현재 View의 상태값)
    struct State {
        var pushEnabled: Bool
        var calendarEnabled: Bool
        @Pulse var alertMessage: String?
    }

    // TODO: 리팩토링 요소 있음, notificationService 관련
    // TODO: 캘린더 권한 묻는 시점 리팩토링
    @Dependency(\.settingsService) var settingsService
    @Dependency(\.notificationService) var notificationService
    @Dependency(\.calendarService) var calendarService

    // 생성자에서 초기 상태 설정
    let initialState: State

    init() {
        @Dependency(\.settingsService) var settingsService
        initialState = State(
            pushEnabled: settingsService.pushNotificationEnabled,
            calendarEnabled: settingsService.autoSaveToCalendar
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
                return notificationService.requestAuthorization()
                    .do(onNext: { [weak self] granted in // 사이드이펙트는 map, flatMap이 아니라 do 안에서 처리
                        if granted {
                            self?.settingsService.pushNotificationEnabled = true
                            self?.setNotificationAll()
                        } else {
                            self?.settingsService.pushNotificationEnabled = false
                        }
                    })
                    .flatMap { granted in
                        if granted {
                            return Observable.just(Mutation.setPushEnabled(true))
                        } else {
                            return .of(
                                .setPushEnabled(false),
                                .showDeniedAlert("알림 권한이 없어요.\n설정 > 알림에서 허용해주세요.")
                            )
                        }
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
        case let .toggleCalendarAutoSave(isOn):
            if isOn {
                return calendarService.requestAccess().asObservable()
                    .map { granted in
                        if granted {
                            self.settingsService.autoSaveToCalendar = true
                            return .setCalendarEnabled(true)
                        } else {
                            self.settingsService.autoSaveToCalendar = false
                            return .showDeniedAlert("캘린더 접근 권한이 없어요.\n설정 > 캘린더에서 허용해주세요.")
                        }
                    }
            } else {
                settingsService.autoSaveToCalendar = false
                return .just(.setCalendarEnabled(false))
            }
        case .refreshCalendarStatus:
            let status = EKEventStore.authorizationStatus(for: .event)
            let isGranted = (status == .fullAccess || status == .writeOnly)
            return .just(.setCalendarEnabled(isGranted && self.settingsService.autoSaveToCalendar))
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
        case let .setCalendarEnabled(isAble):
            newState.calendarEnabled = isAble
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
                title: "\(event.title)+✨",
                body: "내일은 기다리고 기다리던 이벤트 D-DAY 🎉",
                date: event.startTime
            )
        }
    }
}
