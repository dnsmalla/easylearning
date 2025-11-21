import Foundation
import Combine
import UIKit
import LocalAuthentication
import GoogleSignIn

// MARK: - Public API

public final class AuthService: ObservableObject {
    public static let shared = AuthService()

    @Published public private(set) var isAuthenticated: Bool = false
    @Published public private(set) var user: UserProfile? = nil

    private let backend: AuthBackend
    private let persistence: AuthPersistence
    private let queue = DispatchQueue(label: "auth.service.queue")

    public init(backend: AuthBackend = LocalAuthBackend(),
                persistence: AuthPersistence = UserDefaultsAuthPersistence()) {
        self.backend = backend
        self.persistence = persistence
        if let saved = persistence.loadUser() {
            self.user = saved
            self.isAuthenticated = persistence.isAuthenticated
        }
    }

    // MARK: - Email/Password
    public func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        backend.signIn(email: email, password: password) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                DispatchQueue.main.async {
                    self.user = profile
                    self.isAuthenticated = true
                    self.persistence.saveUser(profile)
                    self.persistence.isAuthenticated = true
                    completion(true)
                }
            case .failure:
                DispatchQueue.main.async { completion(false) }
            }
        }
    }

    public func signUp(email: String, password: String, completion: @escaping (Bool) -> Void) {
        backend.signUp(email: email, password: password) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                DispatchQueue.main.async {
                    self.user = profile
                    self.isAuthenticated = true
                    self.persistence.saveUser(profile)
                    self.persistence.isAuthenticated = true
                    completion(true)
                }
            case .failure:
                DispatchQueue.main.async { completion(false) }
            }
        }
    }

    // MARK: - Google Sign-In
    public func signInWithGoogle(completion: @escaping (Bool) -> Void) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.keyWindow?.rootViewController else {
            completion(false)
            return
        }

        guard let clientID = resolveGoogleClientID() else {
            print("[AuthService] Missing GIDClientID. Set Info.plist key 'GIDClientID' or env 'GIDClientID'/'GOOGLE_CLIENT_ID' or provide a Secrets.plist.")
            completion(false)
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                print("[AuthService] Google Sign-In error: \(error)")
                completion(false)
                return
            }
            guard let user = result?.user else { completion(false); return }
            let profile = UserProfile(name: user.profile?.name ?? "Google User",
                                      email: user.profile?.email ?? "")
            DispatchQueue.main.async {
                self.user = profile
                self.isAuthenticated = true
                self.persistence.saveUser(profile)
                self.persistence.isAuthenticated = true
                completion(true)
            }
        }
    }

    // MARK: - Biometrics
    public func signInWithBiometrics(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        let canBio = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        let canDevice = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
        guard canBio || canDevice else { completion(false); return }

        let policy: LAPolicy = canBio ? .deviceOwnerAuthenticationWithBiometrics : .deviceOwnerAuthentication
        context.evaluatePolicy(policy, localizedReason: "Unlock") { [weak self] success, _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if success {
                    if self.user == nil { self.user = UserProfile(name: "User", email: "") }
                    self.isAuthenticated = true
                    if let u = self.user { self.persistence.saveUser(u) }
                    self.persistence.isAuthenticated = true
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }

    // MARK: - Session
    public func signOut() {
        user = nil
        isAuthenticated = false
        persistence.clear()
    }

    public func updateProfile(_ profile: UserProfile) {
        user = profile
        persistence.saveUser(profile)
    }

    // MARK: - Account Deletion (Apple Guideline 5.1.1(v) Compliance)
    /// Permanently deletes the user's account and all associated data
    /// Required by Apple for apps that support account creation
    /// - Parameter completion: Callback with success status and optional error message
    public func deleteAccount(completion: @escaping (Bool, String?) -> Void) {
        backend.deleteAccount { [weak self] result in
            guard let self = self else {
                DispatchQueue.main.async { completion(false, "Service unavailable") }
                return
            }
            
            switch result {
            case .success:
                // Clear all local data
                DispatchQueue.main.async {
                    self.user = nil
                    self.isAuthenticated = false
                    self.persistence.clear()
                    
                    // Clear any other user-specific data
                    self.clearAllUserData()
                    
                    completion(true, nil)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
    
    /// Override this method to clear additional user-specific data
    /// (e.g., cached files, app-specific storage, analytics data)
    open func clearAllUserData() {
        // Subclasses or integrators can override to add custom cleanup
        // Examples:
        // - Clear cached images
        // - Remove local files
        // - Clear analytics identifiers
        // - Remove push notification tokens
    }

    // MARK: - Helpers
    private func resolveGoogleClientID() -> String? {
        if let v = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String, !v.isEmpty { return v }
        let env = ProcessInfo.processInfo.environment
        if let v = env["GIDClientID"], !v.isEmpty { return v }
        if let v = env["GOOGLE_CLIENT_ID"], !v.isEmpty { return v }
        if let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
           let data = try? Data(contentsOf: url),
           let dict = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
           let v = dict["GIDClientID"] as? String, !v.isEmpty {
            return v
        }
        return nil
    }
}

// MARK: - Models

public struct UserProfile: Codable, Equatable {
    public var name: String
    public var email: String
    public var company: String = ""
    public var phone: String = ""
    public var bio: String = ""

    public init(name: String, email: String) {
        self.name = name
        self.email = email
    }
}

// MARK: - Backend abstraction (replace with real server/Firebase)

public protocol AuthBackend {
    func signIn(email: String, password: String, completion: @escaping (Result<UserProfile, Error>) -> Void)
    func signUp(email: String, password: String, completion: @escaping (Result<UserProfile, Error>) -> Void)
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void)
}

public final class LocalAuthBackend: AuthBackend {
    public init() {}
    public func signIn(email: String, password: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.25) {
            if !email.isEmpty && !password.isEmpty {
                completion(.success(UserProfile(name: email.components(separatedBy: "@").first ?? "User", email: email)))
            } else {
                completion(.failure(NSError(domain: "Auth", code: 401)))
            }
        }
    }

    public func signUp(email: String, password: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.25) {
            if !email.isEmpty && !password.isEmpty {
                completion(.success(UserProfile(name: email.components(separatedBy: "@").first ?? "User", email: email)))
            } else {
                completion(.failure(NSError(domain: "Auth", code: 422)))
            }
        }
    }
    
    public func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        // TODO: Implement actual account deletion with your backend
        // For production, replace this with real API call to delete user data
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            // Simulate successful deletion
            completion(.success(()))
            
            // Example for real implementation:
            // let url = URL(string: "\(baseURL)/users/me")!
            // var request = URLRequest(url: url)
            // request.httpMethod = "DELETE"
            // request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
            // URLSession.shared.dataTask(with: request) { data, response, error in
            //     if let error = error {
            //         completion(.failure(error))
            //     } else {
            //         completion(.success(()))
            //     }
            // }.resume()
        }
    }
}

// MARK: - Persistence abstraction (replace with Keychain/DB)

public protocol AuthPersistence {
    var isAuthenticated: Bool { get set }
    func loadUser() -> UserProfile?
    func saveUser(_ user: UserProfile)
    func clear()
}

public final class UserDefaultsAuthPersistence: AuthPersistence {
    private let userKey = "auth.user"
    private let authedKey = "auth.isAuthenticated"
    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public var isAuthenticated: Bool {
        get { defaults.bool(forKey: authedKey) }
        set { defaults.set(newValue, forKey: authedKey) }
    }

    public func loadUser() -> UserProfile? {
        guard let data = defaults.data(forKey: userKey) else { return nil }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }

    public func saveUser(_ user: UserProfile) {
        if let data = try? JSONEncoder().encode(user) {
            defaults.set(data, forKey: userKey)
        }
    }

    public func clear() {
        defaults.removeObject(forKey: userKey)
        defaults.set(false, forKey: authedKey)
    }
}


