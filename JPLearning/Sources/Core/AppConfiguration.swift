//
//  AppConfiguration.swift
//  JLearn
//
//  Application configuration and environment settings for Japanese learning
//

import Foundation

// MARK: - App Configuration

enum AppConfiguration {
  
  // MARK: - App Info
  
  static let appName = "JLearn"
  static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
  static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
  static let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.company.jlearn"
  
  // MARK: - iCloud Configuration
  
  static let iCloudContainerIdentifier = "iCloud.com.company.jlearn"
  
  // MARK: - Learning Configuration
  
  enum Learning {
    static let availableLevels = ["Beginner", "Elementary", "Intermediate", "Advanced", "Proficient"]
    static let defaultLevel = "Beginner"
    
    // Learning categories for Japanese
    static let categories = ["Vocabulary", "Grammar", "Listening", "Speaking", "Writing", "Reading"]
    
    static let levelDescriptions: [String: String] = [
      "Beginner": "Basic greetings and simple phrases",
      "Elementary": "Common everyday conversations",
      "Intermediate": "Detailed conversations on various topics",
      "Advanced": "Complex discussions and formal language",
      "Proficient": "Native-level fluency and cultural nuances"
    ]
    
    static let levelVocabCount: [String: Int] = [
      "Beginner": 500,
      "Elementary": 1000,
      "Intermediate": 2000,
      "Advanced": 4000,
      "Proficient": 8000
    ]
    
    static let levelGrammarCount: [String: Int] = [
      "Beginner": 30,
      "Elementary": 50,
      "Intermediate": 80,
      "Advanced": 120,
      "Proficient": 200
    ]
  }
  
  // MARK: - Audio Configuration
  
  enum Audio {
    static let sampleRate: Double = 44100.0
    static let channels = 1
    static let bitDepth = 16
  }
  
  // MARK: - Practice Configuration
  
  enum Practice {
    static let flashcardSessionSize = 10
    static let quizQuestionCount = 10
    static let timeAttackDuration: TimeInterval = 60
    static let dailyGoalMinutes = 30
    static let streakReminderTime = "20:00"
  }
  
  // MARK: - Network Configuration
  
  enum Network {
    static let timeoutInterval: TimeInterval = 30
    static let retryCount = 3
    static let retryDelay: TimeInterval = 1
  }
  
  // MARK: - Validation
  
  static func validate() throws {
    guard !bundleIdentifier.isEmpty else {
      throw ConfigurationError.missingBundleIdentifier
    }
    
    guard !iCloudContainerIdentifier.isEmpty else {
      throw ConfigurationError.missingCloudKitContainer
    }
    
    #if DEBUG
    print("✅ App configuration validated")
    #endif
  }
}

// MARK: - Configuration Error

enum ConfigurationError: LocalizedError {
  case missingBundleIdentifier
  case missingCloudKitContainer
  case invalidConfiguration(String)
  
  var errorDescription: String? {
    switch self {
    case .missingBundleIdentifier:
      return "Bundle identifier is missing"
    case .missingCloudKitContainer:
      return "iCloud container identifier is missing"
    case .invalidConfiguration(let message):
      return "Invalid configuration: \(message)"
    }
  }
}

// MARK: - User Defaults Keys

extension UserDefaults {
  enum Keys {
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let currentLevel = "currentLevel"
    static let selectedLanguage = "selectedLanguage"
    static let dailyGoal = "dailyGoal"
    static let studyStreak = "studyStreak"
    static let lastStudyDate = "lastStudyDate"
    static let totalStudyTime = "totalStudyTime"
    static let offlineMode = "offlineMode"
    static let audioEnabled = "audioEnabled"
    static let romanizationEnabled = "romanizationEnabled"
    static let notificationsEnabled = "notificationsEnabled"
  }
}

