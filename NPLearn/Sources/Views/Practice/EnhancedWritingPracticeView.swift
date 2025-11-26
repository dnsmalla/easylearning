//
//  EnhancedWritingPracticeView.swift
//  NPLearn
//
//  Enhanced writing practice with character and sentence modes
//

import SwiftUI

// MARK: - Enhanced Writing Practice View

struct EnhancedWritingPracticeView: View {
    @StateObject private var viewModel = EnhancedWritingPracticeViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Mode Selector
                VStack(spacing: 12) {
                    Text("Writing Practice")
                        .font(AppTheme.Typography.title2)
                        .foregroundColor(.primary)
                    
                    // Mode Tabs
                    HStack(spacing: 0) {
                        Button(action: {
                            withAnimation {
                                viewModel.mode = .character
                            }
                        }) {
                            Text("Characters")
                                .font(AppTheme.Typography.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(viewModel.mode == .character ? .white : AppTheme.brandPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(viewModel.mode == .character ? AppTheme.brandPrimary : Color.clear)
                        }
                        
                        Button(action: {
                            withAnimation {
                                viewModel.mode = .sentence
                            }
                        }) {
                            Text("Sentences")
                                .font(AppTheme.Typography.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(viewModel.mode == .sentence ? .white : AppTheme.brandPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(viewModel.mode == .sentence ? AppTheme.brandPrimary : Color.clear)
                        }
                    }
                    .background(AppTheme.secondaryBackground)
                    .clipShape(Capsule())
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                }
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                // Content based on mode
                if viewModel.mode == .character {
                    CharacterPracticeView(viewModel: viewModel)
                } else {
                    SentencePracticeView(viewModel: viewModel)
                }
            }
        }
        .navigationTitle("Writing Practice")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Text("\(viewModel.practiceCount) practiced")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.mutedText)
            }
        }
    }
}

// MARK: - Character Practice View

struct CharacterPracticeView: View {
    @ObservedObject var viewModel: EnhancedWritingPracticeViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Character to Practice
            VStack(spacing: 16) {
                Text("Write this character")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.mutedText)
                
                Text(viewModel.currentCharacter)
                    .font(.system(size: 100))
                    .foregroundColor(AppTheme.brandPrimary)
                
                Text(viewModel.currentRomanization)
                    .font(AppTheme.Typography.title2)
                    .foregroundColor(AppTheme.mutedText)
            }
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
            .background(AppTheme.secondaryBackground)
            
            Divider()
            
            // Drawing Area
            VStack(spacing: 16) {
                Text("Draw here")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.mutedText)
                
                DrawingCanvasView(
                    lines: $viewModel.lines,
                    currentLine: $viewModel.currentLine
                )
                .frame(maxWidth: .infinity)
                .frame(height: 400)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.brandPrimary.opacity(0.3), lineWidth: 2)
                )
                .shadow(
                    color: AppTheme.Shadows.elevation2.color,
                    radius: AppTheme.Shadows.elevation2.radius,
                    y: AppTheme.Shadows.elevation2.y
                )
            }
            .padding(.horizontal, AppTheme.Layout.horizontalPadding)
            .padding(.vertical, 24)
            
            // Action Buttons
            ActionButtons(viewModel: viewModel)
        }
    }
}

// MARK: - Sentence Practice View

struct SentencePracticeView: View {
    @ObservedObject var viewModel: EnhancedWritingPracticeViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Sentence to Practice
            VStack(spacing: 20) {
                Text("Write this sentence")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.mutedText)
                
                // Nepali Sentence
                Text(viewModel.currentSentence)
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(AppTheme.brandPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // English Translation
                Text(viewModel.currentTranslation)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.mutedText)
                    .multilineTextAlignment(.center)
                
                // Romanization
                Text(viewModel.currentSentenceRomanization)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.mutedText.opacity(0.7))
                    .italic()
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(AppTheme.secondaryBackground)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 16) {
                    Text("Write on the lines below")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.mutedText)
                    
                    // Lined Canvas for Sentence Writing
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
                        DrawingCanvasView(
                            lines: $viewModel.lines,
                            currentLine: $viewModel.currentLine
                        )
                        .frame(height: 400)
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppTheme.brandPrimary.opacity(0.3), lineWidth: 2)
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
            ActionButtons(viewModel: viewModel)
        }
    }
}

// MARK: - Action Buttons

struct ActionButtons: View {
    @ObservedObject var viewModel: EnhancedWritingPracticeViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: {
                viewModel.clearDrawing()
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
                viewModel.nextItem()
            }) {
                HStack {
                    Text("Next")
                    Image(systemName: "arrow.right")
                }
                .font(AppTheme.Typography.button)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: AppTheme.Controls.buttonHeight)
                .background(AppTheme.brandPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal, AppTheme.Layout.horizontalPadding)
        .padding(.bottom, 24)
    }
}

// MARK: - Enhanced Writing Practice ViewModel

class EnhancedWritingPracticeViewModel: ObservableObject {
    @Published var mode: WritingMode = .character
    @Published var currentCharacter: String = ""
    @Published var currentRomanization: String = ""
    @Published var currentSentence: String = ""
    @Published var currentTranslation: String = ""
    @Published var currentSentenceRomanization: String = ""
    @Published var lines: [Line] = []
    @Published var currentLine: Line = Line(points: [], color: .black, lineWidth: 3)
    @Published var practiceCount: Int = 0
    
    enum WritingMode {
        case character
        case sentence
    }
    
    // All Devanagari characters
    private let vowels: [(String, String)] = [
        ("अ", "a"), ("आ", "aa"), ("इ", "i"), ("ई", "ii"),
        ("उ", "u"), ("ऊ", "uu"), ("ऋ", "ri"), ("ॠ", "rr"),
        ("ए", "e"), ("ऐ", "ai"), ("ओ", "o"), ("औ", "au")
    ]
    
    private let consonants: [(String, String)] = [
        ("क", "ka"), ("ख", "kha"), ("ग", "ga"), ("घ", "gha"), ("ङ", "nga"),
        ("च", "cha"), ("छ", "chha"), ("ज", "ja"), ("झ", "jha"), ("ञ", "nya"),
        ("ट", "ta"), ("ठ", "tha"), ("ड", "da"), ("ढ", "dha"), ("ण", "na"),
        ("त", "ta"), ("थ", "tha"), ("द", "da"), ("ध", "dha"), ("न", "na"),
        ("प", "pa"), ("फ", "pha"), ("ब", "ba"), ("भ", "bha"), ("म", "ma"),
        ("य", "ya"), ("र", "ra"), ("ल", "la"), ("व", "wa"),
        ("श", "sha"), ("ष", "shha"), ("स", "sa"), ("ह", "ha")
    ]
    
    // Practice sentences
    private let sentences: [(nepali: String, english: String, romanization: String)] = [
        ("नमस्ते", "Hello", "namaste"),
        ("मेरो नाम राम हो।", "My name is Ram.", "mero naam Ram ho"),
        ("तपाईंलाई कस्तो छ?", "How are you?", "tapailai kasto chha"),
        ("म राम्रो छु।", "I am fine.", "ma ramro chhu"),
        ("धन्यवाद", "Thank you", "dhanyabad"),
        ("तपाईं कहाँ जानुहुन्छ?", "Where are you going?", "tapai kaha januhunchha"),
        ("म घर जान्छु।", "I am going home.", "ma ghar janchhu"),
        ("यो राम्रो छ।", "This is good.", "yo ramro chha"),
        ("म नेपाली सिक्दैछु।", "I am learning Nepali.", "ma nepali sikdaichhu"),
        ("तपाईंलाई भेटेर खुसी लाग्यो।", "Nice to meet you.", "tapailai bheter khusi lagyo")
    ]
    
    private var allCharacters: [(String, String)] = []
    
    init() {
        allCharacters = vowels + consonants
        selectRandomCharacter()
        selectRandomSentence()
    }
    
    func selectRandomCharacter() {
        if let random = allCharacters.randomElement() {
            currentCharacter = random.0
            currentRomanization = random.1
        }
    }
    
    func selectRandomSentence() {
        if let random = sentences.randomElement() {
            currentSentence = random.nepali
            currentTranslation = random.english
            currentSentenceRomanization = random.romanization
        }
    }
    
    func clearDrawing() {
        lines.removeAll()
        currentLine = Line(points: [], color: .black, lineWidth: 3)
    }
    
    func nextItem() {
        practiceCount += 1
        clearDrawing()
        
        if mode == .character {
            selectRandomCharacter()
        } else {
            selectRandomSentence()
        }
    }
}

#Preview {
    NavigationStack {
        EnhancedWritingPracticeView()
    }
}

