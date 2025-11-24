//
//  ComprehensivePracticeViews.swift
//  JLearn
//
//  Professional practice views for Reading, Listening, Speaking, and Writing
//  Complete with content, instructions, and proper UX
//

import SwiftUI

// MARK: - Reading Practice View

struct ReadingPracticeView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @StateObject private var viewModel = ReadingPracticeViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                LoadingView()
            } else if viewModel.questions.isEmpty {
                EmptyReadingStateView {
                    viewModel.loadQuestions(from: learningDataService)
                }
            } else if viewModel.showResults {
                ProfessionalResultsView(
                    score: viewModel.score,
                    total: viewModel.questions.count,
                    title: "Reading Complete!",
                    icon: "book.pages.fill",
                    color: .green,
                    restartAction: {
                        viewModel.restart()
                    },
                    dismissAction: {
                        dismiss()
                    }
                )
            } else {
                ReadingQuestionView(viewModel: viewModel)
            }
        }
        .navigationTitle("Reading Practice")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel.questions.isEmpty {
                viewModel.loadQuestions(from: learningDataService)
            }
        }
    }
}

// MARK: - Reading Question View

private struct ReadingQuestionView: View {
    @ObservedObject var viewModel: ReadingPracticeViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress Header
            ProfessionalProgressHeader(
                currentIndex: viewModel.currentQuestionIndex,
                total: viewModel.questions.count,
                score: viewModel.score,
                scoreLabel: "correct",
                progressColor: .green
            )
            
            ScrollView {
                VStack(spacing: 24) {
                    if let question = viewModel.currentQuestion {
                        // Passage Card
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Read the passage:")
                                .font(AppTheme.Typography.subheadline)
                                .foregroundColor(AppTheme.mutedText)
                            
                            Text(question.question)
                                .font(AppTheme.Typography.japaneseBody)
                                .foregroundColor(.primary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.green.opacity(0.05))
                                )
                        }
                        .padding(.horizontal)
                        
                        // Question Text
                        if let explanation = question.explanation {
                            Text(explanation)
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(.primary)
                                .padding(.horizontal)
                        }
                        
                        // Answer Options
                        VStack(spacing: 12) {
                            ForEach(question.options, id: \.self) { option in
                                ProfessionalAnswerButton(
                                    text: option,
                                    isSelected: viewModel.selectedAnswer == option,
                                    isCorrect: viewModel.showFeedback && option == question.correctAnswer,
                                    isWrong: viewModel.showFeedback && viewModel.selectedAnswer == option && option != question.correctAnswer,
                                    action: {
                                        viewModel.selectAnswer(option)
                                    }
                                )
                                .disabled(viewModel.showFeedback)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Feedback
                        if viewModel.showFeedback {
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: viewModel.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(viewModel.isCorrect ? .green : .red)
                                    
                                    Text(viewModel.isCorrect ? "Correct! 正解！" : "Incorrect. 不正解")
                                        .font(AppTheme.Typography.headline)
                                        .foregroundColor(viewModel.isCorrect ? .green : .red)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(viewModel.isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                                )
                                
                                Button(action: viewModel.nextQuestion) {
                                    Text(viewModel.hasNextQuestion ? "Next Question →" : "See Results")
                                        .font(AppTheme.Typography.button)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green)
                                        .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal)
                            .transition(.opacity)
                        }
                    }
                }
                .padding(.vertical)
            }
        }
    }
}

// MARK: - Reading ViewModel

class ReadingPracticeViewModel: ObservableObject {
    @Published var questions: [PracticeQuestion] = []
    @Published var currentQuestionIndex = 0
    @Published var selectedAnswer: String?
    @Published var showFeedback = false
    @Published var isCorrect = false
    @Published var score = 0
    @Published var showResults = false
    @Published var isLoading = false
    
    var currentQuestion: PracticeQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var hasNextQuestion: Bool {
        currentQuestionIndex < questions.count - 1
    }
    
    func loadQuestions(from service: LearningDataService) {
        isLoading = true
        
        Task { @MainActor in
            let allQuestions = await service.loadPracticeQuestions(category: .reading, level: service.currentLevel)
            
            if allQuestions.isEmpty {
                // Generate sample reading questions
                self.questions = generateSampleReadingQuestions(level: service.currentLevel)
            } else {
                self.questions = Array(allQuestions.shuffled().prefix(10))
            }
            
            isLoading = false
        }
    }
    
    func selectAnswer(_ answer: String) {
        selectedAnswer = answer
        isCorrect = (answer == currentQuestion?.correctAnswer)
        
        if isCorrect {
            score += 1
            Haptics.success()
        } else {
            Haptics.error()
        }
        
        withAnimation {
            showFeedback = true
        }
    }
    
    func nextQuestion() {
        if hasNextQuestion {
            currentQuestionIndex += 1
            resetQuestion()
        } else {
            completeSession()
        }
    }
    
    func resetQuestion() {
        withAnimation {
            selectedAnswer = nil
            showFeedback = false
            isCorrect = false
        }
    }
    
    func completeSession() {
        showResults = true
        Haptics.success()
    }
    
    func restart() {
        currentQuestionIndex = 0
        score = 0
        showResults = false
        questions.shuffle()
        resetQuestion()
    }
    
    private func generateSampleReadingQuestions(level: LearningLevel) -> [PracticeQuestion] {
        let samples = [
            PracticeQuestion(
                id: "reading_1",
                question: "今日は天気がいいです。公園に行きましょう。",
                options: ["Let's go to the park", "Let's go to school", "Let's go home", "Let's go shopping"],
                correctAnswer: "Let's go to the park",
                explanation: "What does the passage suggest?",
                category: .reading,
                level: level.rawValue
            ),
            PracticeQuestion(
                id: "reading_2",
                question: "私は毎朝コーヒーを飲みます。",
                options: ["I drink coffee every morning", "I drink tea every morning", "I drink water every day", "I eat breakfast every morning"],
                correctAnswer: "I drink coffee every morning",
                explanation: "What does the sentence mean?",
                category: .reading,
                level: level.rawValue
            ),
            PracticeQuestion(
                id: "reading_3",
                question: "図書館で本を読んでいます。",
                options: ["Reading at the library", "Studying at school", "Working at office", "Shopping at store"],
                correctAnswer: "Reading at the library",
                explanation: "Where and what is happening?",
                category: .reading,
                level: level.rawValue
            )
        ]
        return samples
    }
}

// MARK: - Empty State View

private struct EmptyReadingStateView: View {
    let onRetry: () -> Void
    
    var body: some View {
        ProfessionalEmptyStateView(
            icon: "book.pages",
            title: "No Reading Exercises",
            message: "Reading exercises help you understand Japanese text passages and improve comprehension.",
            actionTitle: "Try Again",
            action: onRetry
        )
    }
}

// MARK: - Listening Practice View

struct ListeningPracticeView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @EnvironmentObject var audioService: AudioService
    @StateObject private var viewModel = ListeningPracticeViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                LoadingView()
            } else if viewModel.questions.isEmpty {
                EmptyListeningStateView {
                    viewModel.loadQuestions(from: learningDataService)
                }
            } else if viewModel.showResults {
                ProfessionalResultsView(
                    score: viewModel.score,
                    total: viewModel.questions.count,
                    title: "Listening Complete!",
                    icon: "headphones",
                    color: .purple,
                    restartAction: {
                        viewModel.restart()
                    },
                    dismissAction: {
                        dismiss()
                    }
                )
            } else {
                ListeningQuestionView(viewModel: viewModel, audioService: audioService)
            }
        }
        .navigationTitle("Listening Practice")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel.questions.isEmpty {
                viewModel.loadQuestions(from: learningDataService)
            }
        }
    }
}

// MARK: - Listening Question View

private struct ListeningQuestionView: View {
    @ObservedObject var viewModel: ListeningPracticeViewModel
    @ObservedObject var audioService: AudioService
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress Header
            ProfessionalProgressHeader(
                currentIndex: viewModel.currentQuestionIndex,
                total: viewModel.questions.count,
                score: viewModel.score,
                scoreLabel: "correct",
                progressColor: .purple
            )
            
            ScrollView {
                VStack(spacing: 24) {
                    if let question = viewModel.currentQuestion {
                        // Audio Player Card
                        VStack(spacing: 16) {
                            Image(systemName: "headphones.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.purple)
                            
                            Text("Listen carefully and choose the correct answer")
                                .font(AppTheme.Typography.subheadline)
                                .foregroundColor(AppTheme.mutedText)
                                .multilineTextAlignment(.center)
                            
                            Button(action: {
                                playAudio(question.question, audioService: audioService)
                            }) {
                                HStack {
                                    Image(systemName: audioService.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                        .font(.title)
                                    Text(audioService.isPlaying ? "Playing..." : "Play Audio")
                                        .font(AppTheme.Typography.headline)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [.purple, .purple.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                            }
                            .disabled(audioService.isPlaying)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.purple.opacity(0.05))
                        )
                        .padding(.horizontal)
                        
                        // Question
                        if let explanation = question.explanation {
                            Text(explanation)
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(.primary)
                                .padding(.horizontal)
                        }
                        
                        // Answer Options
                        VStack(spacing: 12) {
                            ForEach(question.options, id: \.self) { option in
                                ProfessionalAnswerButton(
                                    text: option,
                                    isSelected: viewModel.selectedAnswer == option,
                                    isCorrect: viewModel.showFeedback && option == question.correctAnswer,
                                    isWrong: viewModel.showFeedback && viewModel.selectedAnswer == option && option != question.correctAnswer,
                                    action: {
                                        viewModel.selectAnswer(option)
                                    }
                                )
                                .disabled(viewModel.showFeedback)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Feedback
                        if viewModel.showFeedback {
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: viewModel.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(viewModel.isCorrect ? .green : .red)
                                    
                                    Text(viewModel.isCorrect ? "Correct! 正解！" : "Incorrect. 不正解")
                                        .font(AppTheme.Typography.headline)
                                        .foregroundColor(viewModel.isCorrect ? .green : .red)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(viewModel.isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                                )
                                
                                Button(action: viewModel.nextQuestion) {
                                    Text(viewModel.hasNextQuestion ? "Next Question →" : "See Results")
                                        .font(AppTheme.Typography.button)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.purple)
                                        .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal)
                            .transition(.opacity)
                        }
                    }
                }
                .padding(.vertical)
            }
        }
    }
    
    private func playAudio(_ text: String, audioService: AudioService) {
        Task {
            try? await audioService.speak(text, language: "ja-JP", rate: 0.4)
        }
    }
}

// MARK: - Listening ViewModel

class ListeningPracticeViewModel: ObservableObject {
    @Published var questions: [PracticeQuestion] = []
    @Published var currentQuestionIndex = 0
    @Published var selectedAnswer: String?
    @Published var showFeedback = false
    @Published var isCorrect = false
    @Published var score = 0
    @Published var showResults = false
    @Published var isLoading = false
    
    var currentQuestion: PracticeQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var hasNextQuestion: Bool {
        currentQuestionIndex < questions.count - 1
    }
    
    func loadQuestions(from service: LearningDataService) {
        isLoading = true
        
        Task { @MainActor in
            let allQuestions = await service.loadPracticeQuestions(category: .listening, level: service.currentLevel)
            
            if allQuestions.isEmpty {
                self.questions = generateSampleListeningQuestions(level: service.currentLevel)
            } else {
                self.questions = Array(allQuestions.shuffled().prefix(10))
            }
            
            isLoading = false
        }
    }
    
    func selectAnswer(_ answer: String) {
        selectedAnswer = answer
        isCorrect = (answer == currentQuestion?.correctAnswer)
        
        if isCorrect {
            score += 1
            Haptics.success()
        } else {
            Haptics.error()
        }
        
        withAnimation {
            showFeedback = true
        }
    }
    
    func nextQuestion() {
        if hasNextQuestion {
            currentQuestionIndex += 1
            resetQuestion()
        } else {
            completeSession()
        }
    }
    
    func resetQuestion() {
        withAnimation {
            selectedAnswer = nil
            showFeedback = false
            isCorrect = false
        }
    }
    
    func completeSession() {
        showResults = true
        Haptics.success()
    }
    
    func restart() {
        currentQuestionIndex = 0
        score = 0
        showResults = false
        questions.shuffle()
        resetQuestion()
    }
    
    private func generateSampleListeningQuestions(level: LearningLevel) -> [PracticeQuestion] {
        let samples = [
            PracticeQuestion(
                id: "listening_1",
                question: "おはようございます",
                options: ["Good morning", "Good evening", "Good night", "Goodbye"],
                correctAnswer: "Good morning",
                explanation: "What greeting did you hear?",
                category: .listening,
                level: level.rawValue
            ),
            PracticeQuestion(
                id: "listening_2",
                question: "ありがとうございます",
                options: ["Thank you very much", "You're welcome", "I'm sorry", "Excuse me"],
                correctAnswer: "Thank you very much",
                explanation: "What phrase did you hear?",
                category: .listening,
                level: level.rawValue
            ),
            PracticeQuestion(
                id: "listening_3",
                question: "すみません",
                options: ["Excuse me", "Hello", "Goodbye", "Please"],
                correctAnswer: "Excuse me",
                explanation: "What did the speaker say?",
                category: .listening,
                level: level.rawValue
            )
        ]
        return samples
    }
}

private struct EmptyListeningStateView: View {
    let onRetry: () -> Void
    
    var body: some View {
        ProfessionalEmptyStateView(
            icon: "headphones",
            title: "No Listening Exercises",
            message: "Listening practice helps you understand spoken Japanese and improve your comprehension skills.",
            actionTitle: "Try Again",
            action: onRetry
        )
    }
}

// MARK: - Speaking Practice View (Coming in next file due to length)


