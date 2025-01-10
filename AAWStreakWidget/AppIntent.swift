//
//  AppIntent.swift
//  AAWStreakWidget
//
//  Created by Tim Hazhyi on 28.12.2024.
//

import WidgetKit
import AppIntents
import Intents

struct StreakAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "" }

    @Parameter(title: "Workouts")
    var workouts: [IntetWorkout]?
}

struct IntetWorkout: AppEntity {
    static var defaultQuery = WorkoutEntityQuery()
    var id: Int
    var name: String
    var imageName: String
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(
            name: LocalizedStringResource("Workout", table: "AppIntents"),
            numericFormat: LocalizedStringResource("\(placeholder: .int) workout", table: "AppIntents")
        )
    }
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)",
                              image: DisplayRepresentation.Image(named: imageName))
    }
}

struct WorkoutEntityQuery: EntityQuery {
    let allTypes = HealthService.getAllWorkoutTypes().sorted(by: { $0.name.localizedCaseInsensitiveCompare( $1.name) == .orderedAscending })
    
    func entities(for identifiers: [IntetWorkout.ID]) async throws -> [IntetWorkout] {
        return allTypes.map {
            .init(id: Int($0.rawValue), name: $0.name, imageName: $0.iconName)
        }
    }
    
    func suggestedEntities() async throws -> [IntetWorkout] {
        return allTypes.map {
            .init(id: Int($0.rawValue), name: $0.name, imageName: $0.iconName)
        }
    }
    
    func entities(matching string: String) async throws -> [IntetWorkout] {
        return allTypes.map {
            .init(id: Int($0.rawValue), name: $0.name, imageName: $0.iconName)
        }
    }
}
