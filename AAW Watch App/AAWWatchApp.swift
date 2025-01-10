//
//  AAW_WatchApp.swift
//  AAW Watch Watch App
//
//  Created by Tim Hazhyi on 27.12.2024.
//

import SwiftUI
import WatchKit
import HealthKit

@main
struct AAWWatchApp: App {
    @WKApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var sessionService = SessionService()
    
    var body: some Scene {
        WindowGroup {
            SessionPagingView(sessionViewData: AppDelegate.sessionViewData)
                .environmentObject(sessionService)
                .sheet(isPresented:$sessionService.showingSummaryView) {
                    SummaryView()
                        .environmentObject(sessionService)
                }
        }
    }
}

class AppDelegate: NSObject, WKApplicationDelegate {
    public static var sessionViewData: SessionViewData = SessionViewData()
    
    func handle(_ workoutConfiguration: HKWorkoutConfiguration) {
        AppDelegate.sessionViewData.configuration = workoutConfiguration
    }
}
