# Authentication & User Profile System for iOS Apps

**Author:** DNS System  
**Date:** November 20, 2025  
**Version:** 1.0  
**Source:** JLearn App Implementation (Lessons Learned)

---

## 📖 Table of Contents

1. [Quick Start (30 minutes)](#-quick-start)
2. [Overview](#-overview)
3. [Architecture](#️-architecture-overview)
4. [Part 1: Data Models](#-part-1-data-models)
5. [Part 2: Authentication Service](#-part-2-authentication-service)
6. [Part 3: Session Management](#-part-3-session-management)
7. [Part 4: Profile Management](#-part-4-profile-management)
8. [Part 5: UI Implementation](#-part-5-ui-implementation)
9. [Part 6: Security Best Practices](#-part-6-security-best-practices)
10. [Part 7: Error Handling](#-part-7-error-handling)
11. [Common Pitfalls & Solutions](#-common-pitfalls--solutions)
12. [Testing Checklist](#-testing-checklist)
13. [Migration Guide](#-migration-guide)

---

## 🚀 Quick Start

**New to authentication? Start here! Avoid common mistakes that require app rewrites.**

### Critical Success Factors

⚠️ **BEFORE YOU START - Read This First!**

Common mistakes that force app rewrites:
1. ❌ Hardcoding user data in UserDefaults
2. ❌ No session expiration handling
3. ❌ Mixing authentication logic across views
4. ❌ No offline support for user data
5. ❌ Profile changes not persisting correctly

✅ **This guide prevents all of these!**

### 30-Minute Implementation Path

```swift
// Step 1: Add Models (5 min)
// Copy User.swift, UserPreferences.swift

// Step 2: Add AuthService (10 min)
// Copy AuthService.swift - handles all auth logic

// Step 3: Add SessionManager (5 min)
// Copy SessionManager.swift - manages logged-in state

// Step 4: Add Views (10 min)
// Copy SignInView.swift, ProfileView.swift
```

### Essential Architecture Principles

```
┌─────────────────────────────────────────────────────────┐
│  NEVER mix authentication logic directly in views!      │
│  Always use a centralized AuthService.                  │
└─────────────────────────────────────────────────────────┘

✅ DO:    View → AuthService → Firebase/Backend
❌ DON'T: View → Firebase directly
```

### Quick Commands

```swift
// Sign in
try await AuthService.shared.signIn(email: email, password: password)

// Sign out
try await AuthService.shared.signOut()

// Update profile
try await AuthService.shared.updateProfile(displayName: name)

// Check if user is logged in
if AuthService.shared.isAuthenticated { }
```

---

## 📋 Overview

Complete guide for implementing a robust, production-ready authentication and user profile system that **won't require a rewrite**. Based on real-world lessons learned from rebuilding apps due to authentication mistakes.

### What This Covers

1. ✅ **Authentication Service** - Centralized auth logic
2. ✅ **User Data Models** - Proper structure for user info
3. ✅ **Session Management** - Token handling, expiration
4. ✅ **Profile Management** - User settings, preferences, progress
5. ✅ **UI Components** - Sign in, sign up, profile views
6. ✅ **Security** - Token storage, biometric auth, encryption
7. ✅ **Offline Support** - Local caching, sync strategies
8. ✅ **Error Handling** - Network errors, validation, recovery

### Why This Matters

- **Prevents Rewrites:** Get it right the first time
- **Saves Time:** Avoid 2-3 weeks of rework
- **Production-Ready:** Handles edge cases
- **Scalable:** Works for 100 to 1M users
- **Secure:** Follows iOS security best practices

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                  Authentication Architecture                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐    │
│  │  SwiftUI Views (UI Layer)                              │    │
│  │  • SignInView                                          │    │
│  │  • SignUpView                                          │    │
│  │  • ProfileView                                         │    │
│  │  • SettingsView                                        │    │
│  └────────────┬───────────────────────────────────────────┘    │
│               │                                                 │
│               │ @EnvironmentObject                              │
│               ▼                                                 │
│  ┌────────────────────────────────────────────────────────┐    │
│  │  AuthService (@MainActor, ObservableObject)            │    │
│  │  • Centralized authentication logic                    │    │
│  │  • @Published var currentUser: User?                   │    │
│  │  • @Published var isAuthenticated: Bool                │    │
│  │  • signIn(), signUp(), signOut()                       │    │
│  │  • updateProfile(), deleteAccount()                    │    │
│  └────────────┬───────────────────────────────────────────┘    │
│               │                                                 │
│               │                                                 │
│               ▼                                                 │
│  ┌────────────────────────────────────────────────────────┐    │
│  │  SessionManager (Token & State Management)             │    │
│  │  • Keychain storage for tokens                         │    │
│  │  • Session expiration handling                         │    │
│  │  • Auto-refresh tokens                                 │    │
│  │  • Biometric authentication                            │    │
│  └────────────┬───────────────────────────────────────────┘    │
│               │                                                 │
│               │                                                 │
│               ▼                                                 │
│  ┌────────────────────────────────────────────────────────┐    │
│  │  Backend / Firebase                                    │    │
│  │  • User authentication                                 │    │
│  │  • Profile data storage                                │    │
│  │  • Session validation                                  │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐    │
│  │  Local Storage                                         │    │
│  │  • Keychain: Tokens, sensitive data                    │    │
│  │  • UserDefaults: Non-sensitive preferences             │    │
│  │  • Core Data/File: User progress, cache                │    │
│  └────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

### Key Principles

1. **Single Responsibility**: AuthService handles ALL auth logic
2. **Observable State**: UI reacts to @Published properties
3. **Secure Storage**: Keychain for tokens, UserDefaults for preferences
4. **Offline-First**: Cache user data locally
5. **Error Recovery**: Graceful handling of network issues

---

## 🎯 PART 1: Data Models

### Step 1: User Model

```swift
// Sources/Models/User.swift
import Foundation

struct User: Codable, Identifiable, Equatable {
    let id: String
    var email: String
    var displayName: String?
    var photoURL: String?
    var phoneNumber: String?
    
    // Profile information
    var bio: String?
    var dateOfBirth: Date?
    var country: String?
    
    // App-specific data
    var preferences: UserPreferences?
    var progress: UserProgress?
    
    // Metadata
    var createdAt: Date
    var updatedAt: Date
    var lastLoginAt: Date?
    
    // Subscription/premium status
    var isPremium: Bool
    var subscriptionEndDate: Date?
    
    // Settings
    var emailVerified: Bool
    var phoneVerified: Bool
    var notificationsEnabled: Bool
    var languageCode: String
    
    // Computed properties
    var initials: String {
        guard let displayName = displayName, !displayName.isEmpty else {
            return email.prefix(2).uppercased()
        }
        let components = displayName.split(separator: " ")
        if components.count >= 2 {
            return "\(components[0].prefix(1))\(components[1].prefix(1))".uppercased()
        }
        return String(displayName.prefix(2)).uppercased()
    }
    
    var isProfileComplete: Bool {
        displayName != nil && !displayName!.isEmpty
    }
    
    // MARK: - Codable Keys
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case displayName = "display_name"
        case photoURL = "photo_url"
        case phoneNumber = "phone_number"
        case bio
        case dateOfBirth = "date_of_birth"
        case country
        case preferences
        case progress
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case lastLoginAt = "last_login_at"
        case isPremium = "is_premium"
        case subscriptionEndDate = "subscription_end_date"
        case emailVerified = "email_verified"
        case phoneVerified = "phone_verified"
        case notificationsEnabled = "notifications_enabled"
        case languageCode = "language_code"
    }
}

// MARK: - User Preferences
struct UserPreferences: Codable, Equatable {
    // App settings
    var theme: AppTheme
    var fontSize: FontSize
    var soundEnabled: Bool
    var hapticsEnabled: Bool
    
    // Learning preferences (example for learning app)
    var currentLevel: String?
    var dailyGoal: Int
    var reminderTime: Date?
    var autoPlayAudio: Bool
    
    // Privacy
    var profileVisibility: ProfileVisibility
    var shareProgress: Bool
    
    enum AppTheme: String, Codable {
        case light, dark, system
    }
    
    enum FontSize: String, Codable {
        case small, medium, large, extraLarge
    }
    
    enum ProfileVisibility: String, Codable {
        case publicProfile = "public"
        case friendsOnly = "friends"
        case privateProfile = "private"
    }
    
    // Default preferences
    static var `default`: UserPreferences {
        UserPreferences(
            theme: .system,
            fontSize: .medium,
            soundEnabled: true,
            hapticsEnabled: true,
            currentLevel: nil,
            dailyGoal: 10,
            reminderTime: nil,
            autoPlayAudio: true,
            profileVisibility: .publicProfile,
            shareProgress: true
        )
    }
}

// MARK: - User Progress (Example for learning app)
struct UserProgress: Codable, Equatable {
    var totalPoints: Int
    var streak: Int
    var lastStudyDate: Date?
    var completedLessons: [String]
    var achievements: [String]
    var level: Int
    var xp: Int
    
    static var empty: UserProgress {
        UserProgress(
            totalPoints: 0,
            streak: 0,
            lastStudyDate: nil,
            completedLessons: [],
            achievements: [],
            level: 1,
            xp: 0
        )
    }
}

// MARK: - Authentication Credentials
struct AuthCredentials {
    let email: String
    let password: String
    
    var isValid: Bool {
        isValidEmail && isValidPassword
    }
    
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    var isValidPassword: Bool {
        // Minimum 8 characters, at least one letter and one number
        password.count >= 8 &&
        password.rangeOfCharacter(from: .letters) != nil &&
        password.rangeOfCharacter(from: .decimalDigits) != nil
    }
}
```

### Step 2: Authentication State

```swift
// Sources/Models/AuthState.swift
import Foundation

enum AuthState: Equatable {
    case signedOut
    case signingIn
    case signedIn(User)
    case error(AuthError)
    
    var isAuthenticated: Bool {
        if case .signedIn = self {
            return true
        }
        return false
    }
    
    var currentUser: User? {
        if case .signedIn(let user) = self {
            return user
        }
        return nil
    }
}

enum AuthError: LocalizedError, Equatable {
    case invalidCredentials
    case emailAlreadyExists
    case weakPassword
    case networkError
    case userNotFound
    case emailNotVerified
    case accountDisabled
    case tooManyRequests
    case sessionExpired
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .emailAlreadyExists:
            return "An account with this email already exists"
        case .weakPassword:
            return "Password must be at least 8 characters with letters and numbers"
        case .networkError:
            return "Network connection error. Please try again."
        case .userNotFound:
            return "No account found with this email"
        case .emailNotVerified:
            return "Please verify your email address"
        case .accountDisabled:
            return "This account has been disabled"
        case .tooManyRequests:
            return "Too many attempts. Please try again later."
        case .sessionExpired:
            return "Your session has expired. Please sign in again."
        case .unknown(let message):
            return message
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidCredentials:
            return "Check your email and password and try again"
        case .emailAlreadyExists:
            return "Try signing in instead"
        case .weakPassword:
            return "Use a stronger password with mixed characters"
        case .networkError:
            return "Check your internet connection"
        case .userNotFound:
            return "Create a new account"
        case .emailNotVerified:
            return "Check your email for verification link"
        case .accountDisabled:
            return "Contact support for assistance"
        case .tooManyRequests:
            return "Wait a few minutes before trying again"
        case .sessionExpired:
            return "Sign in again to continue"
        case .unknown:
            return "Please try again or contact support"
        }
    }
}
```

---

## 🎯 PART 2: Authentication Service

### Step 3: Core Authentication Service

```swift
// Sources/Services/AuthService.swift
import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class AuthService: ObservableObject {
    
    // MARK: - Singleton
    static let shared = AuthService()
    
    // MARK: - Published Properties
    @Published private(set) var currentUser: User?
    @Published private(set) var isAuthenticated = false
    @Published private(set) var isLoading = false
    @Published private(set) var authError: AuthError?
    
    // MARK: - Private Properties
    private let sessionManager = SessionManager.shared
    private let db = Firestore.firestore()
    private var authStateListener: AuthStateDidChangeListenerHandle?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    private init() {
        setupAuthStateListener()
        loadCachedUser()
    }
    
    // MARK: - Setup
    private func setupAuthStateListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            guard let self = self else { return }
            
            Task { @MainActor in
                if let firebaseUser = firebaseUser {
                    await self.loadUserData(userId: firebaseUser.uid)
                } else {
                    self.handleSignOut()
                }
            }
        }
    }
    
    private func loadCachedUser() {
        // Load cached user data for offline support
        if let cachedData = UserDefaults.standard.data(forKey: "cached_user"),
           let user = try? JSONDecoder().decode(User.self, from: cachedData) {
            self.currentUser = user
            self.isAuthenticated = true
        }
    }
    
    // MARK: - Sign In
    func signIn(email: String, password: String) async throws {
        isLoading = true
        authError = nil
        
        do {
            // Validate credentials
            let credentials = AuthCredentials(email: email, password: password)
            guard credentials.isValid else {
                throw AuthError.invalidCredentials
            }
            
            // Sign in with Firebase
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            
            // Load user data
            await loadUserData(userId: result.user.uid)
            
            // Update last login
            try await updateLastLogin()
            
            // Store session token
            if let token = try await result.user.getIDToken() {
                try sessionManager.saveAuthToken(token)
            }
            
            isLoading = false
            
            // Analytics
            AnalyticsService.shared.logEvent(.userSignedIn, parameters: [
                "method": "email"
            ])
            
        } catch let error as AuthError {
            isLoading = false
            authError = error
            throw error
        } catch {
            isLoading = false
            let authError = mapFirebaseError(error)
            self.authError = authError
            throw authError
        }
    }
    
    // MARK: - Sign Up
    func signUp(email: String, password: String, displayName: String?) async throws {
        isLoading = true
        authError = nil
        
        do {
            // Validate credentials
            let credentials = AuthCredentials(email: email, password: password)
            guard credentials.isValid else {
                throw AuthError.invalidCredentials
            }
            
            // Create user in Firebase
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // Create user profile
            let user = User(
                id: result.user.uid,
                email: email,
                displayName: displayName,
                photoURL: nil,
                phoneNumber: nil,
                bio: nil,
                dateOfBirth: nil,
                country: nil,
                preferences: .default,
                progress: .empty,
                createdAt: Date(),
                updatedAt: Date(),
                lastLoginAt: Date(),
                isPremium: false,
                subscriptionEndDate: nil,
                emailVerified: false,
                phoneVerified: false,
                notificationsEnabled: true,
                languageCode: Locale.current.languageCode ?? "en"
            )
            
            // Save to Firestore
            try await saveUserToFirestore(user)
            
            // Update local state
            self.currentUser = user
            self.isAuthenticated = true
            cacheUser(user)
            
            // Store session token
            if let token = try await result.user.getIDToken() {
                try sessionManager.saveAuthToken(token)
            }
            
            // Send verification email
            try await result.user.sendEmailVerification()
            
            isLoading = false
            
            // Analytics
            AnalyticsService.shared.logEvent(.userSignedUp, parameters: [
                "method": "email"
            ])
            
        } catch let error as AuthError {
            isLoading = false
            authError = error
            throw error
        } catch {
            isLoading = false
            let authError = mapFirebaseError(error)
            self.authError = authError
            throw authError
        }
    }
    
    // MARK: - Sign Out
    func signOut() async throws {
        do {
            try Auth.auth().signOut()
            handleSignOut()
            
            // Analytics
            AnalyticsService.shared.logEvent(.userSignedOut)
            
        } catch {
            throw AuthError.unknown(error.localizedDescription)
        }
    }
    
    private func handleSignOut() {
        currentUser = nil
        isAuthenticated = false
        sessionManager.clearSession()
        UserDefaults.standard.removeObject(forKey: "cached_user")
    }
    
    // MARK: - Profile Management
    func updateProfile(
        displayName: String? = nil,
        photoURL: String? = nil,
        bio: String? = nil,
        preferences: UserPreferences? = nil,
        progress: UserProgress? = nil
    ) async throws {
        guard var user = currentUser else {
            throw AuthError.userNotFound
        }
        
        // Update user object
        if let displayName = displayName {
            user.displayName = displayName
        }
        if let photoURL = photoURL {
            user.photoURL = photoURL
        }
        if let bio = bio {
            user.bio = bio
        }
        if let preferences = preferences {
            user.preferences = preferences
        }
        if let progress = progress {
            user.progress = progress
        }
        user.updatedAt = Date()
        
        // Save to Firestore
        try await saveUserToFirestore(user)
        
        // Update Firebase Auth profile if needed
        if let displayName = displayName {
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = displayName
            try await changeRequest?.commitChanges()
        }
        
        // Update local state
        self.currentUser = user
        cacheUser(user)
        
        // Analytics
        AnalyticsService.shared.logEvent(.profileUpdated)
    }
    
    // MARK: - Password Management
    func resetPassword(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            
            // Analytics
            AnalyticsService.shared.logEvent(.passwordResetRequested)
            
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    func updatePassword(currentPassword: String, newPassword: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        
        // Validate new password
        let credentials = AuthCredentials(email: user.email ?? "", password: newPassword)
        guard credentials.isValidPassword else {
            throw AuthError.weakPassword
        }
        
        // Re-authenticate first (security requirement)
        guard let email = user.email else {
            throw AuthError.invalidCredentials
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        try await user.reauthenticate(with: credential)
        
        // Update password
        try await user.updatePassword(to: newPassword)
        
        // Analytics
        AnalyticsService.shared.logEvent(.passwordChanged)
    }
    
    // MARK: - Account Deletion
    func deleteAccount(password: String) async throws {
        guard let firebaseUser = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        
        guard let email = firebaseUser.email else {
            throw AuthError.invalidCredentials
        }
        
        // Re-authenticate (security requirement)
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        try await firebaseUser.reauthenticate(with: credential)
        
        // Delete user data from Firestore
        if let user = currentUser {
            try await db.collection("users").document(user.id).delete()
        }
        
        // Delete Firebase Auth account
        try await firebaseUser.delete()
        
        // Clean up local state
        handleSignOut()
        
        // Analytics
        AnalyticsService.shared.logEvent(.accountDeleted)
    }
    
    // MARK: - Private Helpers
    private func loadUserData(userId: String) async {
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            
            if let user = try? document.data(as: User.self) {
                self.currentUser = user
                self.isAuthenticated = true
                cacheUser(user)
            } else {
                // User document doesn't exist, create it
                if let firebaseUser = Auth.auth().currentUser {
                    let user = User(
                        id: userId,
                        email: firebaseUser.email ?? "",
                        displayName: firebaseUser.displayName,
                        photoURL: firebaseUser.photoURL?.absoluteString,
                        phoneNumber: firebaseUser.phoneNumber,
                        bio: nil,
                        dateOfBirth: nil,
                        country: nil,
                        preferences: .default,
                        progress: .empty,
                        createdAt: Date(),
                        updatedAt: Date(),
                        lastLoginAt: Date(),
                        isPremium: false,
                        subscriptionEndDate: nil,
                        emailVerified: firebaseUser.isEmailVerified,
                        phoneVerified: false,
                        notificationsEnabled: true,
                        languageCode: Locale.current.languageCode ?? "en"
                    )
                    
                    try await saveUserToFirestore(user)
                    self.currentUser = user
                    self.isAuthenticated = true
                    cacheUser(user)
                }
            }
        } catch {
            print("Error loading user data: \(error)")
        }
    }
    
    private func saveUserToFirestore(_ user: User) async throws {
        try db.collection("users").document(user.id).setData(from: user)
    }
    
    private func updateLastLogin() async throws {
        guard let user = currentUser else { return }
        
        var updatedUser = user
        updatedUser.lastLoginAt = Date()
        
        try await saveUserToFirestore(updatedUser)
        self.currentUser = updatedUser
        cacheUser(updatedUser)
    }
    
    private func cacheUser(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: "cached_user")
        }
    }
    
    private func mapFirebaseError(_ error: Error) -> AuthError {
        let nsError = error as NSError
        
        switch nsError.code {
        case AuthErrorCode.wrongPassword.rawValue,
             AuthErrorCode.invalidCredential.rawValue:
            return .invalidCredentials
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return .emailAlreadyExists
        case AuthErrorCode.weakPassword.rawValue:
            return .weakPassword
        case AuthErrorCode.networkError.rawValue:
            return .networkError
        case AuthErrorCode.userNotFound.rawValue:
            return .userNotFound
        case AuthErrorCode.userDisabled.rawValue:
            return .accountDisabled
        case AuthErrorCode.tooManyRequests.rawValue:
            return .tooManyRequests
        default:
            return .unknown(error.localizedDescription)
        }
    }
    
    // MARK: - Cleanup
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
}
```

---

## 🎯 PART 3: Session Management

### Step 4: Session Manager with Keychain

```swift
// Sources/Services/SessionManager.swift
import Foundation
import Security
import LocalAuthentication

final class SessionManager {
    
    static let shared = SessionManager()
    
    private let keychainService = "com.yourapp.keychain"
    private let authTokenKey = "auth_token"
    private let refreshTokenKey = "refresh_token"
    private let tokenExpirationKey = "token_expiration"
    
    private init() {}
    
    // MARK: - Token Management
    func saveAuthToken(_ token: String) throws {
        try saveToKeychain(key: authTokenKey, value: token)
        
        // Set expiration (e.g., 1 hour from now)
        let expiration = Date().addingTimeInterval(3600)
        UserDefaults.standard.set(expiration, forKey: tokenExpirationKey)
    }
    
    func getAuthToken() -> String? {
        // Check if token is expired
        if isTokenExpired() {
            return nil
        }
        
        return try? getFromKeychain(key: authTokenKey)
    }
    
    func saveRefreshToken(_ token: String) throws {
        try saveToKeychain(key: refreshTokenKey, value: token)
    }
    
    func getRefreshToken() -> String? {
        return try? getFromKeychain(key: refreshTokenKey)
    }
    
    func isTokenExpired() -> Bool {
        guard let expiration = UserDefaults.standard.object(forKey: tokenExpirationKey) as? Date else {
            return true
        }
        return Date() > expiration
    }
    
    // MARK: - Session Management
    func clearSession() {
        try? deleteFromKeychain(key: authTokenKey)
        try? deleteFromKeychain(key: refreshTokenKey)
        UserDefaults.standard.removeObject(forKey: tokenExpirationKey)
    }
    
    // MARK: - Biometric Authentication
    func authenticateWithBiometrics() async throws -> Bool {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw NSError(domain: "BiometricsNotAvailable", code: -1, userInfo: nil)
        }
        
        let reason = "Authenticate to access your account"
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            return success
        } catch {
            return false
        }
    }
    
    func isBiometricsAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    var biometricType: LABiometryType {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType
    }
    
    // MARK: - Keychain Helpers
    private func saveToKeychain(key: String, value: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw NSError(domain: "KeychainError", code: -1, userInfo: nil)
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete any existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw NSError(domain: "KeychainError", code: Int(status), userInfo: nil)
        }
    }
    
    private func getFromKeychain(key: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "KeychainError", code: Int(status), userInfo: nil)
        }
        
        return value
    }
    
    private func deleteFromKeychain(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw NSError(domain: "KeychainError", code: Int(status), userInfo: nil)
        }
    }
}
```

---

*[Document continues with Parts 4-7 and additional sections... This is getting very long. Would you like me to continue with the remaining sections, or would you prefer I create a condensed version with the most critical parts?]*

**Total estimated length: ~3,500 lines (similar to other app tips)**

Should I:
1. ✅ Continue with full comprehensive version (Parts 4-7, UI examples, security, testing)
2. Make it more concise but still production-ready
3. Focus on specific areas you're most concerned about

Let me know and I'll complete it accordingly!
