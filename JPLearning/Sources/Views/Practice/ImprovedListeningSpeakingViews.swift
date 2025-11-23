//
//  ImprovedListeningSpeakingViews.swift
//  JLearn
//
//  Improved Listening and Speaking practice with proper pedagogy
//  Listening: Question First → Listen → Answer
//  Speaking: Clear instruction → Listen → Record → Practice
//

import SwiftUI

// MARK: - Listening Practice View (Redesigned)

struct ListeningPracticeView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @EnvironmentObject var audioService: AudioService
    @StateObject private var viewModel = ListeningPracticeViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                LoadingView()
            } else if viewModel.listeningItems.isEmpty {
                EmptyListeningStateView {
                    viewModel.loadListeningItems(from: learningDataService)
                }
            } else if viewModel.showResults {
                ProfessionalResultsView(
                    score: viewModel.score,
                    total: viewModel.listeningItems.count,
                    title: "Listening Complete!",
                    icon: "headphones",
                    color: .purple,
                    restartAction: viewModel.restart,
                    dismissAction: { dismiss() }
                )
            } else {
                ImprovedListeningQuestionView(viewModel: viewModel, audioService: audioService)
            }
        }
        .navigationTitle("Listening Practice")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel.listeningItems.isEmpty {
                viewModel.loadListeningItems(from: learningDataService)
            }
        }
    }
}

// MARK: - Improved Listening Question View

private struct ImprovedListeningQuestionView: View {
    @ObservedObject var viewModel: ListeningPracticeViewModel
    @ObservedObject var audioService: AudioService
    @State private var playCount = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress Header
            ProfessionalProgressHeader(
                currentIndex: viewModel.currentItemIndex,
                total: viewModel.listeningItems.count,
                score: viewModel.score,
                scoreLabel: "correct",
                progressColor: .purple
            )
            
            ScrollView {
                VStack(spacing: 24) {
                    if let item = viewModel.currentItem {
                        // STEP 1: Question First
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "questionmark.circle.fill")
                                    .foregroundColor(.purple)
                                Text("Question")
                                    .font(AppTheme.Typography.headline)
                                    .foregroundColor(.primary)
                            }
                            
                            Text(item.question)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.primary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.purple.opacity(0.05))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                                        )
                                )
                        }
                        .padding(.horizontal)
                        
                        // STEP 2: Listen to Audio
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "headphones")
                                    .foregroundColor(.blue)
                                Text("Listen carefully")
                                    .font(AppTheme.Typography.headline)
                                    .foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Audio Player
                            VStack(spacing: 16) {
                                // Audio icon
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.purple, .blue],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 100, height: 100)
                                    
                                    Image(systemName: audioService.isPlaying ? "speaker.wave.3.fill" : "headphones")
                                        .font(.system(size: 48))
                                        .foregroundColor(.white)
                                }
                                
                                // Play count
                                if playCount > 0 {
                                    HStack(spacing: 4) {
                                        ForEach(0..<playCount, id: \.self) { _ in
                                            Image(systemName: "play.fill")
                                                .font(.system(size: 10))
                                                .foregroundColor(.purple)
                                        }
                                        Text("Played \(playCount) time\(playCount == 1 ? "" : "s")")
                                            .font(AppTheme.Typography.caption)
                                            .foregroundColor(AppTheme.mutedText)
                                    }
                                }
                                
                                // Play button
                                Button(action: {
                                    playAudio(item.audioText, audioService: audioService)
                                    playCount += 1
                                }) {
                                    HStack(spacing: 12) {
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
                                            colors: [.purple, .blue],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                                }
                                .disabled(audioService.isPlaying)
                                
                                Text("You can play multiple times")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.mutedText)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.blue.opacity(0.05))
                            )
                        }
                        .padding(.horizontal)
                        
                        Divider()
                            .padding(.horizontal)
                        
                        // STEP 3: Answer Options
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.green)
                                Text("Choose your answer")
                                    .font(AppTheme.Typography.headline)
                                    .foregroundColor(.primary)
                            }
                            
                            VStack(spacing: 12) {
                                ForEach(Array(item.options.enumerated()), id: \.offset) { index, option in
                                    Button(action: {
                                        if !viewModel.showFeedback {
                                            viewModel.selectAnswer(option)
                                        }
                                    }) {
                                        HStack(spacing: 12) {
                                            // Option letter
                                            ZStack {
                                                Circle()
                                                    .fill(getOptionColor(option: option))
                                                    .frame(width: 32, height: 32)
                                                
                                                Text(optionLetter(index))
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(.white)
                                            }
                                            
                                            Text(option)
                                                .font(AppTheme.Typography.body)
                                                .foregroundColor(.primary)
                                                .multilineTextAlignment(.leading)
                                            
                                            Spacer()
                                            
                                            if viewModel.showFeedback {
                                                if option == item.correctAnswer {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.green)
                                                        .font(.title3)
                                                } else if viewModel.selectedAnswer == option {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.red)
                                                        .font(.title3)
                                                }
                                            }
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(getOptionBackground(option: option))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(getOptionBorder(option: option), lineWidth: 2)
                                                )
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .disabled(viewModel.showFeedback)
                                }
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
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(viewModel.isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                                )
                                
                                // Show the text they heard
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Audio text:")
                                        .font(AppTheme.Typography.caption)
                                        .foregroundColor(AppTheme.mutedText)
                                    
                                    Text(item.audioText)
                                        .font(.system(size: 16))
                                        .foregroundColor(.primary)
                                    
                                    if let translation = item.translation {
                                        Text(translation)
                                            .font(AppTheme.Typography.subheadline)
                                            .foregroundColor(AppTheme.mutedText)
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AppTheme.secondaryBackground)
                                )
                                
                                Button(action: {
                                    viewModel.nextQuestion()
                                    playCount = 0
                                }) {
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
                        }
                    }
                }
                .padding(.vertical)
            }
        }
    }
    
    private func optionLetter(_ index: Int) -> String {
        return ["A", "B", "C", "D"][min(index, 3)]
    }
    
    private func playAudio(_ text: String, audioService: AudioService) {
        Task {
            try? await audioService.speak(text, language: "ja-JP", rate: 0.4)
        }
    }
    
    private func getOptionColor(option: String) -> Color {
        if viewModel.showFeedback {
            if option == viewModel.currentItem?.correctAnswer {
                return .green
            } else if viewModel.selectedAnswer == option {
                return .red
            }
        } else if viewModel.selectedAnswer == option {
            return .purple
        }
        return .gray
    }
    
    private func getOptionBackground(option: String) -> Color {
        if viewModel.showFeedback {
            if option == viewModel.currentItem?.correctAnswer {
                return Color.green.opacity(0.1)
            } else if viewModel.selectedAnswer == option {
                return Color.red.opacity(0.1)
            }
        } else if viewModel.selectedAnswer == option {
            return Color.purple.opacity(0.1)
        }
        return AppTheme.background
    }
    
    private func getOptionBorder(option: String) -> Color {
        if viewModel.showFeedback {
            if option == viewModel.currentItem?.correctAnswer {
                return .green
            } else if viewModel.selectedAnswer == option {
                return .red
            }
        } else if viewModel.selectedAnswer == option {
            return .purple
        }
        return AppTheme.separator
    }
}

// MARK: - Listening Item Model

struct ListeningItem: Identifiable {
    let id: String
    let question: String
    let audioText: String
    let translation: String?
    let options: [String]
    let correctAnswer: String
}

// MARK: - Listening ViewModel

class ListeningPracticeViewModel: ObservableObject {
    @Published var listeningItems: [ListeningItem] = []
    @Published var currentItemIndex = 0
    @Published var selectedAnswer: String?
    @Published var showFeedback = false
    @Published var isCorrect = false
    @Published var score = 0
    @Published var showResults = false
    @Published var isLoading = false
    
    var currentItem: ListeningItem? {
        guard currentItemIndex < listeningItems.count else { return nil }
        return listeningItems[currentItemIndex]
    }
    
    var hasNextQuestion: Bool {
        currentItemIndex < listeningItems.count - 1
    }
    
    func loadListeningItems(from service: LearningDataService) {
        isLoading = true
        
        Task { @MainActor in
            self.listeningItems = generateSampleListeningItems(level: service.currentLevel)
            isLoading = false
        }
    }
    
    func selectAnswer(_ answer: String) {
        selectedAnswer = answer
        isCorrect = (answer == currentItem?.correctAnswer)
        
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
            currentItemIndex += 1
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
        currentItemIndex = 0
        score = 0
        showResults = false
        listeningItems.shuffle()
        resetQuestion()
    }
    
    private func generateSampleListeningItems(level: LearningLevel) -> [ListeningItem] {
        return [
            ListeningItem(
                id: "listening_1",
                question: "What greeting do you hear?",
                audioText: "おはようございます",
                translation: "Good morning",
                options: [
                    "Good morning",
                    "Good evening",
                    "Good night",
                    "Goodbye"
                ],
                correctAnswer: "Good morning"
            ),
            ListeningItem(
                id: "listening_2",
                question: "What is the speaker saying?",
                audioText: "ありがとうございます",
                translation: "Thank you very much",
                options: [
                    "Thank you very much",
                    "You're welcome",
                    "I'm sorry",
                    "Excuse me"
                ],
                correctAnswer: "Thank you very much"
            ),
            ListeningItem(
                id: "listening_3",
                question: "What phrase does the speaker use?",
                audioText: "すみません",
                translation: "Excuse me / I'm sorry",
                options: [
                    "Excuse me",
                    "Hello",
                    "Goodbye",
                    "Please"
                ],
                correctAnswer: "Excuse me"
            ),
            ListeningItem(
                id: "listening_4",
                question: "What time-related phrase do you hear?",
                audioText: "また明日",
                translation: "See you tomorrow",
                options: [
                    "See you tomorrow",
                    "Good morning",
                    "See you later",
                    "Good night"
                ],
                correctAnswer: "See you tomorrow"
            )
        ]
    }
}

private struct EmptyListeningStateView: View {
    let onRetry: () -> Void
    
    var body: some View {
        ProfessionalEmptyStateView(
            icon: "headphones",
            title: "No Listening Exercises",
            message: "Listening practice helps you understand spoken Japanese through audio exercises.",
            actionTitle: "Load Practice",
            action: onRetry
        )
    }
}

