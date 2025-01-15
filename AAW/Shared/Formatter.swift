//
//  Formatter.swift
//  AAW
//
//  Created by Tim Hazhyi on 05.01.2025.
//

import Foundation

extension DateComponentsFormatter {
    static let pluralDays: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.day]
        return formatter
    }()
}

extension DateFormatter {
    static let monthGroup: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    static let mediumDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
}

extension NumberFormatter {
    static let percent: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter
    }()
    
    static let ordinal: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter
    }()
}

extension Int {
    var pluralDaysString: String {
        let components = DateComponents(day: self)
        return DateComponentsFormatter.pluralDays.string(for: components) ?? "\(self) Days"
    }
    
    var pluralDaysValue: String {
        return self == 1 ? "Day" : "Days"
    }
}


