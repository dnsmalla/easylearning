//
//  AutoVocabularyEngine.swift
//  JLearn
//
//  JLPT-aware automatic vocabulary discovery tailored for this app.
//  Uses the existing `WebDataService` (Jisho API) and filters strictly
//  by JLPT level and content type (vocabulary / kanji / grammar / sentences).
//

import Foundation

@MainActor
final class AutoVocabularyEngine {
    
    static let shared = AutoVocabularyEngine()
    
    private init() {}
    
    // MARK: - Public API
    
    /// Discover web vocabulary for a given JLPT level and content type.
    /// - Parameters:
    ///   - level: JLPT level selected in the UI (N5–N1).
    ///   - type: Content type (vocabulary / kanji / grammar / sentences / all).
    ///   - targetCount: Maximum number of items to return.
    func discoverVocabulary(
        for level: LearningLevel,
        type: AutoContentType,
        targetCount: Int
    ) async -> [WebDataService.SearchResult] {
        // Special handling for "All Types": we intentionally blend
        // vocabulary, grammar, sentences and kanji so the user does
        // not see only kanji-heavy results.
        if type == .all {
            return await discoverMixedTypes(for: level, targetCount: targetCount)
        }
        
        return await fetch(for: level, type: type, targetCount: targetCount)
    }
    
    // MARK: - Internal Fetchers
    
    /// Fetch results for a single concrete content type.
    private func fetch(
        for level: LearningLevel,
        type: AutoContentType,
        targetCount: Int
    ) async -> [WebDataService.SearchResult] {
        var collected: [WebDataService.SearchResult] = []
        var seen = Set<String>()
        
        let query = jlptTag(for: level)
        
        do {
            let results = try await WebDataService.shared.searchWords(
                query: query,
                level: level.rawValue
            )
            
            for result in results {
                if collected.count >= targetCount {
                    break
                }
                
                guard matchesLevel(result, level: level),
                      matchesType(result, type: type) else {
                    continue
                }
                
                let key = "\(result.word)|\(result.reading)"
                if !seen.contains(key) {
                    seen.insert(key)
                    collected.append(result)
                }
            }
        } catch {
            AppLogger.error("AutoVocabularyEngine query failed: \(query) – \(error.localizedDescription)")
        }
        
        AppLogger.info("AutoVocabularyEngine discovered \(collected.count) items for level \(level.rawValue) and type \(type.rawValue)")
        return collected
    }
    
    /// Blend multiple content types for the "All Types" option so that
    /// results are not dominated by kanji-only entries.
    private func discoverMixedTypes(
        for level: LearningLevel,
        targetCount: Int
    ) async -> [WebDataService.SearchResult] {
        // Prioritise vocabulary and sentences, then grammar, then kanji.
        let orderedTypes: [AutoContentType] = [.vocabulary, .sentences, .grammar, .kanji]
        var merged: [WebDataService.SearchResult] = []
        var seen = Set<String>()
        
        for subtype in orderedTypes {
            let remaining = targetCount - merged.count
            guard remaining > 0 else { break }
            
            let subset = await fetch(for: level, type: subtype, targetCount: remaining)
            for result in subset {
                let key = "\(result.word)|\(result.reading)"
                if !seen.contains(key) {
                    seen.insert(key)
                    merged.append(result)
                }
            }
        }
        
        AppLogger.info("AutoVocabularyEngine mixed-types discovered \(merged.count) items for level \(level.rawValue)")
        return merged
    }
    
    // MARK: - Level & Type Filtering
    
    /// Ensure the result really belongs to the selected JLPT level.
    /// We only accept items whose JLPT level exactly matches the chosen level.
    private func matchesLevel(_ result: WebDataService.SearchResult, level: LearningLevel) -> Bool {
        guard let jlpt = result.jlptLevel else {
            // If JLPT level is unknown, we skip it to avoid mixing levels.
            return false
        }
        return jlpt.uppercased() == level.rawValue.uppercased() // e.g. "N5"
    }
    
    /// Filter by requested content type.
    private func matchesType(_ result: WebDataService.SearchResult, type: AutoContentType) -> Bool {
        switch type {
        case .all:
            // Handled by `discoverMixedTypes`; keep broad here.
            return true
        case .vocabulary:
            // Default: any non-kanji-only item
            return !isSingleKanji(result.word)
        case .kanji:
            // Treat single-character Japanese entries as kanji items
            return isSingleKanji(result.word)
        case .grammar:
            // Use parts-of-speech hints from Jisho to find grammar-like entries
            let pos = result.partsOfSpeech.map { $0.lowercased() }
            return pos.contains(where: { tag in
                tag.contains("expression") ||
                tag.contains("auxiliary") ||
                tag.contains("particle") ||
                tag.contains("conjunction") ||
                tag.contains("grammar")
            })
        case .sentences:
            // Approximate sentences/phrases: longer expressions or items with punctuation.
            let word = result.word
            let meaning = result.meanings.first ?? ""
            
            let hasJapanesePunctuation = word.contains("。") || word.contains("、") || word.contains("？") || word.contains("！")
            let hasSeparators = word.contains(" ") || word.contains("　") // space / full-width space
            let wordLength = word.count
            let meaningLength = meaning.count
            
            return hasJapanesePunctuation
                || hasSeparators
                || wordLength >= 4
                || meaningLength >= 40
        }
    }
    
    private func isSingleKanji(_ text: String) -> Bool {
        return text.count == 1
    }
    
    // MARK: - Query Generation
    
    /// Jisho tag for the JLPT level, e.g. "#jlpt-n5".
    /// This keeps the search aligned with the selected level.
    private func jlptTag(for level: LearningLevel) -> String {
        return "#jlpt-\(level.rawValue.lowercased())"
    }
}


