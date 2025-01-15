//
//  CircularProgressBar.swift
//  AAW
//
//  Created by Tim Hazhyi on 15.12.2024.
//


import SwiftUI

struct CircularProgressBar: View {
    var progress: CGFloat
    var progressPercent: String?
    var strokeWidth: CGFloat = 20
    var lineColor: Color = .workoutGreen
    var backgroundColor: Color = .gray
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: strokeWidth)
                .opacity(0.3)
                .foregroundColor(backgroundColor)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 0.5)))
                .stroke(style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round, lineJoin: .round))
                .foregroundColor(lineColor)
                .rotationEffect(Angle(degrees: 270.0))
            
            Circle()
                .trim(from: CGFloat(abs((min(progress, 1.0))-0.001)), to: CGFloat(abs((min(progress, 1.0))-0.0005)))
                .stroke(style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round, lineJoin: .round))
                .foregroundColor(lineColor)
                .shadow(color: .black, radius: 10, x: 0, y: 0)
                .rotationEffect(Angle(degrees: 270.0))
                .clipShape(Circle().stroke(lineWidth: strokeWidth))
            
            Circle()
                .trim(from: progress > 0.5 ? 0.25 : 0, to: CGFloat(min(progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round, lineJoin: .round))
                .foregroundColor(lineColor)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.easeInOut(duration: 0.5), value: progress)
            progressPercent.map {
                Text($0)
                    .font(.headline)
                    .foregroundStyle(.workoutGreen)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    CircularProgressBar(progress: 0.4, progressPercent: "10%", strokeWidth: 40)
        .padding(.horizontal, 50)
}
