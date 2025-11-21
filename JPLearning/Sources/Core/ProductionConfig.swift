//
//  ProductionConfig.swift
//  JLearn
//
//  Production environment configuration
//

import Foundation

enum ProductionConfig {
  // API Endpoints (update these with your actual endpoints)
  static let apiBaseURL = "https://api.jlearn.app"
  static let translationServiceURL = "https://translate.jlearn.app"
  
  // Firebase
  static let firebaseProjectId = "jlearn-app"
  
  // App Store
  static let appStoreId = "YOUR_APP_ID"
  static let supportEmail = "support@jlearn.app"
  static let websiteURL = "https://www.jlearn.app"
  
  // Analytics
  static let enableAnalytics = true
  static let enableCrashReporting = true
  
  // Limits
  static let maxFlashcardsPerSession = 20
  static let maxDailyPracticeTime = 120 // minutes
  static let maxCacheSize = 100 // MB
  
  // Subscription
  static let enablePremiumFeatures = false
  static let premiumTrialDays = 7
}

