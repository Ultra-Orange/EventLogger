//
//  UserSetting.swift
//  EventLogger
//
//  Created by Yoon on 9/1/25.
//

import Foundation

// UserDefault의 다른 값을 하나로 관리하기 위해 @propertyWrapper 사용
@propertyWrapper
struct UserSetting<T> { // Wrapper로 쌀 내용
    let key: String
    let defaultValue: T
    let userDefaults: UserDefaults

    init(key: String, defaultValue: T, userDefaults: UserDefaults = UserDefaults.standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults
    }

    var wrappedValue: T {
        get { // 유저디폴트 값 획득
            userDefaults.object(forKey: key) as? T ?? defaultValue
        }
        set { // 유저디폴트 값 할당
            userDefaults.set(newValue, forKey: key)
        }
    }
}

// 유저 디폴트 키값을 String 형태로 저장
enum UDKey {
    static let didSetupDefaultCategories = "didSetupDefaultCategories" // 최초 실행 체크
    static let pushNotificationEnabled = "pushNotificationEnabled" // 푸쉬알림 허용 체크
    static let autoSaveToCalendar = "settings.autoSaveToCalendar" // 캘린더 오토세이브
    static let appCalendarName = "appCalendarName"
    static let appCalendarIdKey = "ELCalendarIdentifier"
}

/*
  didSetupDefaultCategories를 쓴다면
  @UserSetting(key: UDKey.didSetupDefaultCategories, defaultValue: false)
 var didSetupDefaultCategories: Type
  위처럼 변수 선언하고 변수 쓰듯이 쓰면 됨 유저디폴트 값이 없으면 defaultValue로 선언한게 들어감
  */
