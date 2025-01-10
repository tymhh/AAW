//
//  ByTypeView.swift
//  AAW
//
//  Created by Tim Hazhyi on 18.12.2024.
//

import SwiftUI

struct ByTypeView: View {
    @StateObject private var viewModel: ByTypeViewModel
    
    init(type: WorkoutType) {
        _viewModel = StateObject(wrappedValue: ByTypeViewModel(type: type))
    }
    
    var body: some View {
        List {
            StreakSection(viewModel: viewModel)
            SegmentInfoSection(viewModel: viewModel)
            WorkoutActivitySection(viewModel: viewModel)
        }
        .overlay { emptyOverlay }
        .navigationBarTitle(viewModel.title, displayMode: .large)
        .toolbar {
            if viewModel.activeWCSession {
                Button("Run on Watch") {
                    viewModel.startWatchApp()
                }
            }
        }
        .task {
            if viewModel.featureFlagService.isFeatureEnabled(.aiSuggestions) {
                await viewModel.requestInfo()
            }
        }
        .listStyle(.grouped)
    }
    
    private var emptyOverlay: some View {
        Group {
            if viewModel.data.isEmpty {
                VStack {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.largeTitle)
                        .foregroundStyle(Color.workoutGreen)
                        .padding()
                    Text("No workouts yet!")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 4)
                    Text("Start working out to see your progress here.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
}

#Preview {
    NavigationView {
        ByTypeView(type: .init(healthType: 1))
    }
}

struct StreakSection: View {
    @StateObject var viewModel: ByTypeViewModel
    
    var body: some View {
        Section {
            HStack {
                let color: Color = viewModel.data.isEmpty ? .white : .workoutGreen
                viewModel.type.iconName.map {
                    Image(systemName: $0)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(color)
                }
                Spacer()
                HStack {
                    Text("\(viewModel.currentStreak)")
                        .font(.largeTitle)
                    VStack(alignment: .leading) {
                        Text("Current streak")
                            .lineLimit(1)
                            .font(.caption)
                        Text(viewModel.currentStreak.pluralDaysValue)
                            .font(.caption)
                    }
                }
                Spacer()
                HStack {
                    Text("\(viewModel.longestStreak)")
                        .font(.largeTitle)
                    VStack(alignment: .leading) {
                        Text("Longest streak")
                            .lineLimit(1)
                            .font(.caption)
                        Text(viewModel.longestStreak.pluralDaysValue)
                            .font(.caption)
                    }
                }
                Spacer()
            }
        }
        .listRowBackground(Color.clear)
        .listSectionSeparator(.hidden)
    }
}

struct SegmentInfoSection: View {
    @StateObject var viewModel: ByTypeViewModel
    var body: some View {
        Section() {
            if viewModel.state == .loading {
                HStack {
                    Spacer()
                    ProgressView("Loading...")
                        .frame(height: 120, alignment: .center)
                        .background()
                    Spacer()
                }
                
            }
            viewModel.info.map {
                SegmentedControlView(workoutTypeInfo: $0)
            }
        }
        .listRowInsets(EdgeInsets())
        .listSectionSeparator(.hidden)
        .background()
    }
}

struct WorkoutActivitySection: View {
    @StateObject var viewModel: ByTypeViewModel
    
    var body: some View {
        ForEach(Array(viewModel.data.keys), id: \.self) { monthKey in
            Section(header: Text(monthKey)
                .font(.subheadline)
                .foregroundColor(.workoutGreen))
            {
                let month = viewModel.data[monthKey] ?? []
                ForEach(month, id: \.self) { workout in
                    let topCorner: CGFloat = workout == month.first ? 8 : 0
                    let bottomCorner: CGFloat = workout == month.last ? 8 : 0
                    HStack {
                        Text(workout.date, formatter: DateFormatter.mediumDate)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 10)
                        Spacer()
                            .alignmentGuide(.listRowSeparatorTrailing) { d in
                                d[.trailing]
                            }
                    }
                    .listRowBackground(
                        Color(UIColor.secondarySystemGroupedBackground)
                            .clipShape(
                                .rect(
                                    topLeadingRadius: topCorner,
                                    bottomLeadingRadius: bottomCorner,
                                    bottomTrailingRadius: bottomCorner,
                                    topTrailingRadius: topCorner
                                )
                            )
                            .padding(.horizontal, 16)
                    )
                }
            }
            .listSectionSeparator(.hidden)
            .listRowInsets(.init(top: 8,
                                 leading: 24,
                                 bottom: 8,
                                 trailing: 24))
            
        }
    }
}
