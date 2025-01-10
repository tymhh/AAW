//
//  ContentView.swift
//  AAW
//
//  Created by Tim Hazhyi on 01.12.2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    var body: some View {
        NavigationStack(path: $appCoordinator.navigationPath) {
            appCoordinator.build(page: .list)
                .navigationDestination(for: AppCoordinator.Destination.self) { page in
                    appCoordinator.build(page: page)
                }
                .fullScreenCover(item: $appCoordinator.fullScreenCover) { item in
                    appCoordinator.buildCover(cover: item)
                }
        }
        .environmentObject(appCoordinator)
        .environmentObject(DIContainer.shared.sessionService)
        .tint(.workoutGreen)
    }
}
