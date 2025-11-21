//
//  GamificationModels.swift
//  JLearn
//
//  Gamification system for engaging learning experience
//  Includes badges, achievements, rewards, and streaks
//

import SwiftUI
import Foundation

// MARK: - Achievement System

struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let requirement: Int
    let rewardStars: Int
    let rewardCoins: Int
    var isUnlocked: Bool
    var progress: Int
    var unlockedDate: Date?
    
    var progressPercentage: Double {
        Double(progress) / Double(requirement)
    }
    
    static let allAchievements: [Achievement] = [
        // Beginner Achievements
        Achievement(id: "first_lesson", title: "こんにちは!", description: "Complete your first lesson", icon: "star.fill", requirement: 1, rewardStars: 5, rewardCoins: 10, isUnlocked: false, progress: 0),
        Achievement(id: "five_lessons", title: "Getting Started", description: "Complete 5 lessons", icon: "book.fill", requirement: 5, rewardStars: 10, rewardCoins: 25, isUnlocked: false, progress: 0),
        Achievement(id: "first_streak", title: "Consistent Learner", description: "Maintain a 3-day streak", icon: "flame.fill", requirement: 3, rewardStars: 15, rewardCoins: 30, isUnlocked: false, progress: 0),
        
        // Intermediate Achievements
        Achievement(id: "week_streak", title: "Week Warrior", description: "Study for 7 days straight", icon: "calendar", requirement: 7, rewardStars: 25, rewardCoins: 50, isUnlocked: false, progress: 0),
        Achievement(id: "twenty_lessons", title: "Dedicated Student", description: "Complete 20 lessons", icon: "graduationcap.fill", requirement: 20, rewardStars: 30, rewardCoins: 75, isUnlocked: false, progress: 0),
        Achievement(id: "perfect_score", title: "Perfect!", description: "Get 100% on any quiz", icon: "checkmark.seal.fill", requirement: 1, rewardStars: 20, rewardCoins: 40, isUnlocked: false, progress: 0),
        
        // Advanced Achievements
        Achievement(id: "month_streak", title: "Month Master", description: "Study for 30 days straight", icon: "trophy.fill", requirement: 30, rewardStars: 50, rewardCoins: 100, isUnlocked: false, progress: 0),
        Achievement(id: "fifty_lessons", title: "Scholar", description: "Complete 50 lessons", icon: "medal.fill", requirement: 50, rewardStars: 75, rewardCoins: 150, isUnlocked: false, progress: 0),
        Achievement(id: "vocabulary_master", title: "Word Wizard", description: "Learn 100 vocabulary words", icon: "textformat.abc", requirement: 100, rewardStars: 40, rewardCoins: 80, isUnlocked: false, progress: 0),
        
        // Expert Achievements
        Achievement(id: "hundred_lessons", title: "Legend", description: "Complete 100 lessons", icon: "crown.fill", requirement: 100, rewardStars: 100, rewardCoins: 200, isUnlocked: false, progress: 0),
        Achievement(id: "all_categories", title: "Well Rounded", description: "Practice all 6 categories", icon: "hexagon.fill", requirement: 6, rewardStars: 30, rewardCoins: 60, isUnlocked: false, progress: 0),
        Achievement(id: "speed_demon", title: "Quick Learner", description: "Complete 5 lessons in one day", icon: "bolt.fill", requirement: 5, rewardStars: 35, rewardCoins: 70, isUnlocked: false, progress: 0)
    ]
}

// MARK: - Badge System

struct Badge: Identifiable, Codable {
    let id: String
    let name: String
    let icon: String
    let color: String // Color name as string
    let description: String
    var isEarned: Bool
    var earnedDate: Date?
    
    var badgeColor: Color {
        switch color {
        case "gold": return AppTheme.brandPrimary
        case "silver": return Color(red: 0.75, green: 0.75, blue: 0.75)
        case "bronze": return Color(red: 0.80, green: 0.50, blue: 0.20)
        case "blue": return AppTheme.brandSecondary
        case "green": return AppTheme.success
        case "purple": return AppTheme.brandPurple
        default: return AppTheme.brandPrimary
        }
    }
    
    static let allBadges: [Badge] = [
        Badge(id: "beginner", name: "Beginner", icon: "leaf.fill", color: "green", description: "Started learning Japanese", isEarned: false),
        Badge(id: "intermediate", name: "Intermediate", icon: "sparkles", color: "blue", description: "Reached intermediate level", isEarned: false),
        Badge(id: "advanced", name: "Advanced", icon: "star.circle.fill", color: "purple", description: "Reached advanced level", isEarned: false),
        Badge(id: "streak_master", name: "Streak Master", icon: "flame.circle.fill", color: "gold", description: "30-day streak achieved", isEarned: false),
        Badge(id: "vocabulary_king", name: "Vocabulary King", icon: "book.circle.fill", color: "gold", description: "Mastered 500 words", isEarned: false),
        Badge(id: "grammar_guru", name: "Grammar Guru", icon: "text.book.closed.fill", color: "silver", description: "Completed all grammar lessons", isEarned: false),
        Badge(id: "perfect_student", name: "Perfect Student", icon: "checkmark.circle.fill", color: "gold", description: "10 perfect scores", isEarned: false),
        Badge(id: "dedicated_learner", name: "Dedicated Learner", icon: "clock.fill", color: "bronze", description: "100 hours of practice", isEarned: false)
    ]
}

// MARK: - Reward System

struct Reward: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let cost: Int // In coins
    var isPurchased: Bool
    let category: RewardCategory
    
    enum RewardCategory: String, Codable {
        case theme
        case avatar
        case soundPack
        case specialEffect
    }
    
    static let availableRewards: [Reward] = [
        // Themes
        Reward(id: "theme_mountain", name: "Mountain Theme", description: "Himalayan-inspired colors", icon: "mountain.2.fill", cost: 50, isPurchased: false, category: .theme),
        Reward(id: "theme_festival", name: "Festival Theme", description: "Colorful festival theme", icon: "sparkles", cost: 75, isPurchased: false, category: .theme),
        
        // Avatars
        Reward(id: "avatar_yeti", name: "Yeti Avatar", description: "Friendly Himalayan yeti", icon: "figure.wave", cost: 100, isPurchased: false, category: .avatar),
        Reward(id: "avatar_panda", name: "Red Panda", description: "Cute red panda", icon: "pawprint.fill", cost: 100, isPurchased: false, category: .avatar),
        
        // Sound Packs
        Reward(id: "sound_traditional", name: "Traditional Sounds", description: "Traditional Japanese instruments", icon: "speaker.wave.3.fill", cost: 150, isPurchased: false, category: .soundPack),
        
        // Special Effects
        Reward(id: "effect_confetti", name: "Confetti Effect", description: "Extra celebration", icon: "party.popper.fill", cost: 50, isPurchased: false, category: .specialEffect),
        Reward(id: "effect_fireworks", name: "Fireworks", description: "Spectacular success", icon: "sparkles", cost: 100, isPurchased: false, category: .specialEffect)
    ]
}

// MARK: - Daily Challenge

struct DailyChallenge: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let goal: Int
    var progress: Int
    let rewardStars: Int
    let rewardCoins: Int
    var isCompleted: Bool
    let date: Date
    
    var progressPercentage: Double {
        Double(progress) / Double(goal)
    }
    
    static func todaysChallenges() -> [DailyChallenge] {
        let today = Date()
        return [
            DailyChallenge(
                id: "daily_practice",
                title: "Daily Practice",
                description: "Complete 3 lessons today",
                icon: "book.fill",
                goal: 3,
                progress: 0,
                rewardStars: 10,
                rewardCoins: 20,
                isCompleted: false,
                date: today
            ),
            DailyChallenge(
                id: "vocabulary_practice",
                title: "Word Master",
                description: "Learn 10 new words",
                icon: "textformat.abc",
                goal: 10,
                progress: 0,
                rewardStars: 8,
                rewardCoins: 15,
                isCompleted: false,
                date: today
            ),
            DailyChallenge(
                id: "perfect_score",
                title: "Accuracy Challenge",
                description: "Get 90% or higher on any quiz",
                icon: "target",
                goal: 1,
                progress: 0,
                rewardStars: 15,
                rewardCoins: 25,
                isCompleted: false,
                date: today
            )
        ]
    }
}

// MARK: - Quest System

struct Quest: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let steps: [QuestStep]
    var currentStep: Int
    let rewardStars: Int
    let rewardCoins: Int
    var isCompleted: Bool
    
    var progress: Double {
        Double(currentStep) / Double(steps.count)
    }
}

struct QuestStep: Identifiable, Codable {
    let id: String
    let description: String
    var isCompleted: Bool
}

// MARK: - User Statistics

struct UserStatistics: Codable {
    var totalStars: Int = 0
    var totalCoins: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var totalLessonsCompleted: Int = 0
    var totalWordsLearned: Int = 0
    var totalTimeSpent: TimeInterval = 0
    var perfectScores: Int = 0
    var lastStudyDate: Date?
    var achievements: [Achievement] = Achievement.allAchievements
    var badges: [Badge] = Badge.allBadges
    var dailyChallenges: [DailyChallenge] = DailyChallenge.todaysChallenges()
    
    mutating func updateStreak() {
        guard let lastDate = lastStudyDate else {
            currentStreak = 1
            lastStudyDate = Date()
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastStudy = calendar.startOfDay(for: lastDate)
        
        let daysDifference = calendar.dateComponents([.day], from: lastStudy, to: today).day ?? 0
        
        if daysDifference == 0 {
            // Same day, don't update
            return
        } else if daysDifference == 1 {
            // Next day, increment streak
            currentStreak += 1
            if currentStreak > longestStreak {
                longestStreak = currentStreak
            }
        } else {
            // Streak broken
            currentStreak = 1
        }
        
        lastStudyDate = Date()
    }
    
    mutating func addStars(_ amount: Int) {
        totalStars += amount
    }
    
    mutating func addCoins(_ amount: Int) {
        totalCoins += amount
    }
    
    mutating func spendCoins(_ amount: Int) -> Bool {
        guard totalCoins >= amount else { return false }
        totalCoins -= amount
        return true
    }
    
    mutating func completeLesson() {
        totalLessonsCompleted += 1
        updateStreak()
    }
}

// MARK: - Mascot Character

enum MascotMood: String, Codable {
    case happy = "😊"
    case excited = "🤩"
    case proud = "🥳"
    case encouraging = "💪"
    case thinking = "🤔"
    case celebrating = "🎉"
}

struct Mascot {
    let name: String = "Namaste"
    var mood: MascotMood = .happy
    
    func getMessage(for situation: MascotSituation) -> String {
        switch situation {
        case .welcome:
            return "こんにちは! Ready to learn today?"
        case .lessonStart:
            return "Let's learn something new!"
        case .correctAnswer:
            return ["Great job! 🎉", "Excellent! 👏", "Perfect! ⭐", "Amazing! 🌟"].randomElement()!
        case .wrongAnswer:
            return ["Keep trying! 💪", "Almost there!", "You can do it! 🎯"].randomElement()!
        case .lessonComplete:
            return "Wonderful! You completed the lesson! 🎊"
        case .streakMilestone(let days):
            return "🔥 Amazing! \(days)-day streak! Keep it up!"
        case .achievementUnlocked:
            return "🏆 New achievement unlocked! You're awesome!"
        case .encouragement:
            return ["You're doing great!", "Keep up the good work!", "I believe in you! 💖"].randomElement()!
        }
    }
    
    enum MascotSituation {
        case welcome
        case lessonStart
        case correctAnswer
        case wrongAnswer
        case lessonComplete
        case streakMilestone(Int)
        case achievementUnlocked
        case encouragement
    }
}

// MARK: - Learning Story

struct LearningStory: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let difficulty: LearningLevel
    let chapters: [StoryChapter]
    var currentChapter: Int
    var isCompleted: Bool
    
    var progress: Double {
        Double(currentChapter) / Double(chapters.count)
    }
}

struct StoryChapter: Identifiable, Codable {
    let id: String
    let title: String
    let content: String
    let dialogue: [DialogueLine]
    let questions: [PracticeQuestion]
    var isCompleted: Bool
}

struct DialogueLine: Identifiable, Codable {
    let id: String
    let character: String
    let japanese: String  // Japanese text (fixed from incorrect 'nepali' field)
    let romanization: String
    let english: String
}

// MARK: - Mini Game Types

enum MiniGameType: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    
    case dragAndDrop = "Drag & Drop"
    case matching = "Word Match"
    case wordBuilder = "Word Builder"
    case memoryCards = "Memory Game"
    case listening = "Listen & Choose"
    case speaking = "Pronunciation"
    
    var icon: String {
        switch self {
        case .dragAndDrop: return "move.3d"
        case .matching: return "link"
        case .wordBuilder: return "character.textbox"
        case .memoryCards: return "square.on.square"
        case .listening: return "ear.fill"
        case .speaking: return "mic.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .dragAndDrop: return AppTheme.vocabularyColor
        case .matching: return AppTheme.grammarColor
        case .wordBuilder: return AppTheme.writingColor
        case .memoryCards: return AppTheme.listeningColor
        case .listening: return AppTheme.speakingColor
        case .speaking: return AppTheme.brandSecondary
        }
    }
}

// MARK: - XP Level System

struct XPLevel: Codable {
    var currentLevel: Int
    var currentXP: Int
    var totalXP: Int
    
    init(currentLevel: Int = 1, currentXP: Int = 0, totalXP: Int = 0) {
        self.currentLevel = currentLevel
        self.currentXP = currentXP
        self.totalXP = totalXP
    }
    
    var xpForNextLevel: Int {
        XPLevelSystem.xpRequired(for: currentLevel + 1)
    }
    
    var xpForCurrentLevel: Int {
        XPLevelSystem.xpRequired(for: currentLevel)
    }
    
    var progressToNextLevel: Double {
        let xpInCurrentLevel = currentXP - xpForCurrentLevel
        let xpNeededForLevel = xpForNextLevel - xpForCurrentLevel
        return Double(xpInCurrentLevel) / Double(xpNeededForLevel)
    }
    
    var levelTitle: String {
        XPLevelSystem.levelTitle(for: currentLevel)
    }
    
    var levelBadgeIcon: String {
        XPLevelSystem.levelBadgeIcon(for: currentLevel)
    }
    
    var levelColor: Color {
        XPLevelSystem.levelColor(for: currentLevel)
    }
    
    mutating func addXP(_ amount: Int) -> Bool {
        currentXP += amount
        totalXP += amount
        
        // Check if leveled up
        if currentXP >= xpForNextLevel {
            currentLevel += 1
            return true // Leveled up
        }
        
        return false // No level up
    }
}

// MARK: - XP Level System Logic

struct XPLevelSystem {
    
    // XP required for each level (exponential growth)
    static func xpRequired(for level: Int) -> Int {
        if level <= 1 {
            return 0
        }
        
        // Formula: 100 * (level - 1)^1.5
        return Int(100 * pow(Double(level - 1), 1.5))
    }
    
    // XP rewards for different actions
    static let xpRewards: [XPAction: Int] = [
        .completedLesson: 20,
        .perfectScore: 30,
        .dailyGoalMet: 15,
        .streakMilestone: 25,
        .flashcardReviewed: 5,
        .grammarMastered: 15,
        .vocabMastered: 10,
        .practiceCompleted: 10,
        .achievementUnlocked: 50,
        .challengeCompleted: 40
    ]
    
    // Level titles
    static func levelTitle(for level: Int) -> String {
        switch level {
        case 1..<5:
            return "Beginner"
        case 5..<10:
            return "Learner"
        case 10..<20:
            return "Student"
        case 20..<30:
            return "Scholar"
        case 30..<40:
            return "Expert"
        case 40..<50:
            return "Master"
        case 50...:
            return "Legend"
        default:
            return "Beginner"
        }
    }
    
    // Level badge icons
    static func levelBadgeIcon(for level: Int) -> String {
        switch level {
        case 1..<5:
            return "leaf.fill"
        case 5..<10:
            return "book.fill"
        case 10..<20:
            return "graduationcap.fill"
        case 20..<30:
            return "medal.fill"
        case 30..<40:
            return "star.circle.fill"
        case 40..<50:
            return "trophy.fill"
        case 50...:
            return "crown.fill"
        default:
            return "leaf.fill"
        }
    }
    
    // Level colors
    static func levelColor(for level: Int) -> Color {
        switch level {
        case 1..<5:
            return .green
        case 5..<10:
            return .blue
        case 10..<20:
            return .purple
        case 20..<30:
            return .orange
        case 30..<40:
            return Color(red: 1.0, green: 0.84, blue: 0.0) // Gold
        case 40..<50:
            return Color(red: 0.85, green: 0.65, blue: 0.13) // Darker gold
        case 50...:
            return Color(red: 1.0, green: 0.5, blue: 0.0) // Legendary orange
        default:
            return .green
        }
    }
}

// MARK: - XP Actions Enum

enum XPAction {
    case completedLesson
    case perfectScore
    case dailyGoalMet
    case streakMilestone
    case flashcardReviewed
    case grammarMastered
    case vocabMastered
    case practiceCompleted
    case achievementUnlocked
    case challengeCompleted
}

// MARK: - Celebration Animation Type

enum CelebrationType {
    case stars
    case confetti
    case fireworks
    case balloons
    case sparkles
}

