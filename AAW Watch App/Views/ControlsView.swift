//
//  ControlsView.swift
//  AAW
//
//  Created by Tim Hazhyi on 27.12.2024.
//

import SwiftUI

struct ControlsView: View {
    @EnvironmentObject var sessionService: SessionService

    var body: some View {
        VStack {
            VStack {
                Button {
                    sessionService.endWorkout()
                } label: {
                    ButtonLabel(title: "End", systemImage: "xmark")
                }
                .tint(.red)
                .disabled(!sessionService.sessionState.isActive)
            }
            VStack {
                let flag = sessionService.sessionState == .running
                Button {
                    flag ? sessionService.session?.pause() : sessionService.session?.resume()
                } label: {
                    let title = flag ? "Pause" : "Resume"
                    let systemImage = flag ? "pause" : "play"
                    ButtonLabel(title: title, systemImage: systemImage)
                }
                .disabled(!sessionService.sessionState.isActive)
                .tint(flag ? .blue : .yellow)
            }
        }
    }
}

struct ControlsView_Previews: PreviewProvider {
    static var previews: some View {
        ControlsView().environmentObject(SessionService())
    }
}
