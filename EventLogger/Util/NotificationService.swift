//
//  NotificationService.swift
//  EventLogger
//
//  Created by Yoon on 9/3/25.
//

import Foundation
import UserNotifications

protocol NotificationServicing {
    func requestAuthorization(completion: @escaping (Bool) -> Void)
    func cancelAll()
    func cancelNotification(id: String)
    func scheduleNotification(id: String, title: String, body: String, date: Date)
}

final class NotificationService: NotificationServicing {
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error = error {
                print("알림 권한 요청 실패:", error.localizedDescription)
                completion(false)
                return
            }
            completion(granted)
        }
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func cancelNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }

    func scheduleNotification(id: String, title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        // 24시간 전 트리거
        let triggerDate = Calendar.current.date(byAdding: .hour, value: -24, to: date) ?? date
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(triggerDate.timeIntervalSinceNow, 1), // 1초 이하 방지
            repeats: false
        )

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("알림 예약 실패:", error.localizedDescription)
            }
        }
    }
}
