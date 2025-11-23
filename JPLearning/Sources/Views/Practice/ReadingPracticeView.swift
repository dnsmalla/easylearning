//
//  ReadingPracticeView.swift
//  JLearn
//
//  IMPROVED: Proper pedagogical structure
//  Flow: Level Selection → Passage → Vocabulary → Question → Answer (A, B, C, D)
//

import SwiftUI

// MARK: - Reading Practice View

struct ReadingPracticeView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @StateObject private var viewModel = ReadingPracticeViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var selectedLevel: LearningLevel?
    
    var body: some View {
        ZStack {
            if selectedLevel == nil {
                // Level Selection Screen
                LevelSelectionView(selectedLevel: $selectedLevel)
            } else if viewModel.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading passages...")
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(AppTheme.mutedText)
                }
            } else if viewModel.passages.isEmpty {
                EmptyReadingStateView {
                    if let level = selectedLevel {
                        viewModel.loadPassages(for: level)
                    }
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
        .navigationTitle(selectedLevel == nil ? "Select Level" : "Reading Practice")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(selectedLevel != nil && !viewModel.showResults)
        .toolbar {
            if selectedLevel != nil && !viewModel.showResults {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        selectedLevel = nil
                        viewModel.reset()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Levels")
                        }
                    }
                }
            }
        }
        .onChange(of: selectedLevel) { newLevel in
            if let level = newLevel {
                viewModel.loadPassages(for: level)
            }
        }
    }
}

// MARK: - Level Selection View

private struct LevelSelectionView: View {
    @Binding var selectedLevel: LearningLevel?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "book.pages")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                    
                    Text("Choose Your Level")
                        .font(AppTheme.Typography.title)
                        .fontWeight(.bold)
                    
                    Text("Select a JLPT level for reading practice")
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.mutedText)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 30)
                .padding(.horizontal)
                
                // Level Cards
                VStack(spacing: 16) {
                    ForEach(LearningLevel.allCases, id: \.self) { level in
                        LevelCardButton(level: level) {
                            withAnimation {
                                selectedLevel = level
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 20)
        }
        .background(AppTheme.background)
    }
}

// MARK: - Level Card Button

private struct LevelCardButton: View {
    let level: LearningLevel
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Level Badge
                ZStack {
                    Circle()
                        .fill(levelColor.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Text(level.rawValue)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(levelColor)
                }
                
                // Level Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.title)
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.primary)
                    
                    Text(level.description)
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(AppTheme.mutedText)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.mutedText)
            }
            .padding(20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: AppTheme.Shadows.elevation2.color,
                radius: AppTheme.Shadows.elevation2.radius,
                y: AppTheme.Shadows.elevation2.y
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var levelColor: Color {
        switch level {
        case .n5: return .green
        case .n4: return .blue
        case .n3: return .orange
        case .n2: return .purple
        case .n1: return .red
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
    
    struct VocabularyItem: Hashable {
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
    @Published var currentLevel: LearningLevel = .n5
    
    var currentPassage: ReadingPassage? {
        guard currentPassageIndex < passages.count else { return nil }
        return passages[currentPassageIndex]
    }
    
    var hasNextQuestion: Bool {
        currentPassageIndex < passages.count - 1
    }
    
    func loadPassages(for level: LearningLevel) {
        isLoading = true
        currentLevel = level
        
        Task { @MainActor in
            // Generate sample reading passages with proper structure
            self.passages = generateSampleReadingPassages(level: level)
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
    
    func reset() {
        passages = []
        currentPassageIndex = 0
        selectedAnswer = nil
        showFeedback = false
        isCorrect = false
        score = 0
        showResults = false
        isLoading = false
    }
    
    private func generateSampleReadingPassages(level: LearningLevel) -> [ReadingPassage] {
        switch level {
        case .n5:
            return generateN5Passages()
        case .n4:
            return generateN4Passages()
        case .n3:
            return generateN3Passages()
        case .n2:
            return generateN2Passages()
        case .n1:
            return generateN1Passages()
        }
    }
    
    private func generateN5Passages() -> [ReadingPassage] {
        return [
            ReadingPassage(
                id: "n5_reading_1",
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
                id: "n5_reading_2",
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
                id: "n5_reading_3",
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
    
    private func generateN4Passages() -> [ReadingPassage] {
        return [
            ReadingPassage(
                id: "n4_reading_1",
                text: "先週の金曜日、友達と映画を見に行きました。とても面白い映画でした。映画の後で、近くのレストランで夕食を食べました。久しぶりに会った友達と楽しい時間を過ごすことができて、とても嬉しかったです。",
                vocabulary: [
                    ReadingPassage.VocabularyItem(word: "映画", reading: "えいが", meaning: "movie"),
                    ReadingPassage.VocabularyItem(word: "面白い", reading: "おもしろい", meaning: "interesting"),
                    ReadingPassage.VocabularyItem(word: "久しぶり", reading: "ひさしぶり", meaning: "after a long time"),
                    ReadingPassage.VocabularyItem(word: "過ごす", reading: "すごす", meaning: "to spend time")
                ],
                question: "How did the person feel about meeting their friend?",
                options: [
                    "Very happy",
                    "A bit sad",
                    "Very tired",
                    "Disappointed"
                ],
                correctAnswer: "Very happy",
                explanation: "The passage ends with 'とても嬉しかったです' (I was very happy)."
            ),
            ReadingPassage(
                id: "n4_reading_2",
                text: "日本の夏は暑くて湿気が多いです。エアコンをつけないと、部屋の中でも汗をかきます。でも、夏には花火大会や夏祭りなど、楽しいイベントがたくさんあります。",
                vocabulary: [
                    ReadingPassage.VocabularyItem(word: "湿気", reading: "しっけ", meaning: "humidity"),
                    ReadingPassage.VocabularyItem(word: "汗", reading: "あせ", meaning: "sweat"),
                    ReadingPassage.VocabularyItem(word: "花火大会", reading: "はなびたいかい", meaning: "fireworks festival"),
                    ReadingPassage.VocabularyItem(word: "夏祭り", reading: "なつまつり", meaning: "summer festival")
                ],
                question: "What is summer like in Japan?",
                options: [
                    "Hot and humid",
                    "Cool and dry",
                    "Cold and snowy",
                    "Warm and pleasant"
                ],
                correctAnswer: "Hot and humid",
                explanation: "The passage states '日本の夏は暑くて湿気が多いです' (Japanese summers are hot and humid)."
            )
        ]
    }
    
    private func generateN3Passages() -> [ReadingPassage] {
        return [
            ReadingPassage(
                id: "n3_reading_1",
                text: "最近、環境問題に関心を持つ人が増えています。プラスチックごみを減らすために、エコバッグを使用したり、リサイクルを心がけたりする人が多くなりました。小さな努力でも、続けることが大切だと言われています。",
                vocabulary: [
                    ReadingPassage.VocabularyItem(word: "環境問題", reading: "かんきょうもんだい", meaning: "environmental issues"),
                    ReadingPassage.VocabularyItem(word: "関心", reading: "かんしん", meaning: "interest"),
                    ReadingPassage.VocabularyItem(word: "心がける", reading: "こころがける", meaning: "to make an effort"),
                    ReadingPassage.VocabularyItem(word: "努力", reading: "どりょく", meaning: "effort")
                ],
                question: "What is considered important regarding environmental efforts?",
                options: [
                    "Continuing even small efforts",
                    "Only making big changes",
                    "Waiting for government action",
                    "Ignoring the problem"
                ],
                correctAnswer: "Continuing even small efforts",
                explanation: "The passage states '小さな努力でも、続けることが大切だと言われています' (It is said that even small efforts are important if continued)."
            ),
            ReadingPassage(
                id: "n3_reading_2",
                text: "健康を維持するためには、規則正しい生活が不可欠です。十分な睡眠を取り、バランスの良い食事をすることが推奨されています。また、適度な運動も健康維持に効果的だと考えられています。",
                vocabulary: [
                    ReadingPassage.VocabularyItem(word: "維持", reading: "いじ", meaning: "maintenance"),
                    ReadingPassage.VocabularyItem(word: "不可欠", reading: "ふかけつ", meaning: "essential"),
                    ReadingPassage.VocabularyItem(word: "推奨", reading: "すいしょう", meaning: "recommendation"),
                    ReadingPassage.VocabularyItem(word: "適度", reading: "てきど", meaning: "moderate")
                ],
                question: "What is essential for maintaining health?",
                options: [
                    "A regular lifestyle",
                    "Expensive medicine",
                    "Working long hours",
                    "Eating only vegetables"
                ],
                correctAnswer: "A regular lifestyle",
                explanation: "The text says '規則正しい生活が不可欠です' (A regular lifestyle is essential)."
            )
        ]
    }
    
    private func generateN2Passages() -> [ReadingPassage] {
        return [
            ReadingPassage(
                id: "n2_reading_1",
                text: "日本の伝統文化は、長い歴史の中で培われてきました。茶道や華道などの芸道は、単なる技術の習得だけでなく、精神性を重視する点が特徴的です。現代においても、これらの伝統文化は多くの人々に受け継がれ、新しい価値を生み出し続けています。",
                vocabulary: [
                    ReadingPassage.VocabularyItem(word: "培う", reading: "つちかう", meaning: "to cultivate"),
                    ReadingPassage.VocabularyItem(word: "芸道", reading: "げいどう", meaning: "art form"),
                    ReadingPassage.VocabularyItem(word: "精神性", reading: "せいしんせい", meaning: "spirituality"),
                    ReadingPassage.VocabularyItem(word: "受け継ぐ", reading: "うけつぐ", meaning: "to inherit")
                ],
                question: "What is characteristic of Japanese traditional arts?",
                options: [
                    "They emphasize spirituality, not just technical skill",
                    "They focus only on technical mastery",
                    "They are no longer practiced today",
                    "They are easy to learn"
                ],
                correctAnswer: "They emphasize spirituality, not just technical skill",
                explanation: "The passage mentions '精神性を重視する点が特徴的です' (The emphasis on spirituality is characteristic)."
            )
        ]
    }
    
    private func generateN1Passages() -> [ReadingPassage] {
        return [
            ReadingPassage(
                id: "n1_reading_1",
                text: "グローバル化が進展する現代社会において、異文化理解の重要性が高まっている。しかしながら、真の異文化理解とは、表面的な文化的差異を認識することにとどまらず、その背景にある価値観や思想を深く洞察することが求められる。このような姿勢こそが、持続可能な国際関係の構築に不可欠である。",
                vocabulary: [
                    ReadingPassage.VocabularyItem(word: "進展", reading: "しんてん", meaning: "progress"),
                    ReadingPassage.VocabularyItem(word: "差異", reading: "さい", meaning: "difference"),
                    ReadingPassage.VocabularyItem(word: "洞察", reading: "どうさつ", meaning: "insight"),
                    ReadingPassage.VocabularyItem(word: "持続可能", reading: "じぞくかのう", meaning: "sustainable")
                ],
                question: "What is true cross-cultural understanding according to the passage?",
                options: [
                    "Deep insight into values and thoughts behind cultural differences",
                    "Just recognizing superficial cultural differences",
                    "Learning foreign languages",
                    "Traveling to many countries"
                ],
                correctAnswer: "Deep insight into values and thoughts behind cultural differences",
                explanation: "The passage states '背景にある価値観や思想を深く洞察することが求められる' (Deep insight into underlying values and thoughts is required)."
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
