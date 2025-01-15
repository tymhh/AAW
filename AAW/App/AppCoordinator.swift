//
//  AppCoordinator.swift
//  AAW
//
//  Created by Tim Hazhyi on 02.12.2024.
//

import Foundation
import SwiftUI

class AppCoordinator: ObservableObject {
    @Published var navigationPath = NavigationPath()
    @Published var fullScreenCover: FullScreenCover?

    enum Destination: Hashable {
        case list
        case byType(WorkoutType)
        case story(progress: CGFloat)
        case trophies(progress: CGFloat)
    }
    
    enum FullScreenCover: String, Identifiable {
        var id: String { self.rawValue }
        case mirroring
    }
    
    @ViewBuilder
    func build(page: Destination) -> some View {
        switch page {
        case .list: ListView()
        case .byType(let type): ByTypeView(type: type)
        case .story(let progress): StoryView(progress: progress)
        case .trophies(let progress): TrophyCollectionView(progress: progress)
        }
    }
    
    @ViewBuilder
    func buildCover(cover: FullScreenCover) -> some View {
        switch cover {
        case .mirroring: MirroringWorkoutView()
        }
    }
    
    func navigate(to destination: Destination) {
        navigationPath.append(destination)
    }
    
    func reset() {
        navigationPath = NavigationPath()
    }
    
    func presentFullScreenCover(_ cover: FullScreenCover) {
        self.fullScreenCover = cover
    }
    
    func goToSystemSetting() {
        if let settingsURL = URL(string: "App-prefs:root=General") {
            UIApplication.shared.open(settingsURL)
        }
    }
}
