//
//  AAWStreakWidget.swift
//  AAWStreakWidget
//
//  Created by Tim Hazhyi on 28.12.2024.
//

import WidgetKit
import SwiftUI

struct AAWStreakWidgetView: View {
    struct Constants {
        struct Spacing {
            static let small: CGFloat = 10
            static let medium: CGFloat = 25
            static let imageSize: CGFloat = 30
        }
    }
    
    @Environment(\.widgetFamily) var widgetFamily
    var entry: StreakProvider.Entry
    
    var body: some View {
        let maxLenght = widgetFamily == .systemSmall ? 4 : 8
        let streaks = entry.sportStreaks.prefix(maxLenght)
        VStack(spacing: Constants.Spacing.small) {
            let count = streaks.count
            switch count {
            case 1:
                sportIcon(for: entry.sportStreaks[0])
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            case 2 where widgetFamily == .systemSmall, 2...4 where widgetFamily == .systemMedium:
                HStack(spacing: Constants.Spacing.medium) {
                    ForEach(0..<count, id: \.self) { index in
                        sportIcon(for: entry.sportStreaks[index])
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            case 3 where widgetFamily == .systemSmall, 4...7 where widgetFamily == .systemMedium:
                let range = widgetFamily == .systemSmall ? 2 : 4
                VStack(spacing: Constants.Spacing.small) {
                    HStack(spacing: Constants.Spacing.medium) {
                        ForEach(0..<range, id: \.self) { index in
                            sportIcon(for: entry.sportStreaks[index])
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    HStack(spacing: Constants.Spacing.medium) {
                        ForEach(range..<count, id: \.self) { index in
                            sportIcon(for: entry.sportStreaks[index])
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            default:
                let count = widgetFamily == .systemSmall ? 2 : 4
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: Constants.Spacing.small), count: count),
                    spacing: Constants.Spacing.small
                ) {
                    ForEach(streaks.indices, id: \.self) { index in
                        sportIcon(for: entry.sportStreaks[index])
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func sportIcon(for streak: SportStreak) -> some View {
        VStack {
            streak.iconName.map {
                Image(systemName: $0)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.Spacing.imageSize,
                           height: Constants.Spacing.imageSize)
                    .foregroundColor(.workoutGreen)
            }
            let text = streak.currentStreak != nil
            ? "\(streak.currentStreak!.pluralDaysString.capitalized)"
            : "n/a"
            Text(text)
                .font(.caption2)
                .foregroundColor(.white)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }
}

struct AAWStreakWidget: Widget {
    let kind: String = "AAWStreakWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: StreakAppIntent.self, provider: StreakProvider()) { entry in
            AAWStreakWidgetView(entry: entry)
                .containerBackground(.workoutGray, for: .widget)
        }.supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemMedium) {
    AAWStreakWidget()
} timeline: {
    StreakEntry(date: .now, sportStreaks: [
        .init(id: 1,
              iconName: "figure.dance",
              currentStreak: 200),
        .init(id: 2,
              iconName: "figure.mind.and.body",
              currentStreak: 300),
        .init(id: 2,
              iconName: "figure.mind.and.body",
              currentStreak: 5),
        .init(id: 2,
              iconName: "figure.mind.and.body",
              currentStreak: 5000),
        .init(id: 2,
              iconName: "figure.mind.and.body",
              currentStreak: 5),
        .init(id: 2,
              iconName: "figure.mind.and.body",
              currentStreak: 5),
        .init(id: 2,
              iconName: "figure.mind.and.body",
              currentStreak: 5),
//        .init(id: 2,
//              iconName: "figure.mind.and.body",
//              currentStreak: 5),
    ])
}
