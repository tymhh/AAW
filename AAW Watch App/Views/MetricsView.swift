//
//  MetricsView.swift
//  AAW
//
//  Created by Tim Hazhyi on 27.12.2024.
//


import SwiftUI
import HealthKit

struct MetricsView: View {
    @EnvironmentObject var sessionService: SessionService
    
    var body: some View {
        TimelineView(MetricsTimelineSchedule(from: sessionService.builder?.startDate ?? Date(),
                                             isPaused: sessionService.session?.state == .paused)) { context in
            VStack(alignment: .leading) {
                sessionService.name.map { Text($0) }
                ElapsedTimeView(
                    elapsedTime:sessionService.builder?.elapsedTime(at: context.date) ?? 0,
                    showSubseconds: context.cadence == .live
                ).foregroundStyle(.workoutGreen)
                
                Text(Measurement(
                    value: sessionService.activeEnergy,
                    unit: UnitEnergy.kilocalories)
                    .formatted(.measurement(width: .abbreviated,
                                            usage: .workout,
                                            numberFormatStyle: .number.precision(.fractionLength(0))))
                )
                
                Text(sessionService.heartRate.formatted(.number.precision(.fractionLength(0))) + " bpm")
            }
            .font(.system(.title, design: .rounded).monospacedDigit().lowercaseSmallCaps())
            .frame(maxWidth: .infinity, alignment: .leading)
            .ignoresSafeArea(edges: .bottom)
            .scenePadding()
        }
    }
}

struct MetricsView_Previews: PreviewProvider {
    static var previews: some View {
        MetricsView().environmentObject(SessionService())
    }
}
