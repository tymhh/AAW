//
//  FilterButton.swift
//  AAW
//
//  Created by Tim Hazhyi on 07.01.2025.
//

import SwiftUI

struct FilterButton: View {
    @ObservedObject var viewModel: WorkoutViewModel
    
    var body: some View {
        Button(action: {
            viewModel.applyNextFilter()
        }) {
            let color: Color = viewModel.filter != .all ? .workoutGreen : .white
            HStack {
                Image(systemName: "line.3.horizontal.decrease")
                    .foregroundColor(color)
                Text("Filter")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(color)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
