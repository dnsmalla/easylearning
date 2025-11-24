import Foundation

/// Service for parsing Japanese learning data from JSON files
final class JSONParserService {
    
    static let shared = JSONParserService()
    
    private init() {}
    
    // MARK: - JSON Models
    
    private struct LearningDataJSON: Codable {
        let flashcards: [FlashcardJSON]
        let grammar: [GrammarJSON]
        let practice: [PracticeJSON]
        let kanji: [KanjiJSON]?
        let games: [GameJSON]?
        let readingPassages: [ReadingPassageJSON]?
    }
    
    private struct FlashcardJSON: Codable {
        let id: String
        let front: String
        let back: String
        let reading: String?
        let meaning: String
        let example: String?
        let exampleReading: String?
        let exampleMeaning: String?
        let level: String
        let category: String
        let tags: [String]?
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
        let jlptLevel: String?
        let notes: String?
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
        let explanation: String?
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
    
    private struct GameJSON: Codable {
        let id: String
        let title: String
        let titleEnglish: String?
        let type: String
        let difficulty: String
        let level: String
        let description: String
        let timeLimit: Int
        let points: Int
        let pairs: [GamePairJSON]?
        let questions: [GameQuestionJSON]?
        let cards: [GameCardJSON]?
    }
    
    private struct GamePairJSON: Codable {
        let kanji: String
        let reading: String
        let meaning: String
    }
    
    private struct GameQuestionJSON: Codable {
        let word: String?
        let reading: String?
        let correctMeaning: String?
        let options: [String]?  // Made optional to support different game types
        let sentence: String?
        let correctParticle: String?
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
        let reading: String?
        let meaning: String
    }
    
    // MARK: - Public Methods
    
    /// Load learning data from bundled JSON file
    func loadLearningData() async throws -> (flashcards: [Flashcard], grammar: [GrammarPoint], practice: [PracticeQuestion], kanji: [Kanji], games: [GameModel]) {
        guard let url = Bundle.main.url(forResource: "japanese_learning_data", withExtension: "json") else {
            print("⚠️ Main JSON file not found in bundle")
            throw JSONParseError.fileNotFound
        }
        
        let data = try Data(contentsOf: url)
        return try parseAllData(data: data)
    }
    
    func parseAllData(data: Data) throws -> (flashcards: [Flashcard], grammar: [GrammarPoint], practice: [PracticeQuestion], kanji: [Kanji], games: [GameModel]) {
        let decoder = JSONDecoder()
        let learningData = try decoder.decode(LearningDataJSON.self, from: data)
        
        let flashcards = learningData.flashcards.map { convertToFlashcard($0) }
        let grammar = learningData.grammar.map { convertToGrammarPoint($0) }
        let practice = learningData.practice.compactMap { convertToPracticeQuestion($0) }
        let kanji = learningData.kanji?.map { convertToKanji($0) } ?? []
        let games = learningData.games?.compactMap { convertToGame($0) } ?? []
        
        print("✅ Loaded from JSON: \(flashcards.count) flashcards, \(grammar.count) grammar, \(practice.count) practice, \(kanji.count) kanji, \(games.count) games")
        
        return (flashcards, grammar, practice, kanji, games)
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
    
    /// Parse games from JSON data
    func parseGames(data: Data) throws -> [GameModel] {
        let decoder = JSONDecoder()
        let learningData = try decoder.decode(LearningDataJSON.self, from: data)
        return learningData.games?.compactMap { convertToGame($0) } ?? []
    }
    
    // MARK: - Private Conversion Methods
    
    private func convertToFlashcard(_ json: FlashcardJSON) -> Flashcard {
        var examples: [String] = []
        if let ex = json.example { examples.append(ex) }
        if let read = json.exampleReading { examples.append(read) }
        if let mean = json.exampleMeaning { examples.append(mean) }
        
        if examples.isEmpty {
           // No examples
        } else if examples.count == 3 {
             let formatted = "\(json.example ?? "") (\(json.exampleReading ?? "")) - \(json.exampleMeaning ?? "")"
             examples = [formatted]
        }
        
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
            notes: json.notes ?? json.formation
        )
    }
    
    private func convertToPracticeQuestion(_ json: PracticeJSON) -> PracticeQuestion? {
        guard let category = PracticeCategory(rawValue: json.category) else {
            if let mapped = PracticeCategory.allCases.first(where: { $0.rawValue.lowercased() == json.category.lowercased() }) {
                return PracticeQuestion(
                    id: json.id,
                    question: json.question,
                    options: json.options,
                    correctAnswer: json.correctAnswer,
                    explanation: json.explanation,
                    category: mapped,
                    level: json.level
                )
            }
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
    
    private func convertToGame(_ json: GameJSON) -> GameModel? {
        // Map private JSON structs to public GameModel structs
        
        let pairs = json.pairs?.map { p in
            GameModel.Pair(kanji: p.kanji, reading: p.reading, meaning: p.meaning)
        }
        
        let questions = json.questions?.map { q in
            GameModel.Question(
                word: q.word,
                reading: q.reading,
                correctMeaning: q.correctMeaning,
                options: q.options ?? [],  // Provide default empty array
                sentence: q.sentence,
                correctParticle: q.correctParticle,
                translation: q.translation
            )
        }
        
        let cards = json.cards?.map { c in
            GameModel.Card(id: c.id, content: c.content, cardType: c.cardType, pairId: c.pairId)
        }
        
        return GameModel(
            id: json.id,
            title: json.title,
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
}

// MARK: - Game Model (Added for JSON Support)
struct GameModel: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let type: String
    let level: String
    let points: Int
    let timeLimit: Int?
    
    let pairs: [Pair]?
    let questions: [Question]?
    let cards: [Card]?
    
    struct Pair: Codable {
        let kanji: String
        let reading: String
        let meaning: String
    }
    
    struct Question: Codable {
        let word: String?
        let reading: String?
        let correctMeaning: String?
        let options: [String]
        let sentence: String?
        let correctParticle: String?
        let translation: String?
    }
    
    struct Card: Codable {
        let id: String
        let content: String
        let cardType: String
        let pairId: String
    }
}

extension JSONParserService {
    /// Parse reading passages from JSON data
    func parseReadingPassages(data: Data) throws -> [ReadingPassage] {
        let decoder = JSONDecoder()
        let learningData = try decoder.decode(LearningDataJSON.self, from: data)
        return learningData.readingPassages?.map { convertToReadingPassage($0) } ?? []
    }
    
    private func convertToReadingPassage(_ json: ReadingPassageJSON) -> ReadingPassage {
        return ReadingPassage(
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
    
    private func convertToVocabularyItem(_ json: VocabularyItemJSON) -> ReadingPassage.VocabularyItem {
        return ReadingPassage.VocabularyItem(
            word: json.word,
            reading: json.reading,
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
