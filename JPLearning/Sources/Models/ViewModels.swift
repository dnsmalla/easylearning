//
//  ViewModels.swift
//  JLearn
//
//  ViewModels for MVVM architecture
//  Separates view logic from view presentation
//

import Foundation
import SwiftUI
import Combine

// MARK: - Base ViewModel

/// Base view model with common functionality
@MainActor
class BaseViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    var cancellables = Set<AnyCancellable>()
    
    func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
        AppLogger.error("ViewModel Error: \(error)")
    }
    
    func clearError() {
        errorMessage = nil
        showError = false
    }
}

// MARK: - Home ViewModel

@MainActor
final class HomeViewModel: BaseViewModel {
    // Dependencies
    private let dataService: any DataServiceProtocol
    private let achievementService: any AchievementServiceProtocol
    private let authService: any AuthServiceProtocol
    
    // Published State
    @Published var currentLevel: LearningLevel
    @Published var kanjiCount: Int = 0
    @Published var vocabularyCount: Int = 0
    @Published var grammarCount: Int = 0
    @Published var currentStreak: Int = 0
    @Published var userProgress: UserProgress?
    
    init(
        dataService: any DataServiceProtocol,
        achievementService: any AchievementServiceProtocol,
        authService: any AuthServiceProtocol
    ) {
        self.dataService = dataService
        self.achievementService = achievementService
        self.authService = authService
        self.currentLevel = dataService.currentLevel
        
        super.init()
        
        setupObservers()
        loadData()
    }
    
    private func setupObservers() {
        // Observe data service changes
        // (In real implementation, would observe Combine publishers)
    }
    
    func loadData() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                await dataService.loadLearningData()
                updateCounts()
                updateProgress()
            } catch {
                handleError(error)
            }
        }
    }
    
    func changeLevel(_ newLevel: LearningLevel) {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            await dataService.setLevel(newLevel)
            currentLevel = newLevel
            updateCounts()
        }
    }
    
    private func updateCounts() {
        kanjiCount = dataService.getKanji().count
        vocabularyCount = dataService.getFlashcards().count
        grammarCount = dataService.getGrammarPoints().count
    }
    
    private func updateProgress() {
        currentStreak = achievementService.currentStreak
        userProgress = authService.currentUser?.progress
    }
}

// MARK: - Practice ViewModel

@MainActor
final class PracticeViewModel: BaseViewModel {
    // Dependencies
    private let dataService: any DataServiceProtocol
    private let spacedRepetitionService: any SpacedRepetitionServiceProtocol
    
    // Published State
    @Published var practiceCategory: PracticeCategory = .kanji
    @Published var questions: [PracticeQuestion] = []
    @Published var currentQuestionIndex = 0
    @Published var score = 0
    @Published var selectedAnswer: String?
    @Published var showFeedback = false
    @Published var isCorrect = false
    @Published var isCompleted = false
    
    init(
        dataService: any DataServiceProtocol,
        spacedRepetitionService: any SpacedRepetitionServiceProtocol
    ) {
        self.dataService = dataService
        self.spacedRepetitionService = spacedRepetitionService
        
        super.init()
    }
    
    // Current question
    var currentQuestion: PracticeQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    // Progress percentage
    var progressPercentage: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentQuestionIndex) / Double(questions.count)
    }
    
    func startPractice(category: PracticeCategory) {
        self.practiceCategory = category
        self.questions = dataService.getPracticeQuestions(category: category).shuffled()
        self.currentQuestionIndex = 0
        self.score = 0
        self.isCompleted = false
        self.resetQuestion()
    }
    
    func selectAnswer(_ answer: String) {
        guard let question = currentQuestion else { return }
        
        selectedAnswer = answer
        isCorrect = (answer == question.correctAnswer)
        
        if isCorrect {
            score += 1
            Haptics.success()
        } else {
            Haptics.error()
        }
        
        showFeedback = true
    }
    
    func nextQuestion() {
        currentQuestionIndex += 1
        
        if currentQuestionIndex >= questions.count {
            completeSession()
        } else {
            resetQuestion()
        }
    }
    
    private func resetQuestion() {
        selectedAnswer = nil
        showFeedback = false
        isCorrect = false
    }
    
    private func completeSession() {
        isCompleted = true
        Haptics.success()
        
        // Log achievement
        Task {
            // Update user progress
        }
    }
    
    func restart() {
        startPractice(category: practiceCategory)
    }
}

// MARK: - Flashcard ViewModel

@MainActor
final class FlashcardViewModel: BaseViewModel {
    // Dependencies
    private let dataService: any DataServiceProtocol
    private let spacedRepetitionService: any SpacedRepetitionServiceProtocol
    
    // Published State
    @Published var flashcards: [Flashcard] = []
    @Published var currentIndex = 0
    @Published var isFlipped = false
    @Published var reviewMode = false
    @Published var masteryFilter: MasteryLevel?
    
    init(
        dataService: any DataServiceProtocol,
        spacedRepetitionService: any SpacedRepetitionServiceProtocol
    ) {
        self.dataService = dataService
        self.spacedRepetitionService = spacedRepetitionService
        
        super.init()
        loadFlashcards()
    }
    
    var currentFlashcard: Flashcard? {
        guard currentIndex < flashcards.count else { return nil }
        return flashcards[currentIndex]
    }
    
    var hasNext: Bool {
        return currentIndex < flashcards.count - 1
    }
    
    var hasPrevious: Bool {
        return currentIndex > 0
    }
    
    func loadFlashcards() {
        var allFlashcards = dataService.getFlashcards()
        
        if reviewMode {
            allFlashcards = spacedRepetitionService.getDueFlashcards(from: allFlashcards)
        }
        
        if let filter = masteryFilter {
            allFlashcards = allFlashcards.filter {
                spacedRepetitionService.getMasteryLevel(for: $0) == filter
            }
        }
        
        flashcards = allFlashcards
        currentIndex = 0
        isFlipped = false
    }
    
    func flipCard() {
        withAnimation(.spring()) {
            isFlipped.toggle()
        }
        Haptics.selection()
    }
    
    func nextCard() {
        guard hasNext else { return }
        withAnimation {
            currentIndex += 1
            isFlipped = false
        }
        Haptics.selection()
    }
    
    func previousCard() {
        guard hasPrevious else { return }
        withAnimation {
            currentIndex -= 1
            isFlipped = false
        }
        Haptics.selection()
    }
    
    func rateFlashcard(quality: Int) {
        guard let flashcard = currentFlashcard else { return }
        
        let updated = spacedRepetitionService.reviewFlashcard(flashcard, quality: quality)
        
        // Update in data service
        Task {
            try? await (dataService as? LearningDataService)?.updateFlashcard(updated)
        }
        
        // Move to next
        nextCard()
    }
    
    func toggleFavorite() {
        guard var flashcard = currentFlashcard else { return }
        flashcard.isFavorite.toggle()
        
        Task {
            try? await (dataService as? LearningDataService)?.updateFlashcard(flashcard)
        }
        
        // Update local array
        flashcards[currentIndex].isFavorite = flashcard.isFavorite
    }
}

// MARK: - Profile ViewModel

@MainActor
final class ProfileViewModel: BaseViewModel {
    // Dependencies
    private let authService: any AuthServiceProtocol
    private let achievementService: any AchievementServiceProtocol
    private let dataService: any DataServiceProtocol
    
    // Published State
    @Published var user: UserModel?
    @Published var achievements: [Achievement] = []
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var totalStudyTime: Int = 0
    @Published var weeklyActivity: [Int] = []
    
    init(
        authService: any AuthServiceProtocol,
        achievementService: any AchievementServiceProtocol,
        dataService: any DataServiceProtocol
    ) {
        self.authService = authService
        self.achievementService = achievementService
        self.dataService = dataService
        
        super.init()
        loadProfile()
    }
    
    func loadProfile() {
        user = authService.currentUser
        achievements = achievementService.getAvailableAchievements()
        currentStreak = achievementService.currentStreak
        longestStreak = achievementService.longestStreak
        totalStudyTime = achievementService.totalStudyMinutes
        weeklyActivity = achievementService.getWeeklyActivity()
    }
    
    func signOut() {
        Task {
            do {
                try authService.signOut()
            } catch {
                handleError(error)
            }
        }
    }
    
    func updateDisplayName(_ newName: String) {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                try await authService.updateProfile(
                    displayName: newName,
                    photoURL: nil,
                    preferences: nil,
                    progress: nil,
                    savedKanji: nil,
                    savedVocabulary: nil
                )
                user = authService.currentUser
            } catch {
                handleError(error)
            }
        }
    }
}

