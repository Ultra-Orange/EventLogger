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
        
        // 개발단계에서 초기화하려면 KVS값 지우는코드 강제 실행 필요,
//        SeedKVS.resetSeedFlags()
        
        // iCloud KVS 최신값 동기화
        NSUbiquitousKeyValueStore.default.synchronize()
        print("KVS seedVersion =", SeedKVS.version())
        
        @Dependency(\.modelContext) var modelContext
        do {
            try CategorySeeder.runIfNeeded(modelContext: modelContext)
            print("✅ Seed checked")
        } catch {
            assertionFailure("기본 카테고리 시딩 실패: \(error.localizedDescription)")
        }

        let appFlow = AppFlow(windowScene: windowScene)
        
        coordinator.coordinate(
            flow: appFlow,
            with: OneStepper(withSingleStep: AppStep.eventList)
        )


//        let appFlow = AppFlow(windowScene: windowScene)
//        coordinator.coordinate(
//            flow: appFlow,
//            with: OneStepper(withSingleStep: AppStep.createSchedule)
////            with: OneStepper(withSingleStep: AppStep.updateSchedule(testItem))
//        )
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
