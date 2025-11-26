//
//  AnalyticsService.swift
//  JLearn
//
//  Professional analytics tracking system
//  Tracks user behavior, performance metrics, and business KPIs
//

import Foundation
import os.log
import SwiftUI

// MARK: - Analytics Service

/// Central analytics service for tracking user behavior and app metrics
@MainActor
final class AnalyticsService: ObservableObject, @unchecked Sendable {
    
    // MARK: - Singleton
    
    static let shared = AnalyticsService()
    
    // MARK: - Properties
    
    private let repository: AnalyticsRepositoryProtocol
    @Published private(set) var isEnabled: Bool = true
    
    // Session tracking
    private var sessionStartTime: Date?
    private var sessionId: String?
    
    // MARK: - Initialization
    
    private init(repository: AnalyticsRepositoryProtocol = LocalAnalyticsRepository()) {
        self.repository = repository
        self.isEnabled = UserDefaults.standard.bool(forKey: "analytics_enabled")
        
        startSession()
        AppLogger.info("AnalyticsService initialized")
    }
    
    // MARK: - Session Management
    
    /// Start a new analytics session
    func startSession() {
        sessionStartTime = Date()
        sessionId = UUID().uuidString
        
        logEvent(.sessionStart)
        AppLogger.debug("Analytics session started: \(sessionId ?? "unknown")")
    }
    
    /// End the current analytics session
    func endSession() {
        guard let startTime = sessionStartTime else { return }
        
        let duration = Date().timeIntervalSince(startTime)
        logEvent(.sessionEnd, parameters: [
            "duration": duration,
            "session_id": sessionId ?? ""
        ])
        
        sessionStartTime = nil
        sessionId = nil
        
        AppLogger.debug("Analytics session ended (duration: \(duration)s)")
    }
    
    // MARK: - Event Tracking
    
    /// Log an analytics event
    func logEvent(_ event: AnalyticsEventType, parameters: [String: Any]? = nil) {
        guard isEnabled else { return }
        
        var params = parameters ?? [:]
        params["session_id"] = sessionId ?? ""
        params["timestamp"] = ISO8601DateFormatter().string(from: Date())
        
        let analyticsEvent = AnalyticsEvent(name: event.rawValue, parameters: params)
        
        // Execute on the main actor to avoid crossing actors with non-Sendable repository types
        Task { @MainActor in
            await repository.logEvent(analyticsEvent)
        }
        
        AppLogger.debug("Analytics: \(event.rawValue)")
    }
    
    // MARK: - Screen Tracking
    
    /// Track screen view
    func trackScreen(_ screenName: String, screenClass: String? = nil) {
        guard isEnabled else { return }
        
        let className = screenClass ?? screenName
        
        Task { @MainActor in
            await repository.logScreenView(screenName: screenName, screenClass: className)
        }
        
        logEvent(.screenView, parameters: [
            "screen_name": screenName,
            "screen_class": className
        ])
    }
    
    // MARK: - User Properties
    
    /// Set user property for segmentation
    func setUserProperty(key: String, value: String) {
        guard isEnabled else { return }
        
        Task { @MainActor in
            await repository.setUserProperty(key: key, value: value)
        }
    }
    
    /// Set user ID
    func setUserId(_ userId: String?) {
        guard isEnabled else { return }
        
        if let userId = userId {
            setUserProperty(key: "user_id", value: userId)
        }
    }
    
    /// Set user level
    func setUserLevel(_ level: LearningLevel) {
        setUserProperty(key: "current_level", value: level.rawValue)
    }
    
    // MARK: - Learning Analytics
    
    /// Track lesson start
    func trackLessonStart(lessonId: String, category: String, level: String) {
        logEvent(.lessonStart, parameters: [
            "lesson_id": lessonId,
            "category": category,
            "level": level
        ])
    }
    
    /// Track lesson completion
    func trackLessonComplete(lessonId: String, category: String, level: String, duration: TimeInterval, score: Double) {
        logEvent(.lessonComplete, parameters: [
            "lesson_id": lessonId,
            "category": category,
            "level": level,
            "duration": duration,
            "score": score
        ])
    }
    
    /// Track practice session
    func trackPracticeSession(category: PracticeCategory, questionsAnswered: Int, correctAnswers: Int, duration: TimeInterval) {
        let accuracy = Double(correctAnswers) / Double(questionsAnswered) * 100
        
        logEvent(.practiceSession, parameters: [
            "category": category.rawValue,
            "questions_answered": questionsAnswered,
            "correct_answers": correctAnswers,
            "accuracy": accuracy,
            "duration": duration
        ])
    }
    
    /// Track flashcard review
    func trackFlashcardReview(flashcardId: String, wasCorrect: Bool, timeSpent: TimeInterval) {
        logEvent(.flashcardReview, parameters: [
            "flashcard_id": flashcardId,
            "was_correct": wasCorrect,
            "time_spent": timeSpent
        ])
    }
    
    /// Track game played
    func trackGamePlayed(gameName: String, score: Int, duration: TimeInterval) {
        logEvent(.gamePlayed, parameters: [
            "game_name": gameName,
            "score": score,
            "duration": duration
        ])
    }
    
    // MARK: - User Engagement
    
    /// Track daily streak
    func trackStreakAchievement(streakDays: Int) {
        logEvent(.streakAchievement, parameters: [
            "streak_days": streakDays
        ])
    }
    
    /// Track level up
    func trackLevelUp(fromLevel: String, toLevel: String) {
        logEvent(.levelUp, parameters: [
            "from_level": fromLevel,
            "to_level": toLevel
        ])
    }
    
    /// Track achievement unlocked
    func trackAchievement(achievementId: String, achievementName: String) {
        logEvent(.achievementUnlocked, parameters: [
            "achievement_id": achievementId,
            "achievement_name": achievementName
        ])
    }
    
    // MARK: - Error Tracking
    
    /// Track error occurrence
    func trackError(_ error: Error, context: String? = nil, additionalInfo: [String: Any]? = nil) {
        var params = additionalInfo ?? [:]
        params["error_description"] = error.localizedDescription
        params["error_type"] = String(describing: type(of: error))
        
        if let context = context {
            params["context"] = context
        }
        
        logEvent(.error, parameters: params)
        
        Task { @MainActor in
            await repository.logError(error, additionalInfo: params)
        }
    }
    
    // MARK: - Performance Monitoring
    
    /// Measure and track performance of an operation
    func measurePerformance<T>(
        operationName: String,
        category: String? = nil,
        operation: () async throws -> T
    ) async rethrows -> T {
        let startTime = Date()
        
        let result = try await operation()
        
        let duration = Date().timeIntervalSince(startTime)
        
        logEvent(.performanceMetric, parameters: [
            "operation": operationName,
            "category": category ?? "general",
            "duration": duration
        ])
        
        // Log warning if operation is slow
        if duration > 1.0 {
            AppLogger.debug("⚠️ Slow operation: \(operationName) took \(duration)s")
        }
        
        return result
    }
    
    // MARK: - Settings
    
    /// Enable or disable analytics
    func setAnalyticsEnabled(_ enabled: Bool) {
        isEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "analytics_enabled")
        
        logEvent(enabled ? .analyticsEnabled : .analyticsDisabled)
        AppLogger.info("Analytics \(enabled ? "enabled" : "disabled")")
    }
}

// MARK: - Analytics Event Types

/// Predefined analytics event types
enum AnalyticsEventType: String {
    // Session events
    case sessionStart = "session_start"
    case sessionEnd = "session_end"
    
    // Screen events
    case screenView = "screen_view"
    
    // Authentication events
    case signUp = "sign_up"
    case signIn = "sign_in"
    case signOut = "sign_out"
    case passwordReset = "password_reset"
    
    // Learning events
    case lessonStart = "lesson_start"
    case lessonComplete = "lesson_complete"
    case practiceSession = "practice_session"
    case flashcardReview = "flashcard_review"
    case gamePlayed = "game_played"
    
    // Engagement events
    case streakAchievement = "streak_achievement"
    case levelUp = "level_up"
    case achievementUnlocked = "achievement_unlocked"
    case favoriteAdded = "favorite_added"
    case favoriteRemoved = "favorite_removed"
    
    // Search events
    case search = "search"
    case searchResult = "search_result"
    case dictionaryLookup = "dictionary_lookup"
    
    // Social events
    case share = "share"
    case rateApp = "rate_app"
    case feedback = "feedback"
    
    // Settings events
    case levelChanged = "level_changed"
    case themeChanged = "theme_changed"
    case languageChanged = "language_changed"
    case notificationToggled = "notification_toggled"
    case analyticsEnabled = "analytics_enabled"
    case analyticsDisabled = "analytics_disabled"
    
    // Error events
    case error = "error"
    case networkError = "network_error"
    case authError = "auth_error"
    
    // Performance events
    case performanceMetric = "performance_metric"
    case appLaunch = "app_launch"
    case appBackground = "app_background"
    case appForeground = "app_foreground"
}

// MARK: - Local Analytics Repository

/// Local implementation of analytics repository (can be replaced with Firebase, Mixpanel, etc.)
final class LocalAnalyticsRepository: AnalyticsRepositoryProtocol, @unchecked Sendable {
    
    private let eventQueue: DispatchQueue
    private var events: [AnalyticsEvent] = []
    private let maxStoredEvents = 1000
    
    init() {
        self.eventQueue = DispatchQueue(label: "com.jlearn.analytics", qos: .utility)
    }
    
    func logEvent(_ event: AnalyticsEvent) async {
        eventQueue.async { [weak self] in
            self?.events.append(event)
            
            // Trim events if needed
            if let self = self, self.events.count > self.maxStoredEvents {
                self.events.removeFirst(self.events.count - self.maxStoredEvents)
            }
            
            #if DEBUG
            self?.printEvent(event)
            #endif
        }
    }
    
    func setUserProperty(key: String, value: String) async {
        AppLogger.debug("User property: \(key) = \(value)")
    }
    
    func logScreenView(screenName: String, screenClass: String) async {
        AppLogger.debug("Screen view: \(screenName)")
    }
    
    func logError(_ error: Error, additionalInfo: [String: Any]?) async {
        var message = "Error: \(error.localizedDescription)"
        if let info = additionalInfo {
            message += " | Info: \(info)"
        }
        AppLogger.error(message)
    }
    
    private func printEvent(_ event: AnalyticsEvent) {
        var message = "📊 Analytics: \(event.name)"
        if let params = event.parameters {
            message += " | \(params)"
        }
        print(message)
    }
    
    // Method to export analytics data for debugging
    func exportEvents() -> [AnalyticsEvent] {
        return events
    }
    
    func clearEvents() {
        eventQueue.async { [weak self] in
            self?.events.removeAll()
        }
    }
}

// MARK: - View Extension for Screen Tracking

extension View {
    /// Automatically track screen views
    func trackScreen(_ screenName: String) -> some View {
        self.onAppear {
            AnalyticsService.shared.trackScreen(screenName)
        }
    }
}

