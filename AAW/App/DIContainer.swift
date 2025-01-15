//
//  DIContainer.swift
//  AAW
//
//  Created by Tim Hazhyi on 02.12.2024.
//

import Foundation

final class DIContainer: NSObject, ObservableObject {
    static let shared = DIContainer()

    var sessionService: SessionService
    let healthService: HealthServiceProtocol
    let storageService: StorageServiceProtocol
    let workoutService: WorkoutServiceProtocol
    let geminiService: GeminiServiceProtocol
    let notificationService: NotificationService
    let featureFlagService: FeatureFlagServiceProtocol
    let cloudKitService: CloudKitServiceProtocol

    private override init() {
        notificationService = NotificationService()
        geminiService = GeminiService()
        let healthService = HealthService()
        self.healthService = healthService
        let storageService = StorageService()
        self.storageService = StorageService()
        let cloudKitService = CloudKitService()
        self.cloudKitService = cloudKitService
        sessionService = SessionService(healthService: healthService)
        featureFlagService = FeatureFlagService(cloudKitService: cloudKitService)
        workoutService = WorkoutService(healthService: healthService,
                                        notificationService: notificationService,
                                        storageService: storageService)
    }
}

