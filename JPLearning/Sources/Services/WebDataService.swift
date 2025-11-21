//
//  WebDataService.swift
//  JLearn
//
//  Service for fetching Japanese learning data from web APIs
//

import Foundation

@MainActor
final class WebDataService: ObservableObject {
    
    static let shared = WebDataService()
    
    @Published var isSearching = false
    @Published var searchResults: [SearchResult] = []
    
    private let jishoAPIBase = "https://jisho.org/api/v1/search/words"
    
    private init() {}
    
    // MARK: - Search Result Types
    
    struct SearchResult: Identifiable {
        let id = UUID()
        let word: String
        let reading: String
        let meanings: [String]
        let jlptLevel: String?
        let isCommon: Bool
        /// Parts of speech information from Jisho (e.g., "noun", "expression").
        /// Used by Auto Vocabulary to distinguish vocabulary vs grammar-like items.
        let partsOfSpeech: [String]
        let alreadyExists: Bool
    }
    
    // MARK: - Search Japanese Words
    
    /// Search for Japanese words using Jisho API
    func searchWords(query: String, level: String = "N5") async throws -> [SearchResult] {
        isSearching = true
        defer { isSearching = false }
        
        guard !query.isEmpty else { return [] }
        
        // URL encode the query
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw WebDataError.invalidQuery
        }
        
        // Construct URL
        let urlString = "\(jishoAPIBase)?keyword=\(encodedQuery)"
        guard let url = URL(string: urlString) else {
            throw WebDataError.invalidURL
        }
        
        // Make request
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw WebDataError.networkError
        }
        
        // Parse response
        let jishoResponse = try JSONDecoder().decode(JishoResponse.self, from: data)
        
        // Convert to SearchResults and check for duplicates
        var results: [SearchResult] = []
        
        // Pull a larger batch so auto-generation can surface plenty of items per level
        for item in jishoResponse.data.prefix(200) {
            guard let firstJapanese = item.japanese.first,
                  let firstSense = item.senses.first else {
                continue
            }
            
            let word = firstJapanese.word ?? firstJapanese.reading
            let reading = firstJapanese.reading
            let meanings = firstSense.englishDefinitions
            // For strict JLPT-based auto search we only trust real JLPT tags.
            // If Jisho does not provide a JLPT tag, `jlptLevel` stays nil.
            let jlptLevel = normalizeJLPTLevel(from: item.jlpt)
            let isCommon = item.isCommon ?? false
            let partsOfSpeech = firstSense.partsOfSpeech
            
            // Check if this word already exists in loaded data
            let exists = await checkIfWordExists(word: word, reading: reading)
            
            results.append(
                SearchResult(
                    word: word,
                    reading: reading,
                    meanings: meanings,
                    jlptLevel: jlptLevel,
                    isCommon: isCommon,
                    partsOfSpeech: partsOfSpeech,
                    alreadyExists: exists
                )
            )
        }
        
        // Publish for any observers (e.g., search views)
        self.searchResults = results
        
        return results
    }
    
    // MARK: - Check for Duplicates
    
    /// Check if a word already exists in the learning data
    private func checkIfWordExists(word: String, reading: String) async -> Bool {
        let flashcards = LearningDataService.shared.flashcards
        
        // Check if any flashcard has the same word or reading
        return flashcards.contains { flashcard in
            flashcard.front == word ||
            flashcard.back == reading ||
            flashcard.reading == reading
        }
    }
    
    /// Normalize JLPT tags from Jisho (e.g. "jlpt-n5") into app level codes ("N5").
    /// Falls back to `nil` if no recognizable JLPT tag is present.
    private func normalizeJLPTLevel(from tags: [String]) -> String? {
        // Jisho returns values like "jlpt-n5", "jlpt-n1"
        guard let raw = tags.first(where: { $0.lowercased().hasPrefix("jlpt-n") }) else {
            return nil
        }
        
        // Extract the trailing part after "jlpt-n"
        if let range = raw.range(of: "jlpt-n", options: .caseInsensitive) {
            let suffix = raw[range.upperBound...]
            // Expect a digit 1–5
            let levelDigit = suffix.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            switch levelDigit {
            case "1": return "N1"
            case "2": return "N2"
            case "3": return "N3"
            case "4": return "N4"
            case "5": return "N5"
            default: return nil
            }
        }
        
        return nil
    }
    
    // MARK: - Add to Data
    
    /// Convert search results to flashcards (without duplicates)
    /// - Parameters:
    ///   - results: Search results from web
    ///   - level: JLPT level to assign
    ///   - category: Flashcard category (`vocabulary`, `kanji`, `grammar`)
    func convertToFlashcards(
        results: [SearchResult],
        level: String,
        category: String = "vocabulary"
    ) -> [Flashcard] {
        return results
            .filter { !$0.alreadyExists } // Only include new words
            .map { result in
                Flashcard(
                    id: UUID().uuidString,
                    front: result.word,
                    back: result.reading,
                    reading: result.reading,
                    meaning: result.meanings.joined(separator: ", "),
                    level: result.jlptLevel ?? level,
                    category: category,
                    examples: [],
                    audioURL: nil,
                    isFavorite: false,
                    lastReviewed: nil,
                    nextReview: nil,
                    reviewCount: 0,
                    correctCount: 0
                )
            }
    }
    
    /// Save new flashcards to the JSON-based local library (avoiding duplicates)
    func saveToLocalLibrary(flashcards: [Flashcard]) async throws {
        // Filter out any that already exist in the in-memory flashcards
        let newFlashcards = flashcards.filter { flashcard in
            !LearningDataService.shared.flashcards.contains { existing in
                existing.front == flashcard.front ||
                existing.reading == flashcard.reading
            }
        }
        
        guard !newFlashcards.isEmpty else {
            AppLogger.info("No new flashcards to save (all were duplicates)")
            return
        }
        
        // Persist to JSON in the app's Documents directory
        UserFlashcardStore.shared.append(newFlashcards)
        
        // Add to in-memory flashcards so current session can use them
        LearningDataService.shared.flashcards.append(contentsOf: newFlashcards)
        
        AppLogger.info("Added \(newFlashcards.count) new flashcards to local JSON library")
    }
    
    /// Export new words to CSV format (for manual Excel import)
    func exportToCSV(results: [SearchResult], level: String) -> String {
        var csv = "Level,Category,Character/Word,Reading,Example Sentence,Translation,Notes\n"
        
        for result in results where !result.alreadyExists {
            let word = result.word.replacingOccurrences(of: ",", with: "，")
            let reading = result.reading.replacingOccurrences(of: ",", with: "，")
            let meanings = result.meanings.joined(separator: "; ").replacingOccurrences(of: ",", with: "，")
            let jlptLevel = result.jlptLevel ?? level
            
            csv += "\(jlptLevel),vocabulary,\(word),\(reading),,\(meanings),From Jisho\n"
        }
        
        return csv
    }
}

// MARK: - JSON Export Support

extension WebDataService {
    
    /// Export new search results to JSON flashcard objects matching `japanese_learning_data.json` schema.
    /// The returned string is a JSON array you can paste into the `flashcards` section.
    /// - Parameters:
    ///   - results: Search results to export
    ///   - level: JLPT level to assign
    ///   - category: Flashcard category (`vocabulary`, `kanji`, `grammar`)
    func exportToJSON(
        results: [SearchResult],
        level: String,
        category: String = "vocabulary"
    ) -> String {
        struct ExportFlashcard: Codable {
            let id: String
            let front: String
            let back: String
            let reading: String
            let meaning: String
            let example: String
            let exampleReading: String
            let exampleMeaning: String
            let level: String
            let category: String
            let tags: [String]
        }
        
        // Build flashcard payloads for items that don't already exist
        let exportItems: [ExportFlashcard] = results
            .filter { !$0.alreadyExists }
            .enumerated()
            .map { index, result in
                let baseIdLevel = level.lowercased()
                let generatedId = "web_\(baseIdLevel)_\(String(format: "%03d", index + 1))"
                let joinedMeanings = result.meanings.joined(separator: "; ")
                
                return ExportFlashcard(
                    id: generatedId,
                    front: result.word,
                    back: result.reading,
                    reading: result.reading,
                    meaning: joinedMeanings,
                    example: result.word,
                    exampleReading: result.reading,
                    exampleMeaning: joinedMeanings,
                    level: result.jlptLevel ?? level,
                    category: category,
                    tags: ["web", "auto", baseIdLevel, category]
                )
            }
        
        guard !exportItems.isEmpty else {
            return "[]"
        }
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(exportItems)
            return String(data: data, encoding: .utf8) ?? "[]"
        } catch {
            print("⚠️ Failed to export JSON from web results: \(error)")
            return "[]"
        }
    }
}


// MARK: - Errors

enum WebDataError: LocalizedError {
    case invalidQuery
    case invalidURL
    case networkError
    case parsingError
    
    var errorDescription: String? {
        switch self {
        case .invalidQuery: return "Invalid search query"
        case .invalidURL: return "Invalid URL"
        case .networkError: return "Network request failed"
        case .parsingError: return "Failed to parse response"
        }
    }
}

// MARK: - Jisho API Response Models

struct JishoResponse: Codable {
    let data: [JishoWord]
}

struct JishoWord: Codable {
    let slug: String
    let isCommon: Bool?
    let jlpt: [String]
    let japanese: [JapaneseReading]
    let senses: [Sense]
    
    enum CodingKeys: String, CodingKey {
        case slug
        case isCommon = "is_common"
        case jlpt
        case japanese
        case senses
    }
}

struct JapaneseReading: Codable {
    let word: String?
    let reading: String
}

struct Sense: Codable {
    let englishDefinitions: [String]
    let partsOfSpeech: [String]
    
    enum CodingKeys: String, CodingKey {
        case englishDefinitions = "english_definitions"
        case partsOfSpeech = "parts_of_speech"
    }
}

