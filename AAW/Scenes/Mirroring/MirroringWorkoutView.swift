//
//  MirroringWorkoutView.swift
//  AAW
//
//  Created by Tim Hazhyi on 28.12.2024.
//

import SwiftUI
import HealthKit

struct MirroringWorkoutView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var sessionService: SessionService

    var body: some View {
        NavigationView {
            let fromDate = sessionService.session?.startDate ?? Date()
            let schedule = MetricsTimelineSchedule(from: fromDate, isPaused: sessionService.sessionState == .paused)
            TimelineView(schedule) { context in
                List {
                    Section {
                        metricsView()
                    } header: {
                        headerView(context: context)
                    } footer: {
                        footerView()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    let flag = sessionService.sessionState.isActive
                    Button(action: {
                        dismissAction()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(flag ? .gray.opacity(0.3) : .workoutGreen)
                    }.disabled(flag)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func dismissAction() {
        appCoordinator.reset()
        dismiss()
    }
}

extension MirroringWorkoutView {
    @ViewBuilder
    private func headerView(context: TimelineViewDefaultContext) -> some View {
        VStack {
            sessionService.name.map {
                Text($0)
                    .textCase(nil)
                    .foregroundColor(.primary)
                    .font(.system(.title2, design: .rounded).monospacedDigit().lowercaseSmallCaps())
                
            }
            Spacer(minLength: 30)
            LabeledContent {
                ElapsedTimeView(elapsedTime: workoutTimeInterval(context.date), showSubseconds: context.cadence == .live)
                    .font(.system(.title, design: .rounded).monospacedDigit().lowercaseSmallCaps())
            } label: {
                Text("Elapsed")
                    .textCase(nil)
            }
            .foregroundColor(.workoutGreen)
            .font(.title2)
            Spacer(minLength: 15)
        }
    }
    
    private func workoutTimeInterval(_ contextDate: Date) -> TimeInterval {
        var timeInterval = sessionService.elapsedTimeInterval
        if sessionService.sessionState == .running {
            if let referenceContextDate = sessionService.contextDate {
                timeInterval += (contextDate.timeIntervalSinceReferenceDate - referenceContextDate.timeIntervalSinceReferenceDate)
            } else {
                sessionService.contextDate = contextDate
            }
        } else {
            var date = contextDate
            date.addTimeInterval(sessionService.elapsedTimeInterval)
            timeInterval = date.timeIntervalSinceReferenceDate - contextDate.timeIntervalSinceReferenceDate
            sessionService.contextDate = nil
        }
        return timeInterval
    }
    
    @ViewBuilder
    private func metricsView() -> some View {
        Group {
            LabeledContent("Active Energy", value: sessionService.activeEnergy, format: .number.precision(.fractionLength(0)))
            LabeledContent("Heart Rate", value: sessionService.heartRate, format: .number.precision(.fractionLength(0)))
        }
        .font(.system(.title2))
    }
    
    @ViewBuilder
    private func footerView() -> some View {
        VStack {
            Spacer(minLength: 40)
            HStack {
                Spacer()
                VStack {
                    Button {
                        sessionService.endWorkout()
                    } label: {
                        ButtonLabel(title: "End", systemImage: "xmark")
                    }
                    .tint(.red)
                    .disabled(!sessionService.sessionState.isActive)
                }
                VStack {
                    let flag = sessionService.sessionState == .running
                    Button {
                        flag ? sessionService.session?.pause() : sessionService.session?.resume()
                    } label: {
                        let title = flag ? "Pause" : "Resume"
                        let systemImage = flag ? "pause" : "play"
                        ButtonLabel(title: title, systemImage: systemImage)
                    }
                    .disabled(!sessionService.sessionState.isActive)
                    .tint(flag ? .blue : .yellow)
                }

                Spacer()
            }
            .buttonStyle(.bordered)
        }
    }
}

struct MirroringWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        MirroringWorkoutView().environmentObject(SessionService())
    }
}
