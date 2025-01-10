//
//  SessionService.swift
//  AAW
//
//  Created by Tim Hazhyi on 27.12.2024.
//

import Foundation
import HealthKit
import WatchConnectivity

class SessionService: NSObject, ObservableObject {
    struct SessionStateChange {
        let newState: HKWorkoutSessionState
        let date: Date
    }
    
    var selectedWorkout: HKWorkoutConfiguration? {
        didSet {
            guard let selectedWorkout = selectedWorkout else { return }
            resetWorkout()
            name = WorkoutType(healthType: Int(selectedWorkout.activityType.rawValue)).name
            #if os(watchOS)
            Task {
                try await startWorkout(workoutConfiguration: selectedWorkout)
            }
            #endif
        }
    }
    private var wcSession: WCSession?
    private let asyncStream = AsyncStream.makeStream(of: SessionStateChange.self, bufferingPolicy: .bufferingNewest(1))
    @Published var sessionState: HKWorkoutSessionState = .notStarted
    @Published var averageHeartRate: Double = 0
    @Published var heartRate: Double = 0
    @Published var activeEnergy: Double = 0
    @Published var elapsedTimeInterval: TimeInterval = 0
    @Published var name: String?
    @Published var workout: HKWorkout?
    @Published var shouldFetchSamples: Bool = false
    @Published var showingSummaryView: Bool = false {
        didSet {
            if showingSummaryView == false {
                resetWorkout()
            }
        }
    }

    internal let healthService: HealthService
    internal var session: HKWorkoutSession?
    
    init(healthService: HealthService = HealthService()) {
        self.healthService = healthService
        super.init()
        Task {
            for await value in asyncStream.stream {
                await consumeSessionStateChange(value)
            }
        }
        #if os(iOS)
        if WCSession.isSupported() {
            self.wcSession = WCSession.default
            self.wcSession?.delegate = self
            self.wcSession?.activate()
        }
        retrieveRemoteSession()
        #endif
    }

    #if os(watchOS)
    var builder: HKLiveWorkoutBuilder?
    #else
    var contextDate: Date?
    #endif

    func endWorkout() {
        shouldFetchSamples = true
        session?.stopActivity(with: .now)
        showingSummaryView = true
    }
    
    @MainActor
    private func consumeSessionStateChange(_ change: SessionStateChange) async {
        sessionState = change.newState
        #if os(watchOS)
        let elapsedTimeInterval = session?.associatedWorkoutBuilder().elapsedTime(at: change.date) ?? 0
        let elapsedTime = WorkoutElapsedTime(timeInterval: elapsedTimeInterval, date: change.date)
        if let elapsedTimeData = try? JSONEncoder().encode(elapsedTime) {
            await sendData(elapsedTimeData)
        }

        guard change.newState == .stopped, let builder else {
            return
        }

        let finishedWorkout: HKWorkout?
        do {
            try await builder.endCollection(at: change.date)
            finishedWorkout = try await builder.finishWorkout()
            session?.end()
        } catch {
            return
        }
        workout = finishedWorkout
        showingSummaryView = true
        #endif
    }

    func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }

        DispatchQueue.main.async {
            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                self.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                self.averageHeartRate = statistics.averageQuantity()?.doubleValue(for: heartRateUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                let energyUnit = HKUnit.kilocalorie()
                self.activeEnergy = statistics.sumQuantity()?.doubleValue(for: energyUnit) ?? 0
            default:
                return
            }
        }
    }

    func resetWorkout() {
        #if os(watchOS)
        builder = nil
        #endif
        workout = nil
        session = nil
        activeEnergy = 0
        averageHeartRate = 0
        heartRate = 0
        name = nil
        sessionState = .notStarted
    }
    
    func retrieveRemoteSession() {
        healthService.healthStore.workoutSessionMirroringStartHandler = { mirroredSession in
            Task { @MainActor in
                self.resetWorkout()
                self.session = mirroredSession
                self.session?.delegate = self
                self.name = mirroredSession.workoutConfiguration.activityType.name
                self.sessionState = mirroredSession.state
            }
        }
    }
    
    func sendData(_ data: Data) async {
        do {
            try await session?.sendToRemoteWorkoutSession(data: data)
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension SessionService: HKWorkoutSessionDelegate {
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession,
                                    didChangeTo toState: HKWorkoutSessionState,
                                    from fromState: HKWorkoutSessionState,
                                    date: Date) {
        let sessionSateChange = SessionStateChange(newState: toState, date: date)
        asyncStream.continuation.yield(sessionSateChange)
    }
        
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession,
                                    didFailWithError error: Error) {
    }
    
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession,
                                    didDisconnectFromRemoteDeviceWithError error: Error?) {
    }
    
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession,
                                    didReceiveDataFromRemoteWorkoutSession data: [Data]) {
        Task { @MainActor in
            do {
                for anElement in data {
                    try handleReceivedData(anElement)
                }
            } catch {

            }
        }
    }
}

extension SessionService: WCSessionDelegate {
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) { }
    
    func sessionDidDeactivate(_ session: WCSession) { }
    #endif
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
}

struct WorkoutElapsedTime: Codable {
    var timeInterval: TimeInterval
    var date: Date
}

extension HKWorkoutSessionState {
    var isActive: Bool {
        get { self != .notStarted && self != .ended }
        set { }
    }
}
