//
//  WebSearchView.swift
//  JLearn
//
//  View for searching and adding Japanese learning content from web
//

import SwiftUI
import UIKit

struct WebSearchView: View {
    @StateObject private var webDataService = WebDataService.shared
    @EnvironmentObject var learningDataService: LearningDataService
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchQuery = ""
    @State private var selectedLevel: LearningLevel = .n5
    @State private var selectedResults: Set<UUID> = []
    @State private var showingSaveAlert = false
    @State private var saveMessage = ""
    @State private var showingExportSheet = false
    @State private var exportContent = ""
    
    var newResultsCount: Int {
        webDataService.searchResults.filter { !$0.alreadyExists }.count
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Header
                VStack(spacing: 16) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search Japanese words...", text: $searchQuery)
                            .textFieldStyle(.plain)
                            .onSubmit {
                                performSearch()
                            }
                        
                        if !searchQuery.isEmpty {
                            Button {
                                searchQuery = ""
                                webDataService.searchResults = []
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    // Level Picker
                    Picker("Level", selection: $selectedLevel) {
                        ForEach(LearningLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    // Search Button
                    Button {
                        performSearch()
                    } label: {
                        HStack {
                            if webDataService.isSearching {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text(webDataService.isSearching ? "Searching..." : "Search")
                                .font(AppTheme.Typography.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.brandPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
                    }
                    .disabled(searchQuery.isEmpty || webDataService.isSearching)
                }
                .padding()
                .background(Color.white)
                
                // Results Info
                if !webDataService.searchResults.isEmpty {
                    HStack {
                        Text("\(webDataService.searchResults.count) results")
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
                if webDataService.searchResults.isEmpty && !webDataService.isSearching {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("Search for Japanese Words")
                            .font(AppTheme.Typography.title)
                        Text("Find and add new vocabulary to your learning data")
                            .font(AppTheme.Typography.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(webDataService.searchResults) { result in
                                SearchResultCard(
                                    result: result,
                                    isSelected: selectedResults.contains(result.id)
                                ) {
                                    toggleSelection(result.id)
                                }
                            }
                        }
                        .padding()
                    }
                }
                
                // Bottom Action Bar
                if !webDataService.searchResults.isEmpty {
                    HStack(spacing: 12) {
                        // Export to CSV
                        Button {
                            exportToCSV()
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export CSV")
                                    .font(AppTheme.Typography.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        // Export to JSON
                        Button {
                            exportToJSON()
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "curlybraces.square")
                                Text("Export JSON")
                                    .font(AppTheme.Typography.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        // Add Selected
                        Button {
                            addSelectedToFirebase()
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "plus.circle.fill")
                                Text("Add (\(selectedResults.count))")
                                    .font(AppTheme.Typography.caption)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedResults.isEmpty ? Color.gray : AppTheme.brandPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .disabled(selectedResults.isEmpty)
                    }
                    .padding()
                    .background(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 5, y: -2)
                }
            }
            .background(AppTheme.background)
            .navigationTitle("Web Search")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Sync the default JLPT level with the global selection
                selectedLevel = learningDataService.currentLevel
                AnalyticsService.shared.trackScreen("WebSearch", screenClass: "WebSearchView")
            }
            .alert("Save Results", isPresented: $showingSaveAlert) {
                Button("OK") { }
            } message: {
                Text(saveMessage)
            }
            .sheet(isPresented: $showingExportSheet) {
                ShareSheet(items: [exportContent])
            }
        }
    }
    
    // MARK: - Actions
    
    private func performSearch() {
        Task {
            do {
                _ = try await webDataService.searchWords(query: searchQuery, level: selectedLevel.rawValue)
                
                AnalyticsService.shared.logEvent(.search, parameters: [
                    "query": searchQuery,
                    "level": selectedLevel.rawValue
                ])
                
                // Auto-select all new results
                selectedResults = Set(webDataService.searchResults
                    .filter { !$0.alreadyExists }
                    .map { $0.id })
            } catch {
                saveMessage = "Search failed: \(error.localizedDescription)"
                showingSaveAlert = true
            }
        }
    }
    
    private func toggleSelection(_ id: UUID) {
        if selectedResults.contains(id) {
            selectedResults.remove(id)
        } else {
            selectedResults.insert(id)
        }
    }
    
    private func addSelectedToFirebase() { // now saves to local JSON library
        Task {
            let selectedResultItems = webDataService.searchResults.filter { selectedResults.contains($0.id) }
            let flashcards = webDataService.convertToFlashcards(results: selectedResultItems, level: selectedLevel.rawValue)
            
            do {
                try await webDataService.saveToLocalLibrary(flashcards: flashcards)
                
                // Reload learning data
                await learningDataService.loadLearningData()
                
                saveMessage = "Successfully added \(flashcards.count) new words to your library!"
                showingSaveAlert = true
                
                AnalyticsService.shared.logEvent(.searchResult, parameters: [
                    "added_count": flashcards.count,
                    "level": selectedLevel.rawValue
                ])
                
                // Clear selections
                selectedResults.removeAll()
            } catch {
                saveMessage = "Failed to save: \(error.localizedDescription)"
                showingSaveAlert = true
            }
        }
    }
    
    private func exportToCSV() {
        let selectedResultItems = selectedResults.isEmpty ?
            webDataService.searchResults :
            webDataService.searchResults.filter { selectedResults.contains($0.id) }
        
        exportContent = webDataService.exportToCSV(results: selectedResultItems, level: selectedLevel.rawValue)
        showingExportSheet = true
    }
    
    private func exportToJSON() {
        let selectedResultItems = selectedResults.isEmpty ?
            webDataService.searchResults :
            webDataService.searchResults.filter { selectedResults.contains($0.id) }
        
        exportContent = webDataService.exportToJSON(results: selectedResultItems, level: selectedLevel.rawValue)
        showingExportSheet = true
    }
}

// MARK: - Search Result Card

struct SearchResultCard: View {
    let result: WebDataService.SearchResult
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Selection Indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .green : .gray)
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    // Word and Reading
                    HStack {
                        Text(result.word)
                            .font(AppTheme.Typography.japaneseTitle)
                            .foregroundColor(.primary)
                        
                        Text("(\(result.reading))")
                            .font(AppTheme.Typography.body)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // Status Badge
                        if result.alreadyExists {
                            Text("EXISTS")
                                .font(AppTheme.Typography.caption2)
                                .foregroundColor(.orange)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        } else if result.isCommon {
                            Text("COMMON")
                                .font(AppTheme.Typography.caption2)
                                .foregroundColor(.green)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                    
                    // Meanings
                    Text(result.meanings.joined(separator: ", "))
                        .font(AppTheme.Typography.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    // JLPT Level
                    if let jlpt = result.jlptLevel {
                        Text(jlpt)
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(AppTheme.brandPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius)
                    .stroke(isSelected ? .green : AppTheme.separator, lineWidth: isSelected ? 2 : 1)
            )
            .shadow(
                color: AppTheme.Shadows.elevation1.color,
                radius: AppTheme.Shadows.elevation1.radius,
                y: AppTheme.Shadows.elevation1.y
            )
        }
        .disabled(result.alreadyExists)
        .opacity(result.alreadyExists ? 0.6 : 1.0)
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    WebSearchView()
        .environmentObject(LearningDataService.shared)
}

