//
//  ImprovedPracticeViews.swift
//  JLearn
//
//  Professional practice views with proper educational structure
//  Reading: Passage → Vocabulary → Questions
//  Listening: Question → Audio → Options
//  Speaking: Clear prompts and recording
//

import SwiftUI

// MARK: - Reading Practice View (Redesigned)

struct ReadingPracticeView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @StateObject private var viewModel = ReadingPracticeViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                LoadingView()
            } else if viewModel.passages.isEmpty {
                EmptyReadingStateView {
                    viewModel.loadPassages(from: learningDataService)
                }
            } else if viewModel.showResults {
                ProfessionalResultsView(
                    score: viewModel.score,
                    total: viewModel.passages.count,
                    title: "Reading Complete!",
                    icon: "book.pages.fill",
                    color: .green,
                    restartAction: viewModel.restart,
                    dismissAction: { dismiss() }
                )
            } else {
                ImprovedReadingQuestionView(viewModel: viewModel)
            }
        }
        .navigationTitle("Reading Practice")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel.passages.isEmpty {
                viewModel.loadPassages(from: learningDataService)
            }
        }
    }
}

// MARK: - Improved Reading Question View

private struct ImprovedReadingQuestionView: View {
    @ObservedObject var viewModel: ReadingPracticeViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress Header
            ProfessionalProgressHeader(
                currentIndex: viewModel.currentPassageIndex,
                total: viewModel.passages.count,
                score: viewModel.score,
                scoreLabel: "correct",
                progressColor: .green
            )
            
            ScrollView {
                VStack(spacing: 24) {
                    if let passage = viewModel.currentPassage {
                        // STEP 1: Reading Passage
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "book.pages")
                                    .foregroundColor(.green)
                                Text("Read the passage carefully")
                                    .font(AppTheme.Typography.subheadline)
                                    .foregroundColor(AppTheme.mutedText)
                            }
                            
                            // Japanese Text
                            Text(passage.text)
                                .font(.system(size: 18, design: .default))
                                .lineSpacing(8)
                                .foregroundColor(.primary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.green.opacity(0.05))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.green.opacity(0.2), lineWidth: 1)
                                        )
                                )
                        }
                        .padding(.horizontal)
                        
                        // STEP 2: Key Vocabulary
                        if !passage.vocabulary.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "text.book.closed")
                                        .foregroundColor(.blue)
                                    Text("Key Vocabulary")
                                        .font(AppTheme.Typography.headline)
                                        .foregroundColor(.primary)
                                }
                                
                                VStack(spacing: 8) {
                                    ForEach(passage.vocabulary, id: \.word) { vocab in
                                        HStack {
                                            Text(vocab.word)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.primary)
                                            
                                            if let reading = vocab.reading {
                                                Text("(\(reading))")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(AppTheme.mutedText)
                                            }
                                            
                                            Spacer()
                                            
                                            Text(vocab.meaning)
                                                .font(.system(size: 14))
                                                .foregroundColor(.blue)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.blue.opacity(0.05))
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Divider()
                            .padding(.horizontal)
                        
                        // STEP 3: Comprehension Question
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "questionmark.circle")
                                    .foregroundColor(.orange)
                                Text("Answer the question")
                                    .font(AppTheme.Typography.headline)
                                    .foregroundColor(.primary)
                            }
                            
                            Text(passage.question)
                                .font(AppTheme.Typography.body)
                                .foregroundColor(.primary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.orange.opacity(0.05))
                                )
                        }
                        .padding(.horizontal)
                        
                        // STEP 4: Answer Options
                        VStack(spacing: 12) {
                            ForEach(Array(passage.options.enumerated()), id: \.offset) { index, option in
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
                                            if option == passage.correctAnswer {
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
                                
                                if let explanation = passage.explanation {
                                    Text(explanation)
                                        .font(AppTheme.Typography.body)
                                        .foregroundColor(AppTheme.mutedText)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(AppTheme.secondaryBackground)
                                        )
                                }
                                
                                Button(action: viewModel.nextQuestion) {
                                    Text(viewModel.hasNextQuestion ? "Next Passage →" : "See Results")
                                        .font(AppTheme.Typography.button)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green)
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
    
    private func getOptionColor(option: String) -> Color {
        if viewModel.showFeedback {
            if option == viewModel.currentPassage?.correctAnswer {
                return .green
            } else if viewModel.selectedAnswer == option {
                return .red
            }
        } else if viewModel.selectedAnswer == option {
            return .blue
        }
        return .gray
    }
    
    private func getOptionBackground(option: String) -> Color {
        if viewModel.showFeedback {
            if option == viewModel.currentPassage?.correctAnswer {
                return Color.green.opacity(0.1)
            } else if viewModel.selectedAnswer == option {
                return Color.red.opacity(0.1)
            }
        } else if viewModel.selectedAnswer == option {
            return Color.blue.opacity(0.1)
        }
        return AppTheme.background
    }
    
    private func getOptionBorder(option: String) -> Color {
        if viewModel.showFeedback {
            if option == viewModel.currentPassage?.correctAnswer {
                return .green
            } else if viewModel.selectedAnswer == option {
                return .red
            }
        } else if viewModel.selectedAnswer == option {
            return .blue
        }
        return AppTheme.separator
    }
}

// MARK: - Reading Passage Model

struct ReadingPassage: Identifiable {
    let id: String
    let text: String
    let vocabulary: [VocabularyItem]
    let question: String
    let options: [String]
    let correctAnswer: String
    let explanation: String?
    
    struct VocabularyItem {
        let word: String
        let reading: String?
        let meaning: String
    }
}

// MARK: - Reading ViewModel

class ReadingPracticeViewModel: ObservableObject {
    @Published var passages: [ReadingPassage] = []
    @Published var currentPassageIndex = 0
    @Published var selectedAnswer: String?
    @Published var showFeedback = false
    @Published var isCorrect = false
    @Published var score = 0
    @Published var showResults = false
    @Published var isLoading = false
    
    var currentPassage: ReadingPassage? {
        guard currentPassageIndex < passages.count else { return nil }
        return passages[currentPassageIndex]
    }
    
    var hasNextQuestion: Bool {
        currentPassageIndex < passages.count - 1
    }
    
    func loadPassages(from service: LearningDataService) {
        isLoading = true
        
        Task { @MainActor in
            // Generate sample reading passages with proper structure
            self.passages = generateSampleReadingPassages(level: service.currentLevel)
            isLoading = false
        }
    }
    
    func selectAnswer(_ answer: String) {
        selectedAnswer = answer
        isCorrect = (answer == currentPassage?.correctAnswer)
        
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
            currentPassageIndex += 1
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
        currentPassageIndex = 0
        score = 0
        showResults = false
        passages.shuffle()
        resetQuestion()
    }
    
    private func generateSampleReadingPassages(level: LearningLevel) -> [ReadingPassage] {
        return [
            ReadingPassage(
                id: "reading_1",
                text: "今日は天気がとてもいいです。青い空に白い雲が浮かんでいます。公園には多くの人がいます。子供たちは元気に遊んでいます。家族でピクニックをしている人もいます。",
                vocabulary: [
                    ReadingPassage.VocabularyItem(word: "天気", reading: "てんき", meaning: "weather"),
                    ReadingPassage.VocabularyItem(word: "雲", reading: "くも", meaning: "cloud"),
                    ReadingPassage.VocabularyItem(word: "浮かぶ", reading: "うかぶ", meaning: "to float"),
                    ReadingPassage.VocabularyItem(word: "ピクニック", reading: nil, meaning: "picnic")
                ],
                question: "What is the weather like today?",
                options: [
                    "It's very good weather",
                    "It's raining",
                    "It's cloudy and dark",
                    "It's snowing"
                ],
                correctAnswer: "It's very good weather",
                explanation: "The passage says '今日は天気がとてもいいです' (Today's weather is very good)."
            ),
            ReadingPassage(
                id: "reading_2",
                text: "私は毎朝六時に起きます。朝ご飯を食べてから、学校に行きます。学校まで三十分かかります。自転車で通学しています。",
                vocabulary: [
                    ReadingPassage.VocabularyItem(word: "毎朝", reading: "まいあさ", meaning: "every morning"),
                    ReadingPassage.VocabularyItem(word: "朝ご飯", reading: "あさごはん", meaning: "breakfast"),
                    ReadingPassage.VocabularyItem(word: "自転車", reading: "じてんしゃ", meaning: "bicycle"),
                    ReadingPassage.VocabularyItem(word: "通学", reading: "つうがく", meaning: "commute to school")
                ],
                question: "How does the person go to school?",
                options: [
                    "By bicycle",
                    "By bus",
                    "By train",
                    "On foot"
                ],
                correctAnswer: "By bicycle",
                explanation: "The passage states '自転車で通学しています' (commuting to school by bicycle)."
            ),
            ReadingPassage(
                id: "reading_3",
                text: "図書館は静かな場所です。たくさんの本があります。私は週に二回、図書館に行きます。そこで勉強したり、本を借りたりします。",
                vocabulary: [
                    ReadingPassage.VocabularyItem(word: "図書館", reading: "としょかん", meaning: "library"),
                    ReadingPassage.VocabularyItem(word: "静か", reading: "しずか", meaning: "quiet"),
                    ReadingPassage.VocabularyItem(word: "借りる", reading: "かりる", meaning: "to borrow"),
                    ReadingPassage.VocabularyItem(word: "週に二回", reading: "しゅうににかい", meaning: "twice a week")
                ],
                question: "How often does the person go to the library?",
                options: [
                    "Twice a week",
                    "Every day",
                    "Once a month",
                    "Three times a week"
                ],
                correctAnswer: "Twice a week",
                explanation: "The text says '週に二回、図書館に行きます' (I go to the library twice a week)."
            )
        ]
    }
}

private struct EmptyReadingStateView: View {
    let onRetry: () -> Void
    
    var body: some View {
        ProfessionalEmptyStateView(
            icon: "book.pages",
            title: "No Reading Passages",
            message: "Reading practice includes passages with vocabulary and comprehension questions to improve your understanding.",
            actionTitle: "Load Practice",
            action: onRetry
        )
    }
}

