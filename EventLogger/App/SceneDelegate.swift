//
//  SceneDelegate.swift
//  EventLogger
//
//  Created by 김우성 on 8/20/25.
//

import Dependencies
import RxSwift
import RxFlow
import RxRelay
import UIKit
import CoreData
import CloudKit

class AppStepper: Stepper {
    
    let steps = PublishRelay<Step>()
    let disposeBag = DisposeBag()
    
    func readyToEmitSteps() {
        @UserSetting(key: UDKey.didSetupDefaultCategories, defaultValue: false)
        var didSetupDefaultCategories: Bool
//        if didSetupDefaultCategories { // 카테고리가 시딩이 되어있으면
//            steps.accept(AppStep.eventList)
//            return
//        }
        // 최초 실행시 카테고리 시딩
        let notification = NSPersistentCloudKitContainer.eventChangedNotification
        NotificationCenter.default.rx.notification(notification).take(1)
            .debug()
            .subscribe(onNext: { [steps] _ in
//                @Dependency(\.swiftDataManager) var swiftDataManager
//                let categories = swiftDataManager.fetchAllCategories()
//                
//                if categories.isEmpty {
//                    //카테고리가 비어있으면 시딩함수 실행
//                    @Dependency(\.modelContext) var modelContext
//                    do {
//                        try CategorySeeder.runIfNeeded(modelContext: modelContext)
//                        print("✅ Seed checked")
//                    } catch {
//                        assertionFailure("기본 카테고리 시딩 실패: \(error.localizedDescription)")
//                    }
//                }
                steps.accept(AppStep.eventList)
            })
            .disposed(by: disposeBag)
        Task {
            do {
                try await probeCloudPresence(recordType: "")
            } catch {
                print(error)
            }
        }
    }
    
    func probeCloudPresence(recordType: String) async throws -> Bool {
      let container = CKContainer(identifier: "iCloud.UltraOrange.EventLogger")
        let predicate = NSPredicate(value: true)
            let query = CKQuery(recordType: "CD_CategoryStore", predicate: predicate)
            do {
                let items = (try await container.privateCloudDatabase.records(matching: query)).matchResults
                return items.isEmpty
            } catch {
                print(error)
                return false
                // this is for the answer's simplicity,
                // but obviously you should handle errors accordingly.
            }
      
    }
    
    func checkIfDataExists(completion: @escaping (Bool) -> Void) {
        let container = CKContainer.default()
        let privateDB = container.privateCloudDatabase
        let query = CKQuery(recordType: "EventStore", predicate: NSPredicate(value: true))
        let queryOperation = CKQueryOperation(query: query)
        var found = false

        queryOperation.recordFetchedBlock = { record in
            found = true
        }

        queryOperation.queryCompletionBlock = { _, _ in
            completion(found)
        }

        privateDB.add(queryOperation)
    }
}


class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private let coordinator = FlowCoordinator()
    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
               
        let appFlow = AppFlow(windowScene: windowScene)
        
//        @Dependency(\.modelContext) var modelContext
//        do {
//            try CategorySeeder.runIfNeeded(modelContext: modelContext)
//            print("✅ Seed checked")
//        } catch {
//            assertionFailure("기본 카테고리 시딩 실패: \(error.localizedDescription)")
//        }
        
        coordinator.coordinate(
            flow: appFlow,
//            with: AppStepper()
            with: OneStepper(withSingleStep: AppStep.eventList)
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
