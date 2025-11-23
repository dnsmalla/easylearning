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
        
        // FAILSAFE: If no data loaded, force reload
        if flashcards.isEmpty && kanji.isEmpty && grammarPoints.isEmpty {
            AppLogger.error("⚠️ [FAILSAFE] No data loaded! Forcing reload...")
            await forceReloadAllData()
        }
    }
    
    /// Emergency failsafe - force reload with all possible methods
    private func forceReloadAllData() async {
        AppLogger.info("🚨 [FAILSAFE] Attempting emergency data load...")
        
        let level = currentLevel
        let filename = "japanese_learning_data_\(level.rawValue.lowercased())_jisho"
        
        // Try multiple methods to find the file
        var data: Data?
        
        // Method 1: Bundle.main.url
        if let url = Bundle.main.url(forResource: filename, withExtension: "json") {
            data = try? Data(contentsOf: url)
            AppLogger.info("✅ [FAILSAFE] Method 1 succeeded")
        }
        
        // Method 2: Bundle.main.path
        if data == nil, let path = Bundle.main.path(forResource: filename, ofType: "json") {
            let url = URL(fileURLWithPath: path)
            data = try? Data(contentsOf: url)
            AppLogger.info("✅ [FAILSAFE] Method 2 succeeded")
        }
        
        // Method 3: Direct resource path
        if data == nil, let resourcePath = Bundle.main.resourcePath {
            let fullPath = "\(resourcePath)/\(filename).json"
            let url = URL(fileURLWithPath: fullPath)
            data = try? Data(contentsOf: url)
            AppLogger.info("✅ [FAILSAFE] Method 3 succeeded")
        }
        
        if let data = data {
            do {
                let parsed = try await Task.detached(priority: .userInitiated) {
                    return try JSONParserService.shared.parseAllData(data: data)
                }.value
                
                self.flashcards = parsed.flashcards
                self.grammarPoints = parsed.grammar
                self.kanji = parsed.kanji
                self.games = parsed.games
                self.practiceQuestions = parsed.practice
                
                AppLogger.info("✅ [FAILSAFE] Successfully loaded:")
                AppLogger.info("   - Flashcards: \(self.flashcards.count)")
                AppLogger.info("   - Grammar: \(self.grammarPoints.count)")
                AppLogger.info("   - Kanji: \(self.kanji.count)")
            } catch {
                AppLogger.error("❌ [FAILSAFE] Parse error: \(error)")
            }
        } else {
            AppLogger.error("❌ [FAILSAFE] Could not find JSON file with any method!")
            AppLogger.error("   Bundle path: \(Bundle.main.resourcePath ?? "nil")")
        }
    }
    
    // MARK: - Load Data
    
    func loadLearningData() async {
        isLoading = true
        
        let level = currentLevel
        print("======================================================================")
        print("🔄 [LOAD] Starting loadLearningData for level: \(level.rawValue)")
        print("======================================================================")
        AppLogger.info("🔄 [DATA] Starting loadLearningData for level: \(level.rawValue)")
        
        let completedLessons = userProgress?.completedLessons ?? []
        let filename = "japanese_learning_data_\(level.rawValue.lowercased())_jisho"
        
        print("📁 [LOAD] Looking for file: \(filename).json")
        AppLogger.info("📁 [DATA] Looking for file: \(filename).json")
        AppLogger.info("📁 [DATA] Current level: \(level.rawValue)")
        
        // Perform IO and Parsing in background
        let result = await Task.detached(priority: .userInitiated) { () -> (Data?, Error?) in
            // 1. Try to load from Bundle
            AppLogger.info("🔍 [DATA] Searching for: \(filename)")
            
            // Debug: List all JSON files in bundle
            if let resourcePath = Bundle.main.resourcePath {
                AppLogger.info("📂 [DATA] Resource path: \(resourcePath)")
                if let files = try? FileManager.default.contentsOfDirectory(atPath: resourcePath) {
                    let jsonFiles = files.filter { $0.hasSuffix(".json") }
                    AppLogger.info("📋 [DATA] JSON files in bundle: \(jsonFiles)")
                }
            }
            
            if let url = Bundle.main.url(forResource: filename, withExtension: "json") {
                do {
                    let data = try Data(contentsOf: url)
                    print("✅ [LOAD] Found file at: \(url.path)")
                    print("✅ [LOAD] File size: \(data.count) bytes")
                    AppLogger.info("✅ [DATA] Found file at: \(url.path)")
                    AppLogger.info("✅ [DATA] File size: \(data.count) bytes")
                    return (data, nil)
                } catch {
                    print("❌ [LOAD] Failed to read file: \(error)")
                    AppLogger.error("❌ [DATA] Failed to read file: \(error)")
                    return (nil, error)
                }
            } else {
                print("❌ [LOAD] File not found in bundle: \(filename).json")
                AppLogger.error("❌ [DATA] File not found in bundle: \(filename).json")
            }
            return (nil, nil) // Not found
        }.value
        
        do {
            if let data = result.0 {
                print("✅ [LOAD] Found bundled JSON for \(level.rawValue), parsing...")
                AppLogger.info("✅ Found bundled JSON for \(level.rawValue)")
                
                // Parse in background
                let parsed = try await Task.detached(priority: .userInitiated) {
                    return try JSONParserService.shared.parseAllData(data: data)
                }.value
                
                print("✅ [LOAD] Parsed successfully!")
                print("   Flashcards: \(parsed.flashcards.count)")
                print("   Grammar: \(parsed.grammar.count)")
                print("   Kanji: \(parsed.kanji.count)")
                
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
                
                print("🔄 [LOAD] Updating UI...")
                // Update UI on MainActor
                self.flashcards = parsed.flashcards
                self.grammarPoints = parsed.grammar
                self.kanji = parsed.kanji
                self.games = parsed.games
                self.practiceQuestions = parsed.practice
                self.lessons = derivedLessons
                self.exercises = derivedExercises
                
                print("✅ [LOAD] UI UPDATED!")
                print("   self.flashcards.count = \(self.flashcards.count)")
                print("   self.grammarPoints.count = \(self.grammarPoints.count)")
                print("   self.kanji.count = \(self.kanji.count)")
                print("======================================================================")
                
                AppLogger.info("📊 [DATA] Loaded data counts for level \(level.rawValue):")
                AppLogger.info("   - Lessons: \(self.lessons.count)")
                AppLogger.info("   - Flashcards: \(self.flashcards.count)")
                AppLogger.info("   - Grammar: \(self.grammarPoints.count)")
                AppLogger.info("   - Kanji: \(self.kanji.count)")
                AppLogger.info("   - Exercises: \(self.exercises.count)")
                AppLogger.info("   - Games: \(self.games.count)")
                
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
