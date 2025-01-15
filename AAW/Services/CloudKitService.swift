//
//  CloudKitService.swift
//  AAW
//
//  Created by Tim Hazhyi on 14.01.2025.
//

import CloudKit

protocol CloudKitServiceProtocol {
    func fetchFeatureFlags() async throws -> [CKRecord]
    
    func findUserRank() async throws -> Int?
    func updateOrCreateUserProgress(newProgress: Int) async throws -> CKRecord
}

class CloudKitService: CloudKitServiceProtocol {
    enum RecordType: String {
        case featureFlag = "FeatureFlag"
        case globalProgress = "GlobalProgress"
    }
    
    private let container = CKContainer(identifier: "iCloud.com.tymh.AAWContainer")
    private let database: CKDatabase
    private var userId: String?
    private var cachedRecord: CKRecord?
    
    init() {
        database = container.publicCloudDatabase
    }
    
    private func fetchUserId() async throws -> String {
        if let userId = self.userId {
            return userId
        }
        
        let userRecordID = try await container.userRecordID()
        let fetchedUserId = userRecordID.recordName
        self.userId = fetchedUserId
        return fetchedUserId
    }
    
    func fetchFeatureFlags() async throws -> [CKRecord] {
        let query = CKQuery(recordType: RecordType.featureFlag.rawValue, predicate: NSPredicate(value: true))
        return try await records(matching: query)
    }
    
    func updateOrCreateUserProgress(newProgress: Int) async throws -> CKRecord {
        let records = try await fetchUsersProgress()
        if let userRecord = try await findUserRecord(in: records) {
            userRecord["value"] = newProgress as CKRecordValue
            return try await save(userRecord)
        } else {
            let userId = try await fetchUserId()
            let newRecord = CKRecord(recordType: RecordType.globalProgress.rawValue)
            newRecord["userId"] = userId as CKRecordValue
            newRecord["value"] = newProgress as CKRecordValue
            return try await save(newRecord)
        }
    }
    
    func findUserRank() async throws -> Int? {
        let userId = try await fetchUserId()
        let records = try await fetchUsersProgress()
        return findRank(for: userId, in: records)
    }
    
    func findRank(for userId: String, in records: [CKRecord]) -> Int? {
        let records = records.sorted(by: {
            let left = $0["value"] as? Int ?? 0
            let right = $1["value"] as? Int ?? 0
            return left > right
        })
        var rank = 0
        var lastProgress: Int? = nil
        var userRank: Int? = nil
        
        for record in records {
            let progress = record["value"] as? Int ?? 0
            
            if progress != lastProgress {
                rank += 1
                lastProgress = progress
            }
            
            if let recordUserId = record["userId"] as? String, recordUserId == userId {
                userRank = rank
                break
            }
        }
        
        return userRank
    }
    
    private func fetchUsersProgress() async throws -> [CKRecord] {
        let query = CKQuery(recordType: RecordType.globalProgress.rawValue, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "value", ascending: false)]
        var records = try await records(matching: query)
        if let cachedRecord, !records.contains(where: {
            let cachedId = cachedRecord["userId"] as? String
            let recordId = $0["userId"] as? String
            let cachedValue = cachedRecord["value"] as? Int
            let recordValue = $0["value"] as? Int
            return cachedId == recordId && cachedValue == recordValue
        }) {
            records.append(cachedRecord)
        }
        return records
    }
    
    private func findUserRecord(in records: [CKRecord]) async throws -> CKRecord? {
        let userId = try await fetchUserId()
        return records.first { record in
            if let recordUserId = record["userId"] as? String {
                return recordUserId == userId
            }
            return false
        }
    }
    
    private func checkiCloudAccountAvailability() async throws -> Bool {
        let status = try await container.accountStatus()
        return status == .available
    }
    
    private func records(matching: CKQuery) async throws -> [CKRecord] {
        do {
            guard try await checkiCloudAccountAvailability() else { throw CKError(.notAuthenticated) }
            let records = try await database.records(matching: matching)
            let result = records.matchResults.compactMap { matchResult in
                switch matchResult.1 {
                case .success(let record):
                    return record
                case .failure(let error):
                    print("Error fetching record: \(error)")
                    return nil
                }
            }
            return result
        } catch {
            throw error
        }
    }
    
    private func save(_ record: CKRecord) async throws -> CKRecord {
        do {
            guard try await checkiCloudAccountAvailability() else { throw CKError(.notAuthenticated) }
            let record = try await database.save(record)
            cachedRecord = record
            return record
        } catch {
            throw error
        }
    }
}
