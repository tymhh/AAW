//
//  ByTypeViewModel.swift
//  AAW
//
//  Created by Tim Hazhyi on 18.12.2024.
//

import Foundation
import HealthKit
import OrderedCollections
import WatchConnectivity

@MainActor
class ByTypeViewModel: NSObject, ObservableObject {
    enum State {
        case loading
        case content
    }
    
    @Published var state: State = .content
    @Published var title: String
    @Published var data: OrderedDictionary<String, [Workout]> = [:]
    @Published var currentStreak: Int
    @Published var longestStreak: Int
    @Published var info: [String: String]?
    @Published var activeWCSession: Bool = false
    private let geminiService: GeminiServiceProtocol
    private let healthService: HealthServiceProtocol
    internal let sessionService: SessionService
    internal let featureFlagService: FeatureFlagServiceProtocol
    internal let type: WorkoutType
    
    init(type: WorkoutType,
         geminiService: GeminiServiceProtocol = DIContainer.shared.geminiService,
         healthService: HealthServiceProtocol = DIContainer.shared.healthService,
         featureFlagService: FeatureFlagServiceProtocol = DIContainer.shared.featureFlagService,
         sessionService: SessionService = DIContainer.shared.sessionService) {
        self.geminiService = geminiService
        self.healthService = healthService
        self.sessionService = sessionService
        self.featureFlagService = featureFlagService
        self.type = type
        self.title = type.name
        self.data = ByTypeViewModel.groupWorkoutsByMonth(type.done)
        let streak = ByTypeViewModel.calculateStreak(type.done.map { $0.date })
        currentStreak = streak.current
        longestStreak = streak.longest
        super.init()
        getActiveWCSession() { [weak self] session in
            self?.activeWCSession = session.isWatchAppInstalled
        }
    }
    
    static func groupWorkoutsByMonth(_ workouts: [Workout]) -> OrderedDictionary<String, [Workout]> {
        let groupedWorkouts = OrderedDictionary(grouping: workouts) { workout in
            return DateFormatter.monthGroup.string(from: workout.date)
        }
        return groupedWorkouts
    }
    
    static func calculateCurrentSteak(_ dates: [Date]) -> Int {
        guard let first = dates.first,
              (Calendar.current.isDateInToday(first) ||
              Calendar.current.isDateInYesterday(first))
        else { return 0 }
        var previousDate: Date?
        var currentStreak = 0
        for date in dates {
            if let prev = previousDate {
                if Calendar.current.isDate(date, inSameDayAs: prev) {
                    continue
                } else if Calendar.current.isDate(date, inSameDayAs: Calendar.current.date(byAdding: .day, value: -1, to: prev) ?? prev) {
                    currentStreak += 1
                } else {
                    return currentStreak
                }
            } else {
                currentStreak = 1
            }
            previousDate = date
        }
        return currentStreak
    }
    
    static func calculateStreak(_ dates: [Date]) -> (current: Int, longest: Int) {
        let sortedDates = dates.reversed()
        var currentStreak = 0
        var longestStreak = 0
        var previousDate: Date?
        
        for date in sortedDates {
            if let prev = previousDate {
                if Calendar.current.isDate(date, inSameDayAs: prev) {
                    continue
                } else if Calendar.current.isDate(date, inSameDayAs: Calendar.current.date(byAdding: .day, value: 1, to: prev) ?? prev) {
                    currentStreak += 1
                } else {
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }
            longestStreak = max(longestStreak, currentStreak)
            previousDate = date
        }
        
        if let lastDate = sortedDates.last,
           !Calendar.current.isDateInToday(lastDate) &&
            !Calendar.current.isDateInYesterday(lastDate) {
            currentStreak = 0
        }
        
        longestStreak = max(longestStreak, currentStreak)
        return (currentStreak, longestStreak)
    }
    
    func requestInfo() async {
        state = .loading
        let info = (try? await geminiService.streamMessage(prompt: WorkoutRequestObjcet(workout: title).promt)) ?? [:]
        self.info = info
        state = .content
    }
    
    func startWatchApp() {
        guard let activityType = HKWorkoutActivityType(rawValue: UInt(type.healthType)) else { return }
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = activityType
        
        getActiveWCSession { (wcSession) in
            if wcSession.activationState == .activated && wcSession.isWatchAppInstalled {
                Task {
                    try await self.healthService.healthStore.startWatchApp(toHandle: configuration)
                }
            }
        }
    }
    
    func getActiveWCSession(completion: @escaping (WCSession)->Void) {
        guard WCSession.isSupported() else { return }
        
        let wcSession = WCSession.default
        wcSession.delegate = sessionService
        
        if wcSession.activationState == .activated {
            completion(wcSession)
        } else {
            wcSession.activate()
        }
    }
}
