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

// MARK: - Practice Category Card (using consolidated version from ReusableCards)

// MARK: - Kanji Practice View

struct KanjiPracticeView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @State private var currentIndex = 0
    @State private var showAnswer = false
    @State private var isUpdating = false
    @State private var hasAppeared = false
    
    // Use the kanji array directly - no computed property
    var body: some View {
        VStack(spacing: 0) {
            // Level Indicator
            CompactLevelHeader()
            
            // Progress Bar
            if !learningDataService.kanji.isEmpty {
                ProgressView(value: Double(min(currentIndex + 1, learningDataService.kanji.count)), total: Double(learningDataService.kanji.count))
                    .tint(AppTheme.kanjiColor)
                    .padding()
            }
            
            if !learningDataService.kanji.isEmpty && currentIndex < learningDataService.kanji.count {
                // Kanji Card
                VStack {
                    Spacer()
                    
                    KanjiCardView(
                        kanji: learningDataService.kanji[currentIndex],
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
                        .disabled(currentIndex >= learningDataService.kanji.count - 1)
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
                            print("🔄 [MANUAL RELOAD] Button tapped")
                            Task {
                                await learningDataService.loadLearningData()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.kanjiColor)
                    }
                }
                .padding()
            }
        }
        .background(AppTheme.background)
        .navigationTitle("Kanji Practice")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Always reload when view appears
            if !hasAppeared {
                print("👀 [KANJI VIEW] First appear - loading data")
                hasAppeared = true
                if learningDataService.kanji.isEmpty && !learningDataService.isLoading {
                    print("🔄 [KANJI VIEW] Data empty, triggering load")
                    await learningDataService.loadLearningData()
                }
            }
            print("👀 [KANJI VIEW] Current kanji count: \(learningDataService.kanji.count)")
        }
        .reloadOnLevelChange {
            print("🔄 [KANJI VIEW] Level changed - reloading kanji data")
            currentIndex = 0
            showAnswer = false
            await learningDataService.loadLearningData()
        }
        .onChange(of: learningDataService.kanji.count) { _ in
            // Safety check if kanji list changes
            if currentIndex >= learningDataService.kanji.count {
                currentIndex = 0
            }
        }
    }
    
    private func nextCard() {
        if currentIndex < learningDataService.kanji.count - 1 {
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
    @State private var hasAppeared = false
    
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
            
            if !flashcards.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(flashcards) { flashcard in
                            VocabularyCardView(flashcard: flashcard)
                        }
                    }
                    .padding()
                }
            } else {
                VStack(spacing: 16) {
                    if learningDataService.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading vocabulary...")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.mutedText)
                    } else {
                        ProfessionalEmptyStateView(
                            icon: "book.closed.fill",
                            title: "No Vocabulary Available",
                            message: "Check back later for new content"
                        )
                        Button("Reload Data") {
                            Task {
                                await learningDataService.loadLearningData()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
            }
        }
        .background(AppTheme.background)
        .navigationTitle("Vocabulary")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if !hasAppeared {
                hasAppeared = true
                if flashcards.isEmpty && !learningDataService.isLoading {
                    await learningDataService.loadLearningData()
                }
            }
        }
        .reloadOnLevelChange {
            AppLogger.info("🔄 [VOCABULARY VIEW] Level changed to \(learningDataService.currentLevel.rawValue) - reloading vocabulary data")
            await learningDataService.loadLearningData()
            
            // Log first 3 vocabulary items to verify data
            let vocabCards = learningDataService.flashcards.filter { $0.category == "vocabulary" }
            AppLogger.info("📊 [VOCABULARY VIEW] Loaded \(vocabCards.count) vocabulary cards")
            for (i, card) in vocabCards.prefix(3).enumerated() {
                AppLogger.info("   \(i+1). \(card.front) - \(card.meaning)")
            }
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
    @State private var hasAppeared = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Level Indicator
            CompactLevelHeader()
            
            if !learningDataService.grammarPoints.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(learningDataService.grammarPoints) { grammar in
                            GrammarCardView(grammar: grammar)
                        }
                    }
                    .padding()
                }
            } else {
                VStack(spacing: 16) {
                    if learningDataService.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading grammar...")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.mutedText)
                    } else {
                        ProfessionalEmptyStateView(
                            icon: "text.book.closed.fill",
                            title: "No Grammar Available",
                            message: "Check back later for new content"
                        )
                        Button("Reload Data") {
                            Task {
                                await learningDataService.loadLearningData()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
            }
        }
        .background(AppTheme.background)
        .navigationTitle("Grammar")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if !hasAppeared {
                hasAppeared = true
                if learningDataService.grammarPoints.isEmpty && !learningDataService.isLoading {
                    await learningDataService.loadLearningData()
                }
            }
        }
        .reloadOnLevelChange {
            AppLogger.info("🔄 [GRAMMAR VIEW] Level changed to \(learningDataService.currentLevel.rawValue) - reloading grammar data")
            await learningDataService.loadLearningData()
            
            // Log first 3 grammar points to verify data
            AppLogger.info("📊 [GRAMMAR VIEW] Loaded \(learningDataService.grammarPoints.count) grammar points")
            for (i, grammar) in learningDataService.grammarPoints.prefix(3).enumerated() {
                AppLogger.info("   \(i+1). \(grammar.pattern) - \(grammar.meaning)")
            }
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

// MARK: - Listening, Speaking, and Writing Practice Views
// These views are now defined in:
// - ImprovedListeningSpeakingViews.swift (ListeningPracticeView)
// - SpeakingWritingPracticeViews.swift (SpeakingPracticeView, WritingPracticeView)
