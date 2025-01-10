//
//  Workout.swift
//  AAW
//
//  Created by Tim Hazhyi on 02.12.2024.
//

import HealthKit

struct Workout: Hashable, Codable {
    let id: UUID
    let type: Int
    let date: Date
    
    init(id: UUID = UUID(), type: Int, date: Date) {
        self.id = id
        self.type = type
        self.date = date
    }
}
