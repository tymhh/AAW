//
//  ListView.swift
//  AAW
//
//  Created by Tim Hazhyi on 02.12.2024.
//

import SwiftUI
import HealthKit
import Combine

struct ListView: View {
    @State private var cancellables = Set<AnyCancellable>()
    @EnvironmentObject var appCoordinator: AppCoordinator
    @StateObject private var viewModel = WorkoutViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ProgressSection(appCoordinator: appCoordinator, viewModel: viewModel)
                    ActionButtonsSection(appCoordinator: appCoordinator, viewModel: viewModel)
                    WorkoutListSection(appCoordinator: appCoordinator, viewModel: viewModel)
                }
            }
            .listSectionSpacing(20)
            .navigationTitle("Workouts")
            .overlay { loadingOverlay }
            .alert(isPresented: .constant(viewModel.error != nil)) { errorAlert() }
            .onChange(of: viewModel.sessionService.shouldFetchSamples) { _, shouldFetchSamples in handleFetchSamples(shouldFetchSamples)
            }
            .onAppear {
                observeShouldShowMirroring()
            }
        }
    }
    
    private var loadingOverlay: some View {
        Group {
            if viewModel.state == .loading {
                ProgressView("Loading...")
            }
        }
    }
    
    private func errorAlert() -> Alert {
        Alert(
            title: Text("Error"),
            message: Text(viewModel.error ?? ""),
            dismissButton: .default(Text("OK"))
        )
    }
    
    private func handleFetchSamples(_ shouldFetch: Bool) {
        if shouldFetch {
            Task {
                await viewModel.fetchWorkouts(force: true)
            }
        }
    }
    
    private func observeShouldShowMirroring() {
        viewModel.sessionService.$sessionState
            .sink { [weak appCoordinator] newValue in
                switch newValue {
                case .paused, .running, .prepared:
                    appCoordinator?.fullScreenCover = .mirroring
                default: break
                }
            }
            .store(in: &cancellables)
    }
}

struct ProgressSection: View {
    let appCoordinator: AppCoordinator
    @ObservedObject var viewModel: WorkoutViewModel
    
    var body: some View {
        Section() {
            Button(action: {
                appCoordinator.navigate(to: .story(progress: viewModel.progress))
            }) {
                HStack() {
                    Spacer()
                    Text(viewModel.progressString)
                        .font(.headline)
                        .foregroundStyle(.workoutGreen)
                        .frame(maxWidth: .infinity)
                    CircularProgressBar(progress: viewModel.progress)
                        .padding()
                        .frame(maxWidth: .infinity)
                    Text(viewModel.progressPercent)
                        .font(.headline)
                        .foregroundStyle(.workoutGreen)
                        .frame(maxWidth: .infinity)
                    Spacer()
                }
            }
        }
    }
}

struct ActionButtonsSection: View {
    let appCoordinator: AppCoordinator
    @ObservedObject var viewModel: WorkoutViewModel
    
    var body: some View {
        Section {
            HStack(spacing: 16) {
                TrophyButton(appCoordinator: appCoordinator, progress: viewModel.progress)
                Divider()
                FilterButton(viewModel: viewModel)
            }
        }
    }
}

struct WorkoutListSection: View {
    let appCoordinator: AppCoordinator
    @ObservedObject var viewModel: WorkoutViewModel
    let notice = "The list of available workout types may differ from the workouts in the Apple Watch app due to variations in iOS versions, hardware models, and updates"
    
    var body: some View {
        Section {
            ForEach(viewModel.displayList) { workout in
                WorkoutRow(appCoordinator: appCoordinator, workout: workout)
            }
        } footer: {
            Text(notice)
                .font(.footnote)
        }
    }
}

#Preview {
    @Previewable @StateObject var appCoordinator = AppCoordinator()
    ListView()
        .environmentObject(appCoordinator)
}

