//
//  AuthService.swift
//  NPLearn
//
//  Authentication service with Firebase Auth (Local Storage Only)
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseAuth
import AuthenticationServices

// MARK: - Auth Service

@MainActor
final class AuthService: ObservableObject {
    
    static let shared = AuthService()
    
    @Published var currentUser: UserModel?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?
    
    private var auth: Auth? {
        // Only access Auth if Firebase is configured
        guard FirebaseApp.app() != nil else {
            return nil
        }
        return Auth.auth()
    }
    
    nonisolated private init() {
        Task { @MainActor in
            await checkAuthenticationWithTimeout()
        }
    }
    
    // MARK: - Authentication State
    
    private func checkAuthenticationWithTimeout() async {
        // Add timeout to prevent infinite loading
        await withTaskGroup(of: Void.self) { group in
            // Main authentication check
            group.addTask { @MainActor in
                await self.checkAuthentication()
            }
            
            // Timeout task (3 seconds max for initial load)
            group.addTask {
                do {
                    try await Task.sleep(nanoseconds: 3_000_000_000)
                } catch {
                    // Task was cancelled, which is expected
                    return
                }
                await MainActor.run {
                    // If still loading after 3 seconds, force completion
                    if self.isLoading {
                        AppLogger.warning("⚠️ Authentication check timed out, enabling guest mode")
                        self.isLoading = false
                        // Allow user to continue without auth (they can use guest mode)
                        self.isAuthenticated = false
                        self.currentUser = nil
                    }
                }
            }
            
            // Wait for first completion
            await group.next()
            group.cancelAll()
        }
    }
    
    func checkAuthentication() async {
        isLoading = true
        
        do {
            // Check if Firebase is configured
            guard let auth = auth, let user = auth.currentUser else {
                // Running in demo mode - check for demo user
                if let demoUser = loadDemoUser() {
                    currentUser = demoUser
                    isAuthenticated = true
                } else {
                    isAuthenticated = false
                    currentUser = nil
                }
                isLoading = false
                return
            }
            
            // Firebase is configured - use Firebase Auth
            if let userData = loadUserDataFromLocal(uid: user.uid) {
                currentUser = userData
            } else {
                let userModel = createUserModelFromFirebaseUser(user)
                currentUser = userModel
                saveUserDataToLocal(userModel)
            }
            isAuthenticated = true
            
        } catch {
            AppLogger.error("❌ Authentication check failed", error: error)
            isAuthenticated = false
            currentUser = nil
        }
        
        isLoading = false
    }
    
    private func createUserModelFromFirebaseUser(_ user: User) -> UserModel {
        return UserModel(
            id: user.uid,
            email: user.email ?? "",
            displayName: user.displayName,
            photoURL: user.photoURL?.absoluteString,
            createdAt: Date(),
            preferences: UserPreferences(),
            progress: UserProgress()
        )
    }
    
    // MARK: - Local Storage
    
    private func loadDemoUser() -> UserModel? {
        guard let data = UserDefaults.standard.data(forKey: "demo_user"),
              let user = try? JSONDecoder().decode(UserModel.self, from: data) else {
            return nil
        }
        return user
    }
    
    private func saveDemoUser(_ user: UserModel) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: "demo_user")
        }
    }
    
    private func loadUserDataFromLocal(uid: String) -> UserModel? {
        guard let data = UserDefaults.standard.data(forKey: "user_\(uid)"),
              let user = try? JSONDecoder().decode(UserModel.self, from: data) else {
            return nil
        }
        return user
    }
    
    private func saveUserDataToLocal(_ user: UserModel) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: "user_\(user.id)")
        }
    }
    
    private func deleteUserDataFromLocal(uid: String) {
        UserDefaults.standard.removeObject(forKey: "user_\(uid)")
    }
    
    // MARK: - Sign Up
    
    func signUpWithEmail(email: String, password: String) async throws {
        isLoading = true
        error = nil
        
        // Check if Firebase is configured
        guard let auth = auth else {
            // Demo mode - create local user
            let demoUser = UserModel(
                id: UUID().uuidString,
                email: email,
                createdAt: Date(),
                preferences: UserPreferences(),
                progress: UserProgress()
            )
            saveDemoUser(demoUser)
            currentUser = demoUser
            isAuthenticated = true
            isLoading = false
            print("✅ Demo user created: \(email)")
            return
        }
        
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            
            let userModel = UserModel(
                id: result.user.uid,
                email: email,
                createdAt: Date(),
                preferences: UserPreferences(),
                progress: UserProgress()
            )
            
            // Save to local storage
            saveUserDataToLocal(userModel)
            
            currentUser = userModel
            isAuthenticated = true
        } catch {
            self.error = error.localizedDescription
            throw AppError.authentication(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    // MARK: - Sign In
    
    func signInWithEmail(email: String, password: String) async throws {
        isLoading = true
        error = nil
        
        // Check if Firebase is configured
        guard let auth = auth else {
            // Demo mode - check for existing demo user
            if let demoUser = loadDemoUser(), demoUser.email == email {
                currentUser = demoUser
                isAuthenticated = true
                isLoading = false
                print("✅ Demo user signed in: \(email)")
                return
            } else {
                // Create new demo user if doesn't exist
                let demoUser = UserModel(
                    id: UUID().uuidString,
                    email: email,
                    createdAt: Date(),
                    preferences: UserPreferences(),
                    progress: UserProgress()
                )
                saveDemoUser(demoUser)
                currentUser = demoUser
                isAuthenticated = true
                isLoading = false
                print("✅ New demo user created: \(email)")
                return
            }
        }
        
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            
            // Load from local storage or create new
            if let userData = loadUserDataFromLocal(uid: result.user.uid) {
                currentUser = userData
            } else {
                currentUser = createUserModelFromFirebaseUser(result.user)
                saveUserDataToLocal(currentUser!)
            }
            
            isAuthenticated = true
        } catch {
            self.error = error.localizedDescription
            throw AppError.authentication(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    // MARK: - Sign in with Apple
    
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws {
        isLoading = true
        error = nil
        
        // Add timeout protection for Apple Sign In
        let timeoutTask = Task {
            do {
                try await Task.sleep(nanoseconds: 8_000_000_000) // 8 seconds
            } catch {
                // Task was cancelled, which is expected
                return
            }
            if isLoading {
                await MainActor.run {
                    isLoading = false
                    AppLogger.warning("⚠️ Apple Sign In timed out")
                }
            }
        }
        
        defer {
            timeoutTask.cancel()
        }
        
        // Check if Firebase is configured
        guard let auth = auth else {
            // Demo mode - create user from Apple credential
            var displayName: String? = nil
            if let fullName = credential.fullName {
                displayName = [fullName.givenName, fullName.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")
            }
            
            let demoUser = UserModel(
                id: UUID().uuidString,
                email: credential.email ?? "apple_user@demo.com",
                displayName: displayName,
                createdAt: Date(),
                preferences: UserPreferences(),
                progress: UserProgress()
            )
            saveDemoUser(demoUser)
            currentUser = demoUser
            isAuthenticated = true
            isLoading = false
            AppLogger.info("✅ Demo Apple Sign In successful")
            return
        }
        
        guard let idToken = credential.identityToken,
              let tokenString = String(data: idToken, encoding: .utf8) else {
            isLoading = false
            throw AppError.authentication("Unable to fetch identity token")
        }
        
        let firebaseCredential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: tokenString,
            rawNonce: nil
        )
        
        do {
            let result = try await auth.signIn(with: firebaseCredential)
            
            // Load from local storage or create new
            if let userData = loadUserDataFromLocal(uid: result.user.uid) {
                currentUser = userData
            } else {
                var userModel = createUserModelFromFirebaseUser(result.user)
                
                // Update with Apple credentials
                if let fullName = credential.fullName {
                    let displayName = [fullName.givenName, fullName.familyName]
                        .compactMap { $0 }
                        .joined(separator: " ")
                    userModel.displayName = displayName.isEmpty ? nil : displayName
                }
                
                currentUser = userModel
                saveUserDataToLocal(userModel)
            }
            
            isAuthenticated = true
            isLoading = false
        } catch {
            isLoading = false
            self.error = error.localizedDescription
            AppLogger.error("❌ Apple Sign In failed", error: error)
            throw AppError.authentication(error.localizedDescription)
        }
    }
    
    // MARK: - Guest Mode
    
    func continueAsGuest() async throws {
        isLoading = true
        error = nil
        
        // Create a guest user (no authentication required)
        let guestUser = UserModel(
            id: "guest_\(UUID().uuidString)",
            email: "guest@nplearn.local",
            displayName: "Guest User",
            createdAt: Date(),
            preferences: UserPreferences(),
            progress: UserProgress()
        )
        
        // Save guest user locally
        saveDemoUser(guestUser)
        currentUser = guestUser
        isAuthenticated = true
        isLoading = false
        
        AppLogger.info("✅ Guest user created successfully")
    }
    
    // MARK: - Sign Out
    
    func signOut() throws {
        // Demo mode or Firebase mode
        if let auth = auth {
            do {
                try auth.signOut()
            } catch {
                throw AppError.authentication("Failed to sign out: \(error.localizedDescription)")
            }
        }
        
        // Clear demo user
        UserDefaults.standard.removeObject(forKey: "demo_user")
        
        isAuthenticated = false
        currentUser = nil
    }
    
    // MARK: - Update Profile
    
    func updateProfile(
        displayName: String? = nil,
        photoURL: String? = nil,
        preferences: UserPreferences? = nil,
        progress: UserProgress? = nil,
        savedVocabulary: [String]? = nil
    ) async throws {
        guard var user = currentUser else {
            throw AppError.notAuthenticated
        }
        
        if let displayName = displayName {
            user.displayName = displayName
        }
        
        if let photoURL = photoURL {
            user.photoURL = photoURL
        }
        
        if let preferences = preferences {
            user.preferences = preferences
        }
        
        if let progress = progress {
            user.progress = progress
        }
        
        if let savedVocabulary = savedVocabulary {
            user.savedVocabulary = savedVocabulary
        }
        
        // Save to local storage (works in both demo and Firebase mode)
        if auth != nil {
            saveUserDataToLocal(user)
        } else {
            saveDemoUser(user)
        }
        currentUser = user
    }
    
    // MARK: - Delete Account
    
    func deleteAccount() async throws {
        isLoading = true
        
        do {
            // Get current user ID before deletion
            let userId = currentUser?.id
            
            // Check if Firebase is configured
            guard let auth = auth, let user = auth.currentUser else {
                // Demo mode or Guest mode - clear local data
                AppLogger.info("🗑️ Deleting local account data")
                
                // Clear all local user data
                UserDefaults.standard.removeObject(forKey: "demo_user")
                
                // Clear any stored guest user data
                if let userId = userId {
                    deleteUserDataFromLocal(uid: userId)
                }
                
                isAuthenticated = false
                currentUser = nil
                isLoading = false
                
                AppLogger.info("✅ Account deleted successfully (local mode)")
                return
            }
            
            // Firebase mode - delete both Firebase account and local data
            let uid = user.uid
            
            AppLogger.info("🗑️ Deleting Firebase account: \(uid)")
            
            // Delete from Firebase
            try await user.delete()
            
            // Delete local data
            deleteUserDataFromLocal(uid: uid)
            
            // Clear all user-related data
            UserDefaults.standard.removeObject(forKey: "demo_user")
            
            isAuthenticated = false
            currentUser = nil
            
            AppLogger.info("✅ Account deleted successfully (Firebase)")
            
        } catch let error as NSError {
            isLoading = false
            
            // Handle re-authentication required error
            if error.domain == "FIRAuthErrorDomain" && error.code == 17014 {
                AppLogger.error("❌ Account deletion failed: User needs to re-authenticate")
                throw AppError.authentication("For security reasons, please sign out and sign in again, then try deleting your account.")
            }
            
            AppLogger.error("❌ Account deletion failed", error: error)
            throw AppError.authentication("Failed to delete account: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}

