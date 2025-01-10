//
//  StoryView.swift
//  AAW
//
//  Created by Tim Hazhyi on 19.12.2024.
//

import UIKit
import SwiftUI

struct StoryView: View {
    let progress: CGFloat

    var body: some View {
        VStack {
            Text("Challange Progress")
                .font(.title)
                .fontWeight(.bold)
                .padding()

            StoryContentView(progress: progress)
                .cornerRadius(50)
                .padding()

            Spacer()

            Button(action: {
                shareWorkoutStory(progress: progress)
            }) {
                Text("Share")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.workoutGray)
                    .foregroundColor(.workoutGreen)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
    }
    
    private func shareWorkoutStory(progress: CGFloat) {
        let storyView = StoryContentView(progress: progress).cornerRadius(50)
        if let pngData = storyView.renderAsPNG(size: UIScreen.main.bounds.size),
           let url = saveAndCreateLink(data: pngData, withName: "AAW.png") {
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            if let topController = UIApplication.shared.windows.first?.rootViewController {
                topController.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
    
    private func saveAndCreateLink(data: Data, withName fileName: String) -> URL? {
        let fileManager = FileManager.default
        let tempDirectoryURL = fileManager.temporaryDirectory
        let linkURL = tempDirectoryURL.appendingPathComponent(fileName)
        do {
            if fileManager.fileExists(atPath: linkURL.path) {
                try fileManager.removeItem(at: linkURL)
            }
            try data.write(to: linkURL)
            return linkURL
        } catch let error as NSError {
            print("\(error)")
            return nil
        }
    }
}

extension View {
    func renderAsPNG(size: CGSize, scale: CGFloat = UIScreen.main.scale) -> Data? {
        let renderer = ImageRenderer(content: self)
        renderer.proposedSize = .init(size)
        renderer.scale = scale
        return renderer.uiImage?.pngData()
    }
}

#Preview {
    StoryView(progress: 0.3)
}
