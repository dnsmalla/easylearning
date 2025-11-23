//
//  AchievementService.swift
//  JLearn
//
//  Daily streak and achievements tracking
//

import Foundation
import Combine
import SwiftUI

class AchievementService: ObservableObject {
    static let shared = AchievementService()
    
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var lastStudyDate: Date?
    @Published var unlockedAchievements: Set<String> = []
    @Published var totalStudyMinutes: Int = 0
    
    private let streakKey = "daily_streak"
    private let longestStreakKey = "longest_streak"
    private let lastStudyKey = "last_study_date"
    private let achievementsKey = "unlocked_achievements"
    private let studyTimeKey = "total_study_minutes"
    
    private init() {
        loadProgress()
    }
    
    // MARK: - Streak Management
    
    func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastDate = lastStudyDate {
            let lastStudyDay = calendar.startOfDay(for: lastDate)
            let daysDiff = calendar.dateComponents([.day], from: lastStudyDay, to: today).day ?? 0
            
            if daysDiff == 0 {
                // Already studied today
                return
            } else if daysDiff == 1 {
                // Consecutive day - increment streak
                currentStreak += 1
            } else {
                // Streak broken - reset
                currentStreak = 1
            }
        } else {
            // First time
            currentStreak = 1
        }
        
        lastStudyDate = Date()
        
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
        
        saveProgress()
        checkAchievements()
    }
    
    // MARK: - Study Time Tracking
    
    func addStudyTime(minutes: Int) {
        totalStudyMinutes += minutes
        saveProgress()
        checkAchievements()
    }
    
    // MARK: - Achievements
    
    func unlockAchievement(_ achievementId: String) {
        guard !unlockedAchievements.contains(achievementId) else { return }
        
        unlockedAchievements.insert(achievementId)
        saveProgress()
        
        // Haptic feedback
        Haptics.notification(.success)
    }
    
    private func checkAchievements() {
        // Streak achievements
        if currentStreak >= 7 {
            unlockAchievement("week_streak")
        }
        if currentStreak >= 30 {
            unlockAchievement("month_streak")
        }
        if currentStreak >= 100 {
            unlockAchievement("century_streak")
        }
        
        // Study time achievements
        if totalStudyMinutes >= 60 {
            unlockAchievement("1hour_study")
        }
        if totalStudyMinutes >= 600 {
            unlockAchievement("10hour_study")
        }
        if totalStudyMinutes >= 6000 {
            unlockAchievement("100hour_study")
        }
    }
    
    func getAvailableAchievements() -> [Achievement] {
        // Use achievements from GamificationModels and update unlock status
        return Achievement.allAchievements.map { achievement in
            var updated = achievement
            updated.isUnlocked = unlockedAchievements.contains(achievement.id)
            return updated
        }
    }
    
    // MARK: - Persistence
    
    private func loadProgress() {
        currentStreak = UserDefaults.standard.integer(forKey: streakKey)
        longestStreak = UserDefaults.standard.integer(forKey: longestStreakKey)
        totalStudyMinutes = UserDefaults.standard.integer(forKey: studyTimeKey)
        
        if let dateData = UserDefaults.standard.object(forKey: lastStudyKey) as? Date {
            lastStudyDate = dateData
        }
        
        if let achievementsArray = UserDefaults.standard.array(forKey: achievementsKey) as? [String] {
            unlockedAchievements = Set(achievementsArray)
        }
    }
    
    private func saveProgress() {
        UserDefaults.standard.set(currentStreak, forKey: streakKey)
        UserDefaults.standard.set(longestStreak, forKey: longestStreakKey)
        UserDefaults.standard.set(totalStudyMinutes, forKey: studyTimeKey)
        UserDefaults.standard.set(lastStudyDate, forKey: lastStudyKey)
        UserDefaults.standard.set(Array(unlockedAchievements), forKey: achievementsKey)
    }
    
    // MARK: - Stats
    
    func getWeeklyActivity() -> [Int] {
        // Returns study activity for the last 7 days
        // For now, returning dummy data - can be enhanced with real tracking
        return (0..<7).map { _ in Int.random(in: 0...60) }
    }
}

// Note: Achievement struct is defined in GamificationModels.swift
