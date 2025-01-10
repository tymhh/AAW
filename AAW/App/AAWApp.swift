//
//  AAWApp.swift
//  AAW
//
//  Created by Tim Hazhyi on 01.12.2024.
//

import SwiftUI

@main
struct AAWApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelagate
    @StateObject private var diContainer = DIContainer.shared
    @StateObject private var appCoordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appCoordinator)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        DIContainer.shared.workoutService.startObservingChanges()
        return true
    }
}
