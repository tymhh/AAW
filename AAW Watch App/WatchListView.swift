//
//  WatchListView.swift
//  AAW
//
//  Created by Tim Hazhyi on 27.12.2024.
//


import SwiftUI

//struct WatchListView: View {
//    @StateObject private var viewModel = WorkoutViewModel()
//    let scenePhase: ScenePhase
    
//    var body: some View {
////        NavigationView {
//            List {
//                Section {
//                    ZStack {
//                        CircularProgressBar(progress: viewModel.progress, strokeWidth: 30)
//                            .padding()
//                        VStack {
//                            Text(viewModel.progressString)
//                                .font(.headline)
//                            Text(viewModel.progressPercent)
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                        }
//                    }.padding()
//                }
//                .listRowInsets(EdgeInsets())
//                .background()
//                
//                Section {
//                    ForEach(viewModel.list) { workout in
//                        let lastWorkout = workout.done.first
//                        let color: Color = lastWorkout != nil ? .workoutGreen : .primary
//                        VStack(alignment: .leading) {
//                            Text(workout.name)
//                                .font(.headline)
//                                .foregroundColor(color)
//                            if let lastWorkout {
//                                Text("Last done: \(lastWorkout.date, formatter: DateFormatter.shortDate)")
//                                    .font(.caption)
//                                    .foregroundColor(color)
//                            }
//                        }
//                    }
//                }
//            }
//            .padding(.top, -20)
//            .listStyle(.carousel)
//            .task {
//                await viewModel.fetchWorkouts()
//            }
//        }
//    }
//}

//#Preview {
//    @Previewable @Environment(\.scenePhase) var scenePhase
//    WatchListView()
//}
