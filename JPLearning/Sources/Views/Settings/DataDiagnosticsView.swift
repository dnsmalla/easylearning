//
//  DataDiagnosticsView.swift
//  JLearn
//
//  Diagnostics view to help debug data loading issues
//

import SwiftUI

struct DataDiagnosticsView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @State private var diagnosticsText = "Loading diagnostics..."
    @State private var isRefreshing = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Data Diagnostics")
                    .font(.title.bold())
                    .padding(.bottom)
                
                // Current Level
                diagnosticSection(
                    title: "Current Level",
                    content: learningDataService.currentLevel.rawValue
                )
                
                // Flashcard Statistics
                diagnosticSection(
                    title: "Flashcard Statistics",
                    content: """
                    Total: \(learningDataService.flashcards.count)
                    Vocabulary: \(learningDataService.flashcards.filter { $0.category == "vocabulary" }.count)
                    Kanji: \(learningDataService.flashcards.filter { $0.category == "kanji" }.count)
                    """
                )
                
                // Grammar Statistics
                diagnosticSection(
                    title: "Grammar Statistics",
                    content: "Total: \(learningDataService.grammarPoints.count)"
                )
                
                // Sample Flashcards
                if !learningDataService.flashcards.isEmpty {
                    diagnosticSection(
                        title: "Sample Flashcards (first 3)",
                        content: learningDataService.flashcards.prefix(3).map { card in
                            "\(card.category): \(card.front) = \(card.meaning)"
                        }.joined(separator: "\n")
                    )
                }
                
                // Bundle Check
                diagnosticSection(
                    title: "Bundle Resource Check",
                    content: checkBundleResources()
                )
                
                // Force Reload Button
                Button {
                    forceReloadData()
                } label: {
                    HStack {
                        if isRefreshing {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                        Text("Force Reload Data")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.brandPrimary)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isRefreshing)
                
                // Load from Bundle Button
                Button {
                    testBundleLoading()
                } label: {
                    HStack {
                        Image(systemName: "doc.text")
                        Text("Test Bundle Loading")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.accentColor)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .background(AppTheme.background)
        .navigationTitle("Diagnostics")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func diagnosticSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppTheme.brandPrimary)
            
            Text(content)
                .font(.body.monospaced())
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    private func checkBundleResources() -> String {
        var results: [String] = []
        
        for level in LearningLevel.allCases {
            let fileName = "japanese_learning_data_\(level.rawValue.lowercased())_jisho"
            if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
                results.append("✅ \(level.rawValue): Found at \(url.lastPathComponent)")
                
                // Try to load and parse
                if let data = try? Data(contentsOf: url) {
                    results.append("   Size: \(data.count) bytes")
                    
                    // Try to decode
                    if let json = try? JSONDecoder().decode(LearningDataFile.self, from: data) {
                        results.append("   Flashcards: \(json.flashcards.count)")
                        results.append("   Grammar: \(json.grammar.count)")
                        results.append("   Practice: \(json.practice.count)")
                        results.append("   Kanji: \(json.flashcards.filter { $0.category == "kanji" }.count)")
                    } else {
                        results.append("   ❌ Failed to decode JSON")
                    }
                } else {
                    results.append("   ❌ Failed to read data")
                }
            } else {
                results.append("❌ \(level.rawValue): NOT FOUND")
            }
        }
        
        return results.joined(separator: "\n")
    }
    
    private func forceReloadData() {
        isRefreshing = true
        
        Task {
            await learningDataService.loadLearningData()
            
            await MainActor.run {
                isRefreshing = false
            }
        }
    }
    
    private func testBundleLoading() {
        Task {
            let level = learningDataService.currentLevel
            let fileName = "japanese_learning_data_\(level.rawValue.lowercased())_jisho"
            
            if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
                do {
                    let data = try Data(contentsOf: url)
                    let json = try JSONDecoder().decode(LearningDataFile.self, from: data)
                    
                    let kanjiCount = json.flashcards.filter { $0.category == "kanji" }.count
                    let vocabCount = json.flashcards.filter { $0.category == "vocabulary" }.count
                    
                    await MainActor.run {
                        diagnosticsText = """
                        ✅ Successfully loaded from bundle:
                        - Total Flashcards: \(json.flashcards.count)
                        - Kanji: \(kanjiCount)
                        - Vocabulary: \(vocabCount)
                        - Grammar: \(json.grammar.count)
                        - Practice: \(json.practice.count)
                        
                        The bundle file IS working correctly!
                        If kanji still doesn't show, check LearningDataService.
                        """
                    }
                } catch {
                    await MainActor.run {
                        diagnosticsText = "❌ Error: \(error.localizedDescription)"
                    }
                }
            } else {
                await MainActor.run {
                    diagnosticsText = "❌ Bundle resource not found for \(level.rawValue)"
                }
            }
        }
    }
}

// Helper struct to decode the JSON structure
struct LearningDataFile: Codable {
    let flashcards: [Flashcard]
    let grammar: [GrammarPoint]
    let practice: [PracticeQuestion]
}

#Preview {
    NavigationStack {
        DataDiagnosticsView()
            .environmentObject(LearningDataService.shared)
    }
}

