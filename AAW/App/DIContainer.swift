//
//  DIContainer.swift
//  AAW
//
//  Created by Tim Hazhyi on 02.12.2024.
//

import Foundation

final class DIContainer: NSObject, ObservableObject {
    static let shared = DIContainer()

    let healthService: HealthService
    var sessionService: SessionService
    let storageService: StorageService
    let workoutService: WorkoutService
    let geminiService: GeminiService
    let notificationService: NotificationService
    let featureFlagService: FeatureFlagService

    private override init() {
        healthService = HealthService()
        storageService = StorageService()
        sessionService = SessionService(healthService: healthService)
        featureFlagService = FeatureFlagService()
        notificationService = NotificationService()
        geminiService = GeminiService()
        workoutService = WorkoutService(healthService: healthService,
                                        notificationService: notificationService,
                                        storageService: storageService)
    }
}

