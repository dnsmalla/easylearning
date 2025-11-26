//
//  FlashcardViews.swift
//  JLearn
//
//  Flashcard system and views
//

import SwiftUI

// MARK: - Flashcards List View

struct FlashcardsListView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @State private var selectedCategory = "all"
    
    var filteredFlashcards: [Flashcard] {
        if selectedCategory == "all" {
            return learningDataService.flashcards
        } else if selectedCategory == "favorites" {
            return learningDataService.flashcards.filter { $0.isFavorite }
        } else {
            return learningDataService.flashcards.filter { $0.category == selectedCategory }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Level Indicator
                LevelIndicatorBar()
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                    .padding(.top, 8)
                
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterChip(title: "All", isSelected: selectedCategory == "all") {
                            selectedCategory = "all"
                        }
                        FilterChip(title: "Favorites", isSelected: selectedCategory == "favorites") {
                            selectedCategory = "favorites"
                        }
                        FilterChip(title: "Kanji", isSelected: selectedCategory == "kanji") {
                            selectedCategory = "kanji"
                        }
                        FilterChip(title: "Vocabulary", isSelected: selectedCategory == "vocabulary") {
                            selectedCategory = "vocabulary"
                        }
                    }
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                    .padding(.vertical, 12)
                }
                .background(Color.white)
                
                // Flashcards List
                if filteredFlashcards.isEmpty {
                    ProfessionalEmptyStateView(
                        icon: "rectangle.stack",
                        title: "No Flashcards",
                        message: "Add some flashcards to get started"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredFlashcards) { flashcard in
                                FlashcardListItem(flashcard: flashcard)
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(AppTheme.background)
            .navigationTitle("Flashcards")
            .onAppear {
                AnalyticsService.shared.trackScreen("Flashcards", screenClass: "FlashcardsListView")
            }
        }
    }
}

// MARK: - Filter Chip (using consolidated version from ReusableCards)

// MARK: - Flashcard List Item

struct FlashcardListItem: View {
    let flashcard: Flashcard
    @State private var showDetail = false
    
    var body: some View {
        Button {
            showDetail = true
        } label: {
            HStack(spacing: 16) {
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(flashcard.front)
                        .font(AppTheme.Typography.japaneseBody)
                        .foregroundColor(.primary)
                    
                    if let reading = flashcard.reading {
                        Text(reading)
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.mutedText)
                    }
                    
                    Text(flashcard.meaning)
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(AppTheme.mutedText)
                }
                
                Spacer()
                
                // Favorite Icon
                Image(systemName: flashcard.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(flashcard.isFavorite ? .red : AppTheme.mutedText)
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
        .sheet(isPresented: $showDetail) {
            FlashcardDetailView(flashcard: flashcard)
        }
    }
}

// MARK: - Flashcard View (for practice)

struct FlashcardView: View {
    let flashcard: Flashcard
    @Binding var showAnswer: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            // Front (Question)
            Text(flashcard.front)
                .font(AppTheme.Typography.japaneseTitle)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            
            // Answer (if shown)
            if showAnswer {
                Divider()
                
                VStack(spacing: 12) {
                    if let reading = flashcard.reading {
                        Text(reading)
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.mutedText)
                    }
                    
                    Text(flashcard.meaning)
                        .font(AppTheme.Typography.title3)
                        .foregroundColor(.primary)
                    
                    if let examples = flashcard.examples, !examples.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Examples:")
                                .font(AppTheme.Typography.caption)
                                .fontWeight(.semibold)
                            
                            ForEach(examples, id: \.self) { example in
                                Text(example)
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.mutedText)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                    }
                }
                .padding(.vertical, 20)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .frame(height: 400)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.largeCornerRadius))
        .shadow(
            color: AppTheme.Shadows.elevation3.color,
            radius: AppTheme.Shadows.elevation3.radius,
            y: AppTheme.Shadows.elevation3.y
        )
        .padding(.horizontal, AppTheme.Layout.horizontalPadding)
    }
}

// MARK: - Flashcard Detail View

struct FlashcardDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var learningDataService: LearningDataService
    let flashcard: Flashcard
    @StateObject private var audioService = AudioService.shared
    @State private var isFavorite: Bool
    
    init(flashcard: Flashcard) {
        self.flashcard = flashcard
        _isFavorite = State(initialValue: flashcard.isFavorite)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Main Content
                    VStack(spacing: 16) {
                        Text(flashcard.front)
                            .font(AppTheme.Typography.japaneseTitle)
                            .foregroundColor(.primary)
                        
                        if let reading = flashcard.reading {
                            Text(reading)
                                .font(AppTheme.Typography.title3)
                                .foregroundColor(AppTheme.mutedText)
                        }
                        
                        Divider()
                        
                        Text(flashcard.meaning)
                            .font(AppTheme.Typography.title3)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                    
                    // Examples
                    if let examples = flashcard.examples, !examples.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Examples")
                                .font(AppTheme.Typography.headline)
                            
                            ForEach(examples, id: \.self) { example in
                                Text(example)
                                    .font(AppTheme.Typography.body)
                                    .foregroundColor(AppTheme.mutedText)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(AppTheme.secondaryBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius))
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                    }
                    
                    // Stats
                    VStack(spacing: 16) {
                        HStack(spacing: 24) {
                            StatItem(title: "Reviews", value: "\(flashcard.reviewCount)")
                            StatItem(title: "Correct", value: "\(flashcard.correctCount)")
                            StatItem(title: "Accuracy", value: String(format: "%.0f%%", flashcard.accuracy * 100))
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                    
                    // Audio Button
                    if flashcard.audioURL != nil {
                        Button {
                            playAudio()
                        } label: {
                            HStack {
                                Image(systemName: audioService.isPlaying ? "stop.fill" : "speaker.wave.2.fill")
                                Text(audioService.isPlaying ? "Playing..." : "Play Audio")
                            }
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(AppTheme.listeningColor)
                            .clipShape(Capsule())
                        }
                    }
                }
                .padding()
            }
            .background(AppTheme.background)
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isFavorite.toggle()
                        Haptics.selection()
                        
                        // Update flashcard in service
                        Task {
                            var updatedCard = flashcard
                            updatedCard.isFavorite = isFavorite
                            try? await learningDataService.updateFlashcard(updatedCard)
                        }
                    } label: {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? .red : .primary)
                    }
                }
            }
        }
    }
    
    private func playAudio() {
        guard let audioURL = flashcard.audioURL else { return }
        
        Task {
            do {
                try await audioService.playAudio(from: audioURL)
            } catch {
                print("Failed to play audio: \(error)")
            }
        }
    }
}

// MARK: - Stat Item

struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(AppTheme.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.mutedText)
        }
        .frame(maxWidth: .infinity)
    }
}

