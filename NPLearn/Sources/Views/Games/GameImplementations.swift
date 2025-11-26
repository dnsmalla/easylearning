//
//  GameImplementations.swift
//  NPLearn
//
//  All game view implementations for NPLearn
//

import SwiftUI

// MARK: - Daily Quest View

struct DailyQuestView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @State private var quests: [Quest] = []
    @State private var completedQuests: Set<String> = []
    @State private var totalScore = 0
    @State private var isLoading = true
    
    struct Quest: Identifiable {
        let id = UUID().uuidString
        let title: String
        let description: String
        let icon: String
        let points: Int
        let color: Color
        let action: () async -> Bool
    }
    
    var allCompleted: Bool {
        completedQuests.count == quests.count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Daily Quest")
                        .font(AppTheme.Typography.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Complete all quests to earn bonus points!")
                        .font(AppTheme.Typography.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 32) {
                        VStack {
                            Text("\(completedQuests.count)/\(quests.count)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.blue)
                            Text("Completed")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("\(totalScore)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.orange)
                            Text("Points")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                
                // Quests List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(quests) { quest in
                            QuestCard(
                                quest: quest,
                                isCompleted: completedQuests.contains(quest.id)
                            ) {
                                await completeQuest(quest)
                            }
                        }
                        
                        // Completion Bonus
                        if allCompleted {
                            VStack(spacing: 16) {
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.yellow)
                                
                                Text("All Quests Complete!")
                                    .font(AppTheme.Typography.title)
                                    .fontWeight(.bold)
                                
                                Text("Bonus: +50 points")
                                    .font(AppTheme.Typography.headline)
                                    .foregroundColor(.orange)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.yellow.opacity(0.2), .orange.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding()
                }
            }
        }
        .background(AppTheme.background)
        .navigationTitle("Daily Quest")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await setupQuests()
        }
    }
    
    private func setupQuests() async {
        isLoading = true
        
        quests = [
            Quest(
                title: "Review 5 Flashcards",
                description: "Practice with flashcards",
                icon: "rectangle.on.rectangle",
                points: 10,
                color: .blue,
                action: { return true }
            ),
            Quest(
                title: "Answer 5 Questions",
                description: "Test your knowledge",
                icon: "questionmark.circle",
                points: 15,
                color: .green,
                action: { return true }
            ),
            Quest(
                title: "Study Grammar",
                description: "Learn 3 grammar points",
                icon: "book",
                points: 20,
                color: .purple,
                action: { return true }
            ),
            Quest(
                title: "Practice Listening",
                description: "Complete listening exercise",
                icon: "ear",
                points: 15,
                color: .orange,
                action: { return true }
            )
        ]
        
        isLoading = false
    }
    
    private func completeQuest(_ quest: Quest) async {
        guard !completedQuests.contains(quest.id) else { return }
        
        let success = await quest.action()
        if success {
            completedQuests.insert(quest.id)
            totalScore += quest.points
            Haptics.success()
            
            // Check for completion bonus
            if allCompleted {
                totalScore += 50
            }
        }
    }
}

struct QuestCard: View {
    let quest: DailyQuestView.Quest
    let isCompleted: Bool
    let action: () async -> Void
    
    var body: some View {
        Button {
            Task {
                await action()
            }
        } label: {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.green.opacity(0.2) : quest.color.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : quest.icon)
                        .font(.system(size: 28))
                        .foregroundColor(isCompleted ? .green : quest.color)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(quest.title)
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.primary)
                    Text(quest.description)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Points
                VStack(spacing: 4) {
                    Text("+\(quest.points)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.orange)
                    Text("pts")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isCompleted ? Color.green : Color.clear, lineWidth: 2)
            )
            .opacity(isCompleted ? 0.7 : 1.0)
        }
        .disabled(isCompleted)
    }
}

// MARK: - Word Match View

struct WordMatchView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @State private var flashcards: [Flashcard] = []
    @State private var matchPairs: [(nepali: String, english: String, id: String)] = []
    @State private var shuffledEnglishPairs: [(nepali: String, english: String, id: String)] = []
    @State private var selectedNepali: String?
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
            } else if flashcards.isEmpty {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No Words Available")
                        .font(AppTheme.Typography.title)
                    Text("Check back later for new content")
                        .font(AppTheme.Typography.body)
                        .foregroundColor(.secondary)
                }
                Spacer()
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
                        Text("Match the Nepali words with their English meanings")
                            .font(AppTheme.Typography.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        HStack(alignment: .top, spacing: 16) {
                            // Nepali Column
                            VStack(spacing: 12) {
                                ForEach(matchPairs, id: \.id) { pair in
                                    if !matchedPairs.contains(pair.id) {
                                        WordMatchCard(
                                            text: pair.nepali,
                                            isSelected: selectedNepali == pair.id,
                                            color: .green,
                                            isNepali: true
                                        ) {
                                            selectNepali(pair.id)
                                        }
                                    } else {
                                        MatchedCard(text: pair.nepali, isNepali: true)
                                    }
                                }
                            }
                            
                            // English Column (shuffled order)
                            VStack(spacing: 12) {
                                ForEach(shuffledEnglishPairs, id: \.id) { pair in
                                    if !matchedPairs.contains(pair.id) {
                                        WordMatchCard(
                                            text: pair.english,
                                            isSelected: selectedEnglish == pair.id,
                                            color: .green,
                                            isNepali: false
                                        ) {
                                            selectEnglish(pair.id)
                                        }
                                    } else {
                                        MatchedCard(text: pair.english, isNepali: false)
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
        
        // Use the flashcards from the learning data service
        if !learningDataService.flashcards.isEmpty {
            flashcards = learningDataService.flashcards
        }
        
        // Create match pairs from flashcards
        let selectedCards = Array(flashcards.prefix(6))
        matchPairs = selectedCards.map { card in
            (nepali: card.front, english: card.meaning, id: card.id)
        }
        
        // Create shuffled version for English column display
        shuffledEnglishPairs = matchPairs.shuffled()
        
        isLoading = false
    }
    
    private func selectNepali(_ id: String) {
        selectedNepali = id
        checkMatch()
    }
    
    private func selectEnglish(_ id: String) {
        selectedEnglish = id
        checkMatch()
    }
    
    private func checkMatch() {
        guard let nepaliId = selectedNepali,
              let englishId = selectedEnglish else { return }
        
        attempts += 1
        
        // Find the correct pair for the selected nepali
        if let nepaliPair = matchPairs.first(where: { $0.id == nepaliId }),
           let englishPair = matchPairs.first(where: { $0.id == englishId }) {
            
            // Check if they match
            if nepaliPair.english == englishPair.english {
                // Correct match!
                matchedPairs.insert(nepaliId)
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
        selectedNepali = nil
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

struct WordMatchCard: View {
    let text: String
    let isSelected: Bool
    let color: Color
    let isNepali: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(isNepali ? AppTheme.Typography.nepaliBody : AppTheme.Typography.body)
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
                    color: isSelected ? color.opacity(0.3) : Color.black.opacity(0.05),
                    radius: isSelected ? 8 : 4,
                    y: 2
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct MatchedCard: View {
    let text: String
    let isNepali: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text(text)
                .font(isNepali ? AppTheme.Typography.nepaliBody : AppTheme.Typography.body)
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

// MARK: - Time Attack View

struct TimeAttackView: View {
    @EnvironmentObject var learningDataService: LearningDataService
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
                
                Text("Answer as many questions as you can in 60 seconds!")
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
        
        var allQuestions: [PracticeQuestion] = []
        for category in [PracticeCategory.vocabulary, .grammar, .listening] {
            let categoryQuestions = await learningDataService.loadPracticeQuestions(category: category)
            allQuestions.append(contentsOf: categoryQuestions)
        }
        
        questions = allQuestions.shuffled()
        isLoading = false
    }
    
    private func startGame() {
        timeRemaining = 60
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
        timeRemaining = 60
        showResults = false
        isTimerRunning = false
    }
}

// MARK: - Sentence Builder View

struct SentenceBuilderView: View {
    var body: some View {
        SentenceBuilderGame()
    }
}

// MARK: - Quick Quiz View

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
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No Questions Available")
                        .font(AppTheme.Typography.title)
                    Text("Check back later for new content")
                        .font(AppTheme.Typography.body)
                        .foregroundColor(.secondary)
                }
                Spacer()
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
                        .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
                        
                        // Answer Options
                        VStack(spacing: 12) {
                            ForEach(question.options, id: \.self) { option in
                                AnswerButton(
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
                                .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
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
    }
    
    private var resultsView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Score Circle
            ZStack {
                Circle()
                    .stroke(AppTheme.separator, lineWidth: 10)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: Double(score) / Double(questions.count))
                    .stroke(Color.red, lineWidth: 10)
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("\(score)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.red)
                    Text("out of \(questions.count)")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text("Quiz Complete!")
                .font(AppTheme.Typography.title)
                .foregroundColor(.primary)
            
            let percentage = Int((Double(score) / Double(questions.count)) * 100)
            Text("You got \(percentage)% correct")
                .font(AppTheme.Typography.body)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Buttons
            VStack(spacing: 12) {
                Button {
                    restartQuiz()
                } label: {
                    Text("Try Again")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
                }
            }
            .padding()
        }
    }
    
    private func loadQuestions() async {
        isLoading = true
        
        // Load mixed questions from different categories
        var allQuestions: [PracticeQuestion] = []
        
        for category in [PracticeCategory.vocabulary, .grammar, .listening] {
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

// MARK: - Flashcard Sprint View

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

// MARK: - Answer Button

struct AnswerButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let action: () -> Void
    
    var backgroundColor: Color {
        if isCorrect {
            return AppTheme.success.opacity(0.1)
        } else if isWrong {
            return AppTheme.danger.opacity(0.1)
        } else if isSelected {
            return AppTheme.brandPrimary.opacity(0.1)
        } else {
            return Color.white
        }
    }
    
    var borderColor: Color {
        if isCorrect {
            return AppTheme.success
        } else if isWrong {
            return AppTheme.danger
        } else if isSelected {
            return AppTheme.brandPrimary
        } else {
            return AppTheme.separator
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.success)
                } else if isWrong {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.danger)
                }
            }
            .padding()
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius)
                    .stroke(borderColor, lineWidth: 2)
            )
        }
    }
}

