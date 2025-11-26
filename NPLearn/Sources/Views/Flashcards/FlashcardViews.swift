//
//  FlashcardViews.swift
//  NPLearn
//
//  Flashcard system and views matching JLearn structure
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
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterChip(title: "All", isSelected: selectedCategory == "all") {
                            selectedCategory = "all"
                            Haptics.selection()
                        }
                        FilterChip(title: "Favorites", isSelected: selectedCategory == "favorites") {
                            selectedCategory = "favorites"
                            Haptics.selection()
                        }
                        FilterChip(title: "Vocabulary", isSelected: selectedCategory == "vocabulary") {
                            selectedCategory = "vocabulary"
                            Haptics.selection()
                        }
                        FilterChip(title: "Grammar", isSelected: selectedCategory == "grammar") {
                            selectedCategory = "grammar"
                            Haptics.selection()
                        }
                    }
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                    .padding(.vertical, 12)
                }
                .background(Color.white)
                
                // Flashcards List
                if filteredFlashcards.isEmpty {
                    emptyState
                } else {
                    flashcardsList
                }
            }
            .background(AppTheme.background)
            .navigationTitle("Flashcards")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        FlashcardStudyModeView()
                    } label: {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.brandPrimary)
                    }
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.stack")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No Flashcards")
                .font(AppTheme.Typography.title)
            Text("Add some flashcards to get started")
                .font(AppTheme.Typography.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var flashcardsList: some View {
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

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.Typography.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? AppTheme.brandPrimary : AppTheme.secondaryBackground)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Flashcard List Item

struct FlashcardListItem: View {
    let flashcard: Flashcard
    @EnvironmentObject var learningDataService: LearningDataService
    @State private var isFlipped = false
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isFlipped.toggle()
            }
            Haptics.light()
        } label: {
            VStack(spacing: 16) {
                // Front/Back Content
                if !isFlipped {
                    // Front (Nepali)
                    VStack(spacing: 8) {
                        Text(flashcard.front)
                            .font(AppTheme.Typography.nepaliDisplay)
                            .foregroundColor(AppTheme.brandPrimary)
                        
                        if let romanization = flashcard.romanization {
                            Text(romanization)
                                .font(AppTheme.Typography.romanization)
                                .foregroundColor(AppTheme.mutedText)
                        }
                    }
                } else {
                    // Back (English)
                    VStack(spacing: 8) {
                        Text(flashcard.back)
                            .font(AppTheme.Typography.title2)
                            .foregroundColor(.primary)
                        
                        if let examples = flashcard.examples, let first = examples.first {
                            Text(first)
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.mutedText)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                
                // Category Badge
                Text(flashcard.category)
                    .font(AppTheme.Typography.caption2)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(categoryColor(flashcard.category))
                    .clipShape(Capsule())
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius)
                    .stroke(AppTheme.brandPrimary.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .overlay(alignment: .topTrailing) {
            // Favorite Button
            Button {
                Task {
                    if flashcard.isFavorite {
                        try? await learningDataService.unsaveVocabulary(flashcard.id)
                    } else {
                        try? await learningDataService.saveVocabulary(flashcard.id)
                    }
                    Haptics.success()
                }
            } label: {
                Image(systemName: flashcard.isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 20))
                    .foregroundColor(flashcard.isFavorite ? .red : .gray)
                    .padding(12)
            }
        }
    }
    
    private func categoryColor(_ category: String) -> Color {
        switch category.lowercased() {
        case "vocabulary": return AppTheme.vocabularyColor
        case "grammar": return AppTheme.grammarColor
        default: return AppTheme.brandPrimary
        }
    }
}

// MARK: - Flashcard Study Mode View

struct FlashcardStudyModeView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @Environment(\.dismiss) var dismiss
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var studiedCards: Set<String> = []
    
    var body: some View {
        VStack {
            if learningDataService.flashcards.isEmpty {
                EmptyFlashcardsView()
            } else if currentIndex < learningDataService.flashcards.count {
                studyView
            } else {
                completionView
            }
        }
        .navigationTitle("Study Mode")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
    
    private var studyView: some View {
        let card = learningDataService.flashcards[currentIndex]
        
        return VStack(spacing: 32) {
            // Progress
            VStack(spacing: 12) {
                Text("Card \(currentIndex + 1) of \(learningDataService.flashcards.count)")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.mutedText)
                
                ProgressView(value: Double(currentIndex + 1), total: Double(learningDataService.flashcards.count))
                    .tint(AppTheme.brandPrimary)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Flashcard
            Button {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    isFlipped.toggle()
                }
                Haptics.light()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 20, y: 10)
                    
                    VStack(spacing: 24) {
                        if !isFlipped {
                            // Front
                            VStack(spacing: 12) {
                                Text(card.front)
                                    .font(AppTheme.Typography.nepaliDisplay)
                                    .foregroundColor(AppTheme.brandPrimary)
                                
                                if let romanization = card.romanization {
                                    Text(romanization)
                                        .font(AppTheme.Typography.romanization)
                                        .foregroundColor(AppTheme.mutedText)
                                }
                            }
                        } else {
                            // Back
                            VStack(spacing: 12) {
                                Text(card.back)
                                    .font(AppTheme.Typography.title)
                                    .foregroundColor(.primary)
                                
                                if let examples = card.examples, let first = examples.first {
                                    Text(first)
                                        .font(AppTheme.Typography.body)
                                        .foregroundColor(AppTheme.mutedText)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        
                        Text(isFlipped ? "Tap to see Nepali" : "Tap to see meaning")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.mutedText)
                    }
                    .padding(40)
                }
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )
            }
            .frame(height: 400)
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Navigation Buttons
            HStack(spacing: 16) {
                if currentIndex > 0 {
                    Button {
                        currentIndex -= 1
                        isFlipped = false
                        Haptics.light()
                    } label: {
                        Label("Previous", systemImage: "chevron.left")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.brandPrimary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.brandPrimary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                
                Button {
                    studiedCards.insert(card.id)
                    if currentIndex < learningDataService.flashcards.count - 1 {
                        currentIndex += 1
                        isFlipped = false
                    } else {
                        currentIndex += 1
                    }
                    Haptics.success()
                } label: {
                    Label(currentIndex < learningDataService.flashcards.count - 1 ? "Next" : "Finish", 
                          systemImage: "chevron.right")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.brandPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
    
    private var completionView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(AppTheme.success)
            
            Text("Great Job!")
                .font(AppTheme.Typography.largeTitle)
            
            Text("You've studied all \(learningDataService.flashcards.count) flashcards")
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.mutedText)
            
            Button {
                dismiss()
            } label: {
                Text("Done")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.brandPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 48)
        }
    }
}

// MARK: - Empty Flashcards View

struct EmptyFlashcardsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.stack")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.mutedText)
            
            Text("No Flashcards Yet")
                .font(AppTheme.Typography.title)
            
            Text("Start learning and flashcards will appear here")
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.mutedText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

#Preview {
    NavigationStack {
        FlashcardsListView()
            .environmentObject(LearningDataService.shared)
    }
}
