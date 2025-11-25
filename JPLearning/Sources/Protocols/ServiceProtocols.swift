//
//  ServiceProtocols.swift
//  JLearn
//
//  Protocol definitions for all services
//  Enables dependency injection, testing, and loose coupling
//

import Foundation
import Combine
import AVFoundation

// MARK: - Data Service Protocol

/// Protocol for data services that load and manage learning content
@MainActor
protocol DataServiceProtocol: AnyObject {
    /// Current learning level
    var currentLevel: LearningLevel { get set }
    
    /// Loading state
    var isLoading: Bool { get }
    
    /// Initialize the service
    func initialize() async
    
    /// Load all learning data for current level
    func loadLearningData() async
    
    /// Change learning level
    func setLevel(_ level: LearningLevel) async
    
    /// Get flashcards for current level
    func getFlashcards() -> [Flashcard]
    
    /// Get grammar points for current level
    func getGrammarPoints() -> [GrammarPoint]
    
    /// Get kanji for current level
    func getKanji() -> [Kanji]
    
    /// Get practice questions for category
    func getPracticeQuestions(category: PracticeCategory) -> [PracticeQuestion]
}

// MARK: - Data Source Protocol

/// Protocol for different data sources (bundle, remote, cache)
protocol DataSourceProtocol {
    /// Load learning data for a specific level
    func loadData(for level: LearningLevel) async throws -> LearningData
    
    /// Check if data is available for level
    func hasData(for level: LearningLevel) async -> Bool
    
    /// Get data source priority (higher = preferred)
    var priority: Int { get }
    
    /// Data source name for logging
    var sourceName: String { get }
}

/// Container for all learning data
struct LearningData {
    let flashcards: [Flashcard]
    let grammar: [GrammarPoint]
    let kanji: [Kanji]
    let practice: [PracticeQuestion]
    let games: [GameModel]
    let level: LearningLevel
}

// MARK: - Parsing Service Protocol

/// Protocol for JSON parsing services
protocol ParsingServiceProtocol {
    /// Parse complete learning data from JSON
    func parseAllData(data: Data) throws -> (flashcards: [Flashcard], grammar: [GrammarPoint], practice: [PracticeQuestion], kanji: [Kanji], games: [GameModel])
    
    /// Parse flashcards from JSON
    func parseFlashcards(data: Data) throws -> [Flashcard]
    
    /// Parse grammar points from JSON
    func parseGrammar(data: Data) throws -> [GrammarPoint]
    
    /// Parse kanji from JSON
    func parseKanji(data: Data) throws -> [Kanji]
    
    /// Parse practice questions from JSON
    func parsePracticeQuestions(data: Data) throws -> [PracticeQuestion]
    
    /// Parse games from JSON
    func parseGames(data: Data) throws -> [GameModel]
}

// MARK: - Storage Service Protocol

/// Protocol for local storage services
protocol StorageServiceProtocol {
    /// Save codable data
    func save<T: Codable>(_ data: T, forKey key: String) throws
    
    /// Load codable data
    func load<T: Codable>(forKey key: String, as type: T.Type) throws -> T?
    
    /// Remove data
    func remove(forKey key: String) throws
    
    /// Clear all stored data
    func clearAll() throws
    
    /// Check if data exists
    func exists(forKey key: String) -> Bool
}

// MARK: - Audio Service Protocol

/// Protocol for audio playback and speech recognition
@MainActor
protocol AudioServiceProtocol: ObservableObject {
    /// Is currently playing audio
    var isPlaying: Bool { get }
    
    /// Is currently recording
    var isRecording: Bool { get }
    
    /// Recognized text from speech
    var recognizedText: String { get }
    
    /// Speak text using TTS
    func speak(_ text: String, language: String, rate: Float) async throws
    
    /// Stop speaking
    func stopSpeaking()
    
    /// Play audio from URL
    func playAudio(from url: URL) async throws
    
    /// Play audio from URL string
    func playAudio(from urlString: String) async throws
    
    /// Stop audio playback
    func stopAudio()
    
    /// Start speech recognition
    func startRecording() async throws
    
    /// Stop speech recognition
    func stopRecording()
    
    /// Request speech recognition permission
    func requestSpeechRecognitionPermission() async -> Bool
}

// MARK: - Analytics Service Protocol

/// Protocol for analytics and tracking
protocol AnalyticsServiceProtocol {
    /// Log an event
    func logEvent(_ event: AnalyticsEvent) async
    
    /// Set user property
    func setUserProperty(key: String, value: String) async
    
    /// Track screen view
    func trackScreen(_ screenName: String, screenClass: String) async
    
    /// Log error
    func logError(_ error: Error, additionalInfo: [String: Any]?) async
    
    /// Set user level
    func setUserLevel(_ level: LearningLevel)
}

// MARK: - Achievement Service Protocol

/// Protocol for achievements and gamification
protocol AchievementServiceProtocol: ObservableObject {
    /// Current streak
    var currentStreak: Int { get }
    
    /// Longest streak
    var longestStreak: Int { get }
    
    /// Last study date
    var lastStudyDate: Date? { get }
    
    /// Unlocked achievement IDs
    var unlockedAchievements: Set<String> { get }
    
    /// Total study minutes
    var totalStudyMinutes: Int { get }
    
    /// Update daily streak
    func updateStreak()
    
    /// Add study time
    func addStudyTime(minutes: Int)
    
    /// Unlock achievement
    func unlockAchievement(_ achievementId: String)
    
    /// Get all achievements with unlock status
    func getAvailableAchievements() -> [Achievement]
    
    /// Get weekly activity
    func getWeeklyActivity() -> [Int]
}

// MARK: - Spaced Repetition Service Protocol

/// Protocol for spaced repetition algorithm
@MainActor
protocol SpacedRepetitionServiceProtocol {
    /// Review flashcard and calculate next review
    func reviewFlashcard(_ flashcard: Flashcard, quality: Int) -> Flashcard
    
    /// Get flashcards due for review
    func getDueFlashcards(from flashcards: [Flashcard]) -> [Flashcard]
    
    /// Get count of due flashcards
    func getDueCount(from flashcards: [Flashcard]) -> Int
    
    /// Get upcoming reviews
    func getUpcomingReviews(from flashcards: [Flashcard], days: Int) -> [Flashcard]
    
    /// Get mastery level for flashcard
    func getMasteryLevel(for flashcard: Flashcard) -> MasteryLevel
    
    /// Get review statistics
    func getReviewStats(for flashcards: [Flashcard]) -> ReviewStats
}

// MARK: - Auth Service Protocol

/// Protocol for authentication services
@MainActor
protocol AuthServiceProtocol: ObservableObject {
    /// Current user
    var currentUser: UserModel? { get }
    
    /// Is authenticated
    var isAuthenticated: Bool { get }
    
    /// Is loading
    var isLoading: Bool { get }
    
    /// Error message
    var error: String? { get }
    
    /// Initialize and check authentication
    func initialize() async
    
    /// Check authentication state
    func checkAuthentication() async
    
    /// Sign up with email
    func signUpWithEmail(email: String, password: String) async throws
    
    /// Sign in with email
    func signInWithEmail(email: String, password: String) async throws
    
    /// Continue as guest
    func continueAsGuest() async throws
    
    /// Update profile
    func updateProfile(displayName: String?, photoURL: String?, preferences: UserPreferences?, progress: UserProgress?, savedKanji: [String]?, savedVocabulary: [String]?) async throws
    
    /// Reset password
    func resetPassword(email: String) async throws
    
    /// Sign out
    func signOut() throws
    
    /// Delete account
    func deleteAccount() async throws
}

// MARK: - Network Monitor Protocol

/// Protocol for network monitoring
protocol NetworkMonitorProtocol: ObservableObject {
    /// Is connected to internet
    var isConnected: Bool { get }
    
    /// Connection type
    var connectionType: NetworkConnectionType { get }
    
    /// Check internet connection
    static func hasInternetConnection() async -> Bool
}

enum NetworkConnectionType {
    case wifi
    case cellular
    case ethernet
    case unknown
}

// MARK: - Toast Manager Protocol

/// Protocol for toast notifications
@MainActor
protocol ToastManagerProtocol: ObservableObject {
    /// Current toast
    var currentToast: Toast? { get }
    
    /// Show toast
    func show(_ toast: Toast)
    
    /// Show success toast
    func showSuccess(_ message: String, duration: TimeInterval)
    
    /// Show error toast
    func showError(_ message: String, duration: TimeInterval)
    
    /// Show warning toast
    func showWarning(_ message: String, duration: TimeInterval)
    
    /// Show info toast
    func showInfo(_ message: String, duration: TimeInterval)
    
    /// Dismiss current toast
    func dismiss()
}




