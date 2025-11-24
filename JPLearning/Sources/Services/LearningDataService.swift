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
    @Published var kanji: [Kanji] = []
    @Published var practiceQuestions: [PracticeQuestion] = []
    @Published var exercises: [Exercise] = []
    @Published var games: [GameModel] = []
    @Published var readingPassages: [ReadingPassage] = []
    @Published var userProgress: UserProgress?
    
    @Published var isLoading = false
    
    nonisolated private init() {}
    
    // MARK: - Initialization
    
    func initialize() async {
        AppLogger.info("🚀 [INIT] Initializing LearningDataService")
        
        // Clear RemoteDataService cache to ensure fresh data
        AppLogger.info("🗑️ [INIT] Clearing RemoteDataService cache to prevent stale data")
        RemoteDataService.shared.clearCache()
        
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
        
        let level = currentLevel
        AppLogger.info("🔄 [DATA] Starting loadLearningData for level: \(level.rawValue)")
        
        let completedLessons = userProgress?.completedLessons ?? []
        let filename = "japanese_learning_data_\(level.rawValue.lowercased())_jisho"
        
        AppLogger.info("📁 [DATA] Looking for file: \(filename).json")
        
        // Perform IO and Parsing in background
        let result = await Task.detached(priority: .userInitiated) { () -> (Data?, Error?) in
            // 1. Try to load from Bundle
            if let url = Bundle.main.url(forResource: filename, withExtension: "json") {
                do {
                    let data = try Data(contentsOf: url)
                    AppLogger.info("✅ [DATA] Found file at: \(url.path)")
                    return (data, nil)
                } catch {
                    AppLogger.error("❌ [DATA] Failed to read file: \(error)")
                    return (nil, error)
                }
            } else {
                AppLogger.error("❌ [DATA] File not found in bundle: \(filename).json")
            }
            return (nil, nil) // Not found
        }.value
        
        do {
            if let data = result.0 {
                AppLogger.info("✅ Found bundled JSON for \(level.rawValue)")
                
                // Parse in background
                let parsed = try await Task.detached(priority: .userInitiated) {
                    return try JSONParserService.shared.parseAllData(data: data)
                }.value
                
                // Parse reading passages
                let readingPassages = try await Task.detached(priority: .userInitiated) {
                    return try JSONParserService.shared.parseReadingPassages(data: data)
                }.value
                
                // Generate derived data in background (light computation, but good practice)
                let derivedLessons = LearningDataService.generateLessons(
                    flashcards: parsed.flashcards,
                    grammar: parsed.grammar,
                    level: level,
                    completedLessons: completedLessons
                )
                let derivedExercises = LearningDataService.generateExercises(
                    practice: parsed.practice,
                    level: level
                )
                
                // Update UI on MainActor
                AppLogger.info("🔄 [DATA] Assigning parsed data to published properties...")
                AppLogger.info("   About to assign: Flashcards: \(parsed.flashcards.count), Kanji: \(parsed.kanji.count), Grammar: \(parsed.grammar.count)")
                
                self.flashcards = parsed.flashcards
                self.grammarPoints = parsed.grammar
                self.kanji = parsed.kanji
                self.games = parsed.games
                self.practiceQuestions = parsed.practice
                self.lessons = derivedLessons
                self.exercises = derivedExercises
                self.readingPassages = readingPassages
                
                AppLogger.info("✅ [DATA] Data assigned! Verifying...")
                AppLogger.info("   After assignment: Flashcards: \(self.flashcards.count), Kanji: \(self.kanji.count), Grammar: \(self.grammarPoints.count)")
                
                if level == .n4 {
                    AppLogger.info("🔴 [N4 DEBUG] N4 specific check:")
                    AppLogger.info("   Kanji count: \(self.kanji.count) (should be 10)")
                    AppLogger.info("   Grammar count: \(self.grammarPoints.count) (should be 21)")
                    AppLogger.info("   First flashcard: \(self.flashcards.first?.front ?? "NONE")")
                }
                
                AppLogger.info("📊 [DATA] Loaded data counts for level \(level.rawValue):")
                AppLogger.info("   - Lessons: \(self.lessons.count)")
                AppLogger.info("   - Flashcards: \(self.flashcards.count)")
                AppLogger.info("   - Grammar: \(self.grammarPoints.count)")
                AppLogger.info("   - Kanji: \(self.kanji.count)")
                AppLogger.info("   - Exercises: \(self.exercises.count)")
                AppLogger.info("   - Games: \(self.games.count)")
                AppLogger.info("   - Reading Passages: \(self.readingPassages.count)")
                
                // Log first 3 flashcards for verification
                if !self.flashcards.isEmpty {
                    AppLogger.info("📝 First 3 flashcards:")
                    for (index, card) in self.flashcards.prefix(3).enumerated() {
                        AppLogger.info("   \(index + 1). \(card.front) - \(card.meaning)")
                    }
                }
                
                // Log first 3 kanji for verification
                if !self.kanji.isEmpty {
                    AppLogger.info("📝 First 3 kanji for level \(level.rawValue):")
                    for (index, k) in self.kanji.prefix(3).enumerated() {
                        AppLogger.info("   \(index + 1). \(k.character) - \(k.meaning) (JLPT: \(k.jlptLevel))")
                    }
                } else {
                    AppLogger.error("⚠️ [DATA] No kanji loaded for level \(level.rawValue)!")
                }
                
            } else if let error = result.1 {
                throw error
            } else {
                AppLogger.error("❌ No data found for level \(level.rawValue)")
                // Clear data or show empty state
                self.flashcards = []
                self.grammarPoints = []
                self.kanji = []
                self.lessons = []
                self.exercises = []
                self.games = []
                self.practiceQuestions = []
            }
            
        } catch {
            AppLogger.error("❌ Failed to load learning data: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Data Access
    
    /// Load practice questions from loaded data for a specific category
    func loadPracticeQuestions(category: PracticeCategory, level: LearningLevel? = nil) async -> [PracticeQuestion] {
        // If level is different from current, we might need to load it. 
        // For now, assuming we mostly work with current level or we'd need to fetch via RemoteDataService.
        
        if let level = level, level != currentLevel {
            // Fetch from remote/cache
            do {
                let (_, _, questions) = try await RemoteDataService.shared.loadLearningData(for: level)
                return questions.filter { $0.category == category }
            } catch {
                return []
            }
        }
        
        return practiceQuestions.filter { $0.category == category }
    }

    // MARK: - Data Generation
    
    private static func generateLessons(flashcards: [Flashcard], grammar: [GrammarPoint], level: LearningLevel, completedLessons: [String]) -> [Lesson] {
        var generatedLessons: [Lesson] = []
        
        // 1. Vocabulary Lessons (group by 20 words)
        let vocabChunks = flashcards.chunked(into: 20)
        for (index, chunk) in vocabChunks.enumerated() {
            let lessonId = "vocab_\(level.rawValue)_\(index + 1)"
            let lesson = Lesson(
                id: lessonId,
                title: "Vocabulary Lesson \(index + 1)",
                description: "Learn \(chunk.count) new words including \(chunk.first?.front ?? "words")",
                level: level.rawValue,
                category: "vocabulary",
                points: 100,
                isCompleted: completedLessons.contains(lessonId),
                duration: 15,
                content: chunk.map { fc in
                    LessonContent(
                        type: .text,
                        title: fc.front,
                        text: "\(fc.reading ?? "")\n\(fc.meaning)",
                        audioURL: fc.audioURL,
                        imageURL: nil
                    )
                }
            )
            generatedLessons.append(lesson)
        }
        
        // 2. Grammar Lessons (group by 5 points)
        let grammarChunks = grammar.chunked(into: 5)
        for (index, chunk) in grammarChunks.enumerated() {
            let lessonId = "grammar_\(level.rawValue)_\(index + 1)"
            let lesson = Lesson(
                id: lessonId,
                title: "Grammar Lesson \(index + 1)",
                description: "Learn \(chunk.count) grammar points",
                level: level.rawValue,
                category: "grammar",
                points: 150,
                isCompleted: completedLessons.contains(lessonId),
                duration: 20,
                content: chunk.map { gp in
                    LessonContent(
                        type: .text,
                        title: gp.title,
                        text: "\(gp.meaning)\nUsage: \(gp.usage)",
                        audioURL: nil,
                        imageURL: nil
                    )
                }
            )
            generatedLessons.append(lesson)
        }
        
        return generatedLessons
    }
    
    private static func generateExercises(practice: [PracticeQuestion], level: LearningLevel) -> [Exercise] {
        var generatedExercises: [Exercise] = []
        
        // Group by category
        let byCategory = Dictionary(grouping: practice, by: { $0.category })
        
        for (category, questions) in byCategory {
            // Chunk questions into sets of 10 for exercises
            let questionChunks = questions.chunked(into: 10)
            
            for (index, chunk) in questionChunks.enumerated() {
                let exercise = Exercise(
                    id: "ex_\(level.rawValue)_\(category.rawValue)_\(index + 1)",
                    title: "\(category.rawValue) Practice \(index + 1)",
                    type: .multipleChoice, // Default to multiple choice for now
                    category: category.rawValue.lowercased(),
                    level: level.rawValue,
                    questions: chunk,
                    points: 10 * chunk.count,
                    duration: chunk.count // 1 minute per question approx
                )
                generatedExercises.append(exercise)
            }
        }
        
        return generatedExercises
    }
    
    // MARK: - User Action Methods
    
    func setLevel(_ level: LearningLevel) async {
        AppLogger.info("🔄 [SET LEVEL] Changing from \(currentLevel.rawValue) to \(level.rawValue)")
        
        // Clear cache before switching to ensure fresh data
        AppLogger.info("🗑️ [SET LEVEL] Clearing cache for fresh \(level.rawValue) data")
        RemoteDataService.shared.clearCache()
        
        currentLevel = level
        
        // Persist to UserDefaults so the app can restore on next launch
        UserDefaults.standard.set(level.rawValue, forKey: UserDefaults.Keys.currentLevel)
        
        AppLogger.info("📥 [SET LEVEL] Loading data for \(level.rawValue)...")
        await loadLearningData()
        AppLogger.info("✅ [SET LEVEL] Finished loading \(level.rawValue) - Flashcards: \(flashcards.count), Kanji: \(kanji.count), Grammar: \(grammarPoints.count)")
        
        // Update user preferences locally
        if let user = AuthService.shared.currentUser {
            var updatedPreferences = user.preferences
            updatedPreferences?.currentLevel = level.rawValue
            try? await AuthService.shared.updateProfile(preferences: updatedPreferences)
        }
        
        // Update analytics
        AnalyticsService.shared.setUserLevel(level)
        AnalyticsService.shared.logEvent(.levelChanged, parameters: [
            "level": level.rawValue
        ])
    }
    
    func updateFlashcard(_ flashcard: Flashcard) async throws {
        // Update local array
        if let index = flashcards.firstIndex(where: { $0.id == flashcard.id }) {
            flashcards[index] = flashcard
        }
        
        // Save to local storage for current level
        saveFlashcardsToLocal()
        
        // Also persist user-generated/updated flashcards to JSON store
        if flashcard.reviewCount > 0 || flashcard.correctCount > 0 || flashcard.nextReview != nil {
            UserFlashcardStore.shared.append([flashcard])
        }
    }
    
    private func saveFlashcardsToLocal() {
        if let data = try? JSONEncoder().encode(flashcards) {
            UserDefaults.standard.set(data, forKey: "flashcards_\(currentLevel.rawValue)")
        }
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
                progress.streak += 1
            } else if daysDifference > 1 {
                progress.streak = 1
            }
        } else {
            progress.streak = 1
        }
        
        progress.lastStudyDate = Date()
        
        if let lesson = completedLesson,
           !progress.completedLessons.contains(lesson) {
            progress.completedLessons.append(lesson)
        }
        
        // Save to local storage
        if let data = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(data, forKey: "progress_\(userId)")
        }
        
        userProgress = progress
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

// MARK: - Array Extension for Chunking
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
