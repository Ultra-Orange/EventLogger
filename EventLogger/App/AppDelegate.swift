//
//  AppDelegate.swift
//  EventLogger
//
//  Created by 김우성 on 8/20/25.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions : [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Task {
            let pushEnable = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            application.registerForRemoteNotifications()

            if UserDefaults.standard.object(forKey: UDKey.pushNotificationEnabled) == nil {
                UserDefaults.standard.set(pushEnable ?? false, forKey: UDKey.pushNotificationEnabled)
            }
        }

        let apperance = UINavigationBarAppearance().then {
            $0.configureWithTransparentBackground()
        }
        UINavigationBar.appearance().standardAppearance = apperance
        UINavigationBar.appearance().scrollEdgeAppearance = apperance

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_: UIApplication, didDiscardSceneSessions _: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
