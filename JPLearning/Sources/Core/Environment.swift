//
//  Environment.swift
//  JLearn
//
//  Unified environment configuration system
//  Replaces individual ProductionConfig and environment-specific settings
//

import Foundation

// MARK: - Environment

/// Centralized environment configuration
enum Environment {
    case development
    case staging
    case production
    
    /// Current environment (can be set via build configurations)
    static var current: Environment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }
    
    // MARK: - API Configuration
    
    var apiBaseURL: String {
        switch self {
        case .development:
            return "https://dev-api.jlearn.app"
        case .staging:
            return "https://staging-api.jlearn.app"
        case .production:
            return "https://api.jlearn.app"
        }
    }
    
    var translationServiceURL: String {
        switch self {
        case .development:
            return "https://dev-translate.jlearn.app"
        case .staging:
            return "https://staging-translate.jlearn.app"
        case .production:
            return "https://translate.jlearn.app"
        }
    }
    
    // MARK: - Feature Flags
    
    var enableDebugLogging: Bool {
        switch self {
        case .development: return true
        case .staging: return true
        case .production: return false
        }
    }
    
    var enablePerformanceMonitoring: Bool {
        return true // Enabled for all environments
    }
    
    var enableAnalytics: Bool {
        switch self {
        case .development: return false
        case .staging: return true
        case .production: return true
        }
    }
    
    var enableCrashReporting: Bool {
        switch self {
        case .development: return false
        case .staging: return true
        case .production: return true
        }
    }
    
    // MARK: - App Configuration
    
    var appStoreId: String {
        return "YOUR_APP_ID"
    }
    
    var supportEmail: String {
        return "support@jlearn.app"
    }
    
    var websiteURL: String {
        return "https://www.jlearn.app"
    }
    
    // MARK: - Limits & Constraints
    
    var maxFlashcardsPerSession: Int {
        return 20
    }
    
    var maxDailyPracticeTime: Int {
        return 120 // minutes
    }
    
    var maxCacheSize: Int {
        return 100 // MB
    }
    
    var cacheExpirationDays: Int {
        switch self {
        case .development: return 1 // Short cache for testing
        case .staging: return 7
        case .production: return 30
        }
    }
    
    // MARK: - Network Configuration
    
    var networkTimeoutInterval: TimeInterval {
        return 30.0
    }
    
    var networkRetryCount: Int {
        return 3
    }
    
    var networkRetryDelay: TimeInterval {
        return 1.0
    }
    
    // MARK: - Remote Data (GitHub)
    
    var githubDataBaseURL: String {
        return "https://raw.githubusercontent.com/dnsmalla/easylearning/main/jpleanrning"
    }
    
    var githubManifestURL: String {
        return "\(githubDataBaseURL)/manifest.json"
    }
}

// MARK: - Environment Access Helper

extension Environment {
    /// Quick access to current environment's config
    static var config: Environment {
        return current
    }
}

