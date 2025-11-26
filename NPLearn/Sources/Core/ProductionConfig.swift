//
//  ProductionConfig.swift
//  NPLearn
//
//  Production environment configuration
//

import Foundation

enum ProductionConfig {
  // API Endpoints
  static let apiBaseURL = "https://api.nplearn.com"
  static let translationServiceURL = "https://translate.nplearn.com"
  
  // Firebase
  static let firebaseProjectId = "nplearn-app"
  
  // App Store
  static let appStoreId = "YOUR_APP_ID"
  static let supportEmail = "support@nplearn.com"
  static let websiteURL = "https://www.nplearn.com"
  
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

