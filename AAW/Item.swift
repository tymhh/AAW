//
//  Item.swift
//  AAW
//
//  Created by Tim Hazhyi on 01.12.2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
