//
//  WorkoutViewModel.swift
//  AAW
//
//  Created by Tim Hazhyi on 02.12.2024.
//

import Foundation
import HealthKit
import WidgetKit
import Combine

@MainActor
class WorkoutViewModel: ObservableObject {
    enum State {
        case loading
        case content
    }
    
    enum Filter: CaseIterable {
        case all
        case done
        case undone
    }
    
    private var cancellables: Set<AnyCancellable> = []
    private var data: [WorkoutType] = []
    private let workoutService: WorkoutServiceProtocol
    private let storageService: StorageServiceProtocol
    private let healthService: HealthServiceProtocol
    private let cloudKitService: CloudKitServiceProtocol
    internal let sessionService: SessionService
    
    @Published var displayList: [WorkoutType] = []
    @Published var state: State = .loading
    @Published var error: String?
    @Published var progress: CGFloat = 0
    @Published var progressString: String
    @Published var progressPercent: String = "...%"
    @Published var userRanking: Int?
    @Published var filter: Filter = .all

    init(workoutService: WorkoutServiceProtocol = DIContainer.shared.workoutService,
         sessionService: SessionService = DIContainer.shared.sessionService,
         HealthService: HealthServiceProtocol = DIContainer.shared.healthService,
         cloudKitService: CloudKitServiceProtocol = DIContainer.shared.cloudKitService,
         storageService: StorageServiceProtocol = DIContainer.shared.storageService) {
        self.workoutService = workoutService
        self.sessionService = sessionService
        self.storageService = storageService
        self.healthService = HealthService
        self.cloudKitService = cloudKitService
        self.progressString = "... / \(workoutService.allTypes.count)"
        self.userRanking = storageService.fetchUserProgress(userId: nil)?.value
        
        subscribeToSamplesUpdate()
    }

    func fetchWorkouts(_ prefetch: (data: [WorkoutType], progress: Int)? = nil, force: Bool = false) async {
        guard state != .content || force else { return }
        if !force {
            state = .loading
        }
        do {
            var fetch: (data: [WorkoutType], progress: Int)
            if let prefetch {
                fetch = prefetch
            } else {
                fetch = try await workoutService.fetchList()
            }
            data = fetch.data.sorted(by: {
                $0.name.localizedCaseInsensitiveCompare( $1.name) == .orderedAscending
            })
            displayList = applyFilter()
            resolveProgress(fetch.progress)
            saveSteaks()
            reloadWidget()
            saveUserProgress(fetch.progress)
            error = nil
        } catch {
            displayList = workoutService.allTypes.map { .init(healthType: Int($0.rawValue)) }
            self.error = "Failed to load workouts."
        }
        state = .content
    }
    
    func applyNextFilter() {
        self.filter = self.filter.next()
        self.displayList = applyFilter()
    }
    
    private func resolveProgress(_ fetch: Int) {
        self.progress = CGFloat(fetch) / CGFloat(workoutService.allTypes.count)
        self.progressString = "\(fetch) / \(workoutService.allTypes.count)"
        self.progressPercent = NumberFormatter.percent.string(from: progress as NSNumber) ?? progressPercent
    }
    
    private func subscribeToSamplesUpdate() {
        workoutService.samplesPublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] samples in
                Task {
                    guard let prefetch = self?.workoutService.processFetchedSamples(samples) else { return }
                    await self?.fetchWorkouts(prefetch, force: true)
                }
            }
            .store(in: &cancellables)
    }
    
    private func applyFilter() -> [WorkoutType] {
        return self.data.filter {
            switch filter {
            case .all:
                return true
            case .done:
                return !$0.done.isEmpty
            case .undone:
                return $0.done.isEmpty
            }
        }
    }
    
    private func saveSteaks() {
        let value = data.reduce(into: [:]) {
            $0[$1.healthType] = StreakObject(streak: ByTypeViewModel.calculateCurrentSteak($1.done.map { $0.date }),
                                             lastDate: $1.done.first?.date)
        }
        storageService.saveStreaks(value)
    }
    
    private func reloadWidget() {
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func saveUserProgress(_ fetch: Int) {
        Task {
            let record = try await cloudKitService.updateOrCreateUserProgress(newProgress: fetch)
            let rank = try await cloudKitService.findUserRank()
            userRanking = rank.map { ($0) }
            storageService.saveOrUpdateUserProgress(
                record: .init(userId: record["userId"] as? String,
                              value: rank)
            )
        }
    }
}

private extension CaseIterable where Self: Equatable {
    func next() -> Self {
        let all = Self.allCases
        let idx = all.firstIndex(of: self)!
        let next = all.index(after: idx)
        return all[next == all.endIndex ? all.startIndex : next]
    }
}
