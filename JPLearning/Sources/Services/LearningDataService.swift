//
//  LearningDataService.swift
//  JLearn
//
//  Service for managing learning data (JSON + Local Storage Only)
//

import Foundation
import Combine

// MARK: - Learning Data Service

@MainActor
final class LearningDataService: ObservableObject {
    
    static let shared = LearningDataService()
    
    @Published var currentLevel: LearningLevel = .n5
    @Published var lessons: [Lesson] = []
    @Published var flashcards: [Flashcard] = []
    @Published var grammarPoints: [GrammarPoint] = []
    @Published var exercises: [Exercise] = []
    @Published var userProgress: UserProgress?
    
    @Published var isLoading = false
    
    nonisolated private init() {}
    
    // MARK: - Initialization
    
    func initialize() async {
        // Restore previously selected level from user preferences or UserDefaults
        if let preferred = AuthService.shared.currentUser?.preferences?.currentLevel,
           let preferredLevel = LearningLevel(rawValue: preferred) {
            currentLevel = preferredLevel
        } else if let storedLevel = UserDefaults.standard.string(forKey: UserDefaults.Keys.currentLevel),
                  let level = LearningLevel(rawValue: storedLevel) {
            currentLevel = level
        }
        
        await loadUserProgress()
        await loadLearningData()
    }
    
    // MARK: - Load Data
    
    func loadLearningData() async {
        isLoading = true
        
        // Load from JSON and sample data
        async let lessonsTask = loadLessons(for: currentLevel)
        async let flashcardsTask = loadFlashcardsFromJSON(for: currentLevel)
        async let grammarTask = loadGrammarFromJSON(for: currentLevel)
        async let exercisesTask = loadExercises(for: currentLevel)
        
        let (lessons, flashcards, grammar, exercises) = await (lessonsTask, flashcardsTask, grammarTask, exercisesTask)
        
        self.lessons = lessons
        self.flashcards = flashcards
        self.grammarPoints = grammar
        self.exercises = exercises
        
        isLoading = false
    }
    
    // MARK: - JSON Loading
    
    private func loadFlashcardsFromJSON(for level: LearningLevel) async -> [Flashcard] {
        // Try loading from remote (GitHub) with smart caching
        do {
            let (jsonFlashcards, _, _) = try await RemoteDataService.shared.loadLearningData(for: level)
            let baseFlashcards = jsonFlashcards.filter { $0.level == level.rawValue }
            
            // Merge in user-generated flashcards from JSON store
            let userFlashcards = UserFlashcardStore.shared.load()
                .filter { $0.level == level.rawValue }
            
            // Avoid duplicates when merging
            let baseKeys = Set(baseFlashcards.map { "\($0.front)|\($0.reading ?? "")" })
            let uniqueUserFlashcards = userFlashcards.filter {
                !baseKeys.contains("\($0.front)|\($0.reading ?? "")")
            }
            
            let merged = baseFlashcards + uniqueUserFlashcards
            
            if !merged.isEmpty {
                AppLogger.info("Loaded \(merged.count) flashcards for level \(level.rawValue) (base: \(baseFlashcards.count), user: \(uniqueUserFlashcards.count))")
                return merged
            }
        } catch {
            AppLogger.error("Remote data loading failed: \(error)")
        }
        
        // Fallback to sample data
        AppLogger.info("Using sample flashcard data for demonstration")
        return SampleDataService.shared.getSampleFlashcards(level: level.rawValue)
    }
    
    private func loadGrammarFromJSON(for level: LearningLevel) async -> [GrammarPoint] {
        // Try loading from remote (GitHub) with smart caching
        do {
            let (_, jsonGrammar, _) = try await RemoteDataService.shared.loadLearningData(for: level)
            let baseGrammar = jsonGrammar.filter { $0.level == level.rawValue }
            
            // Merge in user-generated grammar from JSON store
            let userGrammar = UserGrammarStore.shared.load()
                .filter { $0.level == level.rawValue }
            
            let baseKeys = Set(baseGrammar.map { "\($0.title)|\($0.pattern)|\($0.level)" })
            let uniqueUser = userGrammar.filter {
                !baseKeys.contains("\($0.title)|\($0.pattern)|\($0.level)")
            }
            
            let merged = baseGrammar + uniqueUser
            if !merged.isEmpty {
                AppLogger.info("Loaded \(merged.count) grammar points for level \(level.rawValue) (base: \(baseGrammar.count), user: \(uniqueUser.count))")
                return merged
            }
        } catch {
            AppLogger.error("Remote data loading for grammar failed: \(error)")
        }
        
        // Fallback to sample data
        AppLogger.info("Using sample grammar data for demonstration")
        return SampleDataService.shared.getSampleGrammarPoints(level: level.rawValue)
    }
    
    /// Load practice questions from JSON for a specific category
    func loadPracticeQuestions(category: PracticeCategory, level: LearningLevel? = nil) async -> [PracticeQuestion] {
        let selectedLevel = level ?? currentLevel
        
        do {
            let (_, _, jsonPractice) = try await RemoteDataService.shared.loadLearningData(for: selectedLevel)
            let baseQuestions = jsonPractice.filter {
                $0.category == category && $0.level == selectedLevel.rawValue
            }
            
            let userQuestions = UserPracticeStore.shared.load().filter {
                $0.category == category && $0.level == selectedLevel.rawValue
            }
            
            let baseKeys = Set(baseQuestions.map { "\($0.question)|\($0.category.rawValue)|\($0.level)" })
            let uniqueUser = userQuestions.filter {
                !baseKeys.contains("\($0.question)|\($0.category.rawValue)|\($0.level)")
            }
            
            let merged = baseQuestions + uniqueUser
            if !merged.isEmpty {
                AppLogger.info("Loaded \(merged.count) \(category.rawValue) questions for level \(selectedLevel.rawValue) (base: \(baseQuestions.count), user: \(uniqueUser.count))")
                return merged
            }
        } catch {
            AppLogger.error("Failed to load \(category.rawValue) questions from remote: \(error)")
        }
        
        // Fallback to sample data
        AppLogger.info("Using sample \(category.rawValue) questions for demonstration")
        return SampleDataService.shared.getSamplePracticeQuestions(category: category, level: selectedLevel.rawValue)
    }
    
    func setLevel(_ level: LearningLevel) async {
        currentLevel = level
        
        // Persist to UserDefaults so the app can restore on next launch
        UserDefaults.standard.set(level.rawValue, forKey: UserDefaults.Keys.currentLevel)
        
        await loadLearningData()
        
        // Update user preferences locally
        if let user = AuthService.shared.currentUser {
            var updatedPreferences = user.preferences
            updatedPreferences?.currentLevel = level.rawValue
            try? await AuthService.shared.updateProfile(preferences: updatedPreferences)
        }
        
        // Update analytics user properties and emit a level-changed event
        AnalyticsService.shared.setUserLevel(level)
        AnalyticsService.shared.logEvent(.levelChanged, parameters: [
            "level": level.rawValue
        ])
    }
    
    // MARK: - Lessons
    
    private func loadLessons(for level: LearningLevel) async -> [Lesson] {
        // Use sample data
        print("ℹ️ Using sample lesson data for demonstration")
        return SampleDataService.shared.getSampleLessons(level: level.rawValue)
    }
    
    // MARK: - Flashcards
    
    func updateFlashcard(_ flashcard: Flashcard) async throws {
        // Update local array
        if let index = flashcards.firstIndex(where: { $0.id == flashcard.id }) {
            flashcards[index] = flashcard
        }
        
        // Save to local storage for current level
        saveFlashcardsToLocal()
        
        // Also persist user-generated flashcards to JSON store when relevant.
        // We treat any flashcard without scheduling data as base content,
        // and any card with review metadata as user-progress data.
        if flashcard.reviewCount > 0 || flashcard.correctCount > 0 || flashcard.nextReview != nil {
            UserFlashcardStore.shared.append([flashcard])
        }
    }
    
    private func saveFlashcardsToLocal() {
        if let data = try? JSONEncoder().encode(flashcards) {
            UserDefaults.standard.set(data, forKey: "flashcards_\(currentLevel.rawValue)")
        }
    }
    
    // MARK: - Exercises
    
    private func loadExercises(for level: LearningLevel) async -> [Exercise] {
        // Use sample data
        print("ℹ️ Using sample exercise data for demonstration")
        return SampleDataService.shared.getSampleExercises(level: level.rawValue)
    }
    
    // MARK: - User Progress (Local Storage)
    
    private func loadUserProgress() async {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        
        if let data = UserDefaults.standard.data(forKey: "progress_\(userId)"),
           let progress = try? JSONDecoder().decode(UserProgress.self, from: data) {
            userProgress = progress
        } else {
            userProgress = UserProgress()
        }
    }
    
    func updateProgress(points: Int = 0, completedLesson: String? = nil) async throws {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        
        var progress = userProgress ?? UserProgress()
        
        // Update points
        progress.totalPoints += points
        
        // Update streak
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastStudy = progress.lastStudyDate {
            let lastStudyDay = calendar.startOfDay(for: lastStudy)
            let daysDifference = calendar.dateComponents([.day], from: lastStudyDay, to: today).day ?? 0
            
            if daysDifference == 1 {
                // Consecutive day
                progress.streak += 1
            } else if daysDifference > 1 {
                // Streak broken
                progress.streak = 1
            }
            // If same day, don't change streak
        } else {
            // First time studying
            progress.streak = 1
        }
        
        progress.lastStudyDate = Date()
        
        // Add completed lesson
        if let lesson = completedLesson,
           !progress.completedLessons.contains(lesson) {
            progress.completedLessons.append(lesson)
        }
        
        // Save to local storage
        if let data = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(data, forKey: "progress_\(userId)")
        }
        
        userProgress = progress
        
        // Also update user model
        try? await AuthService.shared.updateProfile(progress: progress)
    }
    
    // MARK: - Saved Items (Local Storage)
    
    func saveKanji(_ kanjiId: String) async throws {
        guard let user = AuthService.shared.currentUser else { return }
        
        var savedKanji = user.savedKanji ?? []
        if !savedKanji.contains(kanjiId) {
            savedKanji.append(kanjiId)
            try await AuthService.shared.updateProfile(savedKanji: savedKanji)
        }
    }
    
    func unsaveKanji(_ kanjiId: String) async throws {
        guard let user = AuthService.shared.currentUser else { return }
        
        var savedKanji = user.savedKanji ?? []
        savedKanji.removeAll { $0 == kanjiId }
        try await AuthService.shared.updateProfile(savedKanji: savedKanji)
    }
    
    func saveVocabulary(_ vocabId: String) async throws {
        guard let user = AuthService.shared.currentUser else { return }
        
        var savedVocabulary = user.savedVocabulary ?? []
        if !savedVocabulary.contains(vocabId) {
            savedVocabulary.append(vocabId)
            try await AuthService.shared.updateProfile(savedVocabulary: savedVocabulary)
        }
    }
    
    func unsaveVocabulary(_ vocabId: String) async throws {
        guard let user = AuthService.shared.currentUser else { return }
        
        var savedVocabulary = user.savedVocabulary ?? []
        savedVocabulary.removeAll { $0 == vocabId }
        try await AuthService.shared.updateProfile(savedVocabulary: savedVocabulary)
    }
}
