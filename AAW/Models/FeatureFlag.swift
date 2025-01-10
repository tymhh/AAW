//
//  FeatureFlag.swift
//  AAW
//
//  Created by Tim Hazhyi on 10.01.2025.
//

import CloudKit

enum FeatureFlag: String {
    case aiSuggestions = "AISuggestions"
}

struct FeatureFlagObject {
    let name: FeatureFlag
    let isEnabled: Bool
    
    init?(record: CKRecord) {
        guard let name = record["flagName"] as? String, let flag = FeatureFlag(rawValue: name)  else { return nil }
        self.name = flag
        self.isEnabled = (record["isEnabled"] as? NSNumber)?.boolValue ?? false
    }
}
