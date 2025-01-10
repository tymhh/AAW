//
//  TrophyCollectionView.swift
//  AAW
//
//  Created by Tim Hazhyi on 23.12.2024.
//


import SwiftUI

struct TrophyCollectionView: View {
    let progress: Int
    let trophies: [Trophy] = (1...10).map { Trophy(name: "Trophy \($0 * 10)",
                                                   unlockPercentage: $0 * 10) }

    init(progress: CGFloat) {
        self.progress = Int(progress * 100)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Trophy Collection")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3),
                          spacing: 16) {
                    ForEach(trophies) { trophy in
                        TrophyView(trophy: trophy, isUnlocked: trophy.unlockPercentage <= progress)
                    }
                }
            }
            .padding()
        }
    }
}

struct TrophyView: View {
    let trophy: Trophy
    let isUnlocked: Bool
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(isUnlocked ? .workoutGreen : Color.gray.opacity(0.5))
                    .frame(width: 60, height: 60)
                
                Text("\(trophy.unlockPercentage)%")
                    .font(.headline)
                    .foregroundColor(.black)
            }
            
            Text(trophy.name)
                .font(.caption)
                .foregroundColor(isUnlocked ? .primary : .secondary)
        }
    }
}

struct Trophy: Identifiable {
    let id = UUID()
    let name: String
    let unlockPercentage: Int
}

#Preview {
    TrophyCollectionView(progress: 0.32)
}
