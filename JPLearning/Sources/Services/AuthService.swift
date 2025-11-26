//
//  AuthService.swift
//  JLearn
//
//  Authentication service with Firebase Auth (Local Storage Only)
//

import Foundation
import SwiftUI
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
    
    private let auth = Auth.auth()
    
    private init() {
        // Authentication check will be performed on first access
    }
    
    func initialize() async {
        await checkAuthentication()
    }
    
    // MARK: - Authentication State
    
    func checkAuthentication() async {
        isLoading = true
        
        if let user = auth.currentUser {
            // Load user data from local storage or create new
            if let userData = loadUserDataFromLocal(uid: user.uid) {
                currentUser = userData
            } else {
                // Create user model from Firebase user
                let userModel = createUserModelFromFirebaseUser(user)
                currentUser = userModel
                saveUserDataToLocal(userModel)
            }
            isAuthenticated = true
        } else {
            // Check for demo/guest user
            if let demoUser = loadDemoUser() {
                currentUser = demoUser
                isAuthenticated = true
            } else {
                isAuthenticated = false
                currentUser = nil
            }
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
    
    // MARK: - Guest Mode
    
    func continueAsGuest() async throws {
        isLoading = true
        error = nil
        
        // Create a guest user (no authentication required)
        let guestUser = UserModel(
            id: "guest_\(UUID().uuidString)",
            email: "guest@jlearn.local",
            displayName: "Guest User",
            photoURL: nil,
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
    
    // MARK: - Local Demo Storage
    
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
    
    // MARK: - Sign in with Apple
    
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws {
        isLoading = true
        error = nil
        
        do {
            guard let nonce = AppleSignInCoordinator.currentNonce else {
                throw AppError.authentication("Invalid state: A login callback was received, but no login request was sent.")
            }
            
            guard let appleIDToken = credential.identityToken else {
                throw AppError.authentication("Unable to fetch identity token")
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                throw AppError.authentication("Unable to serialize token string from data")
            }
            
            let firebaseCredential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: nonce
            )
            
            let result = try await auth.signIn(with: firebaseCredential)
            
            var userModel: UserModel
            if let userData = loadUserDataFromLocal(uid: result.user.uid) {
                userModel = userData
            } else {
                userModel = createUserModelFromFirebaseUser(result.user)
                
                // Update display name from Apple if available
                if let fullName = credential.fullName {
                    var name = ""
                    if let givenName = fullName.givenName {
                        name += givenName
                    }
                    if let familyName = fullName.familyName {
                        if !name.isEmpty {
                            name += " "
                        }
                        name += familyName
                    }
                    if !name.isEmpty {
                        userModel.displayName = name
                    }
                }
                
                saveUserDataToLocal(userModel)
            }
            
            currentUser = userModel
            isAuthenticated = true
        } catch {
            self.error = error.localizedDescription
            throw AppError.authentication(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    // MARK: - Update Profile
    
    func updateProfile(
        displayName: String? = nil,
        photoURL: String? = nil,
        preferences: UserPreferences? = nil,
        progress: UserProgress? = nil,
        savedKanji: [String]? = nil,
        savedVocabulary: [String]? = nil
    ) async throws {
        guard var user = currentUser else {
            throw AppError.notAuthenticated
        }
        
        // Update Firebase Auth profile if display name changed
        if let displayName = displayName {
            let changeRequest = auth.currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = displayName
            try await changeRequest?.commitChanges()
            user.displayName = displayName
        }
        
        // Update local user model
        if let photoURL = photoURL {
            user.photoURL = photoURL
        }
        
        if let preferences = preferences {
            user.preferences = preferences
        }
        
        if let progress = progress {
            user.progress = progress
        }
        
        if let savedKanji = savedKanji {
            user.savedKanji = savedKanji
        }
        
        if let savedVocabulary = savedVocabulary {
            user.savedVocabulary = savedVocabulary
        }
        
        // Save to local storage
        saveUserDataToLocal(user)
        currentUser = user
    }
    
    // MARK: - Password Reset
    
    func resetPassword(email: String) async throws {
        do {
            try await auth.sendPasswordReset(withEmail: email)
        } catch {
            throw AppError.authentication("Failed to send password reset email: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() throws {
        do {
            try auth.signOut()
            currentUser = nil
            isAuthenticated = false
            error = nil
            
            // Also clear demo user
            UserDefaults.standard.removeObject(forKey: "demo_user")
        } catch {
            throw AppError.authentication("Failed to sign out: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Delete Account
    
    /// Permanently delete user account and all associated data
    /// This action cannot be undone
    func deleteAccount() async throws {
        guard let user = auth.currentUser else {
            throw AppError.notAuthenticated
        }
        
        let uid = user.uid
        
        // Delete local data
        deleteUserDataFromLocal(uid: uid)
        
        // Delete Firebase Auth account
        try await user.delete()
        
        // Update state
        currentUser = nil
        isAuthenticated = false
        error = nil
    }
}

// MARK: - Apple Sign In Coordinator

class AppleSignInCoordinator {
    static var currentNonce: String?
    
    static func generateNonce() -> String {
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = 32
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    // Return nil instead of crashing - will be filtered by compactMap
                    return nil
                }
                return random
            }.compactMap { $0 }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hashData(inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

// MARK: - SHA256 (Simplified)

import CryptoKit

extension SHA256 {
    static func hashData(_ data: Data) -> SHA256.Digest {
        return SHA256.hash(data: data)
    }
}
