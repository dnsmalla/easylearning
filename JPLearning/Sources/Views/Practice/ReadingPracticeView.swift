//
//  ReadingPracticeView.swift
//  JLearn
//
//  Reading comprehension practice view
//

import SwiftUI

struct ReadingPracticeView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @State private var passages: [ReadingPassage] = []
    @State private var currentIndex = 0
    @State private var showResult = false
    @State private var selectedAnswers: [String: String] = [:]
    @State private var score = 0
    @State private var isLoading = true
    @State private var showResults = false
    
    var currentPassage: ReadingPassage? {
        guard !passages.isEmpty && currentIndex < passages.count else { return nil }
        return passages[currentIndex]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Level Indicator
            CompactLevelHeader()
            
            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if passages.isEmpty {
                ProfessionalEmptyStateView(
                    icon: "book.pages",
                    title: "No Reading Passages",
                    message: "Check back later for new content"
                )
            } else if showResults {
                resultsView
            } else if let passage = currentPassage {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Passage
                        VStack(alignment: .leading, spacing: 12) {
                            Text(passage.title)
                                .font(AppTheme.Typography.title2)
                                .foregroundColor(.primary)
                            
                            Text(passage.content)
                                .font(AppTheme.Typography.japaneseBody)
                                .foregroundColor(.primary)
                                .lineSpacing(8)
                        }
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                        
                        // Questions
                        ForEach(Array(passage.questions.enumerated()), id: \.element.id) { index, question in
                            QuestionCard(
                                question: question,
                                questionNumber: index + 1,
                                selectedAnswer: selectedAnswers[question.id],
                                showResult: showResult
                            ) { answer in
                                selectedAnswers[question.id] = answer
                            }
                        }
                        
                        // Check Button
                        if !showResult && selectedAnswers.count == passage.questions.count {
                            Button {
                                checkAnswers()
                            } label: {
                                Text("Check Answers")
                                    .font(AppTheme.Typography.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppTheme.brandPrimary)
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                            }
                        }
                        
                        // Next Button
                        if showResult {
                            Button {
                                nextPassage()
                            } label: {
                                Text("Next Passage")
                                    .font(AppTheme.Typography.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppTheme.brandPrimary)
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                            }
                        }
                    }
                    .padding()
                }
                .background(AppTheme.background)
            }
        }
        .navigationTitle("Reading Practice")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadPassages()
        }
        .reloadOnLevelChange {
            await loadPassages()
        }
    }
    
    private var resultsView: some View {
        ProfessionalResultsView(
            score: score,
            total: passages.reduce(0) { $0 + $1.questions.count },
            title: "Reading Complete!",
            icon: "book.closed.fill",
            color: .green,
            restartAction: {
                currentIndex = 0
                score = 0
                showResults = false
                selectedAnswers = [:]
                showResult = false
            }
        )
    }
    
    private func loadPassages() async {
        isLoading = true
        // Load reading passages
        passages = ReadingPassage.samplePassages
        isLoading = false
    }
    
    private func checkAnswers() {
        guard let passage = currentPassage else { return }
        
        var correct = 0
        for question in passage.questions {
            if selectedAnswers[question.id] == question.correctAnswer {
                correct += 1
            }
        }
        
        score += correct
        showResult = true
        
        if correct == passage.questions.count {
            Haptics.success()
        } else {
            Haptics.error()
        }
    }
    
    private func nextPassage() {
        if currentIndex < passages.count - 1 {
            currentIndex += 1
            showResult = false
            selectedAnswers = [:]
        } else {
            showResults = true
        }
    }
}

// MARK: - Question Card

private struct QuestionCard: View {
    let question: ReadingQuestion
    let questionNumber: Int
    let selectedAnswer: String?
    let showResult: Bool
    let onSelect: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Question
            HStack(alignment: .top, spacing: 8) {
                Text("\(questionNumber).")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.brandPrimary)
                
                Text(question.question)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(.primary)
            }
            
            // Options
            VStack(spacing: 12) {
                ForEach(question.options, id: \.self) { option in
                    ProfessionalAnswerButton(
                        text: option,
                        isSelected: selectedAnswer == option,
                        isCorrect: showResult && option == question.correctAnswer,
                        isWrong: showResult && selectedAnswer == option && option != question.correctAnswer
                    ) {
                        if !showResult {
                            onSelect(option)
                        }
                    }
                }
            }
            
            // Explanation
            if showResult, let explanation = question.explanation {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Explanation:")
                        .font(AppTheme.Typography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text(explanation)
                        .font(AppTheme.Typography.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(AppTheme.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
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

// MARK: - Models

struct ReadingPassage: Identifiable {
    let id = UUID().uuidString
    let title: String
    let content: String
    let questions: [ReadingQuestion]
    let level: LearningLevel
    
    static let samplePassages: [ReadingPassage] = [
        ReadingPassage(
            title: "日本の食事",
            content: "日本の伝統的な食事は健康的で美味しいです。米、魚、野菜が中心です。朝ご飯には、ご飯、味噌汁、魚、そして漬物を食べます。",
            questions: [
                ReadingQuestion(
                    question: "What is the center of traditional Japanese meals?",
                    options: ["Rice, fish, and vegetables", "Bread and meat", "Pasta and cheese", "Fruit only"],
                    correctAnswer: "Rice, fish, and vegetables",
                    explanation: "The passage states that rice (米), fish (魚), and vegetables (野菜) are the center."
                ),
                ReadingQuestion(
                    question: "What do Japanese people eat for breakfast?",
                    options: ["Rice, miso soup, fish, and pickles", "Bread and coffee", "Cereal and milk", "Eggs and bacon"],
                    correctAnswer: "Rice, miso soup, fish, and pickles",
                    explanation: "朝ご飯には、ご飯、味噌汁、魚、そして漬物を食べます。"
                )
            ],
            level: .n5
        )
    ]
}

struct ReadingQuestion: Identifiable {
    let id = UUID().uuidString
    let question: String
    let options: [String]
    let correctAnswer: String
    let explanation: String?
}


