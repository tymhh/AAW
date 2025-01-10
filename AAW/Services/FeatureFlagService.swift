//
//  FeatureFlagManager.swift
//  AAW
//
//  Created by Tim Hazhyi on 10.01.2025.
//

import CloudKit

class FeatureFlagService {
    private var flags: [FeatureFlag: Bool] = [:]
    private let database = CKContainer.default().publicCloudDatabase
    
    init() {
        Task {
            try await fetchFeatureFlags()
        }
    }
    
    func fetchFeatureFlags() async throws {
        let query = CKQuery(recordType: "FeatureFlag", predicate: NSPredicate(value: true))
        let result = try await database.records(matching: query)
        
        let records = result.matchResults.compactMap { matchResult in
            switch matchResult.1 {
            case .success(let record):
                return record
            case .failure(let error):
                print("Error fetching record: \(error)")
                return nil
            }
        }
        
        self.flags = records.reduce(into: [:]) { result, record in
            guard let flag = FeatureFlagObject(record: record) else { return }
            result[flag.name] = flag.isEnabled
        }
    }
    
    func isFeatureEnabled(_ flag: FeatureFlag) -> Bool {
        return flags[flag] ?? false
    }
}
