//
//  UserPracticeStore.swift
//  JLearn
//
//  Persistent JSON store for user-generated practice questions.
//  This makes it easy to grow level-based quizzes via JSON files.
//

import Foundation
import OSLog

@MainActor
final class UserPracticeStore {
    
    static let shared = UserPracticeStore()
    
    private let fileName = "user_practice.json"
    
    private init() {}
    
    // MARK: - File URL
    
    private var fileURL: URL? {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(fileName)
    }
    
    // MARK: - Public API
    
    /// Load all user-generated practice questions from JSON.
    func load() -> [PracticeQuestion] {
        guard let url = fileURL,
              FileManager.default.fileExists(atPath: url.path) else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let questions = try decoder.decode([PracticeQuestion].self, from: data)
            AppLogger.info("Loaded \(questions.count) user practice questions from JSON")
            return questions
        } catch {
            AppLogger.error("Failed to decode user practice JSON: \(error)")
            return []
        }
    }
    
    /// Append new practice questions to the JSON store, avoiding duplicates.
    func append(_ newItems: [PracticeQuestion]) {
        guard !newItems.isEmpty else { return }
        
        var existing = load()
        let existingKeys = Set(existing.map { Self.key(for: $0) })
        
        let uniqueNew = newItems.filter { !existingKeys.contains(Self.key(for: $0)) }
        guard !uniqueNew.isEmpty else { return }
        
        existing.append(contentsOf: uniqueNew)
        save(existing)
        
        AppLogger.info("Saved \(uniqueNew.count) new user practice questions to JSON")
    }
    
    // MARK: - Private Helpers
    
    private func save(_ questions: [PracticeQuestion]) {
        guard let url = fileURL else { return }
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            
            let data = try encoder.encode(questions)
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try data.write(to: url, options: [.atomic])
        } catch {
            AppLogger.error("Failed to save user practice JSON: \(error)")
        }
    }
    
    private static func key(for question: PracticeQuestion) -> String {
        "\(question.question)|\(question.category.rawValue)|\(question.level)"
    }
}



