//
//  SharedService.swift
//  AAW
//
//  Created by Tim Hazhyi on 29.12.2024.
//

import Foundation
import SwiftData

protocol StorageServiceProtocol {
    func saveStreaks(_ value: [Int: StreakObject])
    func getStreaks() -> [Int: StreakObject]?
    
    func saveOrUpdateUserProgress(record: GlobalProgress?)
    func fetchUserProgress(userId: String?) -> GlobalProgress?
}

class StorageService: StorageServiceProtocol {
    private let context: ModelContext?
    private let sharedDefaults = UserDefaults(suiteName: "group.com.tymh.AAW")
    
    init() {
        do {
            let config = ModelConfiguration(cloudKitDatabase: .none)
            let container = try ModelContainer(for: GlobalProgress.self, configurations: config)
            self.context = ModelContext(container)
        } catch {
            self.context = nil
        }
    }
    
    func saveStreaks(_ value: [Int: StreakObject]) {
        sharedDefaults?.set(object: value, forKey: "streaks")
        sharedDefaults?.synchronize()
    }
    
    func getStreaks() -> [Int: StreakObject]? {
        sharedDefaults?.object([Int: StreakObject].self, with: "streaks")
    }
    
    func fetchUserProgress(userId: String?) -> GlobalProgress? {
        let descriptor = FetchDescriptor<GlobalProgress>(
            predicate: userId != nil ? #Predicate { $0.userId == userId! } : nil
        )
        return try? context?.fetch(descriptor).first
    }
    
    func saveOrUpdateUserProgress(record: GlobalProgress?) {
        guard let record else { return }
        if let existingRecord = fetchUserProgress(userId: record.userId) {
            existingRecord.value = record.value
        } else {
            let newUserProgress = record
            context?.insert(newUserProgress)
        }
        
        do {
            try context?.save()
        } catch {
            print("Error saving user progress: \(error)")
        }
    }
}

extension UserDefaults {
    func object<T: Codable>(_ type: T.Type, with key: String, usingDecoder decoder: JSONDecoder = JSONDecoder()) -> T? {
        guard let data = self.value(forKey: key) as? Data else { return nil }
        return try? decoder.decode(type.self, from: data)
    }

    func set<T: Codable>(object: T, forKey key: String, usingEncoder encoder: JSONEncoder = JSONEncoder()) {
        let data = try? encoder.encode(object)
        self.set(data, forKey: key)
    }
}
