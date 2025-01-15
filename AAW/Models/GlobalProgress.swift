//
//  GlobalProgress.swift
//  AAW
//
//  Created by Tim Hazhyi on 15.01.2025.
//


import SwiftData
import CloudKit

@Model
class GlobalProgress {
    var userId: String?
    var value: Int?

    init(userId: String?, value: Int?) {
        self.userId = userId
        self.value = value
    }
}
