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
    private let defaults: UserDefaults
    private let autoSaveKey = "settings.autoSaveToCalendar"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        // 기본값이 없을 경우 false로 초기화
        if defaults.object(forKey: autoSaveKey) == nil {
            defaults.set(false, forKey: autoSaveKey)
        }
    }

    var autoSaveToCalendar: Bool {
        get { defaults.bool(forKey: autoSaveKey) }
        set { defaults.set(newValue, forKey: autoSaveKey) }
    }

    @UserSetting(key: UDKey.pushNotificationEnabled, defaultValue: false)
    private var pushNotificationKey: Bool

    var pushNotificationEnabled: Bool {
        get { pushNotificationKey }
        set { pushNotificationKey = newValue }
    }
}

/*
 // 설정 화면에서 스위치 어떻게 하면 되나
 final class SettingsViewController: UIViewController {
     private let toggle = UISwitch()
     @Dependency(\.settingsService) private var settingsService

     override func viewDidLoad() {
         super.viewDidLoad()
         view.backgroundColor = .systemBackground
         navigationItem.title = "설정"

         toggle.isOn = settingsService.autoSaveToCalendar
         toggle.addTarget(self, action: #selector(onToggleChanged), for: .valueChanged)

         view.addSubview(toggle)
         toggle.translatesAutoresizingMaskIntoConstraints = false
         NSLayoutConstraint.activate([
             toggle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             toggle.centerYAnchor.constraint(equalTo: view.centerYAnchor),
         ])
     }

     @objc private func onToggleChanged() {
         settingsService.autoSaveToCalendar = toggle.isOn
     }
 }
 */
