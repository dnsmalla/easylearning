//
//  GamesView.swift
//  JLearn
//
//  Interactive learning games
//

import SwiftUI
import AVFoundation
import Speech

struct GamesView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Learning Games")
                            .font(AppTheme.Typography.largeTitle)
                        
                        Text("Make learning fun and interactive")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.mutedText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                    
                    // Level Indicator
                    LevelIndicatorBar()
                        .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                    
                    // Games Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(learningDataService.games) { game in
                            GameCard(
                                title: game.title,
                                icon: iconForGameType(game.type),
                                color: colorForGameType(game.type),
                                description: game.description,
                                destination: destinationForGame(game)
                            )
                        }
                        
                        if learningDataService.games.isEmpty {
                            // Fallback if no games loaded
                            Text("No games available for this level")
                                .foregroundColor(.secondary)
                                .font(AppTheme.Typography.caption)
                        }
                    }
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                }
                .padding(.vertical, 24)
            }
            .background(AppTheme.background)
            .onAppear {
                AnalyticsService.shared.trackScreen("Games", screenClass: "GamesView")
            }
        }
    }
    
    private func iconForGameType(_ type: String) -> String {
        switch type {
        case "matching": return "square.grid.2x2"
        case "speed_quiz": return "timer"
        case "fill_blank": return "square.dashed"
        case "memory": return "rectangle.on.rectangle"
        case "sentence_builder": return "text.bubble.fill"
        case "listening": return "headphones"
        default: return "gamecontroller"
        }
    }
    
    private func colorForGameType(_ type: String) -> Color {
        switch type {
        case "matching": return .green
        case "speed_quiz": return .orange
        case "fill_blank": return .purple
        case "memory": return .blue
        case "sentence_builder": return .purple
        case "listening": return .red
        default: return .gray
        }
    }
    
    private func destinationForGame(_ game: GameModel) -> AnyView {
        switch game.type {
        case "matching":
            return AnyView(WordMatchView(game: game))
        case "speed_quiz":
            return AnyView(TimeAttackView(game: game))
        case "kanji_quiz":
            return AnyView(KanjiQuizView(game: game))
        case "grammar_fill":
            return AnyView(GrammarFillView(game: game))
        case "listening":
            return AnyView(ListeningGameView(game: game))
        case "sentence_builder":
            return AnyView(SentenceBuilderGameView(game: game))
        case "particle_quiz":
            return AnyView(ParticleQuizView(game: game))
        case "mixed_quiz":
            return AnyView(MixedQuizView(game: game))
        case "fill_blank":
            return AnyView(FillInBlankView(game: game))
        case "memory":
            return AnyView(MemoryCardsView(game: game))
        default:
            return AnyView(PlaceholderGameView(title: game.title, icon: "gamecontroller", color: .gray))
        }
    }
}

// MARK: - Game Card

struct GameCard: View {
    let title: String
    let icon: String
    let color: Color
    let description: String
    let destination: AnyView
    
    var body: some View {
        NavigationLink {
            destination
        } label: {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: icon)
                        .font(.system(size: 32))
                        .foregroundColor(color)
                }
                
                VStack(spacing: 6) {
                    Text(title)
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(description)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.mutedText)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, 12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
            .shadow(
                color: AppTheme.Shadows.elevation2.color,
                radius: AppTheme.Shadows.elevation2.radius,
                y: AppTheme.Shadows.elevation2.y
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Game Placeholder Views


struct WordMatchView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    var game: GameModel?
    
    @State private var flashcards: [Flashcard] = []
    @State private var matchPairs: [(japanese: String, english: String, id: String)] = []
    @State private var shuffledEnglishPairs: [(japanese: String, english: String, id: String)] = []
    @State private var selectedJapanese: String?
    @State private var selectedEnglish: String?
    @State private var matchedPairs: Set<String> = []
    @State private var score = 0
    @State private var attempts = 0
    @State private var isLoading = true
    @State private var showCompleted = false
    
    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                Spacer()
                ProgressView()
                    .scaleEffect(1.5)
                Spacer()
            } else if matchPairs.isEmpty {
                ProfessionalEmptyStateView(
                    icon: "square.grid.2x2",
                    title: "No Words Available",
                    message: "Check back later for new content"
                )
            } else if showCompleted {
                completedView
            } else {
                // Progress Header
                VStack(spacing: 8) {
                    HStack {
                        Text("\(matchedPairs.count) / \(matchPairs.count) matched")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Score: \(score)")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.green)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal)
                    
                    ProgressView(value: Double(matchedPairs.count), total: Double(matchPairs.count))
                        .tint(.green)
                        .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(Color.white)
                
                ScrollView {
                    VStack(spacing: 24) {
                        Text("Match the Japanese words with their English meanings")
                            .font(AppTheme.Typography.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        HStack(alignment: .top, spacing: 16) {
                            // Japanese Column
                            VStack(spacing: 12) {
                                ForEach(matchPairs, id: \.id) { pair in
                                    if !matchedPairs.contains(pair.id) {
                                        MatchCard(
                                            text: pair.japanese,
                                            isSelected: selectedJapanese == pair.id,
                                            color: .green,
                                            isJapanese: true
                                        ) {
                                            selectJapanese(pair.id)
                                        }
                                    } else {
                                        MatchedCard(text: pair.japanese, isJapanese: true)
                                    }
                                }
                            }
                            
                            // English Column (shuffled order)
                            VStack(spacing: 12) {
                                ForEach(shuffledEnglishPairs, id: \.id) { pair in
                                    if !matchedPairs.contains(pair.id) {
                                        MatchCard(
                                            text: pair.english,
                                            isSelected: selectedEnglish == pair.id,
                                            color: .green,
                                            isJapanese: false
                                        ) {
                                            selectEnglish(pair.id)
                                        }
                                    } else {
                                        MatchedCard(text: pair.english, isJapanese: false)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .background(AppTheme.background)
        .navigationTitle("Word Match")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadWords()
        }
        .reloadOnLevelChange {
            await loadWords()
        }
    }
    
    private var completedView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("All Matched!")
                .font(AppTheme.Typography.title)
                .foregroundColor(.primary)
            
            Text("Score: \(score) points")
                .font(AppTheme.Typography.title3)
                .foregroundColor(.secondary)
            
            Text("\(attempts) attempts")
                .font(AppTheme.Typography.body)
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
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
            }
            .padding()
        }
    }
    
    private func loadWords() async {
        isLoading = true
        
        print("🎮 [WORD MATCH] Loading words...")
        print("🎮 [WORD MATCH] Game: \(game?.title ?? "nil")")
        print("🎮 [WORD MATCH] Game pairs count: \(game?.pairs?.count ?? 0)")
        
        // Use game data if available
        if let gamePairs = game?.pairs, !gamePairs.isEmpty {
            print("🎮 [WORD MATCH] Using game pairs: \(gamePairs.count)")
            matchPairs = gamePairs.enumerated().map { (index, pair) in
                (japanese: pair.kanji, english: pair.meaning, id: "\(game?.id ?? "game")_\(index)")
            }
            print("🎮 [WORD MATCH] Match pairs created: \(matchPairs.count)")
            print("🎮 [WORD MATCH] First pair: \(matchPairs.first?.japanese ?? "none") - \(matchPairs.first?.english ?? "none")")
        } else {
            print("🎮 [WORD MATCH] No game pairs, using flashcards fallback")
            // Fallback to random flashcards
            if !learningDataService.flashcards.isEmpty {
                flashcards = learningDataService.flashcards
            }
            
            // Create match pairs from flashcards - keep the correct ID mapping
            let selectedCards = Array(flashcards.shuffled().prefix(6))
            matchPairs = selectedCards.map { card in
                (japanese: card.front, english: card.meaning, id: card.id)
            }
        }
        
        // Create shuffled version for English column display
        shuffledEnglishPairs = matchPairs.shuffled()
        
        isLoading = false
    }
    
    private func selectJapanese(_ id: String) {
        selectedJapanese = id
        checkMatch()
    }
    
    private func selectEnglish(_ id: String) {
        selectedEnglish = id
        checkMatch()
    }
    
    private func checkMatch() {
        guard let japaneseId = selectedJapanese,
              let englishId = selectedEnglish else { return }
        
        attempts += 1
        
        // Find the correct pair for the selected japanese
        if let japanesePair = matchPairs.first(where: { $0.id == japaneseId }),
           let englishPair = matchPairs.first(where: { $0.id == englishId }) {
            
            // Check if they match
            if japanesePair.english == englishPair.english {
                // Correct match!
                matchedPairs.insert(japaneseId)
                score += 10
                Haptics.success()
                
                // Check if all matched
                if matchedPairs.count == matchPairs.count {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            showCompleted = true
                        }
                    }
                }
            } else {
                // Wrong match
                Haptics.error()
            }
        }
        
        // Reset selections
        selectedJapanese = nil
        selectedEnglish = nil
    }
    
    private func restartGame() {
        withAnimation {
            matchedPairs.removeAll()
            score = 0
            attempts = 0
            showCompleted = false
        }
        Task {
            await loadWords()
        }
    }
}

struct MatchCard: View {
    let text: String
    let isSelected: Bool
    let color: Color
    let isJapanese: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(isJapanese ? AppTheme.Typography.japaneseBody : AppTheme.Typography.body)
                .foregroundColor(isSelected ? .white : .primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 60)
                .padding()
                .background(isSelected ? color : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius)
                        .stroke(isSelected ? color : AppTheme.separator, lineWidth: 2)
                )
                .shadow(
                    color: isSelected ? color.opacity(0.3) : AppTheme.Shadows.elevation1.color,
                    radius: isSelected ? 8 : AppTheme.Shadows.elevation1.radius,
                    y: AppTheme.Shadows.elevation1.y
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct MatchedCard: View {
    let text: String
    let isJapanese: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text(text)
                .font(isJapanese ? AppTheme.Typography.japaneseBody : AppTheme.Typography.body)
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 60)
        .padding()
        .background(Color.green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius)
                .stroke(Color.green, lineWidth: 2)
        )
    }
}

struct TimeAttackView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    var game: GameModel?
    
    @State private var questions: [PracticeQuestion] = []
    @State private var currentIndex = 0
    @State private var selectedAnswer: String?
    @State private var score = 0
    @State private var isLoading = true
    @State private var showResults = false
    @State private var timeRemaining = 60
    @State private var isTimerRunning = false
    @State private var timer: Timer?
    
    var currentQuestion: PracticeQuestion? {
        guard !questions.isEmpty && currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                Spacer()
                ProgressView()
                    .scaleEffect(1.5)
                Spacer()
            } else if showResults {
                resultsView
            } else if !isTimerRunning {
                startView
            } else if let question = currentQuestion {
                // Timer Header
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "timer")
                            .foregroundColor(.orange)
                        Text("\(timeRemaining)s")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(timeRemaining <= 10 ? .red : .orange)
                        Spacer()
                        Text("\(score) pts")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(.orange)
                    }
                    .padding()
                    
                    ProgressView(value: Double(60 - timeRemaining), total: 60)
                        .tint(timeRemaining <= 10 ? .red : .orange)
                }
                .background(Color.white)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Question Number
                        Text("Question \(currentIndex + 1)")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.secondary)
                        
                        // Question
                        Text(question.question)
                            .font(AppTheme.Typography.title3)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                        
                        // Answer Options
                        VStack(spacing: 12) {
                            ForEach(question.options, id: \.self) { option in
                                Button {
                                    answerQuestion(option)
                                } label: {
                                    Text(option)
                                        .font(AppTheme.Typography.body)
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius)
                                                .stroke(Color.orange, lineWidth: 2)
                                        )
                                }
                            }
                        }
                    }
                    .padding()
                }
                .background(AppTheme.background)
            }
        }
        .navigationTitle("Time Attack")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadQuestions()
        }
        .reloadOnLevelChange {
            await loadQuestions()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var startView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "timer")
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            VStack(spacing: 16) {
                Text("Time Attack!")
                    .font(AppTheme.Typography.largeTitle)
                    .fontWeight(.bold)
                
                Text("Answer as many questions as you can in \(game?.timeLimit ?? 60) seconds!")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Correct answer: +10 points")
                    }
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Text("Wrong answer: -5 points")
                    }
                }
                .font(AppTheme.Typography.body)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Spacer()
            
            Button {
                startGame()
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start Game")
                        .font(AppTheme.Typography.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
            }
            .padding()
        }
        .background(AppTheme.background)
    }
    
    private var resultsView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "flag.checkered")
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            Text("Time's Up!")
                .font(AppTheme.Typography.title)
            
            VStack(spacing: 16) {
                HStack {
                    Text("Final Score:")
                        .font(AppTheme.Typography.body)
                    Spacer()
                    Text("\(score) points")
                        .font(AppTheme.Typography.title)
                        .foregroundColor(.orange)
                }
                
                HStack {
                    Text("Questions Answered:")
                        .font(AppTheme.Typography.body)
                    Spacer()
                    Text("\(currentIndex)")
                        .font(AppTheme.Typography.headline)
                }
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            
            Spacer()
            
            Button {
                restartGame()
            } label: {
                Text("Play Again")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
            }
            .padding()
        }
        .background(AppTheme.background)
    }
    
    private func loadQuestions() async {
        isLoading = true
        
        if let gameQuestions = game?.questions, !gameQuestions.isEmpty {
            // Map GameModel.Question to PracticeQuestion
            questions = gameQuestions.enumerated().map { (index, q) in
                PracticeQuestion(
                    id: "\(game?.id ?? "game")_q_\(index)",
                    question: q.word ?? "Question", // Fallback if word is nil
                    options: q.options,
                    correctAnswer: q.correctMeaning ?? q.options.first ?? "",
                    explanation: nil,
                    category: .vocabulary, // Default
                    level: game?.level ?? "N5"
                )
            }
        } else {
            var allQuestions: [PracticeQuestion] = []
            for category in [PracticeCategory.kanji, .vocabulary, .grammar] {
                let categoryQuestions = await learningDataService.loadPracticeQuestions(category: category)
                allQuestions.append(contentsOf: categoryQuestions)
            }
            questions = allQuestions.shuffled()
        }
        
        isLoading = false
    }
    
    private func startGame() {
        timeRemaining = game?.timeLimit ?? 60
        currentIndex = 0
        score = 0
        isTimerRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                endGame()
            }
        }
    }
    
    private func answerQuestion(_ answer: String) {
        guard let question = currentQuestion else { return }
        
        if answer == question.correctAnswer {
            score += 10
            Haptics.success()
        } else {
            score = max(0, score - 5)
            Haptics.error()
        }
        
        currentIndex += 1
        
        if currentIndex >= questions.count {
            endGame()
        }
    }
    
    private func endGame() {
        timer?.invalidate()
        isTimerRunning = false
        showResults = true
    }
    
    private func restartGame() {
        currentIndex = 0
        score = 0
        timeRemaining = game?.timeLimit ?? 60
        showResults = false
        isTimerRunning = false
    }
}

struct SentenceBuilderView: View {
    var body: some View {
        SentenceBuilderGame()
    }
}

struct QuickQuizView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @State private var questions: [PracticeQuestion] = []
    @State private var currentIndex = 0
    @State private var selectedAnswer: String?
    @State private var showResult = false
    @State private var score = 0
    @State private var showResults = false
    @State private var isLoading = true
    
    var currentQuestion: PracticeQuestion? {
        guard !questions.isEmpty && currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentIndex) / Double(questions.count)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                Spacer()
                ProgressView()
                    .scaleEffect(1.5)
                Spacer()
            } else if questions.isEmpty {
                ProfessionalEmptyStateView(
                    icon: "questionmark.circle",
                    title: "No Questions Available",
                    message: "Check back later for new content"
                )
            } else if showResults {
                resultsView
            } else if let question = currentQuestion {
                // Progress Header
                VStack(spacing: 8) {
                    HStack {
                        Text("Question \(currentIndex + 1) of \(questions.count)")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(score) correct")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.red)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(AppTheme.separator)
                                .frame(height: 4)
                            
                            Rectangle()
                                .fill(Color.red)
                                .frame(width: geometry.size.width * progress, height: 4)
                        }
                    }
                    .frame(height: 4)
                }
                .padding(.top, 8)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Question Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "questionmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.red)
                                Text(question.category.rawValue)
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(.red)
                                    .fontWeight(.semibold)
                            }
                            
                            Text(question.question)
                                .font(AppTheme.Typography.title3)
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                        .shadow(
                            color: AppTheme.Shadows.elevation2.color,
                            radius: AppTheme.Shadows.elevation2.radius,
                            y: AppTheme.Shadows.elevation2.y
                        )
                        
                        // Answer Options
                        VStack(spacing: 12) {
                            ForEach(question.options, id: \.self) { option in
                                ProfessionalAnswerButton(
                                    text: option,
                                    isSelected: selectedAnswer == option,
                                    isCorrect: showResult && option == question.correctAnswer,
                                    isWrong: showResult && selectedAnswer == option && option != question.correctAnswer
                                ) {
                                    if !showResult {
                                        selectedAnswer = option
                                        checkAnswer()
                                    }
                                }
                            }
                        }
                        
                        // Explanation
                        if showResult, let explanation = question.explanation {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: selectedAnswer == question.correctAnswer ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(selectedAnswer == question.correctAnswer ? AppTheme.success : AppTheme.danger)
                                    Text(selectedAnswer == question.correctAnswer ? "Correct!" : "Incorrect")
                                        .font(AppTheme.Typography.headline)
                                        .foregroundColor(selectedAnswer == question.correctAnswer ? AppTheme.success : AppTheme.danger)
                                }
                                
                                Text(explanation)
                                    .font(AppTheme.Typography.body)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(AppTheme.secondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
                        }
                        
                        // Next Button
                        if showResult {
                            Button {
                                nextQuestion()
                            } label: {
                                HStack {
                                    Text("Next")
                                        .font(AppTheme.Typography.headline)
                                    Image(systemName: "arrow.right")
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
                                .shadow(
                                    color: AppTheme.Shadows.elevation2.color,
                                    radius: AppTheme.Shadows.elevation2.radius,
                                    y: AppTheme.Shadows.elevation2.y
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .background(AppTheme.background)
        .navigationTitle("Quick Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadQuestions()
        }
        .reloadOnLevelChange {
            await loadQuestions()
        }
    }
    
    private var resultsView: some View {
        ProfessionalResultsView(
            score: score,
            total: questions.count,
            title: "Quiz Complete!",
            icon: "checkmark.seal.fill",
            color: .red,
            restartAction: restartQuiz
        )
    }
    
    private func loadQuestions() async {
        isLoading = true
        
        // Load mixed questions from different categories
        var allQuestions: [PracticeQuestion] = []
        
        for category in [PracticeCategory.kanji, .vocabulary, .grammar] {
            let categoryQuestions = await learningDataService.loadPracticeQuestions(category: category)
            allQuestions.append(contentsOf: categoryQuestions.prefix(3)) // Take 3 from each
        }
        
        questions = allQuestions.shuffled()
        isLoading = false
    }
    
    private func checkAnswer() {
        let isCorrect = selectedAnswer == currentQuestion?.correctAnswer
        if isCorrect {
            score += 1
            Haptics.success()
        } else {
            Haptics.error()
        }
        
        withAnimation {
            showResult = true
        }
    }
    
    private func nextQuestion() {
        if currentIndex < questions.count - 1 {
            withAnimation {
                currentIndex += 1
                selectedAnswer = nil
                showResult = false
            }
        } else {
            withAnimation {
                showResults = true
            }
        }
    }
    
    private func restartQuiz() {
        withAnimation {
            currentIndex = 0
            selectedAnswer = nil
            showResult = false
            score = 0
            showResults = false
        }
        Task {
            await loadQuestions()
        }
    }
}

struct FlashcardSprintView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @State private var flashcards: [Flashcard] = []
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var timeRemaining = 30
    @State private var isTimerRunning = false
    @State private var showResults = false
    @State private var isLoading = true
    @State private var timer: Timer?
    @State private var showFront = true
    
    var currentCard: Flashcard? {
        guard !flashcards.isEmpty && currentIndex < flashcards.count else { return nil }
        return flashcards[currentIndex]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if showResults {
                resultsView
            } else if !isTimerRunning {
                startView
            } else if let card = currentCard {
                // Timer Header
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.yellow)
                        Text("\(timeRemaining)s")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(timeRemaining <= 10 ? .red : .yellow)
                        Spacer()
                        Text("\(score) cards")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(.yellow)
                    }
                    .padding()
                    
                    ProgressView(value: Double(30 - timeRemaining), total: 30)
                        .tint(.yellow)
                }
                .background(Color.white)
                
                Spacer()
                
                // Flashcard
                VStack(spacing: 32) {
                    // Card
                    Button {
                        withAnimation {
                            showFront.toggle()
                        }
                    } label: {
                        VStack(spacing: 16) {
                            Text(showFront ? "Front" : "Back")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(.secondary)
                            
                            Text(showFront ? card.front : card.back)
                                .font(.system(size: 40))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            if !showFront {
                                Text(card.meaning)
                                    .font(AppTheme.Typography.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(
                            color: .yellow.opacity(0.3),
                            radius: 10,
                            y: 5
                        )
                        .rotation3DEffect(
                            .degrees(showFront ? 0 : 180),
                            axis: (x: 0, y: 1, z: 0)
                        )
                    }
                    .padding(.horizontal, 32)
                    
                    // Action Buttons
                    HStack(spacing: 16) {
                        // Wrong Button
                        Button {
                            nextCard(correct: false)
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 40))
                                Text("Wrong")
                                    .font(AppTheme.Typography.caption)
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Correct Button
                        Button {
                            nextCard(correct: true)
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 40))
                                Text("Correct")
                                    .font(AppTheme.Typography.caption)
                            }
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal, 32)
                }
                
                Spacer()
            }
        }
        .background(AppTheme.background)
        .navigationTitle("Flashcard Sprint")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadFlashcards()
        }
        .reloadOnLevelChange {
            await loadFlashcards()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var startView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "bolt.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.yellow)
            
            VStack(spacing: 16) {
                Text("Flashcard Sprint")
                    .font(AppTheme.Typography.largeTitle)
                    .fontWeight(.bold)
                
                Text("Review as many flashcards as you can in 30 seconds!")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "hand.tap.fill")
                            .foregroundColor(.blue)
                        Text("Tap card to flip")
                    }
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Tap Correct if you knew it")
                    }
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Text("Tap Wrong if you didn't")
                    }
                }
                .font(AppTheme.Typography.body)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Spacer()
            
            Button {
                startGame()
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start Sprint")
                        .font(AppTheme.Typography.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.yellow)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
            }
            .padding()
        }
        .background(AppTheme.background)
    }
    
    private var resultsView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "bolt.badge.checkmark.fill")
                .font(.system(size: 80))
                .foregroundColor(.yellow)
            
            Text("Sprint Complete!")
                .font(AppTheme.Typography.title)
            
            VStack(spacing: 16) {
                HStack {
                    Text("Cards Reviewed:")
                        .font(AppTheme.Typography.body)
                    Spacer()
                    Text("\(score)")
                        .font(AppTheme.Typography.title)
                        .foregroundColor(.yellow)
                }
                
                if score > 0 {
                    HStack {
                        Text("Speed:")
                            .font(AppTheme.Typography.body)
                        Spacer()
                        Text(String(format: "%.1f", 30.0 / Double(score)) + " sec/card")
                            .font(AppTheme.Typography.headline)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            
            Spacer()
            
            Button {
                restartGame()
            } label: {
                Text("Sprint Again")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.yellow)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
            }
            .padding()
        }
        .background(AppTheme.background)
    }
    
    private func loadFlashcards() async {
        isLoading = true
        flashcards = learningDataService.flashcards.shuffled()
        isLoading = false
    }
    
    private func startGame() {
        timeRemaining = 30
        currentIndex = 0
        score = 0
        showFront = true
        isTimerRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                endGame()
            }
        }
    }
    
    private func nextCard(correct: Bool) {
        if correct {
            score += 1
            Haptics.success()
        } else {
            Haptics.error()
        }
        
        currentIndex += 1
        showFront = true
        
        if currentIndex >= flashcards.count {
            endGame()
        }
    }
    
    private func endGame() {
        timer?.invalidate()
        isTimerRunning = false
        showResults = true
    }
    
    private func restartGame() {
        currentIndex = 0
        score = 0
        timeRemaining = 30
        showResults = false
        isTimerRunning = false
        flashcards = flashcards.shuffled()
    }
}

struct PlaceholderGameView: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        ProfessionalEmptyStateView(
            icon: icon,
            title: title,
            message: "Coming soon!"
        )
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Exercise Detail View

struct ExerciseDetailView: View {
    let exercise: Exercise
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: String?
    @State private var showResult = false
    @State private var score = 0
    
    var currentQuestion: PracticeQuestion? {
        guard currentQuestionIndex < exercise.questions.count else { return nil }
        return exercise.questions[currentQuestionIndex]
    }
    
    var progressHeader: some View {
            VStack(spacing: 8) {
                ProgressView(value: Double(currentQuestionIndex + 1), total: Double(exercise.questions.count))
                    .tint(AppTheme.brandPrimary)
                
                HStack {
                    Text("Question \(currentQuestionIndex + 1) of \(exercise.questions.count)")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.mutedText)
                    
                    Spacer()
                    
                    Text("Score: \(score)")
                        .font(AppTheme.Typography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.brandPrimary)
                }
            }
            .padding()
            .background(Color.white)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress
            progressHeader
            
            if let question = currentQuestion {
                ScrollView {
                    VStack(spacing: 24) {
                        // Question
                        Text(question.question)
                            .font(AppTheme.Typography.title3)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                        
                        // Options
                        if !question.options.isEmpty {
                            VStack(spacing: 12) {
                                ForEach(question.options, id: \.self) { option in
                                    ProfessionalAnswerButton(
                                        text: option,
                                        isSelected: selectedAnswer == option,
                                        isCorrect: showResult && option == question.correctAnswer,
                                        isWrong: showResult && selectedAnswer == option && option != question.correctAnswer
                                    ) {
                                        if !showResult {
                                            selectedAnswer = option
                                            checkAnswer()
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Next Button
                        if showResult {
                            Button {
                                nextQuestion()
                            } label: {
                                Text(currentQuestionIndex < exercise.questions.count - 1 ? "Next Question" : "Finish")
                                    .font(AppTheme.Typography.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(AppTheme.brandPrimary)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding()
                }
            } else {
                // Completed
                VStack(spacing: 24) {
                    Spacer()
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(AppTheme.success)
                    
                    Text("Exercise Complete!")
                        .font(AppTheme.Typography.title)
                        .foregroundColor(.primary)
                    
                    Text("Final Score: \(score)/\(exercise.questions.count)")
                        .font(AppTheme.Typography.title3)
                        .foregroundColor(AppTheme.mutedText)
                    
                    Spacer()
                }
            }
        }
        .background(AppTheme.background)
        .navigationTitle(exercise.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func checkAnswer() {
        guard let question = currentQuestion else { return }
        
        if selectedAnswer == question.correctAnswer {
            score += 1
            Haptics.success()
        } else {
            Haptics.error()
        }
        
        withAnimation {
            showResult = true
        }
    }
    
    private func nextQuestion() {
        currentQuestionIndex += 1
        selectedAnswer = nil
        showResult = false
    }
}

// MARK: - Answer Button is now ProfessionalAnswerButton in CommonViews

// MARK: - New Game Views

// Memory Cards Game
struct MemoryCardsView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    var game: GameModel?
    
    @State private var cards: [MemoryCard] = []
    @State private var flippedCards: Set<UUID> = []
    @State private var matchedCards: Set<UUID> = []
    @State private var score = 0
    @State private var moves = 0
    @State private var isLoading = true
    @State private var showCompleted = false
    
    var body: some View {
        VStack(spacing: 24) {
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            } else if cards.isEmpty {
                ProfessionalEmptyStateView(
                    icon: "rectangle.on.rectangle",
                    title: "No Cards Available",
                    message: "Check back later for new content"
                )
            } else if showCompleted {
                ProfessionalResultsView(
                    score: score,
                    total: 100, // Normalized score
                    title: "Memory Master!",
                    icon: "brain.head.profile",
                    color: .blue,
                    restartAction: restartGame
                )
        } else {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Moves: \(moves)")
                            .font(AppTheme.Typography.headline)
                        Text("Matches: \(matchedCards.count / 2)/8")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.mutedText)
                    }
                    
                    Spacer()
                    
                    Text("Score: \(score)")
                        .font(AppTheme.Typography.title3)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.brandPrimary)
                }
                .padding()
                
                // Cards Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(cards) { card in
                        MemoryCardView(
                            card: card,
                            isFlipped: flippedCards.contains(card.id) || matchedCards.contains(card.id),
                            isMatched: matchedCards.contains(card.id)
                        )
                        .onTapGesture {
                            handleCardTap(card)
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
        }
        .background(AppTheme.background)
        .navigationTitle("Memory Cards")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadCards()
        }
        .reloadOnLevelChange {
            await loadCards()
        }
    }
    
    func loadCards() async {
        isLoading = true
        
        var newCards: [MemoryCard] = []
        
        if let gameCards = game?.cards, !gameCards.isEmpty {
            // Use cards from game definition
            // Assuming pairs share same pairId in JSON
            for card in gameCards {
                // We need UUID for matchId, so we can hash pairId or map it
                // Simple way: Dictionary map
                // But since we need to construct pairs, let's trust the JSON structure
                // The MemoryCard struct uses UUID for matchId. We need to ensure pairs have same matchId.
                // We can generate deterministic UUIDs from pairId if needed, or just track them.
            }
            
            // Better approach: Group by pairId
            let groups = Dictionary(grouping: gameCards, by: { $0.pairId })
            for (_, group) in groups {
                let matchId = UUID()
                for c in group {
                    newCards.append(MemoryCard(content: c.content, matchId: matchId, isText: true))
                }
            }
        } else {
            // Fallback to flashcards
            let allFlashcards = learningDataService.flashcards.shuffled()
            let selected = Array(allFlashcards.prefix(8))
            
            for flashcard in selected {
                let matchId = UUID()
                newCards.append(MemoryCard(content: flashcard.front, matchId: matchId, isText: true))
                newCards.append(MemoryCard(content: flashcard.meaning, matchId: matchId, isText: true))
            }
        }
        
        cards = newCards.shuffled()
        isLoading = false
    }
    
    func handleCardTap(_ card: MemoryCard) {
        if matchedCards.contains(card.id) || flippedCards.contains(card.id) { return }
        
        // If 2 cards are already flipped but not matched, reset them
        if flippedCards.count >= 2 {
            // Only if we are tapping a 3rd card, but logic usually handles this with delay
            // For simplicity, if 2 are open, we assume user is waiting or tapping 3rd to reset
            // Let's use a simple logic: allow max 2 flipped.
             return 
        }
        
        flippedCards.insert(card.id)
        
        if flippedCards.count == 2 {
            moves += 1
            checkForMatch()
        }
    }
    
    func checkForMatch() {
        let flippedIds = Array(flippedCards)
        guard flippedIds.count == 2 else { return }
        
        let card1 = cards.first(where: { $0.id == flippedIds[0] })
        let card2 = cards.first(where: { $0.id == flippedIds[1] })
        
        if let c1 = card1, let c2 = card2, c1.matchId == c2.matchId {
            // Match!
            matchedCards.insert(c1.id)
            matchedCards.insert(c2.id)
            score += 10
            Haptics.success()
            flippedCards.removeAll()
            
            if matchedCards.count == cards.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showCompleted = true
                }
            }
        } else {
            // No match
            Haptics.error()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                flippedCards.removeAll()
            }
        }
    }
    
    func restartGame() {
        matchedCards.removeAll()
        flippedCards.removeAll()
        score = 0
        moves = 0
        showCompleted = false
        Task {
            await loadCards()
        }
    }
}

struct MemoryCard: Identifiable {
    let id = UUID()
    let content: String
    let matchId: UUID
    let isText: Bool
}

struct MemoryCardView: View {
    let card: MemoryCard
    let isFlipped: Bool
    let isMatched: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(isMatched ? Color.green.opacity(0.3) : (isFlipped ? Color.white : AppTheme.brandPrimary))
                .shadow(radius: 2)
            
            if isFlipped {
                Text(card.content)
                    .font(.system(size: 14)) // Smaller font to fit English
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(4)
            } else {
                Image(systemName: "questionmark")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .frame(height: 80)
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0.0, y: 1.0, z: 0.0)
        )
        .animation(.spring(), value: isFlipped)
    }
}

// Listening Challenge
struct ListeningChallengeView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @State private var currentFlashcard: Flashcard?
    @State private var options: [String] = []
    @State private var score = 0
    @State private var round = 1
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var isLoading = true
    @State private var showCompleted = false
    
    private let synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        VStack(spacing: 24) {
            if isLoading {
                ProgressView()
            } else if showCompleted {
                ProfessionalResultsView(
                    score: score,
                    total: 10,
                    title: "Listening Complete",
                    icon: "ear.fill",
                    color: .teal,
                    restartAction: restartGame
                )
            } else if let card = currentFlashcard {
                // Header
                ProfessionalProgressHeader(
                    currentIndex: round,
                    total: 10,
                    score: score,
                    progressColor: Color.teal
                )
                
                Spacer()
                
                // Audio Button
                Button(action: playAudio) {
                    VStack(spacing: 16) {
                        Image(systemName: "speaker.wave.3.fill")
                            .font(.system(size: 60))
                        Text("Tap to Listen")
                            .font(AppTheme.Typography.headline)
                    }
                    .foregroundColor(.white)
                    .frame(width: 200, height: 200)
                    .background(Color.teal)
                    .clipShape(Circle())
                    .shadow(radius: 10)
                }
                
                Spacer()
                
                // Options
                VStack(spacing: 12) {
                    ForEach(options, id: \.self) { option in
                        ProfessionalAnswerButton(
                            text: option,
                            isSelected: false,
                            isCorrect: showResult && option == card.meaning,
                            isWrong: showResult && option != card.meaning, // Highlight all wrong if we wanted, but usually just selected. Simple logic here.
                            action: {
                                checkAnswer(option)
                            }
                        )
                        .disabled(showResult)
                    }
                }
                .padding()
            }
        }
        .background(AppTheme.background)
        .navigationTitle("Listening Challenge")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadRound()
        }
        .reloadOnLevelChange {
            await loadRound()
        }
    }
    
    func loadRound() async {
        isLoading = true
        showResult = false
        
        let allCards = learningDataService.flashcards
        if let correctCard = allCards.randomElement() {
            currentFlashcard = correctCard
            
            // Generate distractors
            var distractors = allCards.filter { $0.id != correctCard.id }.shuffled().prefix(3).map { $0.meaning }
            distractors.append(correctCard.meaning)
            options = distractors.shuffled()
            
            // Auto play
            try? await Task.sleep(nanoseconds: 500_000_000)
            playAudio()
        }
        isLoading = false
    }
    
    func playAudio() {
        guard let card = currentFlashcard else { return }
        // Prioritize reading, fallback to front
        let text = card.reading ?? card.front
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
    
    func checkAnswer(_ selected: String) {
        guard let card = currentFlashcard else { return }
        
        isCorrect = selected == card.meaning
        if isCorrect {
            score += 1
            Haptics.success()
        } else {
            Haptics.error()
        }
        
        showResult = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if round < 10 {
                round += 1
                Task {
                    await loadRound()
                }
            } else {
                showCompleted = true
            }
        }
    }
    
    func restartGame() {
        score = 0
        round = 1
        showCompleted = false
        Task {
            await loadRound()
        }
    }
}

// Kanji Drawing
struct KanjiDrawingView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @State private var currentKanji: Flashcard?
    @State private var lines: [Line] = []
    @State private var showHint = false
    @State private var score = 0 // Just tracking completion
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if let kanji = currentKanji {
                // Header info
                VStack {
                    Text(kanji.meaning)
                        .font(AppTheme.Typography.title3)
                    Text(kanji.reading ?? "")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Canvas Area
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(radius: 2)
                    
                    // Hint (Watermark)
                    if showHint {
                        Text(kanji.front)
                            .font(.system(size: 200))
                            .foregroundColor(.gray.opacity(0.2))
                    }
                    
                    // Drawing Canvas
                    Canvas { context, size in
                        for line in lines {
                            var path = Path()
                            path.addLines(line.points)
                            context.stroke(path, with: .color(.black), lineWidth: 5)
                        }
                    }
                    .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged({ value in
                            let newPoint = value.location
                            if value.translation.width + value.translation.height == 0 {
                                lines.append(Line(points: [newPoint]))
                            } else {
                                let index = lines.count - 1
                                lines[index].points.append(newPoint)
                            }
                        })
                    )
                }
                .aspectRatio(1, contentMode: .fit)
                .padding()
                
                // Controls
                HStack(spacing: 20) {
                    Button("Clear") {
                        lines.removeAll()
                    }
                    .buttonStyle(.bordered)
                    
                    Button(showHint ? "Hide Hint" : "Show Hint") {
                        showHint.toggle()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Next") {
                        loadNextKanji()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.indigo)
                }
                .padding()
            } else {
                 ProfessionalEmptyStateView(
                    icon: "scribble.variable",
                    title: "No Kanji Found",
                    message: "Add some kanji flashcards first"
                )
            }
        }
        .background(AppTheme.background)
        .navigationTitle("Kanji Drawing")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadNextKanji()
        }
    }
    
    func loadNextKanji() {
        isLoading = true
        lines.removeAll()
        showHint = false
        
        // Filter for flashcards that are likely kanji:
        // - Single character in front field (kanji are individual characters)
        // - Has a reading (hiragana/katakana pronunciation)
        // - Front contains kanji characters (Japanese ideographic characters)
        let kanjiCards = learningDataService.flashcards.filter { card in
            let front = card.front
            // Check if it's a single kanji character or contains kanji
            let isSingleChar = front.count == 1
            let hasReading = card.reading != nil && !card.reading!.isEmpty
            
            // Kanji characters are in the Unicode range 4E00-9FFF
            let containsKanji = front.unicodeScalars.contains { scalar in
                (0x4E00...0x9FFF).contains(scalar.value)
            }
            
            return (isSingleChar || front.count <= 3) && hasReading && containsKanji
        }
        
        if let random = kanjiCards.randomElement() {
            currentKanji = random
        } else {
            // Fallback: any flashcard with kanji characters
            currentKanji = learningDataService.flashcards.filter { card in
                card.front.unicodeScalars.contains { scalar in
                    (0x4E00...0x9FFF).contains(scalar.value)
                }
            }.randomElement()
        }
        
        isLoading = false
    }
    
    struct Line {
        var points: [CGPoint]
    }
}

// Fill in the Blank
struct FillInBlankView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    var game: GameModel?
    
    @State private var currentCard: Flashcard?
    @State private var currentQuestion: GameModel.Question?
    @State private var sentenceParts: (prefix: String, suffix: String) = ("", "")
    @State private var options: [String] = []
    @State private var score = 0
    @State private var round = 1
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var selectedAnswer: String?
    @State private var isLoading = true
    @State private var showCompleted = false
    
    var body: some View {
        VStack(spacing: 24) {
            if isLoading {
                ProgressView()
            } else if showCompleted {
                ProfessionalResultsView(
                    score: score,
                    total: 10,
                    title: "Exercise Complete",
                    icon: "square.dashed",
                    color: .pink,
                    restartAction: restartGame
                )
            } else if let card = currentCard {
                // Header
                ProfessionalProgressHeader(
                    currentIndex: round,
                    total: 10,
                    score: score,
                    progressColor: Color.pink
                )
                
                Spacer()
                
                // Sentence Display
                VStack(spacing: 8) {
                    Text("Complete the Sentence")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Text(sentenceParts.prefix)
                        Text("_______")
                            .foregroundColor(.pink)
                            .fontWeight(.bold)
                        Text(sentenceParts.suffix)
                    }
                    .font(AppTheme.Typography.title2)
                    .multilineTextAlignment(.center)
                    .padding()
                    
                    Text("Meaning: \(card.meaning)")
                    .font(AppTheme.Typography.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 2)
                .padding()
                
                Spacer()
                
                // Options
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(options, id: \.self) { option in
                        Button {
                            checkAnswer(option)
                        } label: {
                            Text(option)
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(showResult ? (isOptionCorrect(option) ? .white : (option == selectedAnswer ? .white : .primary)) : .primary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    showResult ?
                                    (isOptionCorrect(option) ? Color.green : (option == selectedAnswer ? Color.red : Color.white)) :
                                    Color.white
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(radius: 1)
                        }
                        .disabled(showResult)
                    }
                }
                .padding()
            }
        }
        .background(AppTheme.background)
        .navigationTitle("Fill in the Blank")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadRound()
        }
        .reloadOnLevelChange {
            await loadRound()
        }
    }
    
    func loadRound() async {
        isLoading = true
        showResult = false
        selectedAnswer = nil
        
        let allCards = learningDataService.flashcards
        if let card = allCards.randomElement() {
            currentCard = card
            
            // Strategy 1: Use example if available
            if let example = card.examples?.first, example.contains(card.front) {
                let parts = example.components(separatedBy: card.front)
                if parts.count >= 2 {
                    sentenceParts = (parts[0], parts[1])
                } else {
                    sentenceParts = ("The Japanese word for '\(card.meaning)' is ", "")
                }
            } else {
                 // Strategy 2: Simple meaning check
                 sentenceParts = ("The word for '\(card.meaning)' is ", "")
            }
            
            // Options
            let distractors = allCards.filter { $0.id != card.id }.shuffled().prefix(3).map { $0.front }
            var opts = distractors
            opts.append(card.front)
            options = opts.shuffled()
        }
        isLoading = false
    }
    
    func checkAnswer(_ answer: String) {
        selectedAnswer = answer
        isCorrect = isOptionCorrect(answer)
                
        if isCorrect {
            score += 1
            Haptics.success()
        } else {
            Haptics.error()
        }
        
        showResult = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if round < 10 {
                round += 1
                Task {
                    await loadRound()
                }
            } else {
                showCompleted = true
            }
        }
    }
    
    func isOptionCorrect(_ option: String) -> Bool {
        if let current = currentCard {
            return option == current.front
        }
        // If using GameModel question directly later
        return false
    }
    
    func restartGame() {
        score = 0
        round = 1
        showCompleted = false
        Task {
            await loadRound()
        }
    }
}

// True or False
struct TrueOrFalseView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @State private var currentCard: Flashcard?
    @State private var displayedMeaning: String = ""
    @State private var isAnswerTrue: Bool = false
    @State private var score = 0
    @State private var round = 1
    @State private var showResult = false
    @State private var showCompleted = false
    @State private var isLoading = true
    @State private var resultMessage: String?
    
    var body: some View {
        VStack(spacing: 32) {
            if isLoading {
                ProgressView()
            } else if showCompleted {
                ProfessionalResultsView(
                    score: score,
                    total: 10,
                    title: "Quiz Complete",
                    icon: "checkmark.circle",
                    color: .mint,
                    restartAction: restartGame
                )
            } else if let card = currentCard {
                // Header
                ProfessionalProgressHeader(
                    currentIndex: round,
                    total: 10,
                    score: score,
                    progressColor: Color.mint
                )
                
                Spacer()
                
                // Question Card
                VStack(spacing: 24) {
                    Text(card.front)
                        .font(.system(size: 48))
                        .fontWeight(.bold)
                    
                    if let reading = card.reading {
                        Text(reading)
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    Text("Means")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(displayedMeaning)
                        .font(.title)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                }
                .padding(32)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                .padding()
                
                if let msg = resultMessage {
                    Text(msg)
                        .font(.headline)
                        .foregroundColor(msg == "Correct!" ? .green : .red)
                        .transition(.scale)
                }
                
                Spacer()
                
                // Buttons
                HStack(spacing: 20) {
                    Button {
                        checkAnswer(userSaidTrue: false)
                    } label: {
                        VStack(spacing: 12) {
                    Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 40))
                            Text("False")
                                .font(AppTheme.Typography.headline)
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(Color.red.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(showResult)
                    
                    Button {
                        checkAnswer(userSaidTrue: true)
                    } label: {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 40))
                            Text("True")
                                .font(AppTheme.Typography.headline)
                        }
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(Color.green.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(showResult)
            }
            .padding()
            }
        }
        .background(AppTheme.background)
        .navigationTitle("True or False")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadRound()
        }
        .reloadOnLevelChange {
            await loadRound()
        }
    }
    
    func loadRound() async {
        isLoading = true
        showResult = false
        resultMessage = nil
        
        let allCards = learningDataService.flashcards
        if let card = allCards.randomElement() {
            currentCard = card
            
            isAnswerTrue = Bool.random()
            
            if isAnswerTrue {
                displayedMeaning = card.meaning
            } else {
                if let other = allCards.filter({ $0.id != card.id }).randomElement() {
                    displayedMeaning = other.meaning
                } else {
                    displayedMeaning = "Wrong Meaning"
                }
            }
        }
        isLoading = false
    }
    
    func checkAnswer(userSaidTrue: Bool) {
        let isCorrect = userSaidTrue == isAnswerTrue
        if isCorrect {
            score += 1
            Haptics.success()
            resultMessage = "Correct!"
        } else {
            Haptics.error()
            resultMessage = "Wrong!"
        }
        
        showResult = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if round < 10 {
                round += 1
                Task {
                    await loadRound()
                }
            } else {
                showCompleted = true
            }
        }
    }
    
    func restartGame() {
        score = 0
        round = 1
        showCompleted = false
        Task {
            await loadRound()
        }
    }
}

// Typing Practice
struct TypingPracticeView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @State private var currentCard: Flashcard?
    @State private var userInput = ""
    @State private var score = 0
    @State private var round = 1
    @State private var showResult = false
    @State private var showCompleted = false
    @State private var isLoading = true
    @State private var feedbackMessage: String?
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 32) {
            if isLoading {
                ProgressView()
            } else if showCompleted {
                 ProfessionalResultsView(
                    score: score,
                    total: 5,
                    title: "Typing Complete",
                    icon: "keyboard",
                    color: Color.cyan,
                    restartAction: restartGame
                )
            } else if let card = currentCard {
                // Header
                ProfessionalProgressHeader(
                    currentIndex: round,
                    total: 5,
                    score: score,
                    progressColor: Color.cyan
                )
                
                Spacer()
                
                // Question
                VStack(spacing: 16) {
                    Text("Type the reading (Kana)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(card.front)
                        .font(.system(size: 48))
                        .fontWeight(.bold)
                    
                    Text(card.meaning)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Input
                VStack(spacing: 16) {
                    TextField("Reading...", text: $userInput)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.roundedBorder)
                        .focused($isInputFocused)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .padding(.horizontal)
                    
                    if let msg = feedbackMessage {
                        Text(msg)
                            .foregroundColor(msg.contains("Correct") ? .green : .red)
                    }
                    
                    Button {
                        checkAnswer()
                    } label: {
                        Text("Submit")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(userInput.isEmpty ? Color.gray : Color.cyan)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(userInput.isEmpty || showResult)
                    .padding(.horizontal)
                }
                
                Spacer()
            }
        }
        .background(AppTheme.background)
        .navigationTitle("Typing Practice")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadRound()
        }
        .reloadOnLevelChange {
            await loadRound()
        }
    }
    
    func loadRound() async {
        isLoading = true
        showResult = false
        userInput = ""
        feedbackMessage = nil
        
        let validCards = learningDataService.flashcards.filter { $0.reading != nil }
        if let card = validCards.randomElement() {
            currentCard = card
        }
        isLoading = false
        isInputFocused = true
    }
    
    func checkAnswer() {
        guard let card = currentCard, let reading = card.reading else { return }
        
        let isCorrect = userInput.trimmingCharacters(in: .whitespaces).lowercased() == reading.lowercased()
        
        if isCorrect {
            score += 1
            Haptics.success()
            feedbackMessage = "Correct!"
        } else {
            Haptics.error()
            feedbackMessage = "Wrong! Answer: \(reading)"
        }
        
        showResult = true
        isInputFocused = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if round < 5 {
                round += 1
                Task {
                    await loadRound()
                }
            } else {
                showCompleted = true
            }
        }
    }
    
    func restartGame() {
        score = 0
        round = 1
        showCompleted = false
        Task {
            await loadRound()
        }
    }
}

// Word Scramble
struct WordScrambleView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @State private var currentCard: Flashcard?
    @State private var scrambledChars: [String] = []
    @State private var userSelection: [String] = []
    @State private var score = 0
    @State private var round = 1
    @State private var showResult = false
    @State private var showCompleted = false
    @State private var isLoading = true
    
    var body: some View {
        VStack(spacing: 24) {
            if isLoading {
                ProgressView()
            } else if showCompleted {
                ProfessionalResultsView(
                    score: score,
                    total: 5,
                    title: "Scramble Solved!",
                    icon: "shuffle",
                    color: .brown,
                    restartAction: restartGame
                )
            } else if let card = currentCard {
                ProfessionalProgressHeader(currentIndex: round, total: 5, score: score, progressColor: Color.brown)
                
                Spacer()
                
                // Target
                VStack(spacing: 8) {
                    Text(card.front)
                        .font(.system(size: 40))
                    Text(card.meaning)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                // User Selection Slots
                HStack(spacing: 8) {
                    ForEach(0..<(card.reading?.count ?? 0), id: \.self) { index in
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                                .frame(width: 40, height: 40)
                            
                            if index < userSelection.count {
                                Text(userSelection[index])
                                    .font(.title2)
                            }
                        }
                    }
                }
                .padding()
                
                Spacer()
                
                // Scrambled Buttons
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 12) {
                    ForEach(Array(scrambledChars.enumerated()), id: \.offset) { index, char in
                        Button {
                            userSelection.append(char)
                            checkIfComplete()
                        } label: {
                            Text(char)
                                .font(.title2)
                                .frame(width: 50, height: 50)
                                .background(Color.brown.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .disabled(showResult)
                    }
                }
                .padding()
                
                // Clear Button
                Button("Clear") {
                    userSelection.removeAll()
                }
                .buttonStyle(.bordered)
                
            }
        }
        .background(AppTheme.background)
        .navigationTitle("Word Scramble")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadRound()
        }
        .reloadOnLevelChange {
            await loadRound()
        }
    }
    
    func loadRound() async {
        isLoading = true
        showResult = false
        userSelection = []
        
        let validCards = learningDataService.flashcards.filter { $0.reading != nil && $0.reading!.count > 1 }
        if let card = validCards.randomElement() {
            currentCard = card
            let chars = Array(card.reading!).map { String($0) }
            scrambledChars = chars.shuffled()
        }
        isLoading = false
    }
    
    func checkIfComplete() {
        guard let card = currentCard, let target = card.reading else { return }
        
        if userSelection.count == target.count {
            let guess = userSelection.joined()
            if guess == target {
                score += 1
                Haptics.success()
                showResult = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    nextRound()
                }
            } else {
                Haptics.error()
                userSelection.removeAll() // Retry
            }
        }
    }
    
    func nextRound() {
        if round < 5 {
            round += 1
            Task { await loadRound() }
        } else {
            showCompleted = true
        }
    }
    
    func restartGame() {
        score = 0
        round = 1
        showCompleted = false
        Task { await loadRound() }
    }
}

// Reverse Translation
struct ReverseTranslationView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @State private var currentCard: Flashcard?
    @State private var options: [String] = []
    @State private var score = 0
    @State private var round = 1
    @State private var showResult = false
    @State private var isLoading = true
    @State private var showCompleted = false
    
    var body: some View {
        VStack(spacing: 24) {
            if isLoading { ProgressView() }
            else if showCompleted {
                ProfessionalResultsView(score: score, total: 10, title: "Done!", icon: "arrow.left.arrow.right", color: .purple, restartAction: restartGame)
            } else if let card = currentCard {
                ProfessionalProgressHeader(currentIndex: round, total: 10, score: score, progressColor: Color.purple)
                
                Spacer()
                
                // English Question
                Text(card.meaning)
                    .font(.system(size: 32))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
                
                // Japanese Options
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(options, id: \.self) { option in
                        Button {
                            checkAnswer(option)
                        } label: {
                            Text(option)
                                .font(AppTheme.Typography.japaneseBody)
                                .frame(maxWidth: .infinity, minHeight: 60)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(radius: 1)
            .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(showResult && option == card.front ? Color.green : Color.clear, lineWidth: 3)
                                )
                        }
                        .disabled(showResult)
                    }
                }
                .padding()
            }
        }
        .background(AppTheme.background)
        .navigationTitle("Reverse Translation")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadRound() }
        .reloadOnLevelChange { await loadRound() }
    }
    
    func loadRound() async {
        isLoading = true
        showResult = false
        
        let allCards = learningDataService.flashcards
        if let card = allCards.randomElement() {
            currentCard = card
            let distractors = allCards.filter { $0.id != card.id }.shuffled().prefix(3).map { $0.front }
            var opts = distractors
            opts.append(card.front)
            options = opts.shuffled()
        }
        isLoading = false
    }
    
    func checkAnswer(_ answer: String) {
        if answer == currentCard?.front {
            score += 1
            Haptics.success()
        } else {
            Haptics.error()
        }
        showResult = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if round < 10 { round += 1; Task { await loadRound() } }
            else { showCompleted = true }
        }
    }
    
    func restartGame() { score = 0; round = 1; showCompleted = false; Task { await loadRound() } }
}

// Word Chain
struct WordChainView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @State private var currentWord: Flashcard?
    @State private var options: [Flashcard] = []
    @State private var score = 0
    @State private var showResult = false
    @State private var isLoading = true
    @State private var lastChar: String = ""
    
    var body: some View {
        VStack {
            if isLoading { ProgressView() }
            else if let word = currentWord {
                Text("Current Word")
                    .font(.caption)
                Text(word.front)
                    .font(.system(size: 48))
                Text(word.reading ?? "")
                    .foregroundColor(.secondary)
                
                Divider().padding()
                
                Text("Pick a word starting with: \(lastChar)")
                    .font(.headline)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(options) { option in
                        Button {
                            checkAnswer(option)
                        } label: {
                            VStack {
                                Text(option.front).font(.title2)
                                Text(option.reading ?? "").font(.caption)
                            }
                            .frame(maxWidth: .infinity, minHeight: 80)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 1)
                        }
                    }
                }
                .padding()
            } else {
                ProfessionalEmptyStateView(
                    icon: "link",
                    title: "Game Over",
                    message: "No more words found! Score: \(score)",
                    actionTitle: "Restart",
                    action: restartGame
                )
            }
        }
        .background(AppTheme.background)
        .navigationTitle("Word Chain")
        .navigationBarTitleDisplayMode(.inline)
        .task { await startGame() }
        .reloadOnLevelChange { await startGame() }
    }
    
    func startGame() async {
        isLoading = true
        score = 0
        
        let valid = learningDataService.flashcards.filter { $0.reading != nil && !$0.reading!.isEmpty }
        if let start = valid.randomElement() {
            currentWord = start
            updateNextOptions(from: start)
        }
        isLoading = false
    }
    
    func updateNextOptions(from word: Flashcard) {
        guard let reading = word.reading, let last = reading.last else { return }
        lastChar = String(last)
        
        let candidates = learningDataService.flashcards.filter {
            $0.reading?.hasPrefix(lastChar) == true && $0.id != word.id
        }
        
        if candidates.isEmpty {
            currentWord = nil // End game
        } else {
            let correct = candidates.randomElement()!
            var opts = [correct]
            let wrong = learningDataService.flashcards.filter { $0.reading?.hasPrefix(lastChar) == false }.shuffled().prefix(3)
            opts.append(contentsOf: wrong)
            options = opts.shuffled()
        }
    }
    
    func checkAnswer(_ choice: Flashcard) {
        if choice.reading?.hasPrefix(lastChar) == true {
            score += 1
            Haptics.success()
            currentWord = choice
            updateNextOptions(from: choice)
        } else {
            Haptics.error()
        }
    }
    
    func restartGame() {
        Task { await startGame() }
    }
}

// Pronunciation Quiz
struct PronunciationQuizView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @State private var currentCard: Flashcard?
    @State private var isRecording = false
    @State private var recognizedText = ""
    @State private var score = 0
    @State private var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var body: some View {
        VStack(spacing: 32) {
            if authorizationStatus != .authorized {
                VStack(spacing: 16) {
                    Image(systemName: "mic.slash.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                    
                    Text("Microphone Permission Required")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Please enable microphone and speech recognition in Settings to use this feature.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    Button("Request Permission") {
                        requestPermission()
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else if let card = currentCard {
                Text("Say this word:")
                    .font(.headline)
                
                Text(card.front)
                    .font(.system(size: 60))
                    .fontWeight(.bold)
                
                Text(card.reading ?? "")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                if !recognizedText.isEmpty {
                    Text(recognizedText)
                        .font(.title)
                        .foregroundColor(recognizedText == card.front || recognizedText == card.reading ? .green : .primary)
                        .padding()
                }
                
                Button(action: toggleRecording) {
                    Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(isRecording ? .red : .orange)
                }
                .disabled(authorizationStatus != .authorized)
                
                if recognizedText == card.front || recognizedText == card.reading {
                    Button("Next Word") {
                        loadNext()
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                ProgressView()
            }
        }
        .background(AppTheme.background)
        .navigationTitle("Pronunciation")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            requestPermission()
            loadNext()
        }
        .reloadOnLevelChange {
            loadNext()
        }
        .onDisappear {
            stopRecording()
        }
    }
    
    func requestPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                self.authorizationStatus = status
            }
        }
    }
    
    func loadNext() {
        recognizedText = ""
        currentCard = learningDataService.flashcards.randomElement()
    }
    
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    func startRecording() {
        guard !isRecording else { return }
        guard authorizationStatus == .authorized else {
            print("Speech recognition not authorized")
            return
        }
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            print("Speech recognizer not available")
            return
        }
        
        // Cancel any existing tasks
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session setup failed: \(error)")
            return
        }
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let request = recognitionRequest else {
            print("Unable to create recognition request")
            return
        }
        request.shouldReportPartialResults = true
        
        // Setup audio engine
        let inputNode = audioEngine.inputNode
        
        // Remove any existing tap
        inputNode.removeTap(onBus: 0)
        
        // Install tap on input node
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }
        
        // Start recognition task
        recognitionTask = recognizer.recognitionTask(with: request) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.recognizedText = result.bestTranscription.formattedString
                    
                    if let card = self.currentCard,
                       (self.recognizedText.contains(card.front) || self.recognizedText.contains(card.reading ?? "")) {
                        self.score += 1
                        Haptics.success()
                        self.stopRecording()
                    }
                }
            }
            
            if error != nil || (result?.isFinal ?? false) {
                DispatchQueue.main.async {
                    self.stopRecording()
                }
            }
        }
        
        // Start audio engine
        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            print("Audio engine start failed: \(error)")
            stopRecording()
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        // Stop audio engine
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        // End recognition
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        isRecording = false
        
        // Deactivate audio session
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}

// Category Sort
struct CategorySortView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @State private var currentCard: Flashcard?
    @State private var score = 0
    @State private var showResult = false
    @State private var resultMessage: String?
    
    let categories = ["N5", "N4", "N3", "N2", "N1"]
    
    var body: some View {
        VStack(spacing: 24) {
            if let card = currentCard {
                VStack(spacing: 8) {
                    Text("Score: \(score)")
                        .font(.headline)
                    
                    Text(card.front)
                        .font(.system(size: 48))
                        .fontWeight(.bold)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(radius: 2)
                    
                    Text(card.meaning)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                if let msg = resultMessage {
                    Text(msg)
                        .font(.headline)
                        .foregroundColor(msg == "Correct!" ? .green : .red)
                }
                
                Spacer()
                
                Text("Which Level?")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        Button {
                            checkAnswer(category)
                        } label: {
                            Text(category)
                                .font(.title3)
                                .bold()
                                .frame(maxWidth: .infinity, minHeight: 60)
                                .background(getColor(for: category).opacity(0.2))
                                .foregroundColor(getColor(for: category))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            } else {
                ProgressView()
            }
        }
        .background(AppTheme.background)
        .navigationTitle("Category Sort")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            loadNext()
        }
        .reloadOnLevelChange {
            loadNext()
        }
    }
    
    func loadNext() {
        resultMessage = nil
        currentCard = learningDataService.flashcards.randomElement()
    }
    
    func checkAnswer(_ category: String) {
        if currentCard?.level == category {
            score += 1
            Haptics.success()
            resultMessage = "Correct!"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                loadNext()
            }
        } else {
            Haptics.error()
            resultMessage = "Wrong! It's \(currentCard?.level ?? "?")"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                loadNext()
            }
        }
    }
    
    func getColor(for level: String) -> Color {
        switch level {
        case "N5": return .blue
        case "N4": return .green
        case "N3": return .orange
        case "N2": return .purple
        case "N1": return .red
        default: return .gray
        }
    }
}

// MARK: - Kanji Quiz View
struct KanjiQuizView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    var game: GameModel?
    
    @State private var questions: [GameModel.Question] = []
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    @State private var selectedAnswer: String?
    @State private var showResult = false
    @State private var isLoading = true
    @State private var showCompleted = false
    @State private var timeRemaining: Int = 90
    @State private var timer: Timer?
    
    var currentQuestion: GameModel.Question? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                Spacer()
                ProgressView()
                    .scaleEffect(1.5)
                Spacer()
            } else if showCompleted {
                resultsView
            } else if let question = currentQuestion {
                // Header with progress
                VStack(spacing: 12) {
                    HStack {
                        Text("Question \(currentQuestionIndex + 1)/\(questions.count)")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.mutedText)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                                .foregroundColor(timeRemaining < 30 ? .red : AppTheme.brandAccent)
                            Text("\(timeRemaining)s")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(timeRemaining < 30 ? .red : AppTheme.mutedText)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("\(score)")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.mutedText)
                        }
                    }
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                    .padding(.top, 16)
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                            Rectangle()
                                .fill(AppTheme.brandAccent)
                                .frame(width: geometry.size.width * CGFloat(currentQuestionIndex) / CGFloat(questions.count))
                        }
                    }
                    .frame(height: 4)
                }
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Kanji display
                        VStack(spacing: 16) {
                            Text("How do you read this kanji?")
                                .font(AppTheme.Typography.subheadline)
                                .foregroundColor(AppTheme.mutedText)
                            
                            Text(question.word ?? "")
                                .font(.system(size: 80, weight: .bold))
                                .foregroundColor(Color.primary)
                                .padding(32)
                                .background(AppTheme.secondaryBackground)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                        }
                        .padding(.top, 32)
                        
                        // Options
                        VStack(spacing: 12) {
                            ForEach(question.options, id: \.self) { option in
                                Button {
                                    if !showResult {
                                        selectAnswer(option)
                                    }
                                } label: {
                                    HStack {
                                        Text(option)
                                            .font(AppTheme.Typography.title3)
                                            .foregroundColor(getOptionColor(option))
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer()
                                        
                                        if showResult && option == question.reading {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        } else if showResult && option == selectedAnswer && option != question.reading {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .padding()
                                    .background(getOptionBackground(option))
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
                                }
                                .disabled(showResult)
                            }
                        }
                        .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                        
                        if showResult {
                            VStack(spacing: 8) {
                                if selectedAnswer == question.reading {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text("Correct!")
                                            .font(AppTheme.Typography.headline)
                                            .foregroundColor(.green)
                                    }
                                } else {
                                    VStack(spacing: 8) {
                                        HStack {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                            Text("Incorrect")
                                                .font(AppTheme.Typography.headline)
                                                .foregroundColor(.red)
                                        }
                                        Text("Correct answer: \(question.reading ?? "")")
                                            .font(AppTheme.Typography.body)
                                            .foregroundColor(AppTheme.mutedText)
                                    }
                                }
                                
                                if let meaning = question.correctMeaning {
                                    Text("Meaning: \(meaning)")
                                        .font(AppTheme.Typography.caption)
                                        .foregroundColor(AppTheme.mutedText)
                                        .padding(.top, 4)
                                }
                            }
                            .padding()
                            .background(AppTheme.secondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
                            .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                        }
                    }
                    .padding(.bottom, 100)
                }
                
                // Next button
                if showResult {
                    VStack {
                        Button {
                            nextQuestion()
                        } label: {
                            Text(currentQuestionIndex < questions.count - 1 ? "Next Question" : "Finish")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.brandAccent)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
                        }
                        .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                        .padding(.bottom, 16)
                    }
                    .background(AppTheme.background)
                }
            }
        }
        .background(AppTheme.background)
        .navigationTitle(game?.title ?? "Kanji Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadQuestions()
            startTimer()
        }
        .reloadOnLevelChange {
            await loadQuestions()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var resultsView: some View {
        ProfessionalResultsView(
            score: score,
            total: questions.count,
            title: "Quiz Complete!",
            icon: "checkmark.seal.fill",
            color: .blue,
            restartAction: restartQuiz
        )
    }
    
    private func loadQuestions() async {
        isLoading = true
        
        if let gameQuestions = game?.questions, !gameQuestions.isEmpty {
            questions = gameQuestions
        } else {
            // Fallback: Generate questions from kanji
            let allKanji = learningDataService.kanji.shuffled()
            questions = allKanji.prefix(10).map { kanji in
                var options = [kanji.readings.kunyomi.first ?? kanji.readings.onyomi.first ?? ""]
                let otherReadings = learningDataService.kanji
                    .filter { $0.character != kanji.character }
                    .map { $0.readings.kunyomi.first ?? $0.readings.onyomi.first ?? "" }
                    .shuffled()
                    .prefix(3)
                options.append(contentsOf: otherReadings)
                options.shuffle()
                
                return GameModel.Question(
                    word: kanji.character,
                    reading: kanji.readings.kunyomi.first ?? kanji.readings.onyomi.first ?? "",
                    correctMeaning: kanji.meaning,
                    options: options,
                    sentence: nil,
                    correctParticle: nil,
                    translation: nil
                )
            }
        }
        
        isLoading = false
    }
    
    private func startTimer() {
        timer?.invalidate()
        timeRemaining = game?.timeLimit ?? 90
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                showCompleted = true
            }
        }
    }
    
    private func selectAnswer(_ answer: String) {
        selectedAnswer = answer
        showResult = true
        
        if answer == currentQuestion?.reading {
            score += 1
            Haptics.success()
        } else {
            Haptics.error()
        }
    }
    
    private func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswer = nil
            showResult = false
        } else {
            showCompleted = true
            timer?.invalidate()
        }
    }
    
    private func restartQuiz() {
        currentQuestionIndex = 0
        score = 0
        selectedAnswer = nil
        showResult = false
        showCompleted = false
        Task {
            await loadQuestions()
            startTimer()
        }
    }
    
    private func getOptionColor(_ option: String) -> Color {
        if !showResult {
            return Color.primary
        }
        if option == currentQuestion?.reading {
            return .green
        } else if option == selectedAnswer {
            return .red
        }
        return AppTheme.mutedText
    }
    
    private func getOptionBackground(_ option: String) -> Color {
        if !showResult {
            return AppTheme.secondaryBackground
        }
        if option == currentQuestion?.reading {
            return Color.green.opacity(0.2)
        } else if option == selectedAnswer {
            return Color.red.opacity(0.2)
        }
        return AppTheme.secondaryBackground
    }
}

// MARK: - Grammar Fill View
struct GrammarFillView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    var game: GameModel?
    
    @State private var questions: [GameModel.Question] = []
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    @State private var selectedAnswer: String?
    @State private var showResult = false
    @State private var isLoading = true
    @State private var showCompleted = false
    @State private var timeRemaining: Int = 120
    @State private var timer: Timer?
    
    var currentQuestion: GameModel.Question? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                Spacer()
                ProgressView()
                    .scaleEffect(1.5)
                Spacer()
            } else if showCompleted {
                resultsView
            } else if let question = currentQuestion {
                // Header
                VStack(spacing: 12) {
                    HStack {
                        Text("Question \(currentQuestionIndex + 1)/\(questions.count)")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.mutedText)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                                .foregroundColor(timeRemaining < 30 ? .red : AppTheme.brandAccent)
                            Text("\(timeRemaining)s")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(timeRemaining < 30 ? .red : AppTheme.mutedText)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("\(score)")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.mutedText)
                        }
                    }
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                    .padding(.top, 16)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                            Rectangle()
                                .fill(AppTheme.brandAccent)
                                .frame(width: geometry.size.width * CGFloat(currentQuestionIndex) / CGFloat(questions.count))
                        }
                    }
                    .frame(height: 4)
                }
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            Text("Fill in the blank")
                                .font(AppTheme.Typography.subheadline)
                                .foregroundColor(AppTheme.mutedText)
                            
                            Text(question.sentence ?? "")
                                .font(AppTheme.Typography.title2)
                                .foregroundColor(Color.primary)
                                .multilineTextAlignment(.center)
                                .padding(24)
                                .frame(maxWidth: .infinity)
                                .background(AppTheme.secondaryBackground)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                            
                            if let translation = question.translation {
                                Text(translation)
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.mutedText)
                                    .italic()
                            }
                        }
                        .padding(.top, 32)
                        .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                        
                        VStack(spacing: 12) {
                            ForEach(question.options, id: \.self) { option in
                                Button {
                                    if !showResult {
                                        selectAnswer(option)
                                    }
                                } label: {
                                    HStack {
                                        Text(option)
                                            .font(AppTheme.Typography.title3)
                                            .foregroundColor(getOptionColor(option))
                                        
                                        Spacer()
                                        
                                        if showResult && option == question.word {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        } else if showResult && option == selectedAnswer && option != question.word {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .padding()
                                    .background(getOptionBackground(option))
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
                                }
                                .disabled(showResult)
                            }
                        }
                        .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                        
                        if showResult {
                            resultFeedback
                        }
                    }
                    .padding(.bottom, 100)
                }
                
                if showResult {
                    VStack {
                        Button {
                            nextQuestion()
                        } label: {
                            Text(currentQuestionIndex < questions.count - 1 ? "Next Question" : "Finish")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.brandAccent)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
                        }
                        .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                        .padding(.bottom, 16)
                    }
                    .background(AppTheme.background)
                }
            }
        }
        .background(AppTheme.background)
        .navigationTitle(game?.title ?? "Grammar Fill")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadQuestions()
            startTimer()
        }
        .reloadOnLevelChange {
            await loadQuestions()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var resultsView: some View {
        ProfessionalResultsView(
            score: score,
            total: questions.count,
            title: "Quiz Complete!",
            icon: "checkmark.seal.fill",
            color: .purple,
            restartAction: restartQuiz
        )
    }
    
    private var resultFeedback: some View {
        VStack(spacing: 8) {
            if selectedAnswer == currentQuestion?.word {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Correct!")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.green)
                }
            } else {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Text("Incorrect")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(.red)
                    }
                    Text("Correct answer: \(currentQuestion?.word ?? "")")
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.mutedText)
                }
            }
        }
        .padding()
        .background(AppTheme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
        .padding(.horizontal, AppTheme.Layout.horizontalPadding)
    }
    
    private func loadQuestions() async {
        isLoading = true
        
        if let gameQuestions = game?.questions, !gameQuestions.isEmpty {
            questions = gameQuestions
        } else {
            // Fallback: Generate from grammar points
            questions = learningDataService.grammarPoints.shuffled().prefix(8).map { grammar in
                let options = grammar.examples.map { $0.japanese }.shuffled().prefix(4)
                return GameModel.Question(
                    word: grammar.examples.first?.japanese ?? "",
                    reading: nil,
                    correctMeaning: grammar.examples.first?.english,
                    options: Array(options),
                    sentence: grammar.usage,
                    correctParticle: nil,
                    translation: grammar.examples.first?.english
                )
            }
        }
        
        isLoading = false
    }
    
    private func startTimer() {
        timer?.invalidate()
        timeRemaining = game?.timeLimit ?? 120
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                showCompleted = true
            }
        }
    }
    
    private func selectAnswer(_ answer: String) {
        selectedAnswer = answer
        showResult = true
        
        if answer == currentQuestion?.word {
            score += 1
            Haptics.success()
        } else {
            Haptics.error()
        }
    }
    
    private func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswer = nil
            showResult = false
        } else {
            showCompleted = true
            timer?.invalidate()
        }
    }
    
    private func restartQuiz() {
        currentQuestionIndex = 0
        score = 0
        selectedAnswer = nil
        showResult = false
        showCompleted = false
        Task {
            await loadQuestions()
            startTimer()
        }
    }
    
    private func getOptionColor(_ option: String) -> Color {
        if !showResult {
            return Color.primary
        }
        if option == currentQuestion?.word {
            return .green
        } else if option == selectedAnswer {
            return .red
        }
        return AppTheme.mutedText
    }
    
    private func getOptionBackground(_ option: String) -> Color {
        if !showResult {
            return AppTheme.secondaryBackground
        }
        if option == currentQuestion?.word {
            return Color.green.opacity(0.2)
        } else if option == selectedAnswer {
            return Color.red.opacity(0.2)
        }
        return AppTheme.secondaryBackground
    }
}

// MARK: - Particle Quiz View
struct ParticleQuizView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    var game: GameModel?
    
    @State private var questions: [GameModel.Question] = []
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    @State private var selectedAnswer: String?
    @State private var showResult = false
    @State private var isLoading = true
    @State private var showCompleted = false
    @State private var timeRemaining: Int = 90
    @State private var timer: Timer?
    
    var currentQuestion: GameModel.Question? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                Spacer()
                ProgressView()
                    .scaleEffect(1.5)
                Spacer()
            } else if showCompleted {
                resultsView
            } else if let question = currentQuestion {
                // Header
                VStack(spacing: 12) {
                    HStack {
                        Text("Question \(currentQuestionIndex + 1)/\(questions.count)")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.mutedText)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                                .foregroundColor(timeRemaining < 30 ? .red : AppTheme.brandAccent)
                            Text("\(timeRemaining)s")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(timeRemaining < 30 ? .red : AppTheme.mutedText)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("\(score)")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.mutedText)
                        }
                    }
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                    .padding(.top, 16)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                            Rectangle()
                                .fill(AppTheme.brandAccent)
                                .frame(width: geometry.size.width * CGFloat(currentQuestionIndex) / CGFloat(questions.count))
                        }
                    }
                    .frame(height: 4)
                }
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            Text("Choose the correct particle")
                                .font(AppTheme.Typography.subheadline)
                                .foregroundColor(AppTheme.mutedText)
                            
                            Text(question.sentence ?? "")
                                .font(AppTheme.Typography.title2)
                                .foregroundColor(Color.primary)
                                .multilineTextAlignment(.center)
                                .padding(24)
                                .frame(maxWidth: .infinity)
                                .background(AppTheme.secondaryBackground)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                            
                            if let translation = question.translation {
                                Text(translation)
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.mutedText)
                                    .italic()
                            }
                        }
                        .padding(.top, 32)
                        .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(question.options, id: \.self) { option in
                                Button {
                                    if !showResult {
                                        selectAnswer(option)
                                    }
                                } label: {
                                    Text(option)
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(getOptionColor(option))
                                        .frame(maxWidth: .infinity, minHeight: 80)
                                        .background(getOptionBackground(option))
                                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
                                        .overlay(
                                            Group {
                                                if showResult && option == question.correctParticle {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.green)
                                                        .font(.title)
                                                        .offset(x: -8, y: -8)
                                                } else if showResult && option == selectedAnswer && option != question.correctParticle {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.red)
                                                        .font(.title)
                                                        .offset(x: -8, y: -8)
                                                }
                                            },
                                            alignment: .topTrailing
                                        )
                                }
                                .disabled(showResult)
                            }
                        }
                        .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                        
                        if showResult {
                            resultFeedback
                        }
                    }
                    .padding(.bottom, 100)
                }
                
                if showResult {
                    VStack {
                        Button {
                            nextQuestion()
                        } label: {
                            Text(currentQuestionIndex < questions.count - 1 ? "Next Question" : "Finish")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.brandAccent)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
                        }
                        .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                        .padding(.bottom, 16)
                    }
                    .background(AppTheme.background)
                }
            }
        }
        .background(AppTheme.background)
        .navigationTitle(game?.title ?? "Particle Challenge")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadQuestions()
            startTimer()
        }
        .reloadOnLevelChange {
            await loadQuestions()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var resultsView: some View {
        ProfessionalResultsView(
            score: score,
            total: questions.count,
            title: "Quiz Complete!",
            icon: "checkmark.seal.fill",
            color: .pink,
            restartAction: restartQuiz
        )
    }
    
    private var resultFeedback: some View {
        VStack(spacing: 8) {
            if selectedAnswer == currentQuestion?.correctParticle {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Correct!")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.green)
                }
            } else {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Text("Incorrect")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(.red)
                    }
                    Text("Correct particle: \(currentQuestion?.correctParticle ?? "")")
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.mutedText)
                }
            }
        }
        .padding()
        .background(AppTheme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
        .padding(.horizontal, AppTheme.Layout.horizontalPadding)
    }
    
    private func loadQuestions() async {
        isLoading = true
        
        if let gameQuestions = game?.questions, !gameQuestions.isEmpty {
            questions = gameQuestions
        } else {
            // Fallback: Generate simple particle questions
            let particles = ["は", "が", "を", "に", "で", "と", "へ", "から"]
            questions = (0..<8).map { _ in
                let correctParticle = particles.randomElement() ?? "は"
                let options = particles.shuffled().prefix(4)
                return GameModel.Question(
                    word: nil,
                    reading: nil,
                    correctMeaning: nil,
                    options: Array(options),
                    sentence: "私___学校に行きます。",
                    correctParticle: correctParticle,
                    translation: "I go to school."
                )
            }
        }
        
        isLoading = false
    }
    
    private func startTimer() {
        timer?.invalidate()
        timeRemaining = game?.timeLimit ?? 90
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                showCompleted = true
            }
        }
    }
    
    private func selectAnswer(_ answer: String) {
        selectedAnswer = answer
        showResult = true
        
        if answer == currentQuestion?.correctParticle {
            score += 1
            Haptics.success()
        } else {
            Haptics.error()
        }
    }
    
    private func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswer = nil
            showResult = false
        } else {
            showCompleted = true
            timer?.invalidate()
        }
    }
    
    private func restartQuiz() {
        currentQuestionIndex = 0
        score = 0
        selectedAnswer = nil
        showResult = false
        showCompleted = false
        Task {
            await loadQuestions()
            startTimer()
        }
    }
    
    private func getOptionColor(_ option: String) -> Color {
        if !showResult {
            return Color.primary
        }
        if option == currentQuestion?.correctParticle {
            return .green
        } else if option == selectedAnswer {
            return .red
        }
        return AppTheme.mutedText
    }
    
    private func getOptionBackground(_ option: String) -> Color {
        if !showResult {
            return AppTheme.secondaryBackground
        }
        if option == currentQuestion?.correctParticle {
            return Color.green.opacity(0.2)
        } else if option == selectedAnswer {
            return Color.red.opacity(0.2)
        }
        return AppTheme.secondaryBackground
    }
}

// MARK: - Mixed Quiz View
struct MixedQuizView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    var game: GameModel?
    
    @State private var questions: [GameModel.Question] = []
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    @State private var selectedAnswer: String?
    @State private var showResult = false
    @State private var isLoading = true
    @State private var showCompleted = false
    @State private var timeRemaining: Int = 120
    @State private var timer: Timer?
    
    var currentQuestion: GameModel.Question? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                Spacer()
                ProgressView()
                    .scaleEffect(1.5)
                Spacer()
            } else if showCompleted {
                resultsView
            } else if let question = currentQuestion {
                // Header
                VStack(spacing: 12) {
                    HStack {
                        Text("Question \(currentQuestionIndex + 1)/\(questions.count)")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.mutedText)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                                .foregroundColor(timeRemaining < 30 ? .red : AppTheme.brandAccent)
                            Text("\(timeRemaining)s")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(timeRemaining < 30 ? .red : AppTheme.mutedText)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("\(score)")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.mutedText)
                        }
                    }
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                    .padding(.top, 16)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                            Rectangle()
                                .fill(AppTheme.brandAccent)
                                .frame(width: geometry.size.width * CGFloat(currentQuestionIndex) / CGFloat(questions.count))
                        }
                    }
                    .frame(height: 4)
                }
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.yellow)
                                Text("Mixed Review")
                                    .font(AppTheme.Typography.subheadline)
                                    .foregroundColor(AppTheme.mutedText)
                                Image(systemName: "sparkles")
                                    .foregroundColor(.yellow)
                            }
                            
                            if let word = question.word {
                                Text(word)
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(Color.primary)
                                    .padding(24)
                                    .frame(maxWidth: .infinity)
                                    .background(AppTheme.secondaryBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                            } else if let sentence = question.sentence {
                                VStack(spacing: 8) {
                                    Text(sentence)
                                        .font(AppTheme.Typography.title2)
                                        .foregroundColor(Color.primary)
                                        .multilineTextAlignment(.center)
                                        .padding(24)
                                        .frame(maxWidth: .infinity)
                                        .background(AppTheme.secondaryBackground)
                                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                                    
                                    if let translation = question.translation {
                                        Text(translation)
                                            .font(AppTheme.Typography.caption)
                                            .foregroundColor(AppTheme.mutedText)
                                            .italic()
                                    }
                                }
                            }
                        }
                        .padding(.top, 32)
                        .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                        
                        VStack(spacing: 12) {
                            ForEach(question.options, id: \.self) { option in
                                Button {
                                    if !showResult {
                                        selectAnswer(option)
                                    }
                                } label: {
                                    HStack {
                                        Text(option)
                                            .font(AppTheme.Typography.body)
                                            .foregroundColor(getOptionColor(option))
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer()
                                        
                                        if showResult && isCorrectAnswer(option) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        } else if showResult && option == selectedAnswer && !isCorrectAnswer(option) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .padding()
                                    .background(getOptionBackground(option))
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
                                }
                                .disabled(showResult)
                            }
                        }
                        .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                        
                        if showResult {
                            resultFeedback
                        }
                    }
                    .padding(.bottom, 100)
                }
                
                if showResult {
                    VStack {
                        Button {
                            nextQuestion()
                        } label: {
                            Text(currentQuestionIndex < questions.count - 1 ? "Next Question" : "Finish")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.brandAccent)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
                        }
                        .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                        .padding(.bottom, 16)
                    }
                    .background(AppTheme.background)
                }
            }
        }
        .background(AppTheme.background)
        .navigationTitle(game?.title ?? "Mixed Review")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadQuestions()
            startTimer()
        }
        .reloadOnLevelChange {
            await loadQuestions()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var resultsView: some View {
        ProfessionalResultsView(
            score: score,
            total: questions.count,
            title: "Quiz Complete!",
            icon: "trophy.fill",
            color: .orange,
            restartAction: restartQuiz
        )
    }
    
    private var resultFeedback: some View {
        VStack(spacing: 8) {
            if isCurrentAnswerCorrect() {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Correct!")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.green)
                }
            } else {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Text("Incorrect")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(.red)
                    }
                    Text("Correct answer: \(getCorrectAnswer())")
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.mutedText)
                }
            }
        }
        .padding()
        .background(AppTheme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
        .padding(.horizontal, AppTheme.Layout.horizontalPadding)
    }
    
    private func loadQuestions() async {
        isLoading = true
        
        if let gameQuestions = game?.questions, !gameQuestions.isEmpty {
            questions = gameQuestions
        } else {
            // Generate mixed questions from all categories
            var mixedQuestions: [GameModel.Question] = []
            
            // Add vocabulary questions
            let vocabCards = learningDataService.flashcards.shuffled().prefix(3)
            for card in vocabCards {
                var options = [card.meaning]
                let others = learningDataService.flashcards
                    .filter { $0.id != card.id }
                    .map { $0.meaning }
                    .shuffled()
                    .prefix(3)
                options.append(contentsOf: others)
                options.shuffle()
                
                mixedQuestions.append(GameModel.Question(
                    word: card.front,
                    reading: card.reading,
                    correctMeaning: card.meaning,
                    options: options,
                    sentence: nil,
                    correctParticle: nil,
                    translation: nil
                ))
            }
            
            // Add kanji questions
            let kanjiItems = learningDataService.kanji.shuffled().prefix(2)
            for kanji in kanjiItems {
                var options = [kanji.readings.kunyomi.first ?? kanji.readings.onyomi.first ?? ""]
                let others = learningDataService.kanji
                    .filter { $0.character != kanji.character }
                    .map { $0.readings.kunyomi.first ?? $0.readings.onyomi.first ?? "" }
                    .shuffled()
                    .prefix(3)
                options.append(contentsOf: others)
                options.shuffle()
                
                mixedQuestions.append(GameModel.Question(
                    word: kanji.character,
                    reading: kanji.readings.kunyomi.first ?? kanji.readings.onyomi.first ?? "",
                    correctMeaning: kanji.meaning,
                    options: options,
                    sentence: nil,
                    correctParticle: nil,
                    translation: nil
                ))
            }
            
            // Add grammar questions
            let grammarItems = learningDataService.grammarPoints.shuffled().prefix(3)
            for grammar in grammarItems {
                if let example = grammar.examples.first {
                    var options = [example.japanese]
                    let others = learningDataService.grammarPoints
                        .filter { $0.id != grammar.id }
                        .flatMap { $0.examples.map { $0.japanese } }
                        .shuffled()
                        .prefix(3)
                    options.append(contentsOf: others)
                    options.shuffle()
                    
                    mixedQuestions.append(GameModel.Question(
                        word: nil,
                        reading: nil,
                        correctMeaning: example.japanese,
                        options: options,
                        sentence: grammar.usage,
                        correctParticle: nil,
                        translation: example.english
                    ))
                }
            }
            
            questions = mixedQuestions.shuffled()
        }
        
        isLoading = false
    }
    
    private func startTimer() {
        timer?.invalidate()
        timeRemaining = game?.timeLimit ?? 120
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                showCompleted = true
            }
        }
    }
    
    private func selectAnswer(_ answer: String) {
        selectedAnswer = answer
        showResult = true
        
        if isCorrectAnswer(answer) {
            score += 1
            Haptics.success()
        } else {
            Haptics.error()
        }
    }
    
    private func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswer = nil
            showResult = false
        } else {
            showCompleted = true
            timer?.invalidate()
        }
    }
    
    private func restartQuiz() {
        currentQuestionIndex = 0
        score = 0
        selectedAnswer = nil
        showResult = false
        showCompleted = false
        Task {
            await loadQuestions()
            startTimer()
        }
    }
    
    private func isCorrectAnswer(_ answer: String) -> Bool {
        guard let question = currentQuestion else { return false }
        return answer == question.correctMeaning || answer == question.reading || answer == question.word
    }
    
    private func isCurrentAnswerCorrect() -> Bool {
        guard let answer = selectedAnswer else { return false }
        return isCorrectAnswer(answer)
    }
    
    private func getCorrectAnswer() -> String {
        guard let question = currentQuestion else { return "" }
        return question.correctMeaning ?? question.reading ?? question.word ?? ""
    }
    
    private func getOptionColor(_ option: String) -> Color {
        if !showResult {
            return Color.primary
        }
        if isCorrectAnswer(option) {
            return .green
        } else if option == selectedAnswer {
            return .red
        }
        return AppTheme.mutedText
    }
    
    private func getOptionBackground(_ option: String) -> Color {
        if !showResult {
            return AppTheme.secondaryBackground
        }
        if isCorrectAnswer(option) {
            return Color.green.opacity(0.2)
        } else if option == selectedAnswer {
            return Color.red.opacity(0.2)
        }
        return AppTheme.secondaryBackground
    }
}

// MARK: - Sentence Builder Game View
struct SentenceBuilderGameView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    var game: GameModel?
    
    @State private var currentSentence: String = ""
    @State private var translation: String = ""
    @State private var wordChips: [(word: String, id: UUID)] = []
    @State private var selectedWords: [(word: String, id: UUID)] = []
    @State private var score = 0
    @State private var currentRound = 0
    @State private var totalRounds = 5
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var isLoading = true
    @State private var showCompleted = false
    @State private var timeRemaining: Int = 90
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                Spacer()
                ProgressView()
                    .scaleEffect(1.5)
                Spacer()
            } else if showCompleted {
                resultsView
            } else {
                // Header
                VStack(spacing: 12) {
                    HStack {
                        Text("Round \(currentRound + 1)/\(totalRounds)")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.mutedText)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                                .foregroundColor(timeRemaining < 30 ? .red : AppTheme.brandAccent)
                            Text("\(timeRemaining)s")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(timeRemaining < 30 ? .red : AppTheme.mutedText)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("\(score)")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.mutedText)
                        }
                    }
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                    .padding(.top, 16)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                            Rectangle()
                                .fill(AppTheme.brandAccent)
                                .frame(width: geometry.size.width * CGFloat(currentRound) / CGFloat(totalRounds))
                        }
                    }
                    .frame(height: 4)
                }
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Translation to build
                        VStack(spacing: 8) {
                            Text("Build this sentence:")
                                .font(AppTheme.Typography.subheadline)
                                .foregroundColor(AppTheme.mutedText)
                            
                            Text(translation)
                                .font(AppTheme.Typography.title3)
                                .foregroundColor(Color.primary)
                                .multilineTextAlignment(.center)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(AppTheme.secondaryBackground)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
                        }
                        .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                        .padding(.top, 16)
                        
                        // Selected words area
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Sentence:")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.mutedText)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(selectedWords, id: \.id) { item in
                                    Button {
                                        removeWord(item)
                                    } label: {
                                        HStack(spacing: 4) {
                                            Text(item.word)
                                                .font(AppTheme.Typography.body)
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.caption)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.blue.opacity(0.2))
                                        .foregroundColor(.blue)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(minHeight: 80)
                            .padding()
                            .background(AppTheme.secondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
                        }
                        .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                        
                        // Available words
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Available Words:")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.mutedText)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(wordChips, id: \.id) { item in
                                    Button {
                                        selectWord(item)
                                    } label: {
                                        Text(item.word)
                                            .font(AppTheme.Typography.body)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(AppTheme.secondaryBackground)
                                            .foregroundColor(Color.primary)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                            )
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(minHeight: 120)
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
                        }
                        .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                        
                        if showResult {
                            resultFeedback
                        }
                    }
                    .padding(.bottom, 100)
                }
                
                // Bottom buttons
                VStack(spacing: 12) {
                    if !showResult {
                        HStack(spacing: 12) {
                            Button {
                                clearAll()
                            } label: {
                                Text("Clear")
                                    .font(AppTheme.Typography.subheadline)
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
                            }
                            
                            Button {
                                checkAnswer()
                            } label: {
                                Text("Check Answer")
                                    .font(AppTheme.Typography.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(selectedWords.isEmpty ? Color.gray : AppTheme.brandAccent)
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
                            }
                            .disabled(selectedWords.isEmpty)
                        }
                    } else {
                        Button {
                            nextRound()
                        } label: {
                            Text(currentRound < totalRounds - 1 ? "Next Sentence" : "Finish")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.brandAccent)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                .padding(.bottom, 16)
                .background(AppTheme.background)
            }
        }
        .background(AppTheme.background)
        .navigationTitle(game?.title ?? "Sentence Builder")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            loadRound()
            startTimer()
        }
        .reloadOnLevelChange {
            loadRound()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var resultsView: some View {
        ProfessionalResultsView(
            score: score,
            total: totalRounds,
            title: "Game Complete!",
            icon: "checkmark.seal.fill",
            color: .purple,
            restartAction: restartGame
        )
    }
    
    private var resultFeedback: some View {
        VStack(spacing: 8) {
            if isCorrect {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Correct!")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.green)
                }
            } else {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Text("Incorrect")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(.red)
                    }
                    Text("Correct sentence: \(currentSentence)")
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.mutedText)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding()
        .background(AppTheme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
        .padding(.horizontal, AppTheme.Layout.horizontalPadding)
    }
    
    private func loadRound() {
        isLoading = true
        showResult = false
        isCorrect = false
        
        // Get a random grammar example
        if let grammar = learningDataService.grammarPoints.randomElement(),
           let example = grammar.examples.randomElement() {
            currentSentence = example.japanese
            translation = example.english
            
            // Split sentence into words and shuffle
            let words = currentSentence.components(separatedBy: " ")
            wordChips = words.map { (word: $0, id: UUID()) }.shuffled()
            selectedWords = []
        }
        
        isLoading = false
    }
    
    private func startTimer() {
        timer?.invalidate()
        timeRemaining = game?.timeLimit ?? 90
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                showCompleted = true
            }
        }
    }
    
    private func selectWord(_ item: (word: String, id: UUID)) {
        selectedWords.append(item)
        wordChips.removeAll { $0.id == item.id }
    }
    
    private func removeWord(_ item: (word: String, id: UUID)) {
        wordChips.append(item)
        selectedWords.removeAll { $0.id == item.id }
    }
    
    private func clearAll() {
        wordChips.append(contentsOf: selectedWords)
        selectedWords = []
    }
    
    private func checkAnswer() {
        let userSentence = selectedWords.map { $0.word }.joined(separator: " ")
        isCorrect = userSentence == currentSentence
        showResult = true
        
        if isCorrect {
            score += 1
            Haptics.success()
        } else {
            Haptics.error()
        }
    }
    
    private func nextRound() {
        if currentRound < totalRounds - 1 {
            currentRound += 1
            loadRound()
        } else {
            showCompleted = true
            timer?.invalidate()
        }
    }
    
    private func restartGame() {
        currentRound = 0
        score = 0
        showCompleted = false
        loadRound()
        startTimer()
    }
}


