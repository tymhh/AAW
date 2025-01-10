//
//  ByTypeViewModelTests.swift
//  AAW
//
//  Created by Tim Hazhyi on 27.12.2024.
//

import XCTest
import SwiftUI
@testable import AAW

@MainActor
class ByTypeViewModelTests: XCTestCase {
    func testCurrentAndLongestStreakIncludesToday() {
        let today = Date()
        let dates = [today]
        let result = ByTypeViewModel.calculateStreak(dates)
        XCTAssertEqual(result.current, 1)
        XCTAssertEqual(result.longest, 1)
    }

    func testCurrentAndLongestStreakIncludesYesterdayAndToday() {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let dates = [today, yesterday]
        let result = ByTypeViewModel.calculateStreak(dates)
        XCTAssertEqual(result.current, 2)
        XCTAssertEqual(result.longest, 2)
    }

    func testStreakBrokenByGap() {
        let today = Date()
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!
        let dates = [today, twoDaysAgo]
        let result = ByTypeViewModel.calculateStreak(dates)
        XCTAssertEqual(result.current, 1)
        XCTAssertEqual(result.longest, 1)
    }

    func testLongestStreakWithGap() {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!
        let fourDaysAgo = Calendar.current.date(byAdding: .day, value: -4, to: today)!
        let dates = [today, yesterday, twoDaysAgo, fourDaysAgo]
        let result = ByTypeViewModel.calculateStreak(dates)
        XCTAssertEqual(result.current, 3)
        XCTAssertEqual(result.longest, 3)
    }

    func testNoCurrentStreak() {
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let fourDaysAgo = Calendar.current.date(byAdding: .day, value: -4, to: Date())!
        let dates = [threeDaysAgo, fourDaysAgo]
        let result = ByTypeViewModel.calculateStreak(dates)
        XCTAssertEqual(result.current, 0)
        XCTAssertEqual(result.longest, 2)
    }

    func testEmptyDates() {
        let dates: [Date] = []
        let result = ByTypeViewModel.calculateStreak(dates)
        XCTAssertEqual(result.current, 0)
        XCTAssertEqual(result.longest, 0)
    }

    func testStreakStartsYesterday() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        let dates = [yesterday, twoDaysAgo]
        let result = ByTypeViewModel.calculateStreak(dates)
        XCTAssertEqual(result.current, 2)
        XCTAssertEqual(result.longest, 2)
    }
    
    func testCurrentStreakIncludesToday() {
        let today = Date()
        let dates = [today]
        let result = ByTypeViewModel.calculateCurrentSteak(dates)
        XCTAssertEqual(result, 1)
    }

    func testCurrentStreakIncludesYesterdayAndToday() {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let dates = [today, yesterday]
        let result = ByTypeViewModel.calculateCurrentSteak(dates)
        XCTAssertEqual(result, 2)
    }

    func testCurrentStreakBrokenByGap() {
        let today = Date()
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!
        let dates = [today, twoDaysAgo]
        let result = ByTypeViewModel.calculateCurrentSteak(dates)
        XCTAssertEqual(result, 1)
    }

    func testCurrentStreakWithGap() {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!
        let fourDaysAgo = Calendar.current.date(byAdding: .day, value: -4, to: today)!
        let dates = [today, yesterday, twoDaysAgo, fourDaysAgo]
        let result = ByTypeViewModel.calculateCurrentSteak(dates)
        XCTAssertEqual(result, 3)
    }

    func testNoOnlyCurrentStreak() {
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let fourDaysAgo = Calendar.current.date(byAdding: .day, value: -4, to: Date())!
        let dates = [threeDaysAgo, fourDaysAgo]
        let result = ByTypeViewModel.calculateCurrentSteak(dates)
        XCTAssertEqual(result, 0)
    }

    func testCurrentEmptyDates() {
        let dates: [Date] = []
        let result = ByTypeViewModel.calculateCurrentSteak(dates)
        XCTAssertEqual(result, 0)
    }

    func testCurrentStreakStartsYesterday() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        let dates = [yesterday, twoDaysAgo]
        let result = ByTypeViewModel.calculateCurrentSteak(dates)
        XCTAssertEqual(result, 2)
    }
}
