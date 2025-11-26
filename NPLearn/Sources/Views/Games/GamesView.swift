//
//  GamesView.swift
//  NPLearn
//
//  Interactive learning games matching JLearn structure
//

import SwiftUI

struct GamesView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Learning Games")
                            .font(AppTheme.Typography.largeTitle)
                        
                        Text("Make learning fun and interactive")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.mutedText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                    
                    // Games Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        GameCard(
                            title: "Daily Quest",
                            icon: "calendar.badge.checkmark",
                            color: .blue,
                            description: "Complete daily challenges",
                            destination: AnyView(DailyQuestView())
                        )
                        
                        GameCard(
                            title: "Word Match",
                            icon: "square.grid.2x2",
                            color: .green,
                            description: "Match words with meanings",
                            destination: AnyView(WordMatchView())
                        )
                        
                        GameCard(
                            title: "Time Attack",
                            icon: "timer",
                            color: .orange,
                            description: "Answer questions quickly",
                            destination: AnyView(TimeAttackView())
                        )
                        
                        GameCard(
                            title: "Sentence Builder",
                            icon: "text.alignleft",
                            color: .purple,
                            description: "Build correct sentences",
                            destination: AnyView(SentenceBuilderView())
                        )
                        
                        GameCard(
                            title: "Quick Quiz",
                            icon: "questionmark.circle",
                            color: .red,
                            description: "Test your knowledge",
                            destination: AnyView(QuickQuizView())
                        )
                        
                        GameCard(
                            title: "Flashcard Sprint",
                            icon: "bolt.fill",
                            color: .yellow,
                            description: "Speed flashcard practice",
                            destination: AnyView(FlashcardSprintView())
                        )
                    }
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                }
                .padding(.vertical, 24)
            }
            .background(AppTheme.background)
        }
    }
}

// MARK: - Game Card

struct GameCard: View {
    let title: String
    let icon: String
    let color: Color
    let description: String
    let destination: AnyView
    
    var body: some View {
        NavigationLink {
            destination
        } label: {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: icon)
                        .font(.system(size: 32))
                        .foregroundColor(color)
                }
                
                VStack(spacing: 6) {
                    Text(title)
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(description)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.mutedText)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, 12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
            .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    GamesView()
}
