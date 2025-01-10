//
//  StreakObject.swift
//  AAW
//
//  Created by Tim Hazhyi on 05.01.2025.
//

import Foundation

struct StreakObject: Codable {
    let streak: Int
    let lastDate: Date?
    
    init(streak: Int, lastDate: Date?) {
        self.streak = streak
        self.lastDate = lastDate
    }
    
}
