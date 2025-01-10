//
//  TrophyButton.swift
//  AAW
//
//  Created by Tim Hazhyi on 07.01.2025.
//

import SwiftUI

struct TrophyButton: View {
    let appCoordinator: AppCoordinator
    let progress: Double
    
    var body: some View {
        Button(action: {
            appCoordinator.navigate(to: .trophies(progress: progress))
        }) {
            HStack {
                Image(systemName: "trophy")
                    .foregroundColor(.white)
                Text("Trophies")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
