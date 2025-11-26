//
//  MiniGamesView.swift
//  NPLearn
//
//  Fun and interactive mini-games for children to learn Nepali
//  Includes drag-drop, matching, word building, and more
//

import SwiftUI

// MARK: - Mini Games Hub

struct MiniGamesHubView: View {
    @State private var selectedGame: MiniGameType?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(AppTheme.heroGradient)
                        
                        Text("Learning Games")
                            .font(AppTheme.Typography.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Play and learn Nepali!")
                            .font(AppTheme.Typography.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Games Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(MiniGameType.allCases, id: \.self) { gameType in
                            MiniGameCard(gameType: gameType) {
                                selectedGame = gameType
                                Haptics.selection()
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .background(AppTheme.secondaryBackground)
            .navigationTitle("Mini Games")
            .sheet(item: $selectedGame) { gameType in
                gameView(for: gameType)
            }
        }
    }
    
    @ViewBuilder
    func gameView(for type: MiniGameType) -> some View {
        switch type {
        case .dragAndDrop:
            DragAndDropGameView()
        case .matching:
            MatchingGameView()
        case .wordBuilder:
            WordBuilderGameView()
        case .memoryCards:
            MemoryCardGameView()
        case .listening:
            ListeningGameView()
        case .speaking:
            SpeakingGameView()
        }
    }
}

struct MiniGameCard: View {
    let gameType: MiniGameType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(gameType.color.opacity(0.2))
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: gameType.icon)
                        .font(.system(size: 30))
                        .foregroundColor(gameType.color)
                }
                
                Text(gameType.rawValue)
                    .font(AppTheme.Typography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppTheme.background)
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
            )
        }
    }
}

// MARK: - Drag and Drop Game

struct DragAndDropGameView: View {
    @Environment(\.dismiss) var dismiss
    @State private var words: [DraggableWord] = [
        DraggableWord(id: "1", nepali: "नमस्ते", english: "Hello"),
        DraggableWord(id: "2", nepali: "धन्यवाद", english: "Thank you"),
        DraggableWord(id: "3", nepali: "हो", english: "Yes"),
        DraggableWord(id: "4", nepali: "होइन", english: "No")
    ]
    @State private var targets: [DropTarget] = [
        DropTarget(id: "1", english: "Hello", position: CGPoint(x: 100, y: 200)),
        DropTarget(id: "2", english: "Thank you", position: CGPoint(x: 250, y: 200)),
        DropTarget(id: "3", english: "Yes", position: CGPoint(x: 100, y: 350)),
        DropTarget(id: "4", english: "No", position: CGPoint(x: 250, y: 350))
    ]
    @State private var score = 0
    @State private var showCelebration = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.secondaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Match the Words")
                                .font(AppTheme.Typography.title2)
                                .fontWeight(.bold)
                            Text("Drag Nepali words to English")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("\(score)")
                                .font(AppTheme.Typography.title3)
                                .fontWeight(.bold)
                        }
                    }
                    .padding()
                    
                    // Game Area
                    ZStack {
                        // Drop Targets
                        ForEach(targets) { target in
                            DropTargetView(target: target)
                                .position(target.position)
                        }
                        
                        // Draggable Words
                        ForEach(words) { word in
                            if !word.isMatched {
                                DraggableWordView(word: word) { draggedWord in
                                    checkMatch(draggedWord)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func checkMatch(_ word: DraggableWord) {
        if let matchedIndex = words.firstIndex(where: { $0.id == word.id }) {
            words[matchedIndex].isMatched = true
            score += 10
            Haptics.success()
            
            if words.allSatisfy({ $0.isMatched }) {
                showCelebration = true
            }
        }
    }
}

struct DraggableWord: Identifiable {
    let id: String
    let nepali: String
    let english: String
    var isMatched: Bool = false
}

struct DropTarget: Identifiable {
    let id: String
    let english: String
    let position: CGPoint
}

struct DraggableWordView: View {
    let word: DraggableWord
    let onDrop: (DraggableWord) -> Void
    @State private var position = CGPoint(x: 200, y: 100)
    
    var body: some View {
        Text(word.nepali)
            .font(AppTheme.Typography.title2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.brandPrimary)
                    .shadow(radius: 4)
            )
            .position(position)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        position = value.location
                    }
                    .onEnded { _ in
                        onDrop(word)
                    }
            )
    }
}

struct DropTargetView: View {
    let target: DropTarget
    
    var body: some View {
        Text(target.english)
            .font(AppTheme.Typography.body)
            .foregroundColor(.secondary)
            .frame(width: 120, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.brandPrimary, style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppTheme.background)
                    )
            )
    }
}

// MARK: - Matching Game

struct MatchingGameView: View {
    @Environment(\.dismiss) var dismiss
    @State private var cards: [MatchCard] = MatchCard.sampleCards.shuffled()
    @State private var selectedCards: [MatchCard] = []
    @State private var matchedPairs: Set<String> = []
    @State private var score = 0
    @State private var showCelebration = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.secondaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Score
                    HStack {
                        Text("Find Matching Pairs")
                            .font(AppTheme.Typography.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("\(score)")
                                .font(AppTheme.Typography.title3)
                                .fontWeight(.bold)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Cards Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(cards) { card in
                            MatchCardView(
                                card: card,
                                isFlipped: selectedCards.contains(where: { $0.id == card.id }) || matchedPairs.contains(card.pairId)
                            ) {
                                selectCard(card)
                            }
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func selectCard(_ card: MatchCard) {
        guard selectedCards.count < 2,
              !matchedPairs.contains(card.pairId),
              !selectedCards.contains(where: { $0.id == card.id }) else { return }
        
        selectedCards.append(card)
        Haptics.selection()
        
        if selectedCards.count == 2 {
            checkMatch()
        }
    }
    
    func checkMatch() {
        guard selectedCards.count == 2 else { return }
        
        if selectedCards[0].pairId == selectedCards[1].pairId {
            // Match found!
            matchedPairs.insert(selectedCards[0].pairId)
            score += 20
            Haptics.success()
            
            if matchedPairs.count == cards.count / 2 {
                showCelebration = true
            }
            
            selectedCards.removeAll()
        } else {
            // No match
            Haptics.error()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                selectedCards.removeAll()
            }
        }
    }
}

struct MatchCard: Identifiable, Equatable {
    let id: String
    let content: String
    let pairId: String
    let isNepali: Bool
    
    static var sampleCards: [MatchCard] {
        let pairs = [
            ("नमस्ते", "Hello"),
            ("धन्यवाद", "Thank you"),
            ("हो", "Yes"),
            ("होइन", "No"),
            ("राम्रो", "Good"),
            ("नराम्रो", "Bad")
        ]
        
        var cards: [MatchCard] = []
        for (index, pair) in pairs.enumerated() {
            cards.append(MatchCard(id: "\(index)_nepali", content: pair.0, pairId: "pair_\(index)", isNepali: true))
            cards.append(MatchCard(id: "\(index)_english", content: pair.1, pairId: "pair_\(index)", isNepali: false))
        }
        
        return cards
    }
}

struct MatchCardView: View {
    let card: MatchCard
    let isFlipped: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Back of card
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.brandPrimary, AppTheme.brandSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Image(systemName: "questionmark")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white.opacity(0.5))
                    )
                    .opacity(isFlipped ? 0 : 1)
                
                // Front of card
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.background)
                    .shadow(radius: 4)
                    .overlay(
                        Text(card.content)
                            .font(card.isNepali ? AppTheme.Typography.nepaliTitle : AppTheme.Typography.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding(8)
                    )
                    .opacity(isFlipped ? 1 : 0)
            }
            .frame(height: 100)
            .rotation3DEffect(
                .degrees(isFlipped ? 0 : 180),
                axis: (x: 0, y: 1, z: 0)
            )
            .animation(.easeInOut(duration: 0.3), value: isFlipped)
        }
        .disabled(isFlipped)
    }
}

// MARK: - Word Builder Game

struct WordBuilderGameView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentWord = "नमस्ते"
    @State private var letters: [String] = ["न", "म", "स", "्", "ते"]
    @State private var scrambledLetters: [String] = []
    @State private var builtWord: [String] = []
    @State private var score = 0
    @State private var showCelebration = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.secondaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Build the Word")
                            .font(AppTheme.Typography.title)
                            .fontWeight(.bold)
                        
                        Text("Tap letters in order")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("\(score)")
                                .font(AppTheme.Typography.title3)
                                .fontWeight(.bold)
                        }
                    }
                    .padding()
                    
                    // Target word display
                    Text(currentWord)
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppTheme.background)
                        )
                    
                    // Built word area
                    HStack(spacing: 8) {
                        ForEach(0..<letters.count, id: \.self) { index in
                            if index < builtWord.count {
                                Text(builtWord[index])
                                    .font(.system(size: 36))
                                    .frame(width: 50, height: 60)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(AppTheme.success.opacity(0.2))
                                    )
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppTheme.brandPrimary, style: StrokeStyle(lineWidth: 2, dash: [5]))
                                    .frame(width: 50, height: 60)
                            }
                        }
                    }
                    
                    // Letter buttons
                    FlowLayout(spacing: 12) {
                        ForEach(scrambledLetters.indices, id: \.self) { index in
                            if !builtWord.contains(scrambledLetters[index]) {
                                Button {
                                    selectLetter(scrambledLetters[index])
                                } label: {
                                    Text(scrambledLetters[index])
                                        .font(.system(size: 32))
                                        .frame(width: 60, height: 60)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(AppTheme.brandPrimary)
                                        )
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .padding()
                    
                    // Reset button
                    ProfessionalButton("Reset", icon: "arrow.counterclockwise", style: .outline) {
                        resetGame()
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                scrambledLetters = letters.shuffled()
            }
        }
    }
    
    func selectLetter(_ letter: String) {
        builtWord.append(letter)
        Haptics.selection()
        
        if builtWord.count == letters.count {
            checkWord()
        }
    }
    
    func checkWord() {
        if builtWord.joined() == letters.joined() {
            score += 30
            Haptics.success()
            showCelebration = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                resetGame()
            }
        } else {
            Haptics.error()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                resetGame()
            }
        }
    }
    
    func resetGame() {
        builtWord.removeAll()
        scrambledLetters = letters.shuffled()
    }
}

// MARK: - Flow Layout Helper

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0
        
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for size in sizes {
            if lineWidth + size.width > proposal.width ?? 0 {
                totalHeight += lineHeight + spacing
                lineWidth = size.width
                lineHeight = size.height
            } else {
                lineWidth += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            totalWidth = max(totalWidth, lineWidth)
        }
        
        totalHeight += lineHeight
        
        return CGSize(width: totalWidth, height: totalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var lineX = bounds.minX
        var lineY = bounds.minY
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if lineX + size.width > bounds.maxX {
                lineY += lineHeight + spacing
                lineX = bounds.minX
                lineHeight = 0
            }
            
            subview.place(at: CGPoint(x: lineX, y: lineY), proposal: .unspecified)
            lineX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}

// MARK: - Memory Card Game

struct MemoryCardGameView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.secondaryBackground
                    .ignoresSafeArea()
                
                VStack {
                    Text("Memory Game")
                        .font(AppTheme.Typography.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Coming soon!")
                        .font(AppTheme.Typography.title3)
                        .foregroundColor(.secondary)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Listening Game

struct ListeningGameView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.secondaryBackground
                    .ignoresSafeArea()
                
                VStack {
                    Text("Listening Game")
                        .font(AppTheme.Typography.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Coming soon!")
                        .font(AppTheme.Typography.title3)
                        .foregroundColor(.secondary)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Speaking Game

struct SpeakingGameView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.secondaryBackground
                    .ignoresSafeArea()
                
                VStack {
                    Text("Speaking Game")
                        .font(AppTheme.Typography.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Coming soon!")
                        .font(AppTheme.Typography.title3)
                        .foregroundColor(.secondary)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

