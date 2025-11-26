//
//  UserFlashcardStore.swift
//  JLearn
//
//  Persistent JSON store for user-generated flashcards.
//  This lets Web Search and Auto Vocabulary automatically
//  grow the app's learning library by writing JSON files
//  in the app's sandbox (Documents directory).
//

import Foundation
import OSLog

@MainActor
final class UserFlashcardStore {
    
    static let shared = UserFlashcardStore()
    
    private let fileName = "user_flashcards.json"
    
    private init() {}
    
    // MARK: - File URL
    
    private var fileURL: URL? {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(fileName)
    }
    
    // MARK: - Public API
    
    /// Load all user-generated flashcards from JSON.
    func load() -> [Flashcard] {
        guard let url = fileURL,
              FileManager.default.fileExists(atPath: url.path) else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let flashcards = try decoder.decode([Flashcard].self, from: data)
            AppLogger.info("Loaded \(flashcards.count) user flashcards from JSON")
            return flashcards
        } catch {
            AppLogger.error("Failed to decode user flashcards JSON: \(error)")
            return []
        }
    }
    
    /// Append new flashcards to the JSON store, avoiding duplicates.
    func append(_ newFlashcards: [Flashcard]) {
        guard !newFlashcards.isEmpty else { return }
        
        var existing = load()
        let existingKeys = Set(existing.map { Self.key(for: $0) })
        
        let uniqueNew = newFlashcards.filter { !existingKeys.contains(Self.key(for: $0)) }
        guard !uniqueNew.isEmpty else { return }
        
        existing.append(contentsOf: uniqueNew)
        save(existing)
        
        AppLogger.info("Saved \(uniqueNew.count) new user flashcards to JSON")
    }
    
    // MARK: - Private Helpers
    
    private func save(_ flashcards: [Flashcard]) {
        guard let url = fileURL else { return }
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            
            let data = try encoder.encode(flashcards)
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try data.write(to: url, options: [.atomic])
        } catch {
            AppLogger.error("Failed to save user flashcards JSON: \(error)")
        }
    }
    
    private static func key(for flashcard: Flashcard) -> String {
        "\(flashcard.front)|\(flashcard.reading ?? "")"
    }
}


