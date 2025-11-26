//
//  AutoVocabularyView.swift
//  JLearn
//
//  Automatically fetch level-based vocabulary & sentences from web APIs
//  and convert them into app-ready data formats.
//

import SwiftUI

struct AutoVocabularyView: View {
    @StateObject private var webDataService = WebDataService.shared
    @EnvironmentObject var learningDataService: LearningDataService
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedLevel: LearningLevel = .n5
    @State private var selectedContentType: AutoContentType = .all
    @State private var targetCount: Int = 100
    @State private var isGenerating = false
    @State private var statusMessage: String = ""
    @State private var autoResults: [WebDataService.SearchResult] = []
    @State private var exportContent: String = ""
    @State private var showingExportSheet = false
    @State private var showingAlert = false
    
    var newResultsCount: Int {
        autoResults.filter { !$0.alreadyExists }.count
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    Text("Auto Vocabulary")
                        .font(AppTheme.Typography.title)
                        .foregroundColor(.primary)
                    
                    Text("Select a JLPT level and let the app automatically search for useful vocabulary and example sentences for that level.")
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.mutedText)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Level Picker
                    Picker("Level", selection: $selectedLevel) {
                        ForEach(LearningLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    // Content Type Picker
                    Picker("Content Type", selection: $selectedContentType) {
                        ForEach(AutoContentType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    // Target Count Picker
                    HStack {
                        Text("Max items")
                            .font(AppTheme.Typography.body)
                        Spacer()
                        Picker("Max items", selection: $targetCount) {
                            Text("25").tag(25)
                            Text("50").tag(50)
                            Text("100").tag(100)
                            Text("200").tag(200)
                        }
                        .pickerStyle(.menu)
                    }
                    
                    // Generate Button
                    Button {
                        generateForSelectedLevel()
                    } label: {
                        HStack {
                            if isGenerating {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text(isGenerating ? "Generating..." : "Generate for \(selectedLevel.rawValue)")
                                .font(AppTheme.Typography.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.brandPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
                    }
                    .disabled(isGenerating)
                    
                    if !statusMessage.isEmpty {
                        Text(statusMessage)
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.white)
                
                // Results Info
                if !autoResults.isEmpty {
                    HStack {
                        Text("\(autoResults.count) total items")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if newResultsCount > 0 {
                            Text("\(newResultsCount) new")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(.green)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                }
                
                // Results List
                if autoResults.isEmpty && !isGenerating {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No auto-generated data yet")
                            .font(AppTheme.Typography.title)
                        Text("Choose a level and tap Generate to automatically search web data for this level. The app will convert results into flashcards and practice-ready content.")
                            .font(AppTheme.Typography.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(autoResults) { result in
                                SearchResultCard(
                                    result: result,
                                    isSelected: false,
                                    action: {}
                                )
                            }
                        }
                        .padding()
                    }
                }
                
                // Bottom Action Bar
                if !autoResults.isEmpty {
                    HStack {
                        Button {
                            if newResultsCount > 0 {
                                addAllNewToApp()
                            } else {
                                statusMessage = "All items already exist in your library. Try changing the level or content type, then tap Generate again."
                                showingAlert = true
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                Text(newResultsCount == 0 ? "No New Items" : "Add \(newResultsCount) to Library")
                                    .font(AppTheme.Typography.caption)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(newResultsCount == 0 ? Color.gray : AppTheme.brandPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 5, y: -2)
                }
            }
            .background(AppTheme.background)
            .navigationTitle("Auto Vocabulary")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingExportSheet) {
                ShareSheet(items: [exportContent])
            }
            .alert("Auto Vocabulary", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(statusMessage)
            }
            .onAppear {
                // Sync default level with the globally selected level
                selectedLevel = learningDataService.currentLevel
                AnalyticsService.shared.trackScreen("AutoVocabulary", screenClass: "AutoVocabularyView")
            }
        }
    }
    
    // MARK: - Actions
    
        private func generateForSelectedLevel() {
            isGenerating = true
            statusMessage = "Discovering up to \(targetCount) items for level \(selectedLevel.rawValue)..."
            autoResults = []
            
            Task {
                defer { isGenerating = false }
                
                // Check connectivity first to avoid repeated failing calls
                let isOnline = await NetworkMonitor.hasInternetConnection()
                guard isOnline else {
                    await MainActor.run {
                        self.statusMessage = "Device appears to be offline. Connect to the internet and try again."
                        self.showingAlert = true
                    }
                    return
                }
                
                // Use the JLPT-aware AutoVocabularyEngine which wraps WebDataService
                // and filters strictly by level + content type.
                let results = await AutoVocabularyEngine.shared.discoverVocabulary(
                    for: selectedLevel,
                    type: selectedContentType,
                    targetCount: targetCount
                )
                
                await MainActor.run {
                    self.autoResults = results
                    if results.isEmpty {
                        self.statusMessage = "No items discovered. Please try again with a different level or later."
                        self.showingAlert = true
                    } else {
                        self.statusMessage = "Found \(results.count) items for level \(selectedLevel.rawValue)."
                        AnalyticsService.shared.logEvent(.searchResult, parameters: [
                            "source": "auto_vocabulary",
                            "level": selectedLevel.rawValue,
                            "type": selectedContentType.rawValue,
                            "count": results.count
                        ])
                    }
                }
            }
        }
        
        /// Export all new results to JSON using the app's flashcard format.
        private func exportJSONForApp() {
            let jsonCategory = selectedContentType.jsonCategory
            let json = webDataService.exportToJSON(
                results: autoResults,
                level: selectedLevel.rawValue,
                category: jsonCategory
            )
        exportContent = json
        showingExportSheet = true
            statusMessage = "Exported \(newResultsCount) new items to JSON."
    }
    
    /// Convert all new results into flashcards and append them to in-app data.
    private func addAllNewToApp() {
        Task {
                let flashcards: [Flashcard]
                
                if selectedContentType == .all {
                    // When "All Types" is selected, classify each result into
                    // kanji / grammar / vocabulary based on its shape and POS tags.
                    flashcards = autoResults
                        .filter { !$0.alreadyExists }
                        .map { result in
                            let category = inferredCategory(for: result)
                            return Flashcard(
                                id: UUID().uuidString,
                                front: result.word,
                                back: result.reading,
                                reading: result.reading,
                                meaning: result.meanings.joined(separator: ", "),
                                level: result.jlptLevel ?? selectedLevel.rawValue,
                                category: category,
                                examples: [],
                                audioURL: nil,
                                isFavorite: false,
                                lastReviewed: nil,
                                nextReview: nil,
                                reviewCount: 0,
                                correctCount: 0
                            )
                        }
                } else {
                    let jsonCategory = selectedContentType.jsonCategory
                    flashcards = webDataService.convertToFlashcards(
                        results: autoResults,
                        level: selectedLevel.rawValue,
                        category: jsonCategory
                    )
                }
                
                do {
                    try await webDataService.saveToLocalLibrary(flashcards: flashcards)
                
                // Reload learning data so new items are available in practice views
                await learningDataService.loadLearningData()
                
                await MainActor.run {
                        self.statusMessage = "Added \(flashcards.count) new flashcards for level \(selectedLevel.rawValue) to your JSON library."
                    self.showingAlert = true
                }
            } catch {
                await MainActor.run {
                    self.statusMessage = "Failed to add new items: \(error.localizedDescription)"
                    self.showingAlert = true
                }
            }
        }
    }
}

    // MARK: - Auto Content Type
    
    /// Types of content that can be auto-generated from the web.
    enum AutoContentType: String, CaseIterable, Identifiable {
        case all
        case vocabulary
        case kanji
        case sentences
        case grammar
        
        var id: String { rawValue }
        
        var displayName: String {
            switch self {
            case .all: return "All Types"
            case .vocabulary: return "Vocabulary"
            case .kanji: return "Kanji"
            case .sentences: return "Sentences"
            case .grammar: return "Grammar"
            }
        }
        
        /// Category string used in JSON / flashcards.
        /// Defaults to `vocabulary` when nil (for `.all`).
        var jsonCategory: String {
            switch self {
            case .kanji:
                return "kanji"
            case .grammar:
                return "grammar"
            case .vocabulary, .sentences, .all:
                return "vocabulary"
            }
        }
    }
    
    /// Infer the best flashcard category for a given web result so that
    /// kanji, vocabulary and grammar are routed to the right practice mode.
    private func inferredCategory(for result: WebDataService.SearchResult) -> String {
        // Single-character Japanese entries -> kanji
        if result.word.count == 1 {
            return "kanji"
        }
        
        // Grammar-like entries based on parts-of-speech hints from Jisho
        let pos = result.partsOfSpeech.map { $0.lowercased() }
        let isGrammarLike = pos.contains(where: { tag in
            tag.contains("expression") ||
            tag.contains("auxiliary") ||
            tag.contains("particle") ||
            tag.contains("conjunction") ||
            tag.contains("grammar")
        })
        
        if isGrammarLike {
            return "grammar"
        }
        
        // Default bucket
        return "vocabulary"
    }
    
#Preview {
    AutoVocabularyView()
        .environmentObject(LearningDataService.shared)
}


