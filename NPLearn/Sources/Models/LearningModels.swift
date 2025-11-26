//
//  LearningModels.swift
//  NPLearn
//
//  Core data models for the Nepali learning app
//

import Foundation

// MARK: - User Model

struct UserModel: Identifiable, Codable {
    var id: String
    var email: String
    var displayName: String?
    var photoURL: String?
    var createdAt: Date
    var preferences: UserPreferences?
    var savedVocabulary: [String]?
    var progress: UserProgress?
    
    init(
        id: String,
        email: String,
        displayName: String? = nil,
        photoURL: String? = nil,
        createdAt: Date = Date(),
        preferences: UserPreferences? = nil,
        savedVocabulary: [String]? = nil,
        progress: UserProgress? = nil
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.createdAt = createdAt
        self.preferences = preferences
        self.savedVocabulary = savedVocabulary
        self.progress = progress
    }
}

struct UserPreferences: Codable {
    var currentLevel: String
    var preferredLanguage: String
    var notifications: Bool
    var darkMode: Bool
    var showRomanization: Bool
    
    init(
        currentLevel: String = "Beginner",
        preferredLanguage: String = "en",
        notifications: Bool = true,
        darkMode: Bool = false,
        showRomanization: Bool = true
    ) {
        self.currentLevel = currentLevel
        self.preferredLanguage = preferredLanguage
        self.notifications = notifications
        self.darkMode = darkMode
        self.showRomanization = showRomanization
    }
}

struct UserProgress: Codable {
    var totalPoints: Int
    var streak: Int
    var lastStudyDate: Date?
    var completedLessons: [String]
    var levelProgress: [String: LevelProgress]
    
    init(
        totalPoints: Int = 0,
        streak: Int = 0,
        lastStudyDate: Date? = nil,
        completedLessons: [String] = [],
        levelProgress: [String: LevelProgress] = [:]
    ) {
        self.totalPoints = totalPoints
        self.streak = streak
        self.lastStudyDate = lastStudyDate
        self.completedLessons = completedLessons
        self.levelProgress = levelProgress
    }
}

struct LevelProgress: Codable {
    var vocabularyMastered: Int
    var grammarMastered: Int
    var totalExercises: Int
    
    init(
        vocabularyMastered: Int = 0,
        grammarMastered: Int = 0,
        totalExercises: Int = 0
    ) {
        self.vocabularyMastered = vocabularyMastered
        self.grammarMastered = grammarMastered
        self.totalExercises = totalExercises
    }
}

// MARK: - Lesson Model

struct Lesson: Identifiable, Codable {
    var id: String
    var title: String
    var description: String
    var level: String
    var category: String
    var points: Int
    var isCompleted: Bool
    var duration: Int? // in minutes
    var content: [LessonContent]?
    
    init(
        id: String,
        title: String,
        description: String,
        level: String,
        category: String,
        points: Int,
        isCompleted: Bool = false,
        duration: Int? = nil,
        content: [LessonContent]? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.level = level
        self.category = category
        self.points = points
        self.isCompleted = isCompleted
        self.duration = duration
        self.content = content
    }
}

struct LessonContent: Codable {
    var type: ContentType
    var title: String
    var text: String?
    var audioURL: String?
    var imageURL: String?
    
    enum ContentType: String, Codable {
        case text
        case audio
        case image
        case video
    }
}

// MARK: - Flashcard Model

struct Flashcard: Identifiable, Codable {
    var id: String
    var front: String
    var back: String
    var romanization: String?
    var meaning: String
    var level: String
    var category: String
    var examples: [String]?
    var audioURL: String?
    var isFavorite: Bool
    var lastReviewed: Date?
    var nextReview: Date?
    var reviewCount: Int
    var correctCount: Int
    
    init(
        id: String,
        front: String,
        back: String,
        romanization: String? = nil,
        meaning: String,
        level: String,
        category: String,
        examples: [String]? = nil,
        audioURL: String? = nil,
        isFavorite: Bool = false,
        lastReviewed: Date? = nil,
        nextReview: Date? = nil,
        reviewCount: Int = 0,
        correctCount: Int = 0
    ) {
        self.id = id
        self.front = front
        self.back = back
        self.romanization = romanization
        self.meaning = meaning
        self.level = level
        self.category = category
        self.examples = examples
        self.audioURL = audioURL
        self.isFavorite = isFavorite
        self.lastReviewed = lastReviewed
        self.nextReview = nextReview
        self.reviewCount = reviewCount
        self.correctCount = correctCount
    }
    
    var accuracy: Double {
        guard reviewCount > 0 else { return 0 }
        return Double(correctCount) / Double(reviewCount)
    }
}

// MARK: - Quiz Question Model

struct QuizQuestion: Identifiable, Codable {
    var id: String
    var question: String
    var options: [String]
    var correctAnswer: String
    var explanation: String?
    var category: String
    var level: String
    var audioURL: String?
    
    init(
        id: String,
        question: String,
        options: [String],
        correctAnswer: String,
        explanation: String? = nil,
        category: String,
        level: String,
        audioURL: String? = nil
    ) {
        self.id = id
        self.question = question
        self.options = options
        self.correctAnswer = correctAnswer
        self.explanation = explanation
        self.category = category
        self.level = level
        self.audioURL = audioURL
    }
}

// MARK: - Grammar Point Model

struct GrammarPoint: Identifiable, Codable {
    var id: String
    var title: String
    var pattern: String
    var meaning: String
    var usage: String
    var examples: [GrammarExample]
    var level: String
    var notes: String?
    
    init(
        id: String,
        title: String,
        pattern: String,
        meaning: String,
        usage: String,
        examples: [GrammarExample],
        level: String,
        notes: String? = nil
    ) {
        self.id = id
        self.title = title
        self.pattern = pattern
        self.meaning = meaning
        self.usage = usage
        self.examples = examples
        self.level = level
        self.notes = notes
    }
}

struct GrammarExample: Codable {
    var nepali: String
    var romanization: String
    var english: String
    var audioURL: String?
}

// MARK: - Exercise Model

struct Exercise: Identifiable, Codable {
    var id: String
    var title: String
    var type: ExerciseType
    var category: String
    var level: String
    var questions: [PracticeQuestion]
    var points: Int
    var duration: Int? // in minutes
    
    enum ExerciseType: String, Codable {
        case multipleChoice
        case fillInTheBlank
        case matching
        case listening
        case speaking
        case writing
    }
}

// MARK: - Learning Level

enum LearningLevel: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case elementary = "Elementary"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case proficient = "Proficient"
    
    var title: String {
        switch self {
        case .beginner: return "Beginner Level"
        case .elementary: return "Elementary Level"
        case .intermediate: return "Intermediate Level"
        case .advanced: return "Advanced Level"
        case .proficient: return "Proficient Level"
        }
    }
    
    var description: String {
        switch self {
        case .beginner: return "Basic greetings and simple phrases"
        case .elementary: return "Common everyday conversations"
        case .intermediate: return "Detailed conversations on various topics"
        case .advanced: return "Complex discussions and formal language"
        case .proficient: return "Native-level fluency and cultural nuances"
        }
    }
    
    var vocabularyCount: Int {
        switch self {
        case .beginner: return 500
        case .elementary: return 1000
        case .intermediate: return 2000
        case .advanced: return 4000
        case .proficient: return 8000
        }
    }
    
    var grammarCount: Int {
        switch self {
        case .beginner: return 30
        case .elementary: return 50
        case .intermediate: return 80
        case .advanced: return 120
        case .proficient: return 200
        }
    }
}

// MARK: - Practice Category

enum PracticeCategory: String, Codable, CaseIterable {
    case vocabulary = "Vocabulary"
    case grammar = "Grammar"
    case listening = "Listening"
    case speaking = "Speaking"
    case writing = "Writing"
    case reading = "Reading"
}

// MARK: - Practice Question

struct PracticeQuestion: Identifiable, Codable {
    var id: String
    var question: String
    var options: [String]
    var correctAnswer: String
    var explanation: String?
    var category: PracticeCategory
    var level: String
}

// MARK: - Translation Exception

enum TranslationError: Error {
    case noInternet
    case timeout
    case serverError(Int)
    case connectionError(String)
    case networkError(String)
    case invalidResponse
    case notFound
    
    var localizedDescription: String {
        switch self {
        case .noInternet:
            return "No internet connection. Try offline mode."
        case .timeout:
            return "Request timed out. Please try again."
        case .serverError(let code):
            return "Server error: \(code)"
        case .connectionError(let message):
            return "Connection error: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidResponse:
            return "Invalid response from server"
        case .notFound:
            return "Translation not found"
        }
    }
}

// MARK: - Game Model (JSON-Driven)

struct GameModel: Identifiable, Codable {
    let id: String
    let title: String
    let titleEnglish: String?
    let description: String
    let type: String
    let level: String
    let points: Int
    let timeLimit: Int?
    
    let pairs: [Pair]?
    let questions: [Question]?
    let cards: [Card]?
    
    struct Pair: Codable {
        let nepali: String
        let romanization: String
        let meaning: String
    }
    
    struct Question: Codable {
        let word: String?
        let romanization: String?
        let correctMeaning: String?
        let options: [String]
        let sentence: String?
        let correctAnswer: String?
        let translation: String?
    }
    
    struct Card: Codable {
        let id: String
        let content: String
        let cardType: String
        let pairId: String
    }
}

// MARK: - Reading Passage Model (for JSON data)

struct ReadingPassageModel: Identifiable, Codable {
    let id: String
    let text: String
    let vocabulary: [VocabularyItem]
    let question: String
    let options: [String]
    let correctAnswer: String
    let explanation: String?
    let level: String?
    
    struct VocabularyItem: Hashable, Codable {
        let word: String
        let romanization: String?
        let meaning: String
    }
}

