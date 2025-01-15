//
//  FeatureFlagManager.swift
//  AAW
//
//  Created by Tim Hazhyi on 10.01.2025.
//

import CloudKit

protocol FeatureFlagServiceProtocol {
    func fetchFeatureFlags() async throws
    func isFeatureEnabled(_ flag: FeatureFlag) -> Bool
}

class FeatureFlagService: FeatureFlagServiceProtocol {
    private var flags: [FeatureFlag: Bool] = [:]
    private let cloudKitService: CloudKitService
    
    init(cloudKitService: CloudKitService) {
        self.cloudKitService = cloudKitService
        Task {
            try await fetchFeatureFlags()
        }
    }
    
    func fetchFeatureFlags() async throws {
        let records = try await cloudKitService.fetchFeatureFlags()
        
        self.flags = records.reduce(into: [:]) { result, record in
            guard let flag = FeatureFlagObject(record: record) else { return }
            result[flag.name] = flag.isEnabled
        }
    }
    
    func isFeatureEnabled(_ flag: FeatureFlag) -> Bool {
        return flags[flag] ?? false
    }
}
