//
//  AnalyticsService.swift
//  NPLearn
//
//  Service for tracking user analytics and activity
//

import Foundation

// MARK: - Analytics Event

enum AnalyticsEvent: String {
    case appLaunch = "app_launch"
    case levelChanged = "level_changed"
    case lessonStarted = "lesson_started"
    case lessonCompleted = "lesson_completed"
    case flashcardReviewed = "flashcard_reviewed"
    case practiceStarted = "practice_started"
    case practiceCompleted = "practice_completed"
    case gameStarted = "game_started"
    case gameCompleted = "game_completed"
    case achievementUnlocked = "achievement_unlocked"
    case streakMilestone = "streak_milestone"
    case error = "error"
}

// MARK: - Analytics Service

final class AnalyticsService {
    
    static let shared = AnalyticsService()
    
    private init() {}
    
    // MARK: - User Properties
    
    func setUserId(_ userId: String?) {
        AppLogger.info("📊 [ANALYTICS] User ID set: \(userId ?? "nil")")
        // Integration point for analytics services (Firebase, Mixpanel, etc.)
    }
    
    func setUserLevel(_ level: LearningLevel) {
        AppLogger.info("📊 [ANALYTICS] User level: \(level.rawValue)")
        // Integration point for analytics services
    }
    
    func setUserProperty(_ key: String, value: String?) {
        AppLogger.info("📊 [ANALYTICS] Property \(key): \(value ?? "nil")")
        // Integration point for analytics services
    }
    
    // MARK: - Event Logging
    
    func logEvent(_ event: AnalyticsEvent, parameters: [String: Any]? = nil) {
        var logMessage = "📊 [ANALYTICS] Event: \(event.rawValue)"
        if let params = parameters {
            logMessage += " - \(params)"
        }
        AppLogger.info(logMessage)
        
        // Integration point for analytics services
        // Firebase.Analytics.logEvent(event.rawValue, parameters: parameters)
    }
    
    // MARK: - Convenience Methods
    
    func logLevelChange(from: LearningLevel?, to: LearningLevel) {
        logEvent(.levelChanged, parameters: [
            "from_level": from?.rawValue ?? "none",
            "to_level": to.rawValue
        ])
    }
    
    func logLessonStart(lessonId: String, category: String, level: String) {
        logEvent(.lessonStarted, parameters: [
            "lesson_id": lessonId,
            "category": category,
            "level": level
        ])
    }
    
    func logLessonComplete(lessonId: String, score: Int, duration: TimeInterval) {
        logEvent(.lessonCompleted, parameters: [
            "lesson_id": lessonId,
            "score": score,
            "duration_seconds": Int(duration)
        ])
    }
    
    func logFlashcardReview(flashcardId: String, correct: Bool, responseTime: TimeInterval) {
        logEvent(.flashcardReviewed, parameters: [
            "flashcard_id": flashcardId,
            "correct": correct,
            "response_time_ms": Int(responseTime * 1000)
        ])
    }
    
    func logPracticeStart(category: String, level: String, questionCount: Int) {
        logEvent(.practiceStarted, parameters: [
            "category": category,
            "level": level,
            "question_count": questionCount
        ])
    }
    
    func logPracticeComplete(category: String, score: Int, total: Int, duration: TimeInterval) {
        logEvent(.practiceCompleted, parameters: [
            "category": category,
            "score": score,
            "total": total,
            "percentage": total > 0 ? (score * 100) / total : 0,
            "duration_seconds": Int(duration)
        ])
    }
    
    func logGameStart(gameId: String, gameType: String, level: String) {
        logEvent(.gameStarted, parameters: [
            "game_id": gameId,
            "game_type": gameType,
            "level": level
        ])
    }
    
    func logGameComplete(gameId: String, score: Int, duration: TimeInterval) {
        logEvent(.gameCompleted, parameters: [
            "game_id": gameId,
            "score": score,
            "duration_seconds": Int(duration)
        ])
    }
    
    func logError(_ error: Error, context: String) {
        logEvent(.error, parameters: [
            "error_message": error.localizedDescription,
            "context": context
        ])
    }
    
    func logStreakMilestone(days: Int) {
        logEvent(.streakMilestone, parameters: [
            "streak_days": days
        ])
    }
}

