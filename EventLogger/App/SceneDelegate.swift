//
//  SceneDelegate.swift
//  EventLogger
//
//  Created by 김우성 on 8/20/25.
//

import Dependencies
import RxFlow
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private let coordinator = FlowCoordinator()
    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        @Dependency(\.modelContext) var modelContext
        do {
            try CategorySeeder.runIfNeeded(modelContext: modelContext)
        } catch {
            assertionFailure("기본 카테고리 시딩 실패: \(error.localizedDescription)")
        }

//        prepareDependencies{
//        }

//        let appFlow = AppFlow(windowScene: windowScene)
//        coordinator.coordinate(
//            flow: appFlow,
//            with: OneStepper(withSingleStep: AppStep.eventList)
//        )

        @Dependency(\.eventItems) var eventItems
        let testItem = eventItems[2]
        let appFlow = AppFlow(windowScene: windowScene)
        coordinator.coordinate(
            flow: appFlow,
//            with: OneStepper(withSingleStep: AppStep.createSchedule)
            with: OneStepper(withSingleStep: AppStep.updateSchedule(testItem))
        )
    }

    func sceneDidDisconnect(_: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
