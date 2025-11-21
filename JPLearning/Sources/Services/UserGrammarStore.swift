//
//  UserGrammarStore.swift
//  JLearn
//
//  Persistent JSON store for user-generated grammar points.
//  This lets you extend the built‑in grammar library per level
//  using a simple JSON file in the app's Documents directory.
//

import Foundation
import OSLog

@MainActor
final class UserGrammarStore {
    
    static let shared = UserGrammarStore()
    
    private let fileName = "user_grammar.json"
    
    private init() {}
    
    // MARK: - File URL
    
    private var fileURL: URL? {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(fileName)
    }
    
    // MARK: - Public API
    
    /// Load all user-generated grammar points from JSON.
    func load() -> [GrammarPoint] {
        guard let url = fileURL,
              FileManager.default.fileExists(atPath: url.path) else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let grammar = try decoder.decode([GrammarPoint].self, from: data)
            AppLogger.info("Loaded \(grammar.count) user grammar points from JSON")
            return grammar
        } catch {
            AppLogger.error("Failed to decode user grammar JSON: \(error)")
            return []
        }
    }
    
    /// Append new grammar points to the JSON store, avoiding duplicates.
    func append(_ newItems: [GrammarPoint]) {
        guard !newItems.isEmpty else { return }
        
        var existing = load()
        let existingKeys = Set(existing.map { Self.key(for: $0) })
        
        let uniqueNew = newItems.filter { !existingKeys.contains(Self.key(for: $0)) }
        guard !uniqueNew.isEmpty else { return }
        
        existing.append(contentsOf: uniqueNew)
        save(existing)
        
        AppLogger.info("Saved \(uniqueNew.count) new user grammar points to JSON")
    }
    
    // MARK: - Private Helpers
    
    private func save(_ grammar: [GrammarPoint]) {
        guard let url = fileURL else { return }
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            
            let data = try encoder.encode(grammar)
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try data.write(to: url, options: [.atomic])
        } catch {
            AppLogger.error("Failed to save user grammar JSON: \(error)")
        }
    }
    
    private static func key(for grammar: GrammarPoint) -> String {
        "\(grammar.title)|\(grammar.pattern)|\(grammar.level)"
    }
}



