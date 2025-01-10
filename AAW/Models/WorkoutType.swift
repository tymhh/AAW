//
//  WorkoutType.swift
//  AAW
//
//  Created by Tim Hazhyi on 02.12.2024.
//

import HealthKit

struct WorkoutType: Identifiable, Hashable, Codable {
    let id: UUID
    let healthType: Int
    let name: String
    let iconName: String?
    var done: [Workout] = []
    
    init(id: UUID = UUID(), healthType: Int, done: [Workout] = []) {
        self.id = id
        self.healthType = healthType
        let type = (HKWorkoutActivityType(rawValue: UInt(healthType)) ?? .other)
        self.name = type.name
        self.iconName = type.iconName
        self.done = done
    }
}
