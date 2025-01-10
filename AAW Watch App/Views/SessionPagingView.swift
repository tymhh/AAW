//
//  SessionPagingView.swift
//  AAW
//
//  Created by Tim Hazhyi on 27.12.2024.
//

import SwiftUI
import WatchKit
import HealthKit

public class SessionViewData: ObservableObject {
    @Published var configuration: HKWorkoutConfiguration?

    init(_ configuration: HKWorkoutConfiguration? = nil) {
        self.configuration = configuration
    }

}

struct SessionPagingView: View {
    @ObservedObject var sessionViewData: SessionViewData
    public init(sessionViewData: SessionViewData) {
        self.sessionViewData = sessionViewData
    }
        
    @EnvironmentObject var sessionService: SessionService
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    @State private var selection: Tab = .metrics

    enum Tab {
        case controls, metrics, list
    }

    var body: some View {
        TabView(selection: $selection) {
            ControlsView().tag(Tab.controls)
            MetricsView().tag(Tab.metrics)
//            WatchListView().tag(Tab.list)
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: sessionViewData.configuration, initial: true) {
            sessionService.selectedWorkout = sessionViewData.configuration
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: isLuminanceReduced ? .never : .automatic))
        .onChange(of: isLuminanceReduced) {
            displayMetricsView()
        }
    }

    private func displayMetricsView() {
        withAnimation {
            selection = .metrics
        }
    }
}

struct PagingView_Previews: PreviewProvider {
    static var previews: some View {
        SessionPagingView(sessionViewData: .init())
            .environmentObject(SessionService())
    }
}
