//
//  NetworkService.swift
//  AAW
//
//  Created by Tim Hazhyi on 18.12.2024.
//


import Foundation

struct GeneratedInfoDTO: Codable {
    let info: [String: String]
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let values = try container.decode([String: String].self)
        self.info = values.reduce(into: [:]) {
            if let infoKey = GeneratedInfo(rawValue: $1.key)?.name {
                $0[infoKey] = $1.value
            }
        }
    }
}

enum GeneratedInfo: String, Codable, CaseIterable {
    case keyInformation
    case keyBenefits
    case energyConsumption
    case neededEquipment
    case popularAthletes
    
    var name: String {
        switch self {
        case .keyInformation:
            return "Key Information"
        case .keyBenefits:
            return "Key Benefits"
        case .energyConsumption:
            return "Energy Consumption"
        case .neededEquipment:
            return "Needed Equipment"
        case .popularAthletes:
            return "Popular Athletes"
        }
    }
}

struct BodyObject: Codable {
    let contents: [Content]
    let generationConfig: GenerationConfig
}

struct Content: Codable {
    var role: String = "user"
    let parts: [Part]
}

struct Part: Codable {
    let text: String
}

struct GenerationConfig: Codable {
    var temperature: Double = 1
    var topK: Int = 40
    var topP: Double = 0.95
    var maxOutputTokens: Int = 8192
    var responseMimeType: String = "application/json"
    var responseSchema: WorkoutResponseSchema = .init()
}

struct WorkoutResponseSchema: Codable {
    var type: String = "object"
    var properties: [String: [String: String]] = [
        GeneratedInfo.keyInformation.rawValue: ["type": "String"],
        GeneratedInfo.keyBenefits.rawValue: ["type": "String"],
        GeneratedInfo.energyConsumption.rawValue: ["type": "String"],
        GeneratedInfo.neededEquipment.rawValue: ["type": "String"],
        GeneratedInfo.popularAthletes.rawValue: ["type": "String"],
    ]
    var required: [String] = [
        GeneratedInfo.keyInformation.rawValue,
        GeneratedInfo.keyBenefits.rawValue,
        GeneratedInfo.energyConsumption.rawValue,
    ]
}

struct WorkoutRequestObjcet {
    let promt: String
    init(workout: String) {
        self.promt = """
        Define some information about \(workout) as a workout in Apple Watch app.
        Structure response as a:
        3 sentences of key information,
        Key benefits for health,
        Needed equipment,
        Most popular athleets in this sport,
        Avarange energy consumption. 
        """
    }
}

class GeminiService {
    private let apiKey = ""
    private lazy var endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?alt=sse&key=\(apiKey)"
    private let sesssion = URLSession(configuration: .default)
    private let cacheService = CacheService()
    
    func streamMessage(prompt: String) async throws -> [String: String]? {
        guard cacheService.cache[prompt] == nil else { return cacheService.cache[prompt] }
        guard let url = URL(string: endpoint) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = BodyObject(contents: [.init(parts: [.init(text: prompt)])],
                              generationConfig: GenerationConfig())
        
        request.httpBody = try? JSONEncoder().encode(body)
        
        let (data, _) = try await sesssion.data(for: request)
        var result: [String: String] = [:]
        if let jsonData = data.dropToClearResponse() {
            let json = try JSONDecoder().decode(GeneratedInfoDTO.self, from: jsonData)
            result = json.info
            cacheService.cache[prompt] = result
        }
        return result
    }
}

private extension Data {
    func dropToClearResponse() -> Data? {
        guard let rawString = String(data: self, encoding: .utf8) else { return nil }
        let text = rawString.split(separator: "\"text\": \"").last?.split(separator: "\"}],\"role\":").first
        let jsonString = text?.replacingOccurrences(of: "\\\"", with: "\"")
        return jsonString?.data(using: .utf8)
    }
}
