//
//  DependencyContainer.swift
//  JLearn
//
//  Dependency injection container
//  Manages service lifecycle and dependencies
//

import Foundation
import SwiftUI

// MARK: - Dependency Container

/// Central dependency injection container
@MainActor
final class DependencyContainer: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = DependencyContainer()
    
    // MARK: - Services
    
    // Core Services
    let authService: any AuthServiceProtocol
    let dataService: any DataServiceProtocol
    let audioService: any AudioServiceProtocol
    let analyticsService: any AnalyticsServiceProtocol
    
    // Feature Services
    let achievementService: any AchievementServiceProtocol
    let spacedRepetitionService: any SpacedRepetitionServiceProtocol
    let toastManager: any ToastManagerProtocol
    
    // Infrastructure
    let storageService: any StorageServiceProtocol
    let cacheService: CacheRepositoryProtocol
    let parsingService: ParsingServiceProtocol
    
    // Repositories
    let userRepository: UserRepositoryProtocol
    
    // MARK: - Initialization
    
    private init() {
        // Initialize infrastructure first
        self.storageService = CacheRepository.shared
        self.cacheService = CacheRepository.shared
        self.parsingService = JSONParserService.shared
        
        // Initialize repositories
        self.userRepository = UserRepository(
            userDefaults: .standard,
            cacheRepository: CacheRepository.shared
        )
        
        // Initialize core services
        self.authService = AuthService.shared
        self.dataService = LearningDataService.shared
        self.audioService = AudioService.shared
        self.analyticsService = AnalyticsService.shared
        
        // Initialize feature services
        self.achievementService = AchievementService.shared
        self.spacedRepetitionService = SpacedRepetitionService.shared
        self.toastManager = ToastManager.shared
        
        AppLogger.info("✅ DependencyContainer initialized")
    }
    
    // MARK: - Factory Methods (for testing/mocking)
    
    /// Create a test container with mock services
    static func createTestContainer(
        authService: (any AuthServiceProtocol)? = nil,
        dataService: (any DataServiceProtocol)? = nil,
        audioService: (any AudioServiceProtocol)? = nil
    ) -> DependencyContainer {
        // For future unit testing support
        return .shared
    }
}

// MARK: - SwiftUI Environment Support

private struct DependencyContainerKey: EnvironmentKey {
    static let defaultValue: DependencyContainer = .shared
}

extension EnvironmentValues {
    var dependencies: DependencyContainer {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}

extension View {
    /// Inject dependency container into environment
    func withDependencies(_ container: DependencyContainer = .shared) -> some View {
        self.environment(\.dependencies, container)
    }
}

// MARK: - Service Access Helpers

extension View {
    /// Access injected services from environment
    var services: DependencyContainer {
        return DependencyContainer.shared
    }
}


