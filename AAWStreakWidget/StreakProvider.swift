//
//  StreakProvider.swift
//  AAW
//
//  Created by Tim Hazhyi on 03.01.2025.
//

import SwiftUI
import WidgetKit

struct StreakProvider: AppIntentTimelineProvider {
    let sharedSerice = StorageService()
    
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: .now, sportStreaks: [
            .init(id: 1, iconName: "figure.dance", currentStreak: 4),
            .init(id: 2, iconName: "bicycle", currentStreak: 2),
            .init(id: 2, iconName: "figure.mind.and.body", currentStreak: 40)
        ])
    }
    
    func snapshot(for configuration: StreakAppIntent, in context: Context) async -> StreakEntry {
        StreakEntry(date: .now, sportStreaks: [
            .init(id: 1, iconName: "figure.dance", currentStreak: 4),
            .init(id: 2, iconName: "bicycle", currentStreak: 2),
            .init(id: 2, iconName: "figure.mind.and.body", currentStreak: 40)
        ])
    }
    
    func timeline(for configuration: StreakAppIntent, in context: Context) async -> Timeline<StreakEntry> {
        let streaks = sharedSerice.getStreaks()
        let entries: [StreakEntry] = [.init(
            date: .now,
            sportStreaks:
                (configuration.workouts ?? [.init(id: 37, name: "Running", imageName: "figure.run")]).map {
                    let streakObject = streaks?[$0.id]
                    return SportStreak(id: $0.id,
                                       iconName: $0.imageName,
                                       currentStreak: streakObject?.streak)
                })
        ]
        
        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct StreakEntry: TimelineEntry {
    let date: Date
    let sportStreaks: [SportStreak]
}

struct SportStreak: Identifiable {
    let id: Int
    let iconName: String?
    let currentStreak: Int?
}
