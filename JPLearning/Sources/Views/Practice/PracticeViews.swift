//
//  PracticeViews.swift
//  JLearn
//
//  Practice screens for Kanji, Vocabulary, Grammar, and Listening
//

import SwiftUI

// MARK: - Practice Hub View

struct PracticeView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Practice")
                            .font(AppTheme.Typography.largeTitle)
                        
                        Text("Choose your practice mode")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.mutedText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                    
                    // Practice Categories
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        PracticeCategoryCard(
                            title: "Kanji",
                            icon: "character.textbox",
                            color: AppTheme.kanjiColor,
                            description: "Practice characters",
                            destination: AnyView(KanjiPracticeView())
                        )
                        
                        PracticeCategoryCard(
                            title: "Vocabulary",
                            icon: "book.closed.fill",
                            color: AppTheme.vocabularyColor,
                            description: "Learn words",
                            destination: AnyView(VocabularyPracticeView())
                        )
                        
                        PracticeCategoryCard(
                            title: "Grammar",
                            icon: "text.book.closed.fill",
                            color: AppTheme.grammarColor,
                            description: "Study patterns",
                            destination: AnyView(GrammarPracticeView())
                        )
                        
                        PracticeCategoryCard(
                            title: "Reading",
                            icon: "book.pages",
                            color: .green,
                            description: "Read passages",
                            destination: AnyView(ReadingPracticeView())
                        )
                        
                        PracticeCategoryCard(
                            title: "Listening",
                            icon: "headphones",
                            color: AppTheme.listeningColor,
                            description: "Train your ear",
                            destination: AnyView(ListeningPracticeView())
                        )
                        
                        PracticeCategoryCard(
                            title: "Speaking",
                            icon: "mic.fill",
                            color: AppTheme.speakingColor,
                            description: "Practice speaking",
                            destination: AnyView(SpeakingPracticeView())
                        )
                        
                        PracticeCategoryCard(
                            title: "Writing",
                            icon: "pencil.line",
                            color: AppTheme.writingColor,
                            description: "Write characters",
                            destination: AnyView(WritingPracticeView())
                        )
                    }
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                }
                .padding(.vertical, 24)
            }
            .background(AppTheme.background)
            .onAppear {
                AnalyticsService.shared.trackScreen("Practice", screenClass: "PracticeView")
            }
        }
    }
}

// MARK: - Practice Category Card

struct PracticeCategoryCard: View {
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
                    
                    Text(description)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.mutedText)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
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

// MARK: - Kanji Practice View

struct KanjiPracticeView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @State private var currentIndex = 0
    @State private var showAnswer = false
    @State private var isUpdating = false
    
    var kanjiList: [Kanji] {
        let list = learningDataService.kanji
        print("🎯 [KANJI VIEW] kanjiList computed: \(list.count) kanji")
        print("🎯 [KANJI VIEW] Current level: \(learningDataService.currentLevel.rawValue)")
        if list.isEmpty {
            print("⚠️ [KANJI VIEW] Kanji list is EMPTY!")
        } else {
            print("✅ [KANJI VIEW] First kanji: \(list.first?.character ?? "nil")")
        }
        return list
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Level Indicator
            CompactLevelHeader()
            
            // Progress Bar
            ProgressView(value: Double(currentIndex + 1), total: Double(max(kanjiList.count, 1)))
                .tint(AppTheme.kanjiColor)
                .padding()
            
            if !kanjiList.isEmpty {
                // Kanji Card
                VStack {
                    Spacer()
                    
                    KanjiCardView(
                        kanji: kanjiList[currentIndex],
                        showAnswer: $showAnswer
                    )
                    
                    Spacer()
                    
                    // Controls
                    HStack(spacing: 16) {
                        Button {
                            previousCard()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(AppTheme.brandPrimary)
                                .frame(width: 50, height: 50)
                                .background(AppTheme.secondaryBackground)
                                .clipShape(Circle())
                        }
                        .disabled(currentIndex == 0)
                        
                        Button {
                            showAnswer.toggle()
                            Haptics.selection()
                        } label: {
                            Text(showAnswer ? "Hide Answer" : "Show Answer")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(AppTheme.kanjiColor)
                                .clipShape(Capsule())
                        }
                        
                        Button {
                            nextCard()
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.title2)
                                .foregroundColor(AppTheme.brandPrimary)
                                .frame(width: 50, height: 50)
                                .background(AppTheme.secondaryBackground)
                                .clipShape(Circle())
                        }
                        .disabled(currentIndex >= kanjiList.count - 1)
                    }
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                    .padding(.bottom, 24)
                }
            } else {
                VStack(spacing: 16) {
                    if learningDataService.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(AppTheme.kanjiColor)
                        
                        Text("Loading kanji...")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.mutedText)
                    } else {
                        ProfessionalEmptyStateView(
                            icon: "character.textbox",
                            title: "No Kanji Available",
                            message: "Check back later for new content"
                        )
                        
                        Button("Reload Data") {
                            Task {
                                await learningDataService.loadLearningData()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.kanjiColor)
                    }
                }
                .onAppear {
                    print("❌ [KANJI VIEW] Empty state showing - kanji array is empty")
                    print("❌ [KANJI VIEW] learningDataService.kanji.count = \(learningDataService.kanji.count)")
                    print("❌ [KANJI VIEW] isLoading = \(learningDataService.isLoading)")
                    
                    // Auto-reload if data is empty and not currently loading
                    if !learningDataService.isLoading {
                        print("🔄 [KANJI VIEW] Auto-reloading data...")
                        Task {
                            await learningDataService.loadLearningData()
                        }
                    }
                }
            }
        }
        .background(AppTheme.background)
        .navigationTitle("Kanji Practice")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            print("👀 [KANJI VIEW] View appeared")
            print("👀 [KANJI VIEW] Current level: \(learningDataService.currentLevel.rawValue)")
            print("👀 [KANJI VIEW] Kanji count: \(learningDataService.kanji.count)")
        }
    }
    
    private func nextCard() {
        if currentIndex < kanjiList.count - 1 {
            currentIndex += 1
            showAnswer = false
            Haptics.selection()
        }
    }
    
    private func previousCard() {
        if currentIndex > 0 {
            currentIndex -= 1
            showAnswer = false
            Haptics.selection()
        }
    }
}

// MARK: - Kanji Card View

struct KanjiCardView: View {
    let kanji: Kanji
    @Binding var showAnswer: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Card Container
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppTheme.secondaryBackground)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
                
                VStack(spacing: 24) {
                    // Kanji Character (Front)
                    Text(kanji.character)
                        .font(.system(size: 120, weight: .medium))
                        .foregroundColor(AppTheme.brandPrimary)
                    
                    if showAnswer {
                        // Divider
                        Rectangle()
                            .fill(AppTheme.mutedText.opacity(0.2))
                            .frame(height: 1)
                            .padding(.horizontal, 40)
                        
                        VStack(spacing: 16) {
                            // Meaning
                            VStack(spacing: 8) {
                                Text("Meaning")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.mutedText)
                                Text(kanji.meaning)
                                    .font(AppTheme.Typography.title2)
                                    .fontWeight(.semibold)
                            }
                            
                            // Readings
                            VStack(spacing: 8) {
                                if !kanji.readings.onyomi.isEmpty {
                                    HStack(spacing: 8) {
                                        Text("音読み:")
                                            .font(AppTheme.Typography.caption)
                                            .foregroundColor(AppTheme.mutedText)
                                        Text(kanji.readings.onyomi.joined(separator: ", "))
                                            .font(AppTheme.Typography.body)
                                    }
                                }
                                
                                if !kanji.readings.kunyomi.isEmpty {
                                    HStack(spacing: 8) {
                                        Text("訓読み:")
                                            .font(AppTheme.Typography.caption)
                                            .foregroundColor(AppTheme.mutedText)
                                        Text(kanji.readings.kunyomi.joined(separator: ", "))
                                            .font(AppTheme.Typography.body)
                                    }
                                }
                            }
                            
                            // Stroke Count
                            HStack(spacing: 8) {
                                Text("Strokes:")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.mutedText)
                                Text("\(kanji.strokes)")
                                    .font(AppTheme.Typography.body)
                                    .fontWeight(.medium)
                            }
                            
                            // Examples
                            if !kanji.examples.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Examples")
                                        .font(AppTheme.Typography.caption)
                                        .foregroundColor(AppTheme.mutedText)
                                    ForEach(kanji.examples.prefix(3), id: \.self) { example in
                                        Text(example)
                                            .font(AppTheme.Typography.body)
                                    }
                                }
                            }
                        }
                        .transition(.opacity)
                    }
                }
                .padding(32)
            }
            .frame(maxWidth: 500)
            .frame(height: showAnswer ? nil : 400)
            .padding(.horizontal, AppTheme.Layout.horizontalPadding)
        }
        .animation(.spring(), value: showAnswer)
    }
}

// MARK: - Vocabulary Practice View

struct VocabularyPracticeView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    
    var flashcards: [Flashcard] {
        let all = learningDataService.flashcards.filter { $0.category == "vocabulary" }
        let now = Date()
        let due = all.filter { ($0.nextReview ?? now) <= now }
        let upcoming = all.filter { ($0.nextReview ?? now) > now }
        return due + upcoming
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Level Indicator
            CompactLevelHeader()
            
            ScrollView {
                LazyVStack(spacing: 16) {
                ForEach(flashcards) { flashcard in
                    VocabularyCardView(flashcard: flashcard)
                }
            }
            .padding()
        }
        .background(AppTheme.background)
        .navigationTitle("Vocabulary")
        .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct VocabularyCardView: View {
    let flashcard: Flashcard
    @State private var showMeaning = false
    
    var body: some View {
        Button {
            showMeaning.toggle()
            Haptics.selection()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                // Japanese word
                Text(flashcard.front)
                    .font(AppTheme.Typography.japaneseTitle)
                    .foregroundColor(.primary)
                
                // Reading
                if let reading = flashcard.reading {
                    Text(reading)
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(AppTheme.mutedText)
                }
                
                // Meaning (shown on tap)
                if showMeaning {
                    Divider()
                    
                    Text(flashcard.meaning)
                        .font(AppTheme.Typography.body)
                        .foregroundColor(.primary)
                }
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
        }
    }
}

// MARK: - Grammar Practice View

struct GrammarPracticeView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    
    var body: some View {
        VStack(spacing: 0) {
            // Level Indicator
            CompactLevelHeader()
            
            ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(learningDataService.grammarPoints) { grammar in
                    GrammarCardView(grammar: grammar)
                }
            }
            .padding()
        }
        .background(AppTheme.background)
        .navigationTitle("Grammar")
        .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct GrammarCardView: View {
    let grammar: GrammarPoint
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
                Haptics.selection()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(grammar.title)
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(.primary)
                        
                        Text(grammar.pattern)
                            .font(AppTheme.Typography.japaneseBody)
                            .foregroundColor(AppTheme.grammarColor)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(AppTheme.mutedText)
                }
            }
            
            // Content (expanded)
            if isExpanded {
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(grammar.meaning)
                        .font(AppTheme.Typography.body)
                        .foregroundColor(.primary)
                    
                    Text(grammar.usage)
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(AppTheme.mutedText)
                    
                    // Examples
                    if !grammar.examples.isEmpty {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Examples:")
                                .font(AppTheme.Typography.subheadline)
                                .fontWeight(.semibold)
                            
                            ForEach(grammar.examples.indices, id: \.self) { index in
                                let example = grammar.examples[index]
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(example.japanese)
                                        .font(AppTheme.Typography.japaneseBody)
                                    Text(example.reading)
                                        .font(AppTheme.Typography.caption)
                                        .foregroundColor(AppTheme.mutedText)
                                    Text(example.english)
                                        .font(AppTheme.Typography.subheadline)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
        .shadow(
            color: AppTheme.Shadows.elevation2.color,
            radius: AppTheme.Shadows.elevation2.radius,
            y: AppTheme.Shadows.elevation2.y
        )
    }
}

// MARK: - Listening Practice View

struct ListeningPracticeView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @StateObject private var audioService = AudioService.shared
    @State private var questions: [PracticeQuestion] = []
    @State private var isLoading = true
    @State private var currentIndex = 0
    @State private var showResults = false
    @State private var score = 0
    
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
            // Level Indicator
            CompactLevelHeader()
            
            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if questions.isEmpty {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "ear")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No Listening Exercises")
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
                            .foregroundColor(AppTheme.listeningColor)
                    }
                    .padding(.horizontal)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(AppTheme.separator)
                                .frame(height: 4)
                            
                            Rectangle()
                                .fill(AppTheme.listeningColor)
                                .frame(width: geometry.size.width * progress, height: 4)
                        }
                    }
                    .frame(height: 4)
                }
                .padding(.top, 8)
                
                ScrollView {
                    ListeningQuestionCard(
                        question: question,
                        onAnswered: { isCorrect in
                            if isCorrect {
                                score += 1
                            }
                        },
                        onNext: {
                            nextQuestion()
                        }
                    )
                    .id(question.id) // Force view refresh for each question
                    .padding()
                }
            }
        }
        .background(AppTheme.background)
        .navigationTitle("Listening Practice")
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
            title: "Great Job!",
            icon: "checkmark.circle.fill",
            color: AppTheme.listeningColor,
            restartAction: restartPractice
        )
    }
    
    private func loadQuestions() async {
        isLoading = true
        questions = await learningDataService.loadPracticeQuestions(category: .listening)
        isLoading = false
    }
    
    private func nextQuestion() {
        if currentIndex < questions.count - 1 {
            withAnimation {
                currentIndex += 1
            }
        } else {
            withAnimation {
                showResults = true
            }
        }
    }
    
    private func restartPractice() {
        withAnimation {
            currentIndex = 0
            score = 0
            showResults = false
        }
    }
}

struct ListeningQuestionCard: View {
    let question: PracticeQuestion
    let onAnswered: (Bool) -> Void
    let onNext: () -> Void
    
    @StateObject private var audioService = AudioService.shared
    @State private var isPlaying = false
    @State private var selectedAnswer: String?
    @State private var showResult = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Play Audio Button
            VStack(spacing: 12) {
                Button {
                    playAudio()
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: isPlaying ? "speaker.wave.3.fill" : "speaker.wave.2")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                        
                        Text(isPlaying ? "Playing..." : "Tap to Listen")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.listeningColor, AppTheme.listeningColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                }
                
                Text(question.question)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Answer Options
            VStack(spacing: 12) {
                ForEach(question.options, id: \.self) { option in
                    Button {
                        if !showResult {
                            selectedAnswer = option
                            checkAnswer()
                        }
                    } label: {
                        HStack {
                            Text(option)
                                .font(AppTheme.Typography.body)
                                .foregroundColor(buttonTextColor(for: option))
                            
                            Spacer()
                            
                            if showResult {
                                Image(systemName: iconName(for: option))
                                    .foregroundColor(iconColor(for: option))
                            }
                        }
                        .padding()
                        .background(buttonBackground(for: option))
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius)
                                .stroke(buttonBorder(for: option), lineWidth: 2)
                        )
                    }
                    .disabled(showResult)
                }
            }
            
            // Explanation (if answered)
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
                .padding()
                .background(AppTheme.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
            }
            
            // Next Button (only shown after answering)
            if showResult {
                Button {
                    onNext()
                } label: {
                    HStack {
                        Text("Next")
                            .font(AppTheme.Typography.headline)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.listeningColor)
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
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
        .shadow(
            color: AppTheme.Shadows.elevation2.color,
            radius: AppTheme.Shadows.elevation2.radius,
            y: AppTheme.Shadows.elevation2.y
        )
    }
    
    private func playAudio() {
        isPlaying = true
        
        // Play the correct answer using text-to-speech
        Task {
            try? await audioService.speak(question.correctAnswer, language: "ja-JP")
        }
        
        // Reset playing state after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isPlaying = false
        }
    }
    
    private func checkAnswer() {
        withAnimation {
            showResult = true
        }
        let isCorrect = selectedAnswer == question.correctAnswer
        onAnswered(isCorrect)
        
        if isCorrect {
            Haptics.success()
        } else {
            Haptics.error()
        }
    }
    
    private func buttonBackground(for option: String) -> Color {
        if !showResult {
            return selectedAnswer == option ? AppTheme.listeningColor.opacity(0.1) : Color.white
        }
        
        if option == question.correctAnswer {
            return AppTheme.success.opacity(0.1)
        } else if selectedAnswer == option {
            return AppTheme.danger.opacity(0.1)
        }
        return Color.white
    }
    
    private func buttonBorder(for option: String) -> Color {
        if !showResult {
            return selectedAnswer == option ? AppTheme.listeningColor : AppTheme.separator
        }
        
        if option == question.correctAnswer {
            return AppTheme.success
        } else if selectedAnswer == option {
            return AppTheme.danger
        }
        return AppTheme.separator
    }
    
    private func buttonTextColor(for option: String) -> Color {
        if showResult {
            if option == question.correctAnswer {
                return AppTheme.success
            } else if selectedAnswer == option {
                return AppTheme.danger
            }
        }
        return .primary
    }
    
    private func iconName(for option: String) -> String {
        if option == question.correctAnswer {
            return "checkmark.circle.fill"
        } else if selectedAnswer == option {
            return "xmark.circle.fill"
        }
        return ""
    }
    
    private func iconColor(for option: String) -> Color {
        if option == question.correctAnswer {
            return AppTheme.success
        } else if selectedAnswer == option {
            return AppTheme.danger
        }
        return .clear
    }
}

// MARK: - Speaking Practice View

struct SpeakingPracticeView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @StateObject private var audioService = AudioService.shared
    @State private var showPermissionAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Level Indicator
            CompactLevelHeader()
            
            Spacer()
            
            // Microphone Icon
            ZStack {
                Circle()
                    .fill(audioService.isRecording ? AppTheme.speakingColor.opacity(0.2) : AppTheme.speakingColor.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .scaleEffect(audioService.isRecording ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: audioService.isRecording)
                
                Image(systemName: "mic.fill")
                    .font(.system(size: 50))
                    .foregroundColor(AppTheme.speakingColor)
            }
            
            // Status
            Text(audioService.isRecording ? "Listening..." : "Tap to speak")
                .font(AppTheme.Typography.title2)
                .foregroundColor(.primary)
            
            // Recognized Text
            if !audioService.recognizedText.isEmpty {
                ScrollView {
                    Text(audioService.recognizedText)
                        .font(AppTheme.Typography.japaneseBody)
                        .foregroundColor(.primary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(AppTheme.secondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                }
                .frame(maxHeight: 200)
            }
            
            Spacer()
            
            // Record Button
            Button {
                if audioService.isRecording {
                    audioService.stopRecording()
                } else {
                    startRecording()
                }
            } label: {
                Text(audioService.isRecording ? "Stop Recording" : "Start Recording")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(audioService.isRecording ? AppTheme.danger : AppTheme.speakingColor)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, AppTheme.Layout.horizontalPadding)
            .padding(.bottom, 24)
        }
        .padding()
        .background(AppTheme.background)
        .navigationTitle("Speaking Practice")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Microphone Permission Required", isPresented: $showPermissionAlert) {
            Button("OK") {}
        } message: {
            Text("Please enable microphone access in Settings to use speech recognition.")
        }
    }
    
    private func startRecording() {
        Task {
            do {
                try await audioService.startRecording()
            } catch {
                showPermissionAlert = true
            }
        }
    }
}

// MARK: - Writing Practice View

struct WritingPracticeView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @State private var questions: [PracticeQuestion] = []
    @State private var currentIndex = 0
    @State private var userAnswer = ""
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var score = 0
    @State private var isLoading = true
    @State private var showCompleted = false
    
    var currentQuestion: PracticeQuestion? {
        guard !questions.isEmpty && currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if questions.isEmpty {
                emptyStateView
            } else if showCompleted {
                completedView
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
                            .foregroundColor(AppTheme.writingColor)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(AppTheme.separator)
                                .frame(height: 4)
                            
                            Rectangle()
                                .fill(AppTheme.writingColor)
                                .frame(width: geometry.size.width * (Double(currentIndex) / Double(questions.count)), height: 4)
                        }
                    }
                    .frame(height: 4)
                }
                .padding(.vertical, 8)
                .background(Color.white)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Question Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(AppTheme.writingColor)
                                Text("Write in Hiragana")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.writingColor)
                                    .fontWeight(.semibold)
                            }
                            
                            Text(question.question)
                                .font(AppTheme.Typography.title2)
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
                        
                        // Answer Input
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Answer:")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(.secondary)
                            
                            TextField("Type your answer here", text: $userAnswer)
                                .font(.system(size: 32))
                                .textFieldStyle(.plain)
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .disabled(showResult)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                        .shadow(
                            color: AppTheme.Shadows.elevation2.color,
                            radius: AppTheme.Shadows.elevation2.radius,
                            y: AppTheme.Shadows.elevation2.y
                        )
                        
                        // Hint Options (if available)
                        if !question.options.isEmpty && !showResult {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Hint - Choose from:")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(.secondary)
                                
                                FlowLayout(spacing: 8) {
                                    ForEach(question.options, id: \.self) { option in
                                        Button {
                                            userAnswer = option
                                        } label: {
                                            Text(option)
                                                .font(AppTheme.Typography.body)
                                                .foregroundColor(AppTheme.writingColor)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(AppTheme.writingColor.opacity(0.1))
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(AppTheme.writingColor, lineWidth: 1)
                                                )
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Check Button
                        if !showResult && !userAnswer.isEmpty {
                            Button {
                                checkAnswer()
                            } label: {
                                Text("Check Answer")
                                    .font(AppTheme.Typography.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppTheme.writingColor)
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
                                    .shadow(
                                        color: AppTheme.Shadows.elevation2.color,
                                        radius: AppTheme.Shadows.elevation2.radius,
                                        y: AppTheme.Shadows.elevation2.y
                                    )
                            }
                        }
                        
                        // Result
                        if showResult {
                            VStack(spacing: 16) {
                                HStack {
                                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(isCorrect ? AppTheme.success : AppTheme.danger)
                                    Text(isCorrect ? "Correct!" : "Not quite right")
                                        .font(AppTheme.Typography.headline)
                                        .foregroundColor(isCorrect ? AppTheme.success : AppTheme.danger)
                                }
                                
                                if !isCorrect {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Correct Answer:")
                                            .font(AppTheme.Typography.caption)
                                            .foregroundColor(.secondary)
                                        Text(question.correctAnswer)
                                            .font(.system(size: 32))
                                            .foregroundColor(.primary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(AppTheme.success.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                
                                if let explanation = question.explanation {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Explanation:")
                                            .font(AppTheme.Typography.caption)
                                            .foregroundColor(.secondary)
                                        Text(explanation)
                                            .font(AppTheme.Typography.body)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                
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
                                    .background(AppTheme.writingColor)
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
                                    .shadow(
                                        color: AppTheme.Shadows.elevation2.color,
                                        radius: AppTheme.Shadows.elevation2.radius,
                                        y: AppTheme.Shadows.elevation2.y
                                    )
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
        .navigationTitle("Writing Practice")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadQuestions()
        }
    }
    
    private var emptyStateView: some View {
        ProfessionalEmptyStateView(
            icon: "pencil.slash",
            title: "No Writing Exercises",
            message: "Check back later for new content"
        )
    }
    
    private var completedView: some View {
        ProfessionalResultsView(
            score: score,
            total: questions.count,
            title: "Writing Practice Complete!",
            icon: "checkmark.seal.fill",
            color: AppTheme.writingColor,
            restartAction: restartPractice
        )
    }
    
    private func loadQuestions() async {
        isLoading = true
        questions = await learningDataService.loadPracticeQuestions(category: .writing)
        isLoading = false
    }
    
    private func checkAnswer() {
        guard let question = currentQuestion else { return }
        
        let trimmedAnswer = userAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        isCorrect = trimmedAnswer == question.correctAnswer
        
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
                userAnswer = ""
                showResult = false
                isCorrect = false
            }
        } else {
            withAnimation {
                showCompleted = true
            }
        }
    }
    
    private func restartPractice() {
        withAnimation {
            currentIndex = 0
            userAnswer = ""
            showResult = false
            isCorrect = false
            score = 0
            showCompleted = false
        }
        Task {
            await loadQuestions()
        }
    }
}

