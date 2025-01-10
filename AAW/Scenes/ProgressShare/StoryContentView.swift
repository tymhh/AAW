//
//  StoryContentView.swift
//  AAW
//
//  Created by Tim Hazhyi on 19.12.2024.
//

import SwiftUI

struct StoryContentView: View {
    let progress: CGFloat

    var body: some View {
        ZStack {
            Color(.workoutGray)

            VStack {
                Spacer()
                Text("\(NSDecimalNumber(string: "\(progress)"), formatter: NumberFormatter.percent) \n completed \n🚀")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, -30)

                ZStack {
                    Image("logo")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                    CircularProgressBar(progress: progress, strokeWidth: 30)
                        .frame(width: 200, height: 200)
                }.padding()

                Text("Achieve All Workouts. \n App to track your progress toward completing every workout type available on your Apple Watch")
                    .font(.footnote)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Image("AppStoreBadge")

                Spacer()
            }
            .padding()
        }
    }
}


#Preview {
    StoryContentView(progress: 0.3)
}
