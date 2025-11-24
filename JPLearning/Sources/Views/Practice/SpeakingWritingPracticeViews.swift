//
//  SpeakingWritingPracticeViews.swift
//  JLearn
//
//  Professional Speaking and Writing practice views
//

import SwiftUI

// MARK: - Speaking Practice View

struct SpeakingPracticeView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @EnvironmentObject var audioService: AudioService
    @StateObject private var viewModel = SpeakingPracticeViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                LoadingView()
            } else if viewModel.questions.isEmpty {
                EmptySpeakingStateView {
                    viewModel.loadQuestions(from: learningDataService)
                }
            } else if viewModel.showResults {
                ProfessionalResultsView(
                    score: viewModel.score,
                    total: viewModel.questions.count,
                    title: "Speaking Complete!",
                    icon: "mic.fill",
                    color: .red,
                    restartAction: {
                        viewModel.restart()
                    },
                    dismissAction: {
                        dismiss()
                    }
                )
            } else {
                SpeakingQuestionView(viewModel: viewModel, audioService: audioService)
            }
        }
        .navigationTitle("Speaking Practice")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel.questions.isEmpty {
                viewModel.loadQuestions(from: learningDataService)
            }
        }
    }
}

// MARK: - Speaking Question View

private struct SpeakingQuestionView: View {
    @ObservedObject var viewModel: SpeakingPracticeViewModel
    @ObservedObject var audioService: AudioService
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress Header
            ProfessionalProgressHeader(
                currentIndex: viewModel.currentQuestionIndex,
                total: viewModel.questions.count,
                score: viewModel.score,
                scoreLabel: "practiced",
                progressColor: .red
            )
            
            ScrollView {
                VStack(spacing: 24) {
                    if let question = viewModel.currentQuestion {
                        // Instruction Card
                        VStack(spacing: 16) {
                            Image(systemName: "mic.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.red)
                            
                            Text("Practice speaking this phrase")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(.primary)
                            
                            Text("Listen first, then try to repeat it")
                                .font(AppTheme.Typography.subheadline)
                                .foregroundColor(AppTheme.mutedText)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.red.opacity(0.05))
                        )
                        .padding(.horizontal)
                        
                        // Phrase to Practice
                        VStack(spacing: 12) {
                            Text("Phrase:")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.mutedText)
                            
                            Text(question.question)
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(.primary)
                            
                            if let meaning = question.explanation {
                                Text(meaning)
                                    .font(AppTheme.Typography.subheadline)
                                    .foregroundColor(AppTheme.mutedText)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppTheme.secondaryBackground)
                        )
                        .padding(.horizontal)
                        
                        // Listen Button
                        Button(action: {
                            playAudio(question.question, audioService: audioService)
                        }) {
                            HStack {
                                Image(systemName: audioService.isPlaying ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                                    .font(.title2)
                                Text(audioService.isPlaying ? "Playing..." : "Listen to Pronunciation")
                                    .font(AppTheme.Typography.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.blue, .blue.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                        .disabled(audioService.isPlaying)
                        .padding(.horizontal)
                        
                        // Record Button
                        Button(action: {
                            toggleRecording(audioService: audioService)
                        }) {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(audioService.isRecording ? Color.red : Color.red.opacity(0.1))
                                        .frame(width: 80, height: 80)
                                    
                                    Image(systemName: "mic.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(audioService.isRecording ? .white : .red)
                                }
                                
                                Text(audioService.isRecording ? "Recording... Tap to stop" : "Tap to Record")
                                    .font(AppTheme.Typography.subheadline)
                                    .foregroundColor(audioService.isRecording ? .red : .primary)
                            }
                            .padding()
                        }
                        
                        // Recognition Result
                        if !audioService.recognizedText.isEmpty {
                            VStack(spacing: 8) {
                                Text("You said:")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.mutedText)
                                
                                Text(audioService.recognizedText)
                                    .font(AppTheme.Typography.japaneseBody)
                                    .foregroundColor(.primary)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.green.opacity(0.1))
                                    )
                            }
                            .padding(.horizontal)
                        }
                        
                        // Navigation Buttons
                        HStack(spacing: 12) {
                            if viewModel.currentQuestionIndex > 0 {
                                Button(action: viewModel.previousQuestion) {
                                    Text("← Previous")
                                        .font(AppTheme.Typography.button)
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(AppTheme.secondaryBackground)
                                        .cornerRadius(12)
                                }
                            }
                            
                            Button(action: {
                                viewModel.markAsPracticed()
                            }) {
                                Text(viewModel.hasNextQuestion ? "Next →" : "Finish")
                                    .font(AppTheme.Typography.button)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
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
    
    private func toggleRecording(audioService: AudioService) {
        if audioService.isRecording {
            audioService.stopRecording()
        } else {
            Task {
                try? await audioService.startRecording()
            }
        }
    }
}

// MARK: - Speaking ViewModel

class SpeakingPracticeViewModel: ObservableObject {
    @Published var questions: [PracticeQuestion] = []
    @Published var currentQuestionIndex = 0
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
            let allQuestions = await service.loadPracticeQuestions(category: .speaking, level: service.currentLevel)
            
            if allQuestions.isEmpty {
                self.questions = generateSampleSpeakingQuestions(level: service.currentLevel)
            } else {
                self.questions = Array(allQuestions.shuffled().prefix(10))
            }
            
            isLoading = false
        }
    }
    
    func markAsPracticed() {
        score += 1
        Haptics.success()
        
        if hasNextQuestion {
            currentQuestionIndex += 1
        } else {
            completeSession()
        }
    }
    
    func previousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
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
    }
    
    private func generateSampleSpeakingQuestions(level: LearningLevel) -> [PracticeQuestion] {
        let samples = [
            PracticeQuestion(
                id: "speaking_1",
                question: "おはようございます",
                options: [],
                correctAnswer: "",
                explanation: "Good morning",
                category: .speaking,
                level: level.rawValue
            ),
            PracticeQuestion(
                id: "speaking_2",
                question: "こんにちは",
                options: [],
                correctAnswer: "",
                explanation: "Hello / Good afternoon",
                category: .speaking,
                level: level.rawValue
            ),
            PracticeQuestion(
                id: "speaking_3",
                question: "ありがとうございます",
                options: [],
                correctAnswer: "",
                explanation: "Thank you very much",
                category: .speaking,
                level: level.rawValue
            ),
            PracticeQuestion(
                id: "speaking_4",
                question: "すみません",
                options: [],
                correctAnswer: "",
                explanation: "Excuse me / I'm sorry",
                category: .speaking,
                level: level.rawValue
            ),
            PracticeQuestion(
                id: "speaking_5",
                question: "さようなら",
                options: [],
                correctAnswer: "",
                explanation: "Goodbye",
                category: .speaking,
                level: level.rawValue
            )
        ]
        return samples
    }
}

private struct EmptySpeakingStateView: View {
    let onRetry: () -> Void
    
    var body: some View {
        ProfessionalEmptyStateView(
            icon: "mic.fill",
            title: "No Speaking Exercises",
            message: "Speaking practice helps you improve pronunciation and gain confidence in speaking Japanese.",
            actionTitle: "Try Again",
            action: onRetry
        )
    }
}

// MARK: - Writing Practice View

struct WritingPracticeView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @StateObject private var viewModel = WritingPracticeViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                LoadingView()
            } else if viewModel.questions.isEmpty {
                EmptyWritingStateView {
                    viewModel.loadQuestions(from: learningDataService)
                }
            } else if viewModel.showResults {
                ProfessionalResultsView(
                    score: viewModel.score,
                    total: viewModel.questions.count,
                    title: "Writing Complete!",
                    icon: "pencil.circle.fill",
                    color: .indigo,
                    restartAction: {
                        viewModel.restart()
                    },
                    dismissAction: {
                        dismiss()
                    }
                )
            } else {
                WritingQuestionView(viewModel: viewModel)
            }
        }
        .navigationTitle("Writing Practice")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel.questions.isEmpty {
                viewModel.loadQuestions(from: learningDataService)
            }
        }
    }
}

// MARK: - Writing Question View

private struct WritingQuestionView: View {
    @ObservedObject var viewModel: WritingPracticeViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress Header
            ProfessionalProgressHeader(
                currentIndex: viewModel.currentQuestionIndex,
                total: viewModel.questions.count,
                score: viewModel.score,
                scoreLabel: "correct",
                progressColor: .indigo
            )
            
            ScrollView {
                VStack(spacing: 24) {
                    if let question = viewModel.currentQuestion {
                        // Instruction Card
                        VStack(spacing: 16) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.indigo)
                            
                            Text("Write the correct answer")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(.primary)
                            
                            Text(question.explanation ?? "Choose the correct written form")
                                .font(AppTheme.Typography.subheadline)
                                .foregroundColor(AppTheme.mutedText)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.indigo.opacity(0.05))
                        )
                        .padding(.horizontal)
                        
                        // Question
                        VStack(spacing: 12) {
                            Text("Question:")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.mutedText)
                            
                            Text(question.question)
                                .font(.system(size: 28, weight: .medium))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppTheme.secondaryBackground)
                        )
                        .padding(.horizontal)
                        
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
                                        .background(Color.indigo)
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

// MARK: - Writing ViewModel

class WritingPracticeViewModel: ObservableObject {
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
            let allQuestions = await service.loadPracticeQuestions(category: .writing, level: service.currentLevel)
            
            if allQuestions.isEmpty {
                self.questions = generateSampleWritingQuestions(level: service.currentLevel)
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
    
    private func generateSampleWritingQuestions(level: LearningLevel) -> [PracticeQuestion] {
        let samples = [
            PracticeQuestion(
                id: "writing_1",
                question: "Write 'konnichiwa' in hiragana",
                options: ["こんにちは", "こんばんは", "おはよう", "ありがとう"],
                correctAnswer: "こんにちは",
                explanation: "How do you write 'hello' in hiragana?",
                category: .writing,
                level: level.rawValue
            ),
            PracticeQuestion(
                id: "writing_2",
                question: "Write 'arigatou' in hiragana",
                options: ["ありがとう", "さようなら", "すみません", "ください"],
                correctAnswer: "ありがとう",
                explanation: "How do you write 'thank you' in hiragana?",
                category: .writing,
                level: level.rawValue
            ),
            PracticeQuestion(
                id: "writing_3",
                question: "Write 'sumimasen' in hiragana",
                options: ["すみません", "ごめんなさい", "いいえ", "はい"],
                correctAnswer: "すみません",
                explanation: "How do you write 'excuse me' in hiragana?",
                category: .writing,
                level: level.rawValue
            )
        ]
        return samples
    }
}

private struct EmptyWritingStateView: View {
    let onRetry: () -> Void
    
    var body: some View {
        ProfessionalEmptyStateView(
            icon: "pencil.circle.fill",
            title: "No Writing Exercises",
            message: "Writing practice helps you learn to write Japanese characters and improve your written communication skills.",
            actionTitle: "Load Practice Questions",
            action: onRetry
        )
    }
}


