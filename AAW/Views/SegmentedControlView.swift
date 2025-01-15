//
//  SegmentedControlView.swift
//  AAW
//
//  Created by Tim Hazhyi on 22.12.2024.
//

import SwiftUI

struct SegmentedControlView: View {
    let workoutTypeInfo: [String: String]
    let tabs: [String]
    @State private var selectedTab: String
    
    init?(workoutTypeInfo: [String: String]) {
        let sorted = Array(workoutTypeInfo.keys).sorted()
        guard let first = sorted.first else { return nil }
        self.workoutTypeInfo = workoutTypeInfo
        self.tabs = sorted
        self.selectedTab = first
    }
    
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(tabs, id: \.self) { tab in
                        Button(action: {
                            selectedTab = tab
                        }) {
                            Text(tab)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(selectedTab == tab ? Color.workoutGreen : Color.black.opacity(0.8))
                                .foregroundColor(selectedTab == tab ? Color.black : Color.white)
                                .cornerRadius(20)
                                .animation(.easeInOut, value: selectedTab)
                        }
                    }
                }.padding()
            }
            workoutTypeInfo[selectedTab].map {
                Text($0)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
            }
        }
       
    }
}

#Preview {
    ByTypeView(type: .init(healthType: 1))
}
