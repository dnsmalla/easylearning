//
//  Repository.swift
//  JLearn
//
//  Repository protocols for data abstraction and testability
//  Implements the Repository Pattern for clean architecture
//

import Foundation
import Combine

// MARK: - Base Repository Protocol

/// Base protocol for all repositories
/// Provides standard CRUD operations and error handling
protocol Repository {
    associatedtype Entity: Identifiable & Codable
    
    /// Fetch all entities
    func fetchAll() async throws -> [Entity]
    
    /// Fetch entity by ID
    func fetch(byId id: String) async throws -> Entity?
    
    /// Create new entity
    func create(_ entity: Entity) async throws -> Entity
    
    /// Update existing entity
    func update(_ entity: Entity) async throws -> Entity
    
    /// Delete entity
    func delete(_ entity: Entity) async throws
    
    /// Delete entity by ID
    func delete(byId id: String) async throws
}

// MARK: - User Repository Protocol

/// Protocol for user data operations
@MainActor
protocol UserRepositoryProtocol: AnyObject {
    /// Current user observable
    var currentUserPublisher: AnyPublisher<UserModel?, Never> { get }
    
    /// Fetch current user
    func fetchCurrentUser() async throws -> UserModel?
    
    /// Update user profile
    func updateUser(_ user: UserModel) async throws
    
    /// Delete user account
    func deleteUser(userId: String) async throws
    
    /// Save user locally
    func saveUserLocally(_ user: UserModel) throws
    
    /// Load user from local storage
    func loadUserLocally(userId: String) throws -> UserModel?
}

// MARK: - Learning Data Repository Protocol

/// Protocol for learning content operations (flashcards, grammar, lessons)
protocol LearningDataRepositoryProtocol: AnyObject {
    /// Fetch flashcards for specific level
    func fetchFlashcards(level: LearningLevel) async throws -> [Flashcard]
    
    /// Fetch grammar points for specific level
    func fetchGrammarPoints(level: LearningLevel) async throws -> [GrammarPoint]
    
    /// Fetch lessons for specific level
    func fetchLessons(level: LearningLevel) async throws -> [Lesson]
    
    /// Fetch exercises for specific level and category
    func fetchExercises(level: LearningLevel, category: PracticeCategory?) async throws -> [Exercise]
    
    /// Fetch practice questions
    func fetchPracticeQuestions(level: LearningLevel, category: PracticeCategory) async throws -> [PracticeQuestion]
    
    /// Update flashcard (for spaced repetition data)
    func updateFlashcard(_ flashcard: Flashcard) async throws
    
    /// Cache data locally
    func cacheData<T: Codable>(key: String, data: T) throws
    
    /// Load cached data
    func loadCachedData<T: Codable>(key: String, type: T.Type) throws -> T?
    
    /// Clear cache
    func clearCache() throws
}

// MARK: - Progress Repository Protocol

/// Protocol for user progress tracking
protocol ProgressRepositoryProtocol: AnyObject {
    /// Fetch user progress
    func fetchProgress(userId: String) async throws -> UserProgress
    
    /// Update user progress
    func updateProgress(_ progress: UserProgress, userId: String) async throws
    
    /// Add completed lesson
    func addCompletedLesson(lessonId: String, userId: String) async throws
    
    /// Update streak
    func updateStreak(userId: String) async throws -> Int
    
    /// Add points
    func addPoints(_ points: Int, userId: String) async throws
    
    /// Get level statistics
    func getLevelStatistics(userId: String, level: LearningLevel) async throws -> LevelProgress
}

// MARK: - Authentication Repository Protocol

/// Protocol for authentication operations
protocol AuthRepositoryProtocol: AnyObject {
    /// Authentication state publisher
    var authStatePublisher: AnyPublisher<Bool, Never> { get }
    
    /// Sign up with email and password
    func signUp(email: String, password: String) async throws -> UserModel
    
    /// Sign in with email and password
    func signIn(email: String, password: String) async throws -> UserModel
    
    /// Sign in with Apple
    func signInWithApple(idToken: String, nonce: String) async throws -> UserModel
    
    /// Sign out
    func signOut() async throws
    
    /// Reset password
    func resetPassword(email: String) async throws
    
    /// Delete account
    func deleteAccount() async throws
    
    /// Check if user is authenticated
    func isAuthenticated() -> Bool
    
    /// Get current user ID
    func getCurrentUserId() -> String?
}

// MARK: - Cache Repository Protocol

/// Protocol for caching strategies
protocol CacheRepositoryProtocol: AnyObject {
    /// Save data to cache
    func save<T: Codable>(_ data: T, forKey key: String) throws
    
    /// Load data from cache
    func load<T: Codable>(forKey key: String, as type: T.Type) throws -> T?
    
    /// Remove data from cache
    func remove(forKey key: String) throws
    
    /// Clear all cache
    func clearAll() throws
    
    /// Check if cache exists
    func exists(forKey key: String) -> Bool
    
    /// Get cache age
    func getCacheAge(forKey key: String) -> TimeInterval?
}

// MARK: - Analytics Repository Protocol

/// Protocol for analytics and tracking
protocol AnalyticsRepositoryProtocol: AnyObject {
    /// Log event
    func logEvent(_ event: AnalyticsEvent) async
    
    /// Set user property
    func setUserProperty(key: String, value: String) async
    
    /// Log screen view
    func logScreenView(screenName: String, screenClass: String) async
    
    /// Log error
    func logError(_ error: Error, additionalInfo: [String: Any]?) async
}

// MARK: - Analytics Event

/// Analytics event structure
struct AnalyticsEvent {
    let name: String
    let parameters: [String: Any]?
    let timestamp: Date
    
    init(name: String, parameters: [String: Any]? = nil) {
        self.name = name
        self.parameters = parameters
        self.timestamp = Date()
    }
}

// MARK: - Repository Error

/// Errors that can occur in repositories
enum RepositoryError: LocalizedError {
    case notFound
    case invalidData
    case networkError(Error)
    case cacheError(Error)
    case encodingError(Error)
    case decodingError(Error)
    case unauthorized
    case forbidden
    case serverError(statusCode: Int)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Resource not found"
        case .invalidData:
            return "Invalid data format"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .cacheError(let error):
            return "Cache error: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Encoding error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized access"
        case .forbidden:
            return "Access forbidden"
        case .serverError(let code):
            return "Server error (Status: \(code))"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .notFound:
            return "The requested item could not be found. Please try again."
        case .invalidData:
            return "The data format is invalid. Please contact support."
        case .networkError:
            return "Please check your internet connection and try again."
        case .cacheError:
            return "Clear app cache and try again."
        case .unauthorized:
            return "Please sign in again."
        case .forbidden:
            return "You don't have permission to perform this action."
        case .serverError:
            return "Our servers are experiencing issues. Please try again later."
        default:
            return "Please try again. If the problem persists, contact support."
        }
    }
}

