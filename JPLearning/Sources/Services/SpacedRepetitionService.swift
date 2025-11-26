//
//  SpacedRepetitionService.swift
//  JLearn
//
//  Service for managing spaced repetition algorithm (SM-2)
//

import Foundation

@MainActor
final class SpacedRepetitionService: ObservableObject {
    
    static let shared = SpacedRepetitionService()
    
    private init() {}
    
    // MARK: - SM-2 Algorithm Implementation
    
    /// Calculate next review date and update flashcard progress using SM-2 algorithm
    /// - Parameters:
    ///   - flashcard: The flashcard to update
    ///   - quality: Quality of recall (0-5, where 5 is perfect recall)
    /// - Returns: Updated flashcard with new intervals
    func reviewFlashcard(_ flashcard: Flashcard, quality: Int) -> Flashcard {
        var updated = flashcard
        
        // SM-2 Algorithm
        let q = Double(max(0, min(5, quality))) // Ensure quality is 0-5
        
        // Update repetition count
        updated.reviewCount += 1
        
        // Calculate new easiness factor
        let oldEF = updated.easinessFactor
        let newEF = max(1.3, oldEF + (0.1 - (5.0 - q) * (0.08 + (5.0 - q) * 0.02)))
        updated.easinessFactor = newEF
        
        // Update interval based on quality
        if q < 3 {
            // Failed recall - restart
            updated.repetition = 0
            updated.interval = 1 // Review tomorrow
        } else {
            // Successful recall
            updated.correctCount += 1
            updated.repetition += 1
            
            if updated.repetition == 1 {
                updated.interval = 1 // First successful review - review tomorrow
            } else if updated.repetition == 2 {
                updated.interval = 6 // Second review - review in 6 days
            } else {
                updated.interval = Int(Double(updated.interval) * newEF)
            }
        }
        
        // Set next review date
        updated.lastReviewed = Date()
        updated.nextReview = Calendar.current.date(byAdding: .day, value: updated.interval, to: Date())
        
        AppLogger.info("📚 Flashcard reviewed: \(flashcard.front) - Quality: \(quality), Next review in \(updated.interval) days")
        
        return updated
    }
    
    /// Get flashcards that are due for review
    func getDueFlashcards(from flashcards: [Flashcard]) -> [Flashcard] {
        let now = Date()
        return flashcards.filter { flashcard in
            guard let nextReview = flashcard.nextReview else {
                // Never reviewed before, consider it due
                return true
            }
            return nextReview <= now
        }.sorted { (a, b) in
            // Sort by priority: overdue first, then by due date
            let aDate = a.nextReview ?? Date.distantPast
            let bDate = b.nextReview ?? Date.distantPast
            return aDate < bDate
        }
    }
    
    /// Get count of flashcards due today
    func getDueCount(from flashcards: [Flashcard]) -> Int {
        let now = Date()
        return flashcards.filter { flashcard in
            guard let nextReview = flashcard.nextReview else {
                return true
            }
            return nextReview <= now
        }.count
    }
    
    /// Get flashcards due in the future (for scheduling)
    func getUpcomingReviews(from flashcards: [Flashcard], days: Int = 7) -> [Flashcard] {
        let now = Date()
        let futureDate = Calendar.current.date(byAdding: .day, value: days, to: now) ?? now
        
        return flashcards.filter { flashcard in
            guard let nextReview = flashcard.nextReview else {
                return false
            }
            return nextReview > now && nextReview <= futureDate
        }.sorted { (a, b) in
            let aDate = a.nextReview ?? Date.distantFuture
            let bDate = b.nextReview ?? Date.distantFuture
            return aDate < bDate
        }
    }
    
    /// Calculate mastery level based on repetition and easiness factor
    func getMasteryLevel(for flashcard: Flashcard) -> MasteryLevel {
        if flashcard.repetition == 0 {
            return .new
        } else if flashcard.repetition < 3 {
            return .learning
        } else if flashcard.repetition < 6 && flashcard.easinessFactor < 2.0 {
            return .familiar
        } else if flashcard.repetition < 10 || flashcard.easinessFactor < 2.3 {
            return .proficient
        } else {
            return .mastered
        }
    }
    
    /// Get statistics for review session
    func getReviewStats(for flashcards: [Flashcard]) -> ReviewStats {
        let total = flashcards.count
        let due = getDueCount(from: flashcards)
        let mastered = flashcards.filter { getMasteryLevel(for: $0) == .mastered }.count
        let learning = flashcards.filter { getMasteryLevel(for: $0) == .learning }.count
        let new = flashcards.filter { getMasteryLevel(for: $0) == .new }.count
        
        return ReviewStats(
            total: total,
            due: due,
            mastered: mastered,
            learning: learning,
            new: new
        )
    }
}

// MARK: - Supporting Models

enum MasteryLevel: String, CaseIterable {
    case new = "New"
    case learning = "Learning"
    case familiar = "Familiar"
    case proficient = "Proficient"
    case mastered = "Mastered"
    
    var color: Color {
        switch self {
        case .new: return .gray
        case .learning: return .blue
        case .familiar: return .orange
        case .proficient: return .purple
        case .mastered: return .green
        }
    }
    
    var icon: String {
        switch self {
        case .new: return "star"
        case .learning: return "star.leadinghalf.filled"
        case .familiar: return "star.fill"
        case .proficient: return "star.circle.fill"
        case .mastered: return "crown.fill"
        }
    }
}

struct ReviewStats {
    let total: Int
    let due: Int
    let mastered: Int
    let learning: Int
    let new: Int
    
    var duePercentage: Double {
        guard total > 0 else { return 0 }
        return Double(due) / Double(total)
    }
    
    var masteryPercentage: Double {
        guard total > 0 else { return 0 }
        return Double(mastered) / Double(total)
    }
}

// MARK: - Flashcard Extensions for SM-2

extension Flashcard {
    var easinessFactor: Double {
        get {
            // Stored in UserDefaults or could be added to model
            return UserDefaults.standard.double(forKey: "ef_\(id)").nonZero(default: 2.5)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "ef_\(id)")
        }
    }
    
    var repetition: Int {
        get {
            return UserDefaults.standard.integer(forKey: "rep_\(id)")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "rep_\(id)")
        }
    }
    
    var interval: Int {
        get {
            let stored = UserDefaults.standard.integer(forKey: "interval_\(id)")
            return stored == 0 ? 1 : stored
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "interval_\(id)")
        }
    }
}

extension Double {
    func nonZero(default defaultValue: Double) -> Double {
        return self == 0 ? defaultValue : self
    }
}

import SwiftUI

