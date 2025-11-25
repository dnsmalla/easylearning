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
    let authService: AuthService
    let dataService: LearningDataService
    let audioService: AudioService
    let analyticsService: AnalyticsService
    
    // Feature Services
    let achievementService: AchievementService
    let spacedRepetitionService: SpacedRepetitionService
    let toastManager: ToastManager
    
    // Infrastructure
    let storageService: CacheRepository
    let cacheService: CacheRepository
    let parsingService: JSONParserService
    
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
    
}



