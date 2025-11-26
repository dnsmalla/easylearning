//
//  SentenceBuilderGame.swift
//  NPLearn
//
//  Sentence building game for Nepali
//

import SwiftUI

// MARK: - Sentence Builder Game

struct SentenceBuilderGame: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @State private var grammarPoints: [GrammarPoint] = []
    @State private var currentIndex = 0
    @State private var wordBlocks: [WordBlock] = []
    @State private var selectedBlocks: [WordBlock] = []
    @State private var correctSentence: String = ""
    @State private var showResult = false
    @State private var score = 0
    @State private var isLoading = true
    @State private var showCompleted = false
    
    struct WordBlock: Identifiable, Equatable {
        let id = UUID()
        let word: String
        let isUsed: Bool
    }
    
    var currentGrammar: GrammarPoint? {
        guard !grammarPoints.isEmpty && currentIndex < grammarPoints.count else { return nil }
        return grammarPoints[currentIndex]
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
            } else if let grammar = currentGrammar {
                // Progress Header
                VStack(spacing: 8) {
                    HStack {
                        Text("Sentence \(currentIndex + 1) of \(grammarPoints.count)")
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
                            Text(grammar.examples.first?.english ?? "Build a sentence")
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
                                        .font(AppTheme.Typography.nepaliBody)
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
            await loadGrammar()
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
            
            Text("Final Score: \(score) / \(grammarPoints.count)")
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
    
    private func loadGrammar() async {
        isLoading = true
        grammarPoints = learningDataService.grammarPoints.filter { !$0.examples.isEmpty }
        if !grammarPoints.isEmpty {
            setupSentence()
        }
        isLoading = false
    }
    
    private func setupSentence() {
        guard let grammar = currentGrammar,
              let example = grammar.examples.first else { return }
        
        correctSentence = example.nepali
        
        // Split sentence into words/characters for Nepali
        let words = splitNepaliSentence(example.nepali)
        wordBlocks = words.shuffled().map { WordBlock(word: $0, isUsed: false) }
        selectedBlocks = []
        showResult = false
    }
    
    private func splitNepaliSentence(_ sentence: String) -> [String] {
        // Simple split by character for Devanagari script
        // In a real app, would use proper tokenizer for Nepali
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
        if currentIndex < grammarPoints.count - 1 {
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

// MARK: - Word Block View

struct WordBlockView: View {
    let word: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(word)
                .font(AppTheme.Typography.nepaliBody)
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


