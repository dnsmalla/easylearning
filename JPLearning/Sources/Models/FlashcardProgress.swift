//
//  FlashcardProgress.swift
//  JLearn
//
//  Flashcard progress tracking for spaced repetition
//  Separates progress data from core flashcard model
//

import Foundation

// MARK: - Flashcard Progress

/// Tracks spaced repetition progress for a flashcard
struct FlashcardProgress: Codable, Equatable {
    // MARK: - Properties
    
    /// Flashcard ID this progress belongs to
    let flashcardId: String
    
    /// Last review date
    var lastReviewed: Date?
    
    /// Next scheduled review date
    var nextReview: Date?
    
    /// Total number of reviews
    var reviewCount: Int
    
    /// Number of correct answers
    var correctCount: Int
    
    /// SM-2 Algorithm: Easiness factor (1.3 - 2.5+)
    var easinessFactor: Double
    
    /// SM-2 Algorithm: Repetition number
    var repetition: Int
    
    /// SM-2 Algorithm: Interval in days
    var interval: Int
    
    /// Is marked as favorite
    var isFavorite: Bool
    
    // MARK: - Initialization
    
    init(
        flashcardId: String,
        lastReviewed: Date? = nil,
        nextReview: Date? = nil,
        reviewCount: Int = 0,
        correctCount: Int = 0,
        easinessFactor: Double = 2.5,
        repetition: Int = 0,
        interval: Int = 1,
        isFavorite: Bool = false
    ) {
        self.flashcardId = flashcardId
        self.lastReviewed = lastReviewed
        self.nextReview = nextReview
        self.reviewCount = reviewCount
        self.correctCount = correctCount
        self.easinessFactor = easinessFactor
        self.repetition = repetition
        self.interval = interval
        self.isFavorite = isFavorite
    }
    
    // MARK: - Computed Properties
    
    /// Accuracy percentage (0.0 - 1.0)
    var accuracy: Double {
        guard reviewCount > 0 else { return 0 }
        return Double(correctCount) / Double(reviewCount)
    }
    
    /// Is due for review
    var isDue: Bool {
        guard let nextReview = nextReview else {
            return true // Never reviewed, always due
        }
        return nextReview <= Date()
    }
    
    /// Days until next review (negative if overdue)
    var daysUntilReview: Int? {
        guard let nextReview = nextReview else { return nil }
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: Date(), to: nextReview).day
        return days
    }
    
    /// Is overdue for review
    var isOverdue: Bool {
        guard let days = daysUntilReview else { return false }
        return days < 0
    }
}

// MARK: - Flashcard + Progress

extension Flashcard {
    /// Create a flashcard with progress merged
    func withProgress(_ progress: FlashcardProgress) -> Flashcard {
        var updated = self
        updated.isFavorite = progress.isFavorite
        updated.lastReviewed = progress.lastReviewed
        updated.nextReview = progress.nextReview
        updated.reviewCount = progress.reviewCount
        updated.correctCount = progress.correctCount
        return updated
    }
    
    /// Extract progress from flashcard
    var progress: FlashcardProgress {
        return FlashcardProgress(
            flashcardId: id,
            lastReviewed: lastReviewed,
            nextReview: nextReview,
            reviewCount: reviewCount,
            correctCount: correctCount,
            isFavorite: isFavorite
        )
    }
}

// MARK: - Progress Storage Service

/// Service for persisting flashcard progress
final class FlashcardProgressStore {
    
    static let shared = FlashcardProgressStore()
    
    private let storageKey = "flashcard_progress"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Public Methods
    
    /// Save progress for a flashcard
    func save(_ progress: FlashcardProgress) throws {
        var allProgress = try loadAll()
        allProgress[progress.flashcardId] = progress
        try saveAll(allProgress)
    }
    
    /// Save multiple progress records
    func save(_ progressList: [FlashcardProgress]) throws {
        var allProgress = try loadAll()
        for progress in progressList {
            allProgress[progress.flashcardId] = progress
        }
        try saveAll(allProgress)
    }
    
    /// Load progress for a flashcard
    func load(flashcardId: String) throws -> FlashcardProgress? {
        let allProgress = try loadAll()
        return allProgress[flashcardId]
    }
    
    /// Load all progress records
    func loadAll() throws -> [String: FlashcardProgress] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return [:]
        }
        
        let progress = try decoder.decode([String: FlashcardProgress].self, from: data)
        return progress
    }
    
    /// Delete progress for a flashcard
    func delete(flashcardId: String) throws {
        var allProgress = try loadAll()
        allProgress.removeValue(forKey: flashcardId)
        try saveAll(allProgress)
    }
    
    /// Clear all progress
    func clearAll() throws {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
    
    // MARK: - Private Methods
    
    private func saveAll(_ progress: [String: FlashcardProgress]) throws {
        let data = try encoder.encode(progress)
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}


