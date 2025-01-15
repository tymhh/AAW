//
//  WorkoutService.swift
//  AAW
//
//  Created by Tim Hazhyi on 02.12.2024.
//

import HealthKit
import WidgetKit
import Combine

protocol WorkoutServiceProtocol {
    func fetchList() async throws -> (data: [WorkoutType], progress: Int)
    func processFetchedSamples(_ workouts: [HKWorkout]) -> (data: [WorkoutType], progress: Int)
    func startObservingChanges()
    
    var samples: [HKWorkout]? { get }
    var samplesPublished: Published<[HKWorkout]?> { get }
    var samplesPublisher: Published<[HKWorkout]?>.Publisher { get }
    var allTypes: [HKWorkoutActivityType] { get }
}

class WorkoutService: WorkoutServiceProtocol {
    
    private let healthService: HealthService
    private let storageService: StorageService
    private let notificationService: NotificationService
    let allTypes: [HKWorkoutActivityType]
    @Published var samples: [HKWorkout]?
    var samplesPublished: Published<[HKWorkout]?> { _samples }
    var samplesPublisher: Published<[HKWorkout]?>.Publisher { $samples }
    
    init(healthService: HealthService,
         notificationService: NotificationService,
         storageService: StorageService) {
        self.healthService = healthService
        self.notificationService = notificationService
        self.storageService = storageService
        allTypes = HealthService.getAllWorkoutTypes()
    }
    
    func fetchList() async throws -> (data: [WorkoutType], progress: Int) {
        let workouts = try await healthService.fetchSamples()
        return processFetchedSamples(workouts)
    }
    
    func processFetchedSamples(_ workouts: [HKWorkout]) -> (data: [WorkoutType], progress: Int) {
        var progress: Int = 0
        let list: [WorkoutType] = allTypes
            .reduce(into: [], { result, item in
                let type = Int(item.rawValue)
                let done: [Workout] = workouts
                    .filter { $0.workoutActivityType.rawValue == type }
                    .map { .init(type: Int($0.workoutActivityType.rawValue), date: $0.endDate) }
                result.append(.init(healthType: type, done: done))
                if !done.isEmpty { progress += 1 }
            })
        return (list, progress)
    }
    
    func startObservingChanges() {
        Task {
            try await healthService.requestAuthorization()
            healthService.startObservingChanges { [weak self] _, updateHandler, _ in
                Task {
                    let changes = try? await self?.healthService.resolveObservingChanges()
                    self?.samples = changes?.samples ?? []
                    if let added = changes?.added, let body = self?.resolveNotification(for: added) {
                        self?.notificationService.schedule(title: "Keep going!", body: body)
                    }
                    await MainActor.run {
                        updateHandler()
                    }
                }
            }
        }
    }
    
    private func resolveNotification(for workout: HKWorkout) -> String? {
        var notificationBody: String? = nil
        
        guard var streaks = storageService.getStreaks(),
              let streakObject = streaks[Int(workout.workoutActivityType.rawValue)]
        else { return nil }
        
        var flag = false
        
        if let lastDate = streakObject.lastDate, streakObject.streak > 0 {
            flag = Calendar.current.isDateInYesterday(lastDate) &&
            Calendar.current.isDateInToday(workout.endDate)
        } else {
            flag = streakObject.streak == 0
        }
        
        guard flag else { return nil }
        let newStreak = streakObject.streak + 1
        notificationBody = "\(workout.workoutActivityType.name) streak is \(newStreak.pluralDaysString)"
        streaks[Int(workout.workoutActivityType.rawValue)] = .init(streak: newStreak,
                                                                   lastDate: workout.endDate)
        storageService.saveStreaks(streaks)
        WidgetCenter.shared.reloadAllTimelines()
        return notificationBody
    }
}
