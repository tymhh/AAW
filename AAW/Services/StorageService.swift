//
//  SharedService.swift
//  AAW
//
//  Created by Tim Hazhyi on 29.12.2024.
//

import Foundation

class StorageService {
    let sharedDefaults = UserDefaults(suiteName: "group.com.tymh.AAW")
    
    func saveStreaks(_ value: [Int: StreakObject]) {
        sharedDefaults?.set(object: value, forKey: "streaks")
        sharedDefaults?.synchronize()
    }
    
    func getStreaks() -> [Int: StreakObject]? {
        sharedDefaults?.object([Int: StreakObject].self, with: "streaks")
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
