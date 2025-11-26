//
//  PracticeViews.swift
//  NPLearn
//
//  Practice screens for all categories - matching JLearn structure
//

import SwiftUI
import AVFoundation

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
                            title: "Vocabulary",
                            icon: "book.closed.fill",
                            color: AppTheme.vocabularyColor,
                            description: "Learn words",
                            destination: AnyView(CategoryPracticeView(category: .vocabulary))
                        )
                        
                        PracticeCategoryCard(
                            title: "Grammar",
                            icon: "text.book.closed.fill",
                            color: AppTheme.grammarColor,
                            description: "Study patterns",
                            destination: AnyView(CategoryPracticeView(category: .grammar))
                        )
                        
                        PracticeCategoryCard(
                            title: "Listening",
                            icon: "headphones",
                            color: AppTheme.listeningColor,
                            description: "Train your ear",
                            destination: AnyView(CategoryPracticeView(category: .listening))
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
                    description: "Write Nepali sentences",
                    destination: AnyView(WritingSentencePracticeView())
                )
                        
                        PracticeCategoryCard(
                            title: "Reading",
                            icon: "doc.text.fill",
                            color: AppTheme.readingColor,
                            description: "Read texts",
                            destination: AnyView(ReadingPracticeView())
                        )
                    }
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                }
                .padding(.vertical, 24)
            }
            .background(AppTheme.background)
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
            .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Category Practice View (Generic)

struct CategoryPracticeView: View {
    let category: PracticeCategory
    @EnvironmentObject var learningDataService: LearningDataService
    @EnvironmentObject var audioService: AudioService
    @State private var questions: [PracticeQuestion] = []
    @State private var currentIndex = 0
    @State private var selectedAnswer: String?
    @State private var showResult = false
    @State private var score = 0
    @State private var isLoading = true
    @State private var showResults = false
    
    var currentQuestion: PracticeQuestion? {
        guard !questions.isEmpty && currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    var categoryColor: Color {
        switch category {
        case .vocabulary: return AppTheme.vocabularyColor
        case .grammar: return AppTheme.grammarColor
        case .listening: return AppTheme.listeningColor
        case .speaking: return AppTheme.speakingColor
        case .writing: return AppTheme.writingColor
        case .reading: return AppTheme.readingColor
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                loadingView
            } else if questions.isEmpty {
                emptyView
            } else if showResults {
                resultsView
            } else if let question = currentQuestion {
                practiceView(question: question)
            }
        }
        .background(AppTheme.background)
        .navigationTitle(category.rawValue.capitalized)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadQuestions()
        }
    }
    
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
            Spacer()
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No \(category.rawValue.capitalized) Exercises")
                .font(AppTheme.Typography.title)
            Text("Check back later for new content")
                .font(AppTheme.Typography.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func practiceView(question: PracticeQuestion) -> some View {
        VStack(spacing: 0) {
            // Progress Header
            VStack(spacing: 8) {
                HStack {
                    Text("Question \(currentIndex + 1) of \(questions.count)")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(score) correct")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(categoryColor)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(AppTheme.separator)
                            .frame(height: 4)
                        
                        Rectangle()
                            .fill(categoryColor)
                            .frame(width: geometry.size.width * (Double(currentIndex) / Double(questions.count)), height: 4)
                    }
                }
                .frame(height: 4)
            }
            .padding(.top, 8)
            .background(Color.white)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Question Card
                    VStack(alignment: .leading, spacing: 16) {
                        // Audio button for listening
                        if category == .listening {
                            Button {
                                // For listening, play the Nepali word (extract from question or use audioText)
                                playListeningAudio(question: question)
                            } label: {
                                HStack {
                                    Image(systemName: "speaker.wave.2.fill")
                                        .font(.system(size: 24))
                                    Text("Play Audio")
                                        .font(AppTheme.Typography.headline)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(categoryColor)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        
                        Text(question.question)
                            .font(AppTheme.Typography.title2)
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
                            Button {
                                if !showResult {
                                    selectedAnswer = option
                                    checkAnswer(question: question)
                                }
                            } label: {
                                HStack {
                                    Text(option)
                                        .font(AppTheme.Typography.body)
                                        .foregroundColor(buttonTextColor(for: option, question: question))
                                    
                                    Spacer()
                                    
                                    if showResult {
                                        Image(systemName: iconName(for: option, question: question))
                                            .foregroundColor(iconColor(for: option, question: question))
                                    }
                                }
                                .padding()
                                .background(buttonBackground(for: option, question: question))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(buttonBorder(for: option, question: question), lineWidth: 2)
                                )
                            }
                            .disabled(showResult)
                        }
                    }
                    
                    // Explanation (if answered)
                    if showResult, let explanation = question.explanation {
                        VStack(alignment: .leading, spacing: 12) {
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
                        .clipShape(RoundedRectangle(cornerRadius: 12))
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
                            .background(categoryColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding()
            }
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
                    .stroke(categoryColor, lineWidth: 10)
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("\(score)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(categoryColor)
                    Text("out of \(questions.count)")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text("Great Job!")
                .font(AppTheme.Typography.title)
                .foregroundColor(.primary)
            
            let percentage = Int((Double(score) / Double(questions.count)) * 100)
            Text("You got \(percentage)% correct")
                .font(AppTheme.Typography.body)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button {
                restartPractice()
            } label: {
                Text("Try Again")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(categoryColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
    }
    
    private func loadQuestions() async {
        isLoading = true
        questions = await learningDataService.loadPracticeQuestions(category: category)
        isLoading = false
    }
    
    private func checkAnswer(question: PracticeQuestion) {
        withAnimation {
            showResult = true
        }
        let isCorrect = selectedAnswer == question.correctAnswer
        if isCorrect {
            score += 1
            Haptics.success()
        } else {
            Haptics.error()
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
    
    private func restartPractice() {
        withAnimation {
            currentIndex = 0
            selectedAnswer = nil
            showResult = false
            score = 0
            showResults = false
        }
    }
    
    private func playAudio(text: String) {
        Task {
            await audioService.speak(text: text, language: "ne-NP")
        }
    }
    
    private func playListeningAudio(question: PracticeQuestion) {
        Task {
            // For listening questions, extract the Nepali word from the question
            // The question format is usually "What does 'नमस्ते' mean?" or similar
            // Extract the Nepali word between quotes
            let nepaliWord = extractNepaliWord(from: question.question)
            
            // Play the Nepali word
            await audioService.speak(text: nepaliWord, language: "ne-NP")
        }
    }
    
    private func extractNepaliWord(from text: String) -> String {
        // Try to extract text between single quotes first (e.g., 'नमस्ते')
        if let range = text.range(of: "'"), 
           let endRange = text.range(of: "'", range: range.upperBound..<text.endIndex) {
            return String(text[range.upperBound..<endRange.lowerBound])
        }
        
        // Try double quotes as fallback
        if let range = text.range(of: "\""),
           let endRange = text.range(of: "\"", range: range.upperBound..<text.endIndex) {
            return String(text[range.upperBound..<endRange.lowerBound])
        }
        
        // If no quotes found, return the first Nepali-looking text (Devanagari script)
        let words = text.components(separatedBy: " ")
        for word in words {
            // Check if word contains Devanagari characters (U+0900 to U+097F)
            if word.unicodeScalars.contains(where: { $0.value >= 0x0900 && $0.value <= 0x097F }) {
                return word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
            }
        }
        
        // Fallback to the whole text if nothing found
        return text
    }
    
    // Button styling helpers
    private func buttonBackground(for option: String, question: PracticeQuestion) -> Color {
        if !showResult {
            return selectedAnswer == option ? categoryColor.opacity(0.1) : Color.white
        }
        
        if option == question.correctAnswer {
            return AppTheme.success.opacity(0.1)
        } else if selectedAnswer == option {
            return AppTheme.danger.opacity(0.1)
        }
        return Color.white
    }
    
    private func buttonBorder(for option: String, question: PracticeQuestion) -> Color {
        if !showResult {
            return selectedAnswer == option ? categoryColor : AppTheme.separator
        }
        
        if option == question.correctAnswer {
            return AppTheme.success
        } else if selectedAnswer == option {
            return AppTheme.danger
        }
        return AppTheme.separator
    }
    
    private func buttonTextColor(for option: String, question: PracticeQuestion) -> Color {
        if showResult {
            if option == question.correctAnswer {
                return AppTheme.success
            } else if selectedAnswer == option {
                return AppTheme.danger
            }
        }
        return .primary
    }
    
    private func iconName(for option: String, question: PracticeQuestion) -> String {
        if option == question.correctAnswer {
            return "checkmark.circle.fill"
        } else if selectedAnswer == option {
            return "xmark.circle.fill"
        }
        return ""
    }
    
    private func iconColor(for option: String, question: PracticeQuestion) -> Color {
        if option == question.correctAnswer {
            return AppTheme.success
        } else if selectedAnswer == option {
            return AppTheme.danger
        }
        return .clear
    }
}

// MARK: - Flashcard View (for practice modes)

struct FlashcardView: View {
    let flashcard: Flashcard
    @Binding var showAnswer: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            if !showAnswer {
                VStack(spacing: 12) {
                    Text(flashcard.front)
                        .font(AppTheme.Typography.nepaliDisplay)
                        .foregroundColor(AppTheme.brandPrimary)
                    
                    if let romanization = flashcard.romanization {
                        Text(romanization)
                            .font(AppTheme.Typography.romanization)
                            .foregroundColor(AppTheme.mutedText)
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Text(flashcard.back)
                        .font(AppTheme.Typography.title)
                        .foregroundColor(.primary)
                    
                    Text(flashcard.meaning)
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.mutedText)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.1), radius: 20, y: 10)
        .padding(.horizontal, 24)
    }
}

// MARK: - Writing Sentence Practice View

struct WritingSentencePracticeView: View {
    @StateObject private var viewModel = WritingSentenceViewModel()
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with progress
                VStack(spacing: 8) {
                    HStack {
                        Text("Question \(viewModel.currentIndex + 1) of \(viewModel.totalCount)")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.mutedText)
                        
                        Spacer()
                        
                        Text("\(viewModel.practiceCount) practiced")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.writingColor)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(AppTheme.separator)
                                .frame(height: 4)
                            
                            Rectangle()
                                .fill(AppTheme.writingColor)
                                .frame(width: geometry.size.width * (Double(viewModel.currentIndex + 1) / Double(viewModel.totalCount)), height: 4)
                        }
                    }
                    .frame(height: 4)
                }
                .padding(.top, 8)
                .background(Color.white)
                
                // Mode Switcher (Phrases vs Sentences)
                HStack(spacing: 12) {
                    Button(action: {
                        viewModel.switchMode(.phrases)
                        Haptics.selection()
                    }) {
                        Text("Phrases")
                            .font(AppTheme.Typography.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(viewModel.practiceMode == .phrases ? .white : AppTheme.writingColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(viewModel.practiceMode == .phrases ? AppTheme.writingColor : AppTheme.writingColor.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    
                    Button(action: {
                        viewModel.switchMode(.sentences)
                        Haptics.selection()
                    }) {
                        Text("Sentences")
                            .font(AppTheme.Typography.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(viewModel.practiceMode == .sentences ? .white : AppTheme.writingColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(viewModel.practiceMode == .sentences ? AppTheme.writingColor : AppTheme.writingColor.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                .padding(.vertical, 12)
                .background(Color.white)
                
                // Sentence to write
                VStack(spacing: 20) {
                    Text(viewModel.practiceMode == .phrases ? "Write this phrase" : "Write this sentence")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.mutedText)
                    
                    // Nepali Sentence/Phrase
                    Text(viewModel.currentSentence)
                        .font(.system(size: viewModel.practiceMode == .phrases ? 36 : 32, weight: .medium))
                        .foregroundColor(AppTheme.writingColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // English Translation
                    Text(viewModel.currentTranslation)
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.mutedText)
                        .multilineTextAlignment(.center)
                    
                    // Romanization
                    Text("(\(viewModel.currentRomanization))")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.mutedText.opacity(0.7))
                        .italic()
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .background(AppTheme.secondaryBackground)
                
                Divider()
                
                // Drawing Area with lines
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Write on the lines below")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.mutedText)
                        
                        // Lined Canvas
                        ZStack(alignment: .topLeading) {
                            // Guidelines
                            VStack(spacing: 0) {
                                ForEach(0..<8) { index in
                                    HStack {
                                        Spacer()
                                    }
                                    .frame(height: 1)
                                    .background(AppTheme.separator)
                                    .padding(.vertical, 24)
                                }
                            }
                            
                            // Drawing Canvas
                            WritingDrawingCanvasView(
                                lines: $viewModel.lines,
                                currentLine: $viewModel.currentLine
                            )
                            .frame(height: 400)
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppTheme.writingColor.opacity(0.3), lineWidth: 2)
                        )
                        .shadow(
                            color: AppTheme.Shadows.elevation2.color,
                            radius: AppTheme.Shadows.elevation2.radius,
                            y: AppTheme.Shadows.elevation2.y
                        )
                    }
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                    .padding(.vertical, 16)
                }
                
                // Action Buttons
                HStack(spacing: 16) {
                    Button(action: {
                        viewModel.clearDrawing()
                        Haptics.selection()
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Clear")
                        }
                        .font(AppTheme.Typography.button)
                        .foregroundColor(AppTheme.mutedText)
                        .frame(maxWidth: .infinity)
                        .frame(height: AppTheme.Controls.buttonHeight)
                        .background(AppTheme.secondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button(action: {
                        viewModel.nextSentence()
                        Haptics.success()
                    }) {
                        HStack {
                            Text(viewModel.currentIndex < viewModel.totalCount - 1 ? "Next" : "Done")
                            Image(systemName: "arrow.right")
                        }
                        .font(AppTheme.Typography.button)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: AppTheme.Controls.buttonHeight)
                        .background(AppTheme.writingColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Writing Practice")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Writing Sentence ViewModel

class WritingSentenceViewModel: ObservableObject {
    @Published var currentIndex: Int = 0
    @Published var lines: [WritingLine] = []
    @Published var currentLine: WritingLine = WritingLine(points: [], color: .black, lineWidth: 3)
    @Published var practiceCount: Int = 0
    @Published var practiceMode: WritingPracticeMode = .phrases
    
    enum WritingPracticeMode {
        case phrases
        case sentences
    }
    
    // Practice phrases (common short expressions)
    let phrases: [(nepali: String, english: String, romanization: String)] = [
        ("नमस्ते", "Hello/Greetings", "namaste"),
        ("धन्यवाद", "Thank you", "dhanyabad"),
        ("माफ गर्नुहोस्", "Sorry/Excuse me", "maaf garnuhos"),
        ("कृपया", "Please", "kripaya"),
        ("राम्रो छ", "It's good", "ramro chha"),
        ("हुन्छ", "Okay/Alright", "hunchha"),
        ("हुँदैन", "Not okay/No", "hundaina"),
        ("के छ?", "What's up?", "ke chha"),
        ("सबै ठीक छ", "Everything is fine", "sabai thik chha"),
        ("फेरि भेटौंला", "See you again", "pheri bhetaula"),
        ("बिहानी", "Good morning", "bihani"),
        ("शुभ रात्री", "Good night", "shubha ratri"),
        ("स्वागत छ", "You're welcome", "swagat chha"),
        ("बुझे", "Understood", "bujhe"),
        ("बुझिनँ", "I don't understand", "bujhina"),
        ("अलिकति", "A little bit", "alikati"),
        ("धेरै राम्रो", "Very good", "dherai ramro"),
        ("कति हो?", "How much?", "kati ho"),
        ("पानी", "Water", "pani"),
        ("खाना", "Food", "khana")
    ]
    
    // Full sentences (longer practice)
    let sentences: [(nepali: String, english: String, romanization: String)] = [
        ("मेरो नाम राम हो।", "My name is Ram.", "mero naam Ram ho"),
        ("तपाईंलाई कस्तो छ?", "How are you?", "tapailai kasto chha"),
        ("म राम्रो छु।", "I am fine.", "ma ramro chhu"),
        ("तपाईं कहाँ जानुहुन्छ?", "Where are you going?", "tapai kaha januhunchha"),
        ("म घर जान्छु।", "I am going home.", "ma ghar janchhu"),
        ("यो राम्रो छ।", "This is good.", "yo ramro chha"),
        ("म नेपाली सिक्दैछु।", "I am learning Nepali.", "ma nepali sikdaichhu"),
        ("तपाईंलाई भेटेर खुसी लाग्यो।", "Nice to meet you.", "tapailai bheter khusi lagyo"),
        ("म तपाईंलाई माया गर्छु।", "I love you.", "ma tapailai maya garchhu"),
        ("तपाईं कहाँबाट हुनुहुन्छ?", "Where are you from?", "tapai kahabata hunuhunchha")
    ]
    
    var currentPhrases: [(nepali: String, english: String, romanization: String)] {
        practiceMode == .phrases ? phrases : sentences
    }
    
    var currentSentence: String {
        currentPhrases[currentIndex].nepali
    }
    
    var currentTranslation: String {
        currentPhrases[currentIndex].english
    }
    
    var currentRomanization: String {
        currentPhrases[currentIndex].romanization
    }
    
    var totalCount: Int {
        currentPhrases.count
    }
    
    func clearDrawing() {
        lines.removeAll()
        currentLine = WritingLine(points: [], color: .black, lineWidth: 3)
    }
    
    func nextSentence() {
        practiceCount += 1
        clearDrawing()
        
        if currentIndex < currentPhrases.count - 1 {
            currentIndex += 1
        } else {
            // Restart from beginning
            currentIndex = 0
        }
    }
    
    func switchMode(_ mode: WritingPracticeMode) {
        practiceMode = mode
        currentIndex = 0
        practiceCount = 0
        clearDrawing()
    }
}

// MARK: - Drawing Components (embedded here for build compatibility)

struct WritingLine: Identifiable {
    let id = UUID()
    var points: [CGPoint]
    var color: Color
    var lineWidth: CGFloat
}

struct WritingDrawingCanvasView: View {
    @Binding var lines: [WritingLine]
    @Binding var currentLine: WritingLine
    
    var body: some View {
        Canvas { context, size in
            // Draw completed lines
            for line in lines {
                var path = Path()
                if let firstPoint = line.points.first {
                    path.move(to: firstPoint)
                    for point in line.points.dropFirst() {
                        path.addLine(to: point)
                    }
                }
                context.stroke(
                    path,
                    with: .color(line.color),
                    lineWidth: line.lineWidth
                )
            }
            
            // Draw current line
            var currentPath = Path()
            if let firstPoint = currentLine.points.first {
                currentPath.move(to: firstPoint)
                for point in currentLine.points.dropFirst() {
                    currentPath.addLine(to: point)
                }
            }
            context.stroke(
                currentPath,
                with: .color(currentLine.color),
                lineWidth: currentLine.lineWidth
            )
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    currentLine.points.append(value.location)
                }
                .onEnded { _ in
                    if !currentLine.points.isEmpty {
                        lines.append(currentLine)
                        currentLine = WritingLine(points: [], color: .black, lineWidth: 3)
                    }
                }
        )
    }
}

// MARK: - Speaking Practice View

struct SpeakingPracticeView: View {
    @StateObject private var viewModel = SpeakingPracticeViewModel()
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with progress
                VStack(spacing: 8) {
                    HStack {
                        Text("Question \(viewModel.currentIndex + 1) of \(viewModel.phrases.count)")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.mutedText)
                        
                        Spacer()
                        
                        Text("\(viewModel.practiceCount) practiced")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.speakingColor)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(AppTheme.separator)
                                .frame(height: 4)
                            
                            Rectangle()
                                .fill(AppTheme.speakingColor)
                                .frame(width: geometry.size.width * (Double(viewModel.currentIndex + 1) / Double(viewModel.phrases.count)), height: 4)
                        }
                    }
                    .frame(height: 4)
                }
                .padding(.top, 8)
                .background(Color.white)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Phrase to speak
                        VStack(spacing: 20) {
                            Text("Listen and Repeat")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(AppTheme.mutedText)
                            
                            // Nepali text
                            Text(viewModel.currentPhrase)
                                .font(.system(size: 40, weight: .medium))
                                .foregroundColor(AppTheme.speakingColor)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            // English translation
                            Text(viewModel.currentTranslation)
                                .font(AppTheme.Typography.title3)
                                .foregroundColor(AppTheme.mutedText)
                                .multilineTextAlignment(.center)
                            
                            // Romanization
                            Text("(\(viewModel.currentRomanization))")
                                .font(AppTheme.Typography.body)
                                .foregroundColor(AppTheme.mutedText.opacity(0.7))
                                .italic()
                        }
                        .padding(.vertical, 32)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity)
                        .background(AppTheme.secondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        // Listen button
                        Button(action: {
                            viewModel.playAudio()
                            Haptics.selection()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: viewModel.isPlaying ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                                    .font(.system(size: 24))
                                Text("Listen to Pronunciation")
                                    .font(AppTheme.Typography.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                LinearGradient(
                                    colors: [AppTheme.speakingColor, AppTheme.speakingColor.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: AppTheme.speakingColor.opacity(0.3), radius: 8, y: 4)
                        }
                        .disabled(viewModel.isPlaying)
                        
                        // Recording section
                        VStack(spacing: 16) {
                            Text("Now you try!")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(.primary)
                            
                            // Record button
                            Button(action: {
                                viewModel.toggleRecording()
                                Haptics.selection()
                            }) {
                                VStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(viewModel.isRecording ? Color.red : AppTheme.speakingColor.opacity(0.1))
                                            .frame(width: 100, height: 100)
                                        
                                        Image(systemName: viewModel.isRecording ? "stop.fill" : "mic.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(viewModel.isRecording ? .white : AppTheme.speakingColor)
                                    }
                                    .scaleEffect(viewModel.isRecording ? 1.1 : 1.0)
                                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: viewModel.isRecording)
                                    
                                    Text(viewModel.isRecording ? "Recording..." : "Tap to Record")
                                        .font(AppTheme.Typography.headline)
                                        .foregroundColor(viewModel.isRecording ? Color.red : AppTheme.speakingColor)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 32)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(viewModel.isRecording ? Color.red : AppTheme.speakingColor.opacity(0.3), lineWidth: 2)
                                )
                                .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
                            }
                            
                            // Recording status
                            if viewModel.hasRecording {
                                HStack(spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(AppTheme.success)
                                    Text("Recording complete! Great job!")
                                        .font(AppTheme.Typography.body)
                                        .foregroundColor(AppTheme.success)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(AppTheme.success.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .background(AppTheme.secondaryBackground.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        // Tips section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(AppTheme.speakingColor)
                                Text("Practice Tips")
                                    .font(AppTheme.Typography.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                speakingTipRow(icon: "1.circle.fill", text: "Listen to the pronunciation first")
                                speakingTipRow(icon: "2.circle.fill", text: "Practice saying it slowly")
                                speakingTipRow(icon: "3.circle.fill", text: "Record yourself speaking")
                                speakingTipRow(icon: "4.circle.fill", text: "Compare with the original")
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
                    }
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                    .padding(.vertical, 24)
                }
                
                // Next button
                HStack(spacing: 16) {
                    Button(action: {
                        viewModel.skipPhrase()
                        Haptics.selection()
                    }) {
                        Text("Skip")
                            .font(AppTheme.Typography.button)
                            .foregroundColor(AppTheme.mutedText)
                            .frame(maxWidth: .infinity)
                            .frame(height: AppTheme.Controls.buttonHeight)
                            .background(AppTheme.secondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button(action: {
                        viewModel.nextPhrase()
                        Haptics.success()
                    }) {
                        HStack {
                            Text(viewModel.currentIndex < viewModel.phrases.count - 1 ? "Next" : "Done")
                            Image(systemName: "arrow.right")
                        }
                        .font(AppTheme.Typography.button)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: AppTheme.Controls.buttonHeight)
                        .background(AppTheme.speakingColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                .padding(.bottom, 24)
                .background(Color.white)
            }
        }
        .navigationTitle("Speaking Practice")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.setupAudio()
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }
    
    private func speakingTipRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.speakingColor)
                .font(.system(size: 16))
            Text(text)
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.mutedText)
        }
    }
}

// MARK: - Speaking Practice ViewModel

@MainActor
class SpeakingPracticeViewModel: ObservableObject {
    @Published var currentIndex: Int = 0
    @Published var practiceCount: Int = 0
    @Published var isRecording: Bool = false
    @Published var hasRecording: Bool = false
    @Published var isPlaying: Bool = false
    
    private var audioRecorder: AVAudioRecorder?
    private var audioService: AudioService { AudioService.shared }
    private var recordingSession: AVAudioSession?
    
    // Speaking practice phrases
    let phrases: [(nepali: String, english: String, romanization: String)] = [
        ("नमस्ते", "Hello/Greetings", "namaste"),
        ("धन्यवाद", "Thank you", "dhanyabad"),
        ("माफ गर्नुहोस्", "Sorry/Excuse me", "maaf garnuhos"),
        ("कृपया", "Please", "kripaya"),
        ("तपाईंलाई कस्तो छ?", "How are you?", "tapailai kasto chha"),
        ("म राम्रो छु", "I am fine", "ma ramro chhu"),
        ("राम्रो छ", "It's good", "ramro chha"),
        ("हुन्छ", "Okay/Alright", "hunchha"),
        ("हुँदैन", "Not okay/No", "hundaina"),
        ("के छ?", "What's up?", "ke chha"),
        ("बिहानी", "Good morning", "bihani"),
        ("शुभ रात्री", "Good night", "shubha ratri"),
        ("म बुझिनँ", "I don't understand", "ma bujhina"),
        ("फेरि भन्नुहोस्", "Please say again", "pheri bhannuhos"),
        ("मलाई मद्दत चाहिन्छ", "I need help", "malai maddat chahhinchha")
    ]
    
    var currentPhrase: String {
        phrases[currentIndex].nepali
    }
    
    var currentTranslation: String {
        phrases[currentIndex].english
    }
    
    var currentRomanization: String {
        phrases[currentIndex].romanization
    }
    
    func setupAudio() {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession?.setCategory(.playAndRecord, mode: .default)
            try recordingSession?.setActive(true)
            
            // Request permission
            recordingSession?.requestRecordPermission { allowed in
                DispatchQueue.main.async {
                    if !allowed {
                        AppLogger.warning("⚠️ Microphone permission denied")
                    }
                }
            }
        } catch {
            AppLogger.error("❌ Failed to set up recording session", error: error)
        }
    }
    
    func playAudio() {
        isPlaying = true
        Task {
            await audioService.speak(text: currentPhrase, language: "ne-NP")
            isPlaying = false
        }
    }
    
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            isRecording = true
            AppLogger.info("🎙️ Started recording")
        } catch {
            AppLogger.error("❌ Could not start recording", error: error)
        }
    }
    
    private func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
        hasRecording = true
        AppLogger.info("✅ Stopped recording")
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func nextPhrase() {
        practiceCount += 1
        hasRecording = false
        
        if currentIndex < phrases.count - 1 {
            currentIndex += 1
        } else {
            currentIndex = 0
        }
    }
    
    func skipPhrase() {
        hasRecording = false
        
        if currentIndex < phrases.count - 1 {
            currentIndex += 1
        } else {
            currentIndex = 0
        }
    }
    
    func cleanup() {
        if isRecording {
            stopRecording()
        }
        audioRecorder = nil
    }
}

// MARK: - Reading Practice View

struct ReadingPracticeView: View {
    @StateObject private var viewModel = ReadingPracticeViewModel()
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with progress
                VStack(spacing: 8) {
                    HStack {
                        Text("Story \(viewModel.currentIndex + 1) of \(viewModel.stories.count)")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.mutedText)
                        
                        Spacer()
                        
                        Text("\(viewModel.readCount) read")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.readingColor)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(AppTheme.separator)
                                .frame(height: 4)
                            
                            Rectangle()
                                .fill(AppTheme.readingColor)
                                .frame(width: geometry.size.width * (Double(viewModel.currentIndex + 1) / Double(viewModel.stories.count)), height: 4)
                        }
                    }
                    .frame(height: 4)
                }
                .padding(.top, 8)
                .background(Color.white)
                
                // Story content
                ScrollView {
                    VStack(spacing: 24) {
                        // Title section
                        VStack(spacing: 16) {
                            // Level badge
                            HStack {
                                Image(systemName: viewModel.currentDifficulty == "Easy" ? "star.fill" : viewModel.currentDifficulty == "Medium" ? "star.leadinghalf.filled" : "star.circle.fill")
                                    .foregroundColor(AppTheme.readingColor)
                                Text(viewModel.currentDifficulty)
                                    .font(AppTheme.Typography.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppTheme.readingColor)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppTheme.readingColor.opacity(0.1))
                            .clipShape(Capsule())
                            
                            // Title
                            Text(viewModel.currentTitle)
                                .font(AppTheme.Typography.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            // English title
                            Text(viewModel.currentEnglishTitle)
                                .font(AppTheme.Typography.title3)
                                .foregroundColor(AppTheme.mutedText)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 24)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [AppTheme.readingColor.opacity(0.05), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        
                        // Read aloud button
                        Button(action: {
                            viewModel.toggleAudio()
                            Haptics.selection()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 24))
                                Text(viewModel.isPlaying ? "Pause Reading" : "Read Aloud")
                                    .font(AppTheme.Typography.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppTheme.readingColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                        
                        // Nepali text
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(viewModel.currentParagraphs, id: \.self) { paragraph in
                                Text(paragraph)
                                    .font(.system(size: 18, weight: .regular))
                                    .foregroundColor(.primary)
                                    .lineSpacing(8)
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
                        
                        // Translation toggle
                        VStack(spacing: 16) {
                            Button(action: {
                                withAnimation {
                                    viewModel.showTranslation.toggle()
                                }
                                Haptics.selection()
                            }) {
                                HStack {
                                    Image(systemName: viewModel.showTranslation ? "eye.slash.fill" : "eye.fill")
                                    Text(viewModel.showTranslation ? "Hide Translation" : "Show Translation")
                                        .font(AppTheme.Typography.subheadline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(AppTheme.readingColor)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(AppTheme.readingColor.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            if viewModel.showTranslation {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("English Translation")
                                        .font(AppTheme.Typography.headline)
                                        .foregroundColor(AppTheme.readingColor)
                                    
                                    ForEach(viewModel.currentEnglishParagraphs, id: \.self) { paragraph in
                                        Text(paragraph)
                                            .font(.system(size: 16, weight: .regular))
                                            .foregroundColor(AppTheme.mutedText)
                                            .lineSpacing(6)
                                    }
                                }
                                .padding(20)
                                .background(AppTheme.secondaryBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                        
                        // Vocabulary section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "book.closed.fill")
                                    .foregroundColor(AppTheme.readingColor)
                                Text("Key Vocabulary")
                                    .font(AppTheme.Typography.headline)
                            }
                            
                            VStack(spacing: 12) {
                                ForEach(viewModel.currentVocabulary, id: \.nepali) { word in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(word.nepali)
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(AppTheme.readingColor)
                                            Text(word.romanization)
                                                .font(AppTheme.Typography.caption)
                                                .foregroundColor(AppTheme.mutedText)
                                                .italic()
                                        }
                                        
                                        Spacer()
                                        
                                        Text(word.english)
                                            .font(AppTheme.Typography.body)
                                            .foregroundColor(.primary)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                        .padding(20)
                        .background(AppTheme.secondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                    .padding(.vertical, 24)
                }
                
                // Navigation buttons
                HStack(spacing: 16) {
                    if viewModel.currentIndex > 0 {
                        Button(action: {
                            viewModel.previousStory()
                            Haptics.selection()
                        }) {
                            HStack {
                                Image(systemName: "arrow.left")
                                Text("Previous")
                            }
                            .font(AppTheme.Typography.button)
                            .foregroundColor(AppTheme.mutedText)
                            .frame(maxWidth: .infinity)
                            .frame(height: AppTheme.Controls.buttonHeight)
                            .background(AppTheme.secondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    
                    Button(action: {
                        viewModel.nextStory()
                        Haptics.success()
                    }) {
                        HStack {
                            Text(viewModel.currentIndex < viewModel.stories.count - 1 ? "Next" : "Done")
                            Image(systemName: "arrow.right")
                        }
                        .font(AppTheme.Typography.button)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: AppTheme.Controls.buttonHeight)
                        .background(AppTheme.readingColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                .padding(.bottom, 24)
                .background(Color.white)
            }
        }
        .navigationTitle("Reading Practice")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            viewModel.stopAudio()
        }
    }
}

// MARK: - Reading Practice ViewModel

@MainActor
class ReadingPracticeViewModel: ObservableObject {
    @Published var currentIndex: Int = 0
    @Published var readCount: Int = 0
    @Published var showTranslation: Bool = false
    @Published var isPlaying: Bool = false
    @Published var stories: [Story] = []
    
    private var audioService: AudioService { AudioService.shared }
    
    struct VocabularyWord {
        let nepali: String
        let english: String
        let romanization: String
    }
    
    struct Story {
        let title: String
        let englishTitle: String
        let difficulty: String
        let paragraphs: [String]
        let englishParagraphs: [String]
        let vocabulary: [VocabularyWord]
    }
    
    init() {
        // Load JSON-driven reading passages from LearningDataService
        loadReadingData()
    }
    
    private func loadReadingData() {
        let passages = LearningDataService.shared.readingPassages
        
        if !passages.isEmpty {
            // Convert JSON data to Story format
            self.stories = passages.map { passage in
                Story(
                    title: passage.text.components(separatedBy: "\n").first ?? "Reading",
                    englishTitle: passage.question,
                    difficulty: passage.level ?? "Easy",
                    paragraphs: passage.text.components(separatedBy: "\n"),
                    englishParagraphs: [passage.question] + passage.options,
                    vocabulary: passage.vocabulary.map { vocab in
                        VocabularyWord(
                            nepali: vocab.word,
                            english: vocab.meaning,
                            romanization: vocab.romanization ?? ""
                        )
                    }
                )
            }
            AppLogger.info("📖 Loaded \(passages.count) reading passages from JSON")
        } else {
            // Fallback to default sample stories
            self.stories = Self.sampleStories
            AppLogger.info("📖 Using sample reading stories")
        }
    }
    
    // Sample stories as fallback when JSON data is not available
    private static let sampleStories: [Story] = [
        Story(
            title: "मेरो परिवार",
            englishTitle: "My Family",
            difficulty: "Easy",
            paragraphs: [
                "मेरो नाम राम हो। म नेपालमा बस्छु। मेरो परिवार सानो छ।",
                "मेरो बुबा शिक्षक हुनुहुन्छ। मेरी आमा नर्स हुनुहुन्छ। मेरो एउटा दाजु छ र एउटी बहिनी छ।",
                "हामी सबै साथै बस्छौं। हामी एक अर्कालाई माया गर्छौं। मेरो परिवार धेरै राम्रो छ।"
            ],
            englishParagraphs: [
                "My name is Ram. I live in Nepal. My family is small.",
                "My father is a teacher. My mother is a nurse. I have one brother and one sister.",
                "We all live together. We love each other. My family is very good."
            ],
            vocabulary: [
                VocabularyWord(nepali: "परिवार", english: "Family", romanization: "pariwar"),
                VocabularyWord(nepali: "बुबा", english: "Father", romanization: "buba"),
                VocabularyWord(nepali: "आमा", english: "Mother", romanization: "aama"),
                VocabularyWord(nepali: "दाजु", english: "Brother", romanization: "daju"),
                VocabularyWord(nepali: "बहिनी", english: "Sister", romanization: "bahini")
            ]
        ),
        Story(
            title: "बिहान",
            englishTitle: "Morning",
            difficulty: "Easy",
            paragraphs: [
                "म बिहान छ बजे उठ्छु। म दाँत माझ्छु र नुहाउँछु।",
                "त्यसपछि म नाश्ता खान्छु। म चिया पिउँछु। म रोटी र अण्डा खान्छु।",
                "म विद्यालय जान्छु। म साढे सात बजे घर छोड्छु। म हिँड्छु।"
            ],
            englishParagraphs: [
                "I wake up at six in the morning. I brush my teeth and take a bath.",
                "Then I eat breakfast. I drink tea. I eat bread and eggs.",
                "I go to school. I leave home at seven thirty. I walk."
            ],
            vocabulary: [
                VocabularyWord(nepali: "बिहान", english: "Morning", romanization: "bihaan"),
                VocabularyWord(nepali: "उठ्नु", english: "To wake up", romanization: "uthnu"),
                VocabularyWord(nepali: "नाश्ता", english: "Breakfast", romanization: "naashta"),
                VocabularyWord(nepali: "विद्यालय", english: "School", romanization: "vidyalaya"),
                VocabularyWord(nepali: "हिँड्नु", english: "To walk", romanization: "hindnu")
            ]
        ),
        Story(
            title: "बजार",
            englishTitle: "The Market",
            difficulty: "Easy",
            paragraphs: [
                "आज शनिबार हो। म बजार जान्छु। बजार भीडभाड छ।",
                "म तरकारी किन्छु। म आलु, प्याज र टमाटर किन्छु। म फलफूल पनि किन्छु।",
                "बजारमा धेरै मान्छे छन्। सबै किनमेल गरिरहेका छन्। म घर फर्कन्छु।"
            ],
            englishParagraphs: [
                "Today is Saturday. I go to the market. The market is crowded.",
                "I buy vegetables. I buy potatoes, onions and tomatoes. I also buy fruits.",
                "There are many people in the market. Everyone is shopping. I return home."
            ],
            vocabulary: [
                VocabularyWord(nepali: "बजार", english: "Market", romanization: "bazaar"),
                VocabularyWord(nepali: "तरकारी", english: "Vegetables", romanization: "tarakaari"),
                VocabularyWord(nepali: "फलफूल", english: "Fruits", romanization: "phalphool"),
                VocabularyWord(nepali: "किन्नु", english: "To buy", romanization: "kinnu"),
                VocabularyWord(nepali: "भीडभाड", english: "Crowded", romanization: "bheedbhaad")
            ]
        ),
        Story(
            title: "मेरो साथी",
            englishTitle: "My Friend",
            difficulty: "Medium",
            paragraphs: [
                "मेरो साथीको नाम सीता हो। उनी मेरी राम्री साथी हुन्। हामी सँगै विद्यालय जान्छौं।",
                "सीता धेरै होशियार छिन्। उनी राम्रो विद्यार्थी हुन्। उनी सधैं पढ्छिन्। उनी गाउन पनि जान्छिन्।",
                "हामी सँगै खेल्छौं। हामी सँगै पढ्छौं। हामी एक अर्काको मद्दत गर्छौं। साथीहरू महत्त्वपूर्ण छन्।"
            ],
            englishParagraphs: [
                "My friend's name is Sita. She is my good friend. We go to school together.",
                "Sita is very smart. She is a good student. She always studies. She also knows how to sing.",
                "We play together. We study together. We help each other. Friends are important."
            ],
            vocabulary: [
                VocabularyWord(nepali: "साथी", english: "Friend", romanization: "saathi"),
                VocabularyWord(nepali: "होशियार", english: "Smart/Clever", romanization: "hoshiyaar"),
                VocabularyWord(nepali: "विद्यार्थी", english: "Student", romanization: "vidyaarthi"),
                VocabularyWord(nepali: "मद्दत", english: "Help", romanization: "maddat"),
                VocabularyWord(nepali: "महत्त्वपूर्ण", english: "Important", romanization: "mahattwapurna")
            ]
        ),
        Story(
            title: "दशैं चाड",
            englishTitle: "Dashain Festival",
            difficulty: "Medium",
            paragraphs: [
                "दशैं नेपालको सबैभन्दा ठूलो चाड हो। यो चाड अक्टोबर महिनामा आउँछ।",
                "दशैंमा सबै परिवार साथै भेला हुन्छन्। हामी नयाँ लुगा लगाउँछौं। हामी मीठो खाना खान्छौं।",
                "ठूलाहरूले टीका र जमरा दिन्छन्। बालबालिकाहरू खुसी हुन्छन्। सबैजना रमाइलो गर्छन्। दशैं धेरै राम्रो चाड हो।"
            ],
            englishParagraphs: [
                "Dashain is the biggest festival of Nepal. This festival comes in October.",
                "During Dashain all families gather together. We wear new clothes. We eat delicious food.",
                "Elders give tika and jamara. Children are happy. Everyone enjoys. Dashain is a very good festival."
            ],
            vocabulary: [
                VocabularyWord(nepali: "चाड", english: "Festival", romanization: "chaad"),
                VocabularyWord(nepali: "भेला हुनु", english: "To gather", romanization: "bhela hunu"),
                VocabularyWord(nepali: "टीका", english: "Tika (blessing mark)", romanization: "tika"),
                VocabularyWord(nepali: "जमरा", english: "Jamara (sacred grass)", romanization: "jamara"),
                VocabularyWord(nepali: "रमाइलो गर्नु", english: "To enjoy", romanization: "ramailo garnu")
            ]
        )
    ]
    
    var currentTitle: String {
        stories[currentIndex].title
    }
    
    var currentEnglishTitle: String {
        stories[currentIndex].englishTitle
    }
    
    var currentDifficulty: String {
        stories[currentIndex].difficulty
    }
    
    var currentParagraphs: [String] {
        stories[currentIndex].paragraphs
    }
    
    var currentEnglishParagraphs: [String] {
        stories[currentIndex].englishParagraphs
    }
    
    var currentVocabulary: [VocabularyWord] {
        stories[currentIndex].vocabulary
    }
    
    func toggleAudio() {
        if isPlaying {
            stopAudio()
        } else {
            playAudio()
        }
    }
    
    func playAudio() {
        isPlaying = true
        let fullText = currentParagraphs.joined(separator: " ")
        Task {
            await audioService.speak(text: fullText, language: "ne-NP")
            isPlaying = false
        }
    }
    
    func stopAudio() {
        isPlaying = false
        // Stop audio playback if needed
    }
    
    func nextStory() {
        readCount += 1
        showTranslation = false
        stopAudio()
        
        if currentIndex < stories.count - 1 {
            currentIndex += 1
        } else {
            currentIndex = 0
        }
    }
    
    func previousStory() {
        showTranslation = false
        stopAudio()
        
        if currentIndex > 0 {
            currentIndex -= 1
        }
    }
}

#Preview {
    NavigationStack {
        PracticeView()
            .environmentObject(LearningDataService.shared)
    }
}
