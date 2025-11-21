import Foundation

/// Service for parsing Japanese learning data from JSON files
@MainActor
final class JSONParserService {
    
    static let shared = JSONParserService()
    
    private init() {}
    
    // MARK: - JSON Models
    
    private struct LearningDataJSON: Codable {
        let flashcards: [FlashcardJSON]
        let grammar: [GrammarJSON]
        let practice: [PracticeJSON]
        let kanji: [KanjiJSON]?
    }
    
    private struct FlashcardJSON: Codable {
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
    
    private struct GrammarJSON: Codable {
        let id: String
        let pattern: String
        let title: String
        let meaning: String
        let usage: String
        let formation: String
        let examples: [GrammarExampleJSON]
        let level: String
        let jlptLevel: String
    }
    
    private struct GrammarExampleJSON: Codable {
        let japanese: String
        let reading: String
        let english: String
    }
    
    private struct PracticeJSON: Codable {
        let id: String
        let question: String
        let options: [String]
        let correctAnswer: String
        let explanation: String
        let category: String
        let level: String
    }
    
    private struct KanjiJSON: Codable {
        let id: String
        let character: String
        let meaning: String
        let readings: KanjiReadingsJSON
        let strokes: Int
        let examples: [String]
        let jlptLevel: String
    }
    
    private struct KanjiReadingsJSON: Codable {
        let onyomi: [String]
        let kunyomi: [String]
    }
    
    // MARK: - Public Methods
    
    /// Load learning data from bundled JSON file
    func loadLearningData() async throws -> (flashcards: [Flashcard], grammar: [GrammarPoint], practice: [PracticeQuestion]) {
        guard let url = Bundle.main.url(forResource: "japanese_learning_data", withExtension: "json") else {
            print("⚠️ JSON file not found in bundle")
            throw JSONParseError.fileNotFound
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let learningData = try decoder.decode(LearningDataJSON.self, from: data)
        
        let flashcards = learningData.flashcards.map { convertToFlashcard($0) }
        let grammar = learningData.grammar.map { convertToGrammarPoint($0) }
        let practice = learningData.practice.compactMap { convertToPracticeQuestion($0) }
        
        print("✅ Loaded from JSON: \(flashcards.count) flashcards, \(grammar.count) grammar, \(practice.count) practice")
        
        return (flashcards, grammar, practice)
    }
    
    /// Parse flashcards from JSON data
    func parseFlashcards(data: Data) throws -> [Flashcard] {
        let decoder = JSONDecoder()
        let learningData = try decoder.decode(LearningDataJSON.self, from: data)
        return learningData.flashcards.map { convertToFlashcard($0) }
    }
    
    /// Parse grammar points from JSON data
    func parseGrammar(data: Data) throws -> [GrammarPoint] {
        let decoder = JSONDecoder()
        let learningData = try decoder.decode(LearningDataJSON.self, from: data)
        return learningData.grammar.map { convertToGrammarPoint($0) }
    }
    
    /// Parse practice questions from JSON data
    func parsePracticeQuestions(data: Data) throws -> [PracticeQuestion] {
        let decoder = JSONDecoder()
        let learningData = try decoder.decode(LearningDataJSON.self, from: data)
        return learningData.practice.compactMap { convertToPracticeQuestion($0) }
    }
    
    /// Parse kanji from JSON data
    func parseKanji(data: Data) throws -> [Kanji] {
        let decoder = JSONDecoder()
        let learningData = try decoder.decode(LearningDataJSON.self, from: data)
        return learningData.kanji?.map { convertToKanji($0) } ?? []
    }
    
    // MARK: - Private Conversion Methods
    
    private func convertToFlashcard(_ json: FlashcardJSON) -> Flashcard {
        // Combine example fields into a single array for examples
        let examples = [json.example, json.exampleReading, json.exampleMeaning]
            .filter { !$0.isEmpty }
        
        return Flashcard(
            id: json.id,
            front: json.front,
            back: json.back,
            reading: json.reading,
            meaning: json.meaning,
            level: json.level,
            category: json.category,
            examples: examples.isEmpty ? nil : examples
        )
    }
    
    private func convertToGrammarPoint(_ json: GrammarJSON) -> GrammarPoint {
        let examples = json.examples.map { example in
            GrammarExample(
                japanese: example.japanese,
                reading: example.reading,
                english: example.english
            )
        }
        
        return GrammarPoint(
            id: json.id,
            title: json.title,
            pattern: json.pattern,
            meaning: json.meaning,
            usage: json.usage,
            examples: examples,
            level: json.level,
            notes: json.formation
        )
    }
    
    private func convertToPracticeQuestion(_ json: PracticeJSON) -> PracticeQuestion? {
        guard let category = PracticeCategory(rawValue: json.category) else {
            print("⚠️ Unknown practice category: \(json.category)")
            return nil
        }
        
        return PracticeQuestion(
            id: json.id,
            question: json.question,
            options: json.options,
            correctAnswer: json.correctAnswer,
            explanation: json.explanation,
            category: category,
            level: json.level
        )
    }
    
    private func convertToKanji(_ json: KanjiJSON) -> Kanji {
        let readings = KanjiReadings(
            onyomi: json.readings.onyomi,
            kunyomi: json.readings.kunyomi
        )
        
        return Kanji(
            id: json.id,
            character: json.character,
            meaning: json.meaning,
            readings: readings,
            strokes: json.strokes,
            examples: json.examples,
            jlptLevel: json.jlptLevel
        )
    }
}

// MARK: - Error Types

enum JSONParseError: LocalizedError {
    case fileNotFound
    case invalidData
    case decodingFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "JSON file not found in bundle"
        case .invalidData:
            return "Invalid JSON data format"
        case .decodingFailed(let error):
            return "Failed to decode JSON: \(error.localizedDescription)"
        }
    }
}

