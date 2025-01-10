//
//  HealthService.swift
//  AAW
//
//  Created by Tim Hazhyi on 02.12.2024.
//

import HealthKit

class HealthService {
    static let workoutType: HKSampleType = HKQuantityType.workoutType()
    private var lastAnchor: HKQueryAnchor?
    private let typesToShare: Set = [HealthService.workoutType]
    internal let healthStore = HKHealthStore()

    private let typesToRead: Set = [
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.activitySummaryType(),
        HealthService.workoutType
    ]
    
    static func getAllWorkoutTypes() -> [HKWorkoutActivityType] {
        var activityTypes: [HKWorkoutActivityType] = []
        for rawValue in HKWorkoutActivityType.americanFootball.rawValue...HKWorkoutActivityType.underwaterDiving.rawValue {
            if let activityType = HKWorkoutActivityType(rawValue: rawValue) {
                activityTypes.append(activityType)
            }
        }
        return activityTypes
    }
    
    func fetchSamples() async throws -> [HKWorkout] {
        try await fetchSamplesAsync()
    }
    
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else { throw HealthKitError.notAvailable }
        try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
    }
    
    func resolveObservingChanges() async throws -> (samples: [HKWorkout], added: HKWorkout?) {
        if lastAnchor == nil {
            return (try await fetchSamples(), nil)
        } else {
            let added = try await getAddedSamples()
            let samples = try await fetchSamples()
            guard let first = added.first, Calendar.current.isDateInToday(first.endDate) else { return (samples, nil) }
            return (samples, first)
        }
    }
    
    func startObservingChanges(updateHandler: @escaping @Sendable (HKObserverQuery, @escaping HKObserverQueryCompletionHandler, (any Error)?) -> Void) {
        let query: HKObserverQuery = HKObserverQuery(sampleType: HealthService.workoutType, predicate: nil, updateHandler: updateHandler)
        healthStore.enableBackgroundDelivery(for: HealthService.workoutType, frequency: .immediate) { _, _ in }
        healthStore.execute(query)
    }
    
    private func fetchSamplesAsync() async throws -> [HKWorkout] {
        try await requestAuthorization()
        let query = HKSampleQueryDescriptor(
                predicates: [.workout()],
                sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)],
                limit: HKObjectQueryNoLimit
            )
        let anchoredQuery = HKAnchoredObjectQueryDescriptor(predicates: [.workout()], anchor: nil)
        let anchoredResult = try? await anchoredQuery.result(for: healthStore)
        self.lastAnchor = anchoredResult?.newAnchor
        
        return try await query.result(for: healthStore)
    }
    
    private func getAddedSamples() async throws -> [HKWorkout] {
        let anchoredQuery = HKAnchoredObjectQueryDescriptor(predicates: [.workout()], anchor: lastAnchor)
        let anchoredResult = try await anchoredQuery.result(for: healthStore)
        self.lastAnchor = anchoredResult.newAnchor
        return anchoredResult.addedSamples
    }
}

enum HealthKitError: Error {
    case notAvailable
    case fetchingFailed
}

extension HKWorkoutActivityType {
    var name: String {
        switch self {
        case .americanFootball:             return "American Football"
        case .archery:                      return "Archery"
        case .australianFootball:           return "Australian Football"
        case .badminton:                    return "Badminton"
        case .baseball:                     return "Baseball"
        case .basketball:                   return "Basketball"
        case .bowling:                      return "Bowling"
        case .boxing:                       return "Boxing"
        case .cardioDance:                  return "Cardio Dance"
        case .climbing:                     return "Climbing"
        case .crossTraining:                return "Cross Training"
        case .curling:                      return "Curling"
        case .cooldown:                     return "Cooldown"
        case .cricket:                      return "Cricket"
        case .cycling:                      return "Cycling"
        case .dance:                        return "Dance"
        case .danceInspiredTraining:        return "Dance Inspired Training"
        case .elliptical:                   return "Elliptical"
        case .equestrianSports:             return "Equestrian Sports"
        case .fencing:                      return "Fencing"
        case .fishing:                      return "Fishing"
        case .functionalStrengthTraining:   return "Functional Strength Training"
        case .golf:                         return "Golf"
        case .gymnastics:                   return "Gymnastics"
        case .handball:                     return "Handball"
        case .hiking:                       return "Hiking"
        case .hockey:                       return "Hockey"
        case .hunting:                      return "Hunting"
        case .lacrosse:                     return "Lacrosse"
        case .martialArts:                  return "Martial Arts"
        case .mindAndBody:                  return "Mind and Body"
        case .mixedMetabolicCardioTraining: return "Mixed Metabolic Cardio Training"
        case .paddleSports:                 return "Paddling"
        case .play:                         return "Play"
        case .pickleball:                   return "Pickleball"
        case .preparationAndRecovery:       return "Preparation and Recovery"
        case .racquetball:                  return "Racquetball"
        case .rowing:                       return "Rowing"
        case .rugby:                        return "Rugby"
        case .running:                      return "Running"
        case .sailing:                      return "Sailing"
        case .skatingSports:                return "Skating Sports"
        case .snowSports:                   return "Snow Sports"
        case .soccer:                       return "Soccer"
        case .socialDance:                  return "Social Dance"
        case .softball:                     return "Softball"
        case .squash:                       return "Squash"
        case .stairClimbing:                return "Stair Climbing"
        case .surfingSports:                return "Surfing Sports"
        case .swimming:                     return "Swimming"
        case .swimBikeRun:                  return "Swim Bike Run"
        case .tableTennis:                  return "Table Tennis"
        case .tennis:                       return "Tennis"
        case .trackAndField:                return "Track and Field"
        case .traditionalStrengthTraining:  return "Traditional Strength Training"
        case .transition:                   return "Transition"
        case .underwaterDiving:             return "Underwater Diving"
        case .volleyball:                   return "Volleyball"
        case .walking:                      return "Walking"
        case .waterFitness:                 return "Water Fitness"
        case .waterPolo:                    return "Water Polo"
        case .waterSports:                  return "Water Sports"
        case .wrestling:                    return "Wrestling"
        case .yoga:                         return "Yoga"

        // iOS 10
        case .barre:                        return "Barre"
        case .coreTraining:                 return "Core Training"
        case .crossCountrySkiing:           return "Cross Country Skiing"
        case .downhillSkiing:               return "Downhill Skiing"
        case .flexibility:                  return "Flexibility"
        case .highIntensityIntervalTraining:    return "High Intensity Interval Training"
        case .jumpRope:                     return "Jump Rope"
        case .kickboxing:                   return "Kickboxing"
        case .pilates:                      return "Pilates"
        case .snowboarding:                 return "Snowboarding"
        case .stairs:                       return "Stairs"
        case .stepTraining:                 return "Step Training"
        case .wheelchairWalkPace:           return "Wheelchair Walk Pace"
        case .wheelchairRunPace:            return "Wheelchair Run Pace"

        // iOS 11
        case .taiChi:                       return "Tai Chi"
        case .mixedCardio:                  return "Mixed Cardio"
        case .handCycling:                  return "Hand Cycling"

        // iOS 13
        case .discSports:                   return "Disc Sports"
        case .fitnessGaming:                return "Fitness Gaming"

        // Catch-all
        default:
            return "Other"
        }
    }
    
    var iconName: String {
        workoutIcons[self] ?? "questionmark"
    }

}

let workoutIcons: [HKWorkoutActivityType: String] = [
    .americanFootball: "figure.american.football",   // American Football
    .archery: "figure.archery",                      // Archery
    .australianFootball: "figure.australian.football",// Australian Football
    .badminton: "figure.badminton",                  // Badminton
    .baseball: "figure.baseball",                    // Baseball
    .basketball: "figure.basketball",                // Basketball
    .bowling: "figure.bowling",                      // Bowling
    .boxing: "figure.boxing",                        // Boxing
    .climbing: "figure.climbing",                    // Climbing
    .cricket: "figure.cricket",                      // Cricket
    .crossTraining: "flame",                         // Cross Training
    .curling: "figure.curling",                      // Curling
    .cycling: "bicycle",                             // Cycling
    .dance: "figure.dance",                          // Dance
    .danceInspiredTraining: "figure.dance",          // Dance Inspired Training
    .elliptical: "figure.elliptical",                // Elliptical
    .equestrianSports: "figure.equestrian.sports",   // Equestrian Sports
    .fencing: "figure.fencing",                      // Fencing
    .fishing: "figure.fishing",                      // Fishing
    .functionalStrengthTraining: "figure.strengthtraining.traditional", // Functional Strength Training
    .golf: "figure.golf",                            // Golf
    .gymnastics: "figure.gymnastics",                // Gymnastics
    .handball: "figure.handball",                    // Handball
    .hiking: "figure.hiking",                        // Hiking
    .hockey: "figure.hockey",                        // Hockey
    .hunting: "figure.hunting",                      // Hunting
    .lacrosse: "figure.lacrosse",                    // Lacrosse
    .martialArts: "figure.martial.arts",             // Martial Arts
    .mindAndBody: "figure.mind.and.body",            // Mind and Body
    .mixedMetabolicCardioTraining: "flame",          // Mixed Metabolic Cardio Training
    .paddleSports: "oar.2.crossed",                  // Paddling
    .play: "gamecontroller",                         // Play
    .preparationAndRecovery: "hourglass",            // Preparation and Recovery
    .racquetball: "figure.racquetball",              // Racquetball
    .rowing: "figure.outdoor.rowing",                // Rowing
    .rugby: "figure.rugby",                          // Rugby
    .running: "figure.run",                          // Running
    .sailing: "figure.sailing",                      // Sailing
    .skatingSports: "figure.skating",                // Skating Sports
    .snowSports: "snowflake",                        // Snow Sports
    .soccer: "figure.soccer",                        // Soccer
    .softball: "figure.softball",                    // Softball
    .squash: "figure.squash",                        // Squash
    .stairClimbing: "figure.stairs",                 // Stair Climbing
    .surfingSports: "figure.surfing",                // Surfing Sports
    .swimming: "figure.pool.swim",                   // Swimming
    .tableTennis: "figure.table.tennis",             // Table Tennis
    .tennis: "figure.tennis",                        // Tennis
    .trackAndField: "figure.track.and.field",        // Track and Field
    .traditionalStrengthTraining: "figure.strengthtraining.traditional", // Traditional Strength Training
    .volleyball: "figure.volleyball",                // Volleyball
    .walking: "figure.walk",                         // Walking
    .waterFitness: "figure.water.fitness",           // Water Fitness
    .waterPolo: "figure.waterpolo",                  // Water Polo
    .waterSports: "water.waves",                     // Water Sports
    .wrestling: "figure.wrestling",                  // Wrestling
    .yoga: "figure.yoga",                            // Yoga
    .barre: "figure.barre",                          // Barre
    .coreTraining: "figure.core.training",           // Core Training
    .crossCountrySkiing: "figure.skiing.crosscountry",            // Cross Country Skiing
    .downhillSkiing: "figure.skiing.downhill",       // Downhill Skiing
    .flexibility: "figure.flexibility",              // Flexibility
    .highIntensityIntervalTraining: "flame",         // High Intensity Interval Training
    .jumpRope: "figure.jumprope",                    // Jump Rope
    .kickboxing: "figure.kickboxing",                // Kickboxing
    .pilates: "figure.pilates",                      // Pilates
    .snowboarding: "figure.snowboarding",            // Snowboarding
    .stairs: "figure.stairs",                        // Stairs
    .stepTraining: "figure.step.training",           // Step Training
    .wheelchairWalkPace: "figure.roll",              // Wheelchair Walk Pace
    .wheelchairRunPace: "figure.roll.runningpace",   // Wheelchair Run Pace
    .taiChi: "figure.taichi",                        // Tai Chi
    .mixedCardio: "flame",                           // Mixed Cardio
    .handCycling: "figure.hand.cycling",             // Hand Cycling
    .discSports: "figure.disc.sports",               // Disc Sports
    .fitnessGaming: "gamecontroller",                // Fitness Gaming
    .cardioDance: "figure.dance",                    // Cardio Dance
    .socialDance: "figure.socialdance",              // Social Dance
    .pickleball: "figure.pickleball",                // Pickleball
    .cooldown: "figure.cooldown",                    // Cooldown
    .other: "questionmark",                          // Other
    .swimBikeRun: "medal",                           // Swim Bike Run
    .transition: "hourglass",                        // Transition
    .underwaterDiving: "water.waves.and.arrow.trianglehead.down"               // Underwater Diving
]
