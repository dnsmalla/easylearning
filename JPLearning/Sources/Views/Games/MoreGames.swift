//
//  MoreGames.swift
//  JLearn
//
//  Additional game implementations
//

import SwiftUI

// MARK: - Sentence Builder

struct SentenceBuilderGame: View {
    @EnvironmentObject var learningDataService: LearningDataService
    var game: GameModel?
    
    @State private var questions: [GameModel.Question] = []
    @State private var grammarPoints: [GrammarPoint] = []
    @State private var currentIndex = 0
    @State private var wordBlocks: [WordBlock] = []
    @State private var selectedBlocks: [WordBlock] = []
    @State private var correctSentence: String = ""
    @State private var currentTranslation: String = ""
    @State private var showResult = false
    @State private var score = 0
    @State private var isLoading = true
    @State private var showCompleted = false
    
    struct WordBlock: Identifiable, Equatable {
        let id = UUID()
        let word: String
        let isUsed: Bool
    }
    
    var totalCount: Int {
        if let game = game, let questions = game.questions {
            return questions.count
        }
        return grammarPoints.count
    }
    
    var builtSentence: String {
        selectedBlocks.map { $0.word }.joined()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if showCompleted {
                completedView
            } else {
                // Progress Header
                VStack(spacing: 8) {
                    HStack {
                        Text("Sentence \(currentIndex + 1) of \(totalCount)")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Score: \(score)")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.purple)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(Color.white)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Instructions
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Build the sentence:")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(.secondary)
                            Text(currentTranslation)
                                .font(AppTheme.Typography.headline)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Built Sentence Area
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Sentence:")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(.secondary)
                            
                            if selectedBlocks.isEmpty {
                                Text("Tap words below to build the sentence")
                                    .font(AppTheme.Typography.body)
                                    .foregroundColor(.secondary)
                                    .italic()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .frame(minHeight: 80)
                            } else {
                                FlowLayout(spacing: 8) {
                                    ForEach(selectedBlocks) { block in
                                        WordBlockView(
                                            word: block.word,
                                            color: .purple,
                                            isSelected: true
                                        ) {
                                            removeBlock(block)
                                        }
                                    }
                                }
                                .frame(minHeight: 80)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.purple.opacity(0.3), lineWidth: 2)
                        )
                        
                        // Available Words
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Available Words:")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(.secondary)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(wordBlocks.filter { !$0.isUsed }) { block in
                                    WordBlockView(
                                        word: block.word,
                                        color: .gray,
                                        isSelected: false
                                    ) {
                                        addBlock(block)
                                    }
                                }
                            }
                        }
                        .padding()
                        
                        // Check Button
                        if !selectedBlocks.isEmpty && !showResult {
                            Button {
                                checkSentence()
                            } label: {
                                Text("Check Sentence")
                                    .font(AppTheme.Typography.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.purple)
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
                            }
                        }
                        
                        // Result
                        if showResult {
                            VStack(spacing: 16) {
                                HStack {
                                    Image(systemName: builtSentence == correctSentence ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(builtSentence == correctSentence ? AppTheme.success : AppTheme.danger)
                                    Text(builtSentence == correctSentence ? "Correct!" : "Not quite right")
                                        .font(AppTheme.Typography.headline)
                                        .foregroundColor(builtSentence == correctSentence ? AppTheme.success : AppTheme.danger)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Correct Sentence:")
                                        .font(AppTheme.Typography.caption)
                                        .foregroundColor(.secondary)
                                    Text(correctSentence)
                                        .font(AppTheme.Typography.japaneseBody)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(AppTheme.success.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                Button {
                                    nextSentence()
                                } label: {
                                    Text("Next")
                                        .font(AppTheme.Typography.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.purple)
                                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding()
                }
            }
        }
        .background(AppTheme.background)
        .navigationTitle("Sentence Builder")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadGameData()
        }
    }
    
    private var completedView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "checkmark.seal.fill")
            .font(.system(size: 80))
            .foregroundColor(.purple)
            
            Text("All Sentences Complete!")
                .font(AppTheme.Typography.title)
            
            Text("Final Score: \(score) / \(totalCount)")
                .font(AppTheme.Typography.title3)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button {
                restartGame()
            } label: {
                Text("Play Again")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
            }
            .padding()
        }
    }
    
    private func loadGameData() async {
        isLoading = true
        if let game = game, let gameQuestions = game.questions {
            self.questions = gameQuestions
        } else {
            // Fallback to grammar points
            grammarPoints = learningDataService.grammarPoints.filter { !$0.examples.isEmpty }
        }
        
        if totalCount > 0 {
            setupSentence()
        }
        isLoading = false
    }
    
    private func setupSentence() {
        if let game = game, let gameQuestions = game.questions {
            guard currentIndex < gameQuestions.count else { return }
            let question = gameQuestions[currentIndex]
            correctSentence = question.sentence ?? ""
            currentTranslation = question.translation ?? "Build the sentence"
            
            let options = question.options
            wordBlocks = options.shuffled().map { WordBlock(word: $0, isUsed: false) }
        } else {
            // Fallback logic
            guard currentIndex < grammarPoints.count else { return }
            let grammar = grammarPoints[currentIndex]
            guard let example = grammar.examples.first else { return }
            
            correctSentence = example.japanese
            currentTranslation = example.english
            
            let words = splitJapaneseSentence(example.japanese)
            wordBlocks = words.shuffled().map { WordBlock(word: $0, isUsed: false) }
        }
        
        selectedBlocks = []
        showResult = false
    }
    
    private func splitJapaneseSentence(_ sentence: String) -> [String] {
        return sentence.map { String($0) }
    }
    
    private func addBlock(_ block: WordBlock) {
        if let index = wordBlocks.firstIndex(where: { $0.id == block.id }) {
            wordBlocks[index] = WordBlock(word: block.word, isUsed: true)
            selectedBlocks.append(block)
        }
    }
    
    private func removeBlock(_ block: WordBlock) {
        selectedBlocks.removeAll { $0.id == block.id }
        if let index = wordBlocks.firstIndex(where: { $0.word == block.word && $0.isUsed }) {
            wordBlocks[index] = WordBlock(word: block.word, isUsed: false)
        }
    }
    
    private func checkSentence() {
        if builtSentence == correctSentence {
            score += 1
            Haptics.success()
        } else {
            Haptics.error()
        }
        showResult = true
    }
    
    private func nextSentence() {
        if currentIndex < totalCount - 1 {
            currentIndex += 1
            setupSentence()
        } else {
            showCompleted = true
        }
    }
    
    private func restartGame() {
        currentIndex = 0
        score = 0
        showCompleted = false
        setupSentence()
    }
}

// MARK: - Listening Game View

struct ListeningGameView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    var game: GameModel
    
    @StateObject private var audioService = AudioService.shared
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var showResult = false
    @State private var selectedOption: String?
    @State private var isPlaying = false
    @State private var showCompleted = false
    
    var questions: [GameModel.Question] {
        game.questions ?? []
    }
    
    var currentQuestion: GameModel.Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if showCompleted {
                completedView
            } else if let question = currentQuestion {
                // Header
                VStack(spacing: 8) {
                    HStack {
                        Text("Question \(currentIndex + 1) of \(questions.count)")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Score: \(score)")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.red)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal)
                    
                    ProgressView(value: Double(currentIndex), total: Double(questions.count))
                        .tint(.red)
                        .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(Color.white)
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Audio Button
                        Button {
                            playAudio(for: question)
                        } label: {
                            VStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.red.opacity(0.1))
                                        .frame(width: 120, height: 120)
                                    
                                    Image(systemName: isPlaying ? "speaker.wave.3.fill" : "play.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.red)
                                }
                                
                                Text(isPlaying ? "Playing..." : "Tap to Listen")
                                    .font(AppTheme.Typography.headline)
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Options
                        VStack(spacing: 12) {
                            Text("Select the correct meaning:")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            ForEach(question.options, id: \.self) { option in
                                Button {
                                    if !showResult {
                                        checkAnswer(option)
                                    }
                                } label: {
                                    HStack {
                                        Text(option)
                                            .font(AppTheme.Typography.body)
                                            .foregroundColor(optionTextColor(option, correct: question.correctMeaning))
                                        
                                        Spacer()
                                        
                                        if showResult {
                                            if option == question.correctMeaning {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(AppTheme.success)
                                            } else if option == selectedOption {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(AppTheme.danger)
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(optionBackgroundColor(option, correct: question.correctMeaning))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(optionBorderColor(option, correct: question.correctMeaning), lineWidth: 1)
                                    )
                                }
                                .disabled(showResult)
                            }
                        }
                        
                        // Next Button
                        if showResult {
                            Button {
                                nextQuestion()
                            } label: {
                                Text("Next")
                                    .font(AppTheme.Typography.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .background(AppTheme.background)
        .navigationTitle(game.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Auto-play audio when question appears? Maybe better to let user tap.
        }
    }
    
    private var completedView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "headphones.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.red)
            
            Text("Listening Challenge Complete!")
                .font(AppTheme.Typography.title)
                .multilineTextAlignment(.center)
            
            Text("Final Score: \(score) / \(questions.count)")
                .font(AppTheme.Typography.title3)
                .foregroundColor(.secondary)
            Spacer()
            
            Button {
                restartGame()
            } label: {
                Text("Play Again")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
            }
            .padding()
        }
    }
    
    private func playAudio(for question: GameModel.Question) {
        isPlaying = true
        Task {
            // Prioritize sentence audio if available, otherwise word
            let textToSpeak = question.sentence ?? question.word ?? ""
            try? await audioService.speak(textToSpeak, language: "ja-JP")
            isPlaying = false
        }
    }
    
    private func checkAnswer(_ option: String) {
        selectedOption = option
        showResult = true
        
        if let current = currentQuestion, option == current.correctMeaning {
            score += 1
            Haptics.success()
        } else {
            Haptics.error()
        }
    }
    
    private func nextQuestion() {
        if currentIndex < questions.count - 1 {
            currentIndex += 1
            showResult = false
            selectedOption = nil
        } else {
            showCompleted = true
        }
    }
    
    private func restartGame() {
        currentIndex = 0
        score = 0
        showCompleted = false
        showResult = false
        selectedOption = nil
    }
    
    // Helper colors
    private func optionBackgroundColor(_ option: String, correct: String?) -> Color {
        if showResult {
            if option == correct { return AppTheme.success.opacity(0.1) }
            if option == selectedOption { return AppTheme.danger.opacity(0.1) }
        }
        return Color.white
    }
    
    private func optionBorderColor(_ option: String, correct: String?) -> Color {
        if showResult {
            if option == correct { return AppTheme.success }
            if option == selectedOption { return AppTheme.danger }
        }
        return AppTheme.separator
    }
    
    private func optionTextColor(_ option: String, correct: String?) -> Color {
        if showResult {
            if option == correct { return AppTheme.success }
            if option == selectedOption { return AppTheme.danger }
        }
        return .primary
    }
}

struct WordBlockView: View {
    let word: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(word)
                .font(AppTheme.Typography.japaneseBody)
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? color : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color, lineWidth: 2)
                )
        }
    }
}

// FlowLayout is now in CommonViews.swift

