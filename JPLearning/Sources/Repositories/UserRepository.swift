//
//  UserRepository.swift
//  JLearn
//
//  User data repository implementation with local storage
//  Implements clean architecture repository pattern
//

import Foundation
import Combine

// MARK: - User Repository

/// Concrete implementation of UserRepositoryProtocol
/// Handles user data persistence and retrieval
@MainActor
final class UserRepository: UserRepositoryProtocol {
    
    // MARK: - Properties
    
    private let userDefaults: UserDefaults
    private let cacheRepository: CacheRepositoryProtocol
    private let currentUserSubject = CurrentValueSubject<UserModel?, Never>(nil)
    
    var currentUserPublisher: AnyPublisher<UserModel?, Never> {
        currentUserSubject.eraseToAnyPublisher()
    }
    
    private let userCachePrefix = "user_"
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder
    
    // MARK: - Initialization
    
    init(
        userDefaults: UserDefaults = .standard,
        cacheRepository: CacheRepositoryProtocol = CacheRepository.shared
    ) {
        self.userDefaults = userDefaults
        self.cacheRepository = cacheRepository
        
        // Configure JSON coders with date strategy
        self.jsonEncoder = JSONEncoder()
        self.jsonEncoder.dateEncodingStrategy = .iso8601
        
        self.jsonDecoder = JSONDecoder()
        self.jsonDecoder.dateDecodingStrategy = .iso8601
        
        AppLogger.info("UserRepository initialized")
    }
    
    // MARK: - Fetch Operations
    
    func fetchCurrentUser() async throws -> UserModel? {
        return currentUserSubject.value
    }
    
    // MARK: - Update Operations
    
    func updateUser(_ user: UserModel) async throws {
        AppLogger.debug("Updating user: \(user.id)")
        
        // Validate user data
        guard !user.email.isEmpty else {
            throw RepositoryError.invalidData
        }
        
        // Save to local storage
        try saveUserLocally(user)
        
        // Update publisher
        currentUserSubject.send(user)
        
        AppLogger.info("User updated successfully")
    }
    
    // MARK: - Delete Operations
    
    func deleteUser(userId: String) async throws {
        AppLogger.debug("Deleting user: \(userId)")
        
        // Remove from UserDefaults
        userDefaults.removeObject(forKey: "\(userCachePrefix)\(userId)")
        
        // Remove from cache
        try? cacheRepository.remove(forKey: "\(userCachePrefix)\(userId)")
        
        // Clear current user if it's the deleted one
        if currentUserSubject.value?.id == userId {
            currentUserSubject.send(nil)
        }
        
        AppLogger.info("User deleted successfully")
    }
    
    // MARK: - Local Storage Operations
    
    func saveUserLocally(_ user: UserModel) throws {
        do {
            let data = try jsonEncoder.encode(user)
            let key = "\(userCachePrefix)\(user.id)"
            
            // Save to UserDefaults
            userDefaults.set(data, forKey: key)
            
            // Also save to cache repository for consistency
            try cacheRepository.save(user, forKey: key)
            
            AppLogger.debug("User saved locally: \(user.id)")
        } catch {
            AppLogger.error("Failed to save user locally: \(error)")
            throw RepositoryError.encodingError(error)
        }
    }
    
    func loadUserLocally(userId: String) throws -> UserModel? {
        let key = "\(userCachePrefix)\(userId)"
        
        // Try cache repository first
        if let cachedUser: UserModel = try? cacheRepository.load(forKey: key, as: UserModel.self) {
            currentUserSubject.send(cachedUser)
            return cachedUser
        }
        
        // Fallback to UserDefaults
        guard let data = userDefaults.data(forKey: key) else {
            AppLogger.debug("No local user found for: \(userId)")
            return nil
        }
        
        do {
            let user = try jsonDecoder.decode(UserModel.self, from: data)
            currentUserSubject.send(user)
            AppLogger.debug("User loaded from local storage: \(userId)")
            return user
        } catch {
            AppLogger.error("Failed to decode user: \(error)")
            throw RepositoryError.decodingError(error)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Set the current user (used by AuthService)
    func setCurrentUser(_ user: UserModel?) {
        currentUserSubject.send(user)
    }
    
    /// Clear all user data (for logout)
    func clearAllUserData() throws {
        // Get all UserDefaults keys and remove user-related ones
        let keys = userDefaults.dictionaryRepresentation().keys
            let userKeys = keys.filter { $0.hasPrefix(userCachePrefix) }
            userKeys.forEach { userDefaults.removeObject(forKey: $0) }
        
        // Clear current user
        currentUserSubject.send(nil)
        
        AppLogger.info("All user data cleared")
    }
}

// MARK: - User Repository Error Extension

extension UserRepository {
    
    /// Validate user email format
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    /// Validate user model
    private func validateUser(_ user: UserModel) throws {
        guard !user.id.isEmpty else {
            throw RepositoryError.invalidData
        }
        
        guard !user.email.isEmpty, isValidEmail(user.email) else {
            throw RepositoryError.invalidData
        }
    }
}

