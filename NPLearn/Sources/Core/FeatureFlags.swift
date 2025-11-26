//
//  FeatureFlags.swift
//  NPLearn
//
//  Feature flags for controlling app features
//

import Foundation

enum FeatureFlags {
  // Authentication
  static let enableAppleSignIn = true
  static let enableGoogleSignIn = false
  static let enableEmailSignIn = true
  
  // Learning Features
  static let enableOfflineMode = true
  static let enableSpeechRecognition = true
  static let enableTextToSpeech = true
  static let enableFlashcards = true
  static let enableGames = true
  static let enableProgressTracking = true
  
  // Advanced Features
  static let enableWebSearch = true
  static let enableImageOCR = false
  static let enableSocialFeatures = false
  static let enableAchievements = true
  static let enableLeaderboards = false
  
  // Debug Features
  static let enableDebugLogging = true
  static let enablePerformanceMonitoring = true
  static let showDeveloperMenu = false
}

