//
//  WorkoutRow.swift
//  AAW
//
//  Created by Tim Hazhyi on 07.01.2025.
//

import SwiftUI

struct WorkoutRow: View {
    let appCoordinator: AppCoordinator
    let workout: WorkoutType
    
    var body: some View {
        let lastWorkout = workout.done.first
        let color: Color = lastWorkout != nil ? .workoutGreen : .primary
        Button(action: {
            appCoordinator.navigate(to: .byType(workout))
        }) {
            HStack {
                workout.iconName.map {
                    Image(systemName: $0)
                        .frame(maxWidth: 30)
                        .foregroundColor(color)
                }
                VStack(alignment: .leading) {
                    Text(workout.name)
                        .font(.headline)
                        .foregroundColor(color)
                    if let lastWorkout {
                        Text("Last Activity: \(lastWorkout.date, formatter: DateFormatter.shortDate)")
                            .font(.caption)
                            .foregroundColor(color)
                    }
                }
            }
        }
    }
}
