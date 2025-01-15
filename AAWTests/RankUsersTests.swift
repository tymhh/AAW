//
//  RankUsersTests.swift
//  AAW
//
//  Created by Tim Hazhyi on 15.01.2025.
//

import XCTest
import CloudKit
@testable import AAW

class RankUsersTests: XCTestCase {
    let  rankService = CloudKitService()
    
    func testFirstRank() {
        let records = [
            createMockRecord(userId: "UserC", value: 90),
            createMockRecord(userId: "UserA", value: 100),
            createMockRecord(userId: "UserB", value: 100),
            createMockRecord(userId: "UserD", value: 80),
            createMockRecord(userId: "UserE", value: 80)
        ]
        
        let userRank = rankService.findRank(for: "UserA", in: records)
        
        XCTAssertEqual(userRank, 1)
    }
    
    func testOnlyFirstRank() {
        let records = [
            createMockRecord(userId: "UserA", value: 1)
        ]
        
        let userRank = rankService.findRank(for: "UserA", in: records)
        
        XCTAssertEqual(userRank, 1)
    }
    
    func testSecondRank() {
        let records = [
            createMockRecord(userId: "UserB", value: 100),
            createMockRecord(userId: "UserC", value: 90),
            createMockRecord(userId: "UserD", value: 80),
            createMockRecord(userId: "UserE", value: 80),
            createMockRecord(userId: "UserA", value: 100)
        ]
        
        let userRank = rankService.findRank(for: "UserC", in: records)
        
        XCTAssertEqual(userRank, 2)
    }
    
    func testThirdRank() {
        let records = [
            createMockRecord(userId: "UserA", value: 100),
            createMockRecord(userId: "UserB", value: 100),
            createMockRecord(userId: "UserC", value: 90),
            createMockRecord(userId: "UserD", value: 80),
            createMockRecord(userId: "UserE", value: 80)
        ]
        
        let userRank = rankService.findRank(for: "UserE", in: records)
        
        XCTAssertEqual(userRank, 3)
    }
    
    // Helper function to create a mock CKRecord
    private func createMockRecord(userId: String, value: Int) -> CKRecord {
        let record = CKRecord(recordType: "UserProgress")
        record["userId"] = userId as CKRecordValue
        record["value"] = value as CKRecordValue
        return record
    }
}
