//
//  SettingsService.swift
//  EventLogger
//
//  Created by 김우성 on 9/1/25.
//

import Foundation

protocol SettingsServicing: AnyObject {
    var autoSaveToCalendar: Bool { get set }
    var pushNotificationEnabled: Bool { get set }
}

final class SettingsService: SettingsServicing {
    @UserSetting(key: UDKey.autoSaveToCalendar, defaultValue: false)
    private var autoSaveToCalendaKey: Bool

    var autoSaveToCalendar: Bool {
        get { autoSaveToCalendaKey }
        set { autoSaveToCalendaKey = newValue }
    }

    @UserSetting(key: UDKey.pushNotificationEnabled, defaultValue: false)
    private var pushNotificationKey: Bool

    var pushNotificationEnabled: Bool {
        get { pushNotificationKey }
        set { pushNotificationKey = newValue }
    }
}
