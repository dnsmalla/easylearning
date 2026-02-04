//
//  JSONParserService.swift
//  SKLearn
//
//  Service for parsing Sanskrit learning data from JSON files (JSON-Driven Architecture)
//

import Foundation

/// Service for parsing Sanskrit learning data from JSON files
final class JSONParserService {
    
    static let shared = JSONParserService()
    
    private init() {}
    
    // MARK: - JSON Models
    
    private struct LearningDataJSON: Codable {
        let level: String?
        let version: String?
        let description: String?
        let flashcards: [FlashcardJSON]
        let grammar: [GrammarJSON]
        let practice: [PracticeJSON]
        let games: [GameJSON]?
        let readingPassages: [ReadingPassageJSON]?
    }
    
    private struct FlashcardJSON: Codable {
        let id: String
        let front: String
        let back: String
        let romanization: String?
        let meaning: String
        let example: String?
        let exampleRomanization: String?
        let exampleMeaning: String?
        let level: String
        let category: String
        let tags: [String]?
        let examples: [String]?
        let isFavorite: Bool?
        let reviewCount: Int?
        let correctCount: Int?
    }
    
    private struct GrammarJSON: Codable {
        let id: String
        let pattern: String
        let title: String
        let meaning: String
        let usage: String
        let formation: String?
        let examples: [GrammarExampleJSON]
        let level: String
        let notes: String?
    }
    
    private struct GrammarExampleJSON: Codable {
        let sanskrit: String
        let romanization: String
        let english: String
    }
    
    private struct PracticeJSON: Codable {
        let id: String
        let question: String
        let options: [String]
        let correctAnswer: String
        let explanation: String?
        let category: String
        let level: String
    }
    
    private struct GameJSON: Codable {
        let id: String
        let title: String
        let titleEnglish: String?
        let type: String
        let difficulty: String?
        let level: String
        let description: String
        let timeLimit: Int
        let points: Int
        let pairs: [GamePairJSON]?
        let questions: [GameQuestionJSON]?
        let cards: [GameCardJSON]?
    }
    
    private struct GamePairJSON: Codable {
        let sanskrit: String
        let romanization: String
        let meaning: String
    }
    
    private struct GameQuestionJSON: Codable {
        let word: String?
        let romanization: String?
        let correctMeaning: String?
        let options: [String]?
        let sentence: String?
        let correctAnswer: String?
        let translation: String?
    }
    
    private struct GameCardJSON: Codable {
        let id: String
        let content: String
        let cardType: String
        let pairId: String
    }
    
    private struct ReadingPassageJSON: Codable {
        let id: String
        let text: String
        let vocabulary: [VocabularyItemJSON]
        let question: String
        let options: [String]
        let correctAnswer: String
        let explanation: String?
        let level: String?
    }
    
    private struct VocabularyItemJSON: Codable {
        let word: String
        let romanization: String?
        let meaning: String
    }
    
    // Speaking and Writing JSON structures
    private struct SpeakingDataJSON: Codable {
        let category: String
        let description: String
        let levels: [String: [SpeakingExercise]]
    }
    
    private struct WritingDataJSON: Codable {
        let category: String
        let description: String
        let levels: [String: [WritingExercise]]
    }
    
    private struct GrammarDataJSON: Codable {
        let category: String
        let description: String
        let levels: [String: [GrammarJSON]]
    }
    
    // MARK: - Public Methods
    
    /// Load learning data from bundled JSON file
    func loadLearningData() async throws -> (flashcards: [Flashcard], grammar: [GrammarPoint], practice: [PracticeQuestion], games: [GameModel]) {
        guard let url = Bundle.main.url(forResource: "sanskrit_learning_data", withExtension: "json") else {
            print("⚠️ Main JSON file not found in bundle")
            throw JSONParseError.fileNotFound
        }
        
        let data = try Data(contentsOf: url)
        return try parseAllData(data: data)
    }
    
    func parseAllData(data: Data) throws -> (flashcards: [Flashcard], grammar: [GrammarPoint], practice: [PracticeQuestion], games: [GameModel]) {
        let decoder = JSONDecoder()
        let learningData = try decoder.decode(LearningDataJSON.self, from: data)
        
        let flashcards = learningData.flashcards.map { convertToFlashcard($0) }
        let grammar = learningData.grammar.map { convertToGrammarPoint($0) }
        let practice = learningData.practice.compactMap { convertToPracticeQuestion($0) }
        let games = learningData.games?.compactMap { convertToGame($0) } ?? []
        
        print("✅ Loaded from JSON: \(flashcards.count) flashcards, \(grammar.count) grammar, \(practice.count) practice, \(games.count) games")
        
        return (flashcards, grammar, practice, games)
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
    
    /// Parse games from JSON data
    func parseGames(data: Data) throws -> [GameModel] {
        let decoder = JSONDecoder()
        let learningData = try decoder.decode(LearningDataJSON.self, from: data)
        return learningData.games?.compactMap { convertToGame($0) } ?? []
    }
    
    /// Parse reading passages from JSON data
    func parseReadingPassages(data: Data) throws -> [ReadingPassageModel] {
        let decoder = JSONDecoder()
        let learningData = try decoder.decode(LearningDataJSON.self, from: data)
        return learningData.readingPassages?.map { convertToReadingPassage($0) } ?? []
    }
    
    /// Parse speaking exercises from standalone JSON file
    func parseSpeaking(from filename: String, level: LearningLevel) -> [SpeakingExercise] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            AppLogger.warning("Speaking file not found: \(filename).json")
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            let speakingData = try decoder.decode(SpeakingDataJSON.self, from: data)
            
            // Filter by level
            let levelKey = level.rawValue.lowercased()
            return speakingData.levels[levelKey] ?? []
        } catch {
            AppLogger.error("Failed to parse speaking data: \(error)")
            return []
        }
    }
    
    /// Parse writing exercises from standalone JSON file
    func parseWriting(from filename: String, level: LearningLevel) -> [WritingExercise] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            AppLogger.warning("Writing file not found: \(filename).json")
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            let writingData = try decoder.decode(WritingDataJSON.self, from: data)
            
            // Filter by level
            let levelKey = level.rawValue.lowercased()
            return writingData.levels[levelKey] ?? []
        } catch {
            AppLogger.error("Failed to parse writing data: \(error)")
            return []
        }
    }
    
    /// Parse reading passages from standalone JSON file (level-filtered)
    func parseReading(from filename: String, level: LearningLevel) -> [ReadingPassageModel] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            AppLogger.warning("Reading file not found: \(filename).json")
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            
            // Reading JSON has a different structure with levels
            struct ReadingDataJSON: Codable {
                let category: String
                let description: String
                let levels: [String: [ReadingPassageJSON]]
            }
            
            struct ReadingPassageJSON: Codable {
                let id: String
                let title: String
                let englishTitle: String
                let difficulty: String
                let paragraphs: [String]
                let englishParagraphs: [String]
                let vocabulary: [VocabItemJSON]
                let questions: [QuestionJSON]
                let level: String
                
                struct VocabItemJSON: Codable {
                    let sanskrit: String
                    let english: String
                    let romanization: String
                }
                
                struct QuestionJSON: Codable {
                    let question: String
                    let options: [String]
                    let correctAnswer: String
                }
            }
            
            let readingData = try decoder.decode(ReadingDataJSON.self, from: data)
            
            // Filter by level
            let levelKey = level.rawValue.lowercased()
            guard let passages = readingData.levels[levelKey] else {
                return []
            }
            
            // Convert to ReadingPassageModel
            return passages.compactMap { json -> ReadingPassageModel? in
                guard let firstQuestion = json.questions.first else { return nil }
                
                let vocabularyItems = json.vocabulary.map { vocab in
                    ReadingPassageModel.VocabularyItem(
                        word: vocab.sanskrit,
                        romanization: vocab.romanization,
                        meaning: vocab.english
                    )
                }
                
                return ReadingPassageModel(
                    id: json.id,
                    text: json.paragraphs.joined(separator: "\n\n"),
                    vocabulary: vocabularyItems,
                    question: firstQuestion.question,
                    options: firstQuestion.options,
                    correctAnswer: firstQuestion.correctAnswer,
                    explanation: nil,
                    level: json.level
                )
            }
        } catch {
            AppLogger.error("Failed to parse reading data: \(error)")
            return []
        }
    }
    
    /// Parse grammar from standalone JSON file (level-filtered)
    func parseGrammar(from filename: String, level: LearningLevel) -> [GrammarPoint] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            AppLogger.warning("Grammar file not found: \(filename).json")
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            let grammarData = try decoder.decode(GrammarDataJSON.self, from: data)
            
            // Filter by level
            let levelKey = level.rawValue.lowercased()
            guard let grammarItems = grammarData.levels[levelKey] else {
                return []
            }
            
            // Convert to GrammarPoint
            return grammarItems.map { convertToGrammarPoint($0) }
        } catch {
            AppLogger.error("Failed to parse grammar data: \(error)")
            return []
        }
    }
    
    // MARK: - Private Conversion Methods
    
    private func convertToFlashcard(_ json: FlashcardJSON) -> Flashcard {
        var examples: [String] = json.examples ?? []
        
        // Build examples from individual fields if available
        if examples.isEmpty {
            if let ex = json.example { examples.append(ex) }
            if let rom = json.exampleRomanization { examples.append(rom) }
            if let mean = json.exampleMeaning { examples.append(mean) }
            
            if examples.count == 3, let ex = json.example, let rom = json.exampleRomanization, let mean = json.exampleMeaning {
                let formatted = "\(ex) (\(rom)) - \(mean)"
                examples = [formatted]
            }
        }
        
        return Flashcard(
            id: json.id,
            front: json.front,
            back: json.back,
            romanization: json.romanization,
            meaning: json.meaning,
            level: json.level,
            category: json.category,
            examples: examples.isEmpty ? nil : examples,
            isFavorite: json.isFavorite ?? false,
            reviewCount: json.reviewCount ?? 0,
            correctCount: json.correctCount ?? 0
        )
    }
    
    private func convertToGrammarPoint(_ json: GrammarJSON) -> GrammarPoint {
        let examples = json.examples.map { example in
            GrammarExample(
                sanskrit: example.sanskrit,
                romanization: example.romanization,
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
            notes: json.notes ?? json.formation
        )
    }
    
    /// Maps JSON category strings (e.g. from level data) to app PracticeCategory so questions are not dropped.
    private static let practiceCategoryFallback: [String: PracticeCategory] = [
        "declension": .grammar, "cases": .grammar, "case": .grammar, "sandhi": .grammar,
        "verbs": .grammar, "verb": .grammar, "compounds": .grammar, "compound": .grammar,
        "moods": .grammar, "participles": .grammar, "gerunds": .grammar, "infinitives": .grammar,
        "voice": .grammar, "derived_verbs": .grammar, "noun_stems": .grammar, "pronouns": .grammar,
        "philosophy": .vocabulary, "education": .vocabulary, "verb_classes": .grammar,
        "translation": .reading, "vocabulary": .vocabulary
    ]

    private func convertToPracticeQuestion(_ json: PracticeJSON) -> PracticeQuestion? {
        let category: PracticeCategory
        if let parsed = PracticeCategory(rawValue: json.category) {
            category = parsed
        } else if let mapped = PracticeCategory.allCases.first(where: { $0.rawValue.lowercased() == json.category.lowercased() }) {
            category = mapped
        } else if let fallback = Self.practiceCategoryFallback[json.category.lowercased()] {
            category = fallback
        } else {
            print("⚠️ Unknown practice category: \(json.category), defaulting to Grammar")
            category = .grammar
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
    
    private func convertToGame(_ json: GameJSON) -> GameModel? {
        let pairs = json.pairs?.map { p in
            GameModel.Pair(sanskrit: p.sanskrit, romanization: p.romanization, meaning: p.meaning)
        }
        
        let questions = json.questions?.map { q in
            GameModel.Question(
                word: q.word,
                romanization: q.romanization,
                correctMeaning: q.correctMeaning,
                options: q.options ?? [],
                sentence: q.sentence,
                correctAnswer: q.correctAnswer,
                translation: q.translation
            )
        }
        
        let cards = json.cards?.map { c in
            GameModel.Card(id: c.id, content: c.content, cardType: c.cardType, pairId: c.pairId)
        }
        
        return GameModel(
            id: json.id,
            title: json.title,
            titleEnglish: json.titleEnglish,
            description: json.description,
            type: json.type,
            level: json.level,
            points: json.points,
            timeLimit: json.timeLimit,
            pairs: pairs,
            questions: questions,
            cards: cards
        )
    }
    
    private func convertToReadingPassage(_ json: ReadingPassageJSON) -> ReadingPassageModel {
        return ReadingPassageModel(
            id: json.id,
            text: json.text,
            vocabulary: json.vocabulary.map { convertToVocabularyItem($0) },
            question: json.question,
            options: json.options,
            correctAnswer: json.correctAnswer,
            explanation: json.explanation,
            level: json.level
        )
    }
    
    private func convertToVocabularyItem(_ json: VocabularyItemJSON) -> ReadingPassageModel.VocabularyItem {
        return ReadingPassageModel.VocabularyItem(
            word: json.word,
            romanization: json.romanization,
            meaning: json.meaning
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
