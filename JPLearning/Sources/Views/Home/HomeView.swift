//
//  HomeView.swift
//  JLearn
//
//  Main home screen with level selection and study materials
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @EnvironmentObject var authService: AuthService
    @State private var showKanaPractice = false
    @State private var refreshID = UUID() // Force view refresh when level changes
    
    // MARK: - Today's Stats
    
    private var todayVocabDue: Int {
        let now = Date()
        return learningDataService.flashcards.filter {
            $0.category == "vocabulary" && (($0.nextReview ?? now) <= now)
        }.count
    }
    
    private var todayKanjiDue: Int {
        // Kanji are stored separately in learningDataService.kanji
        // For now, show the total count as "due" since they don't have review dates
        return learningDataService.kanji.count
    }
    
    private var todayGrammarCount: Int {
        learningDataService.grammarPoints.count
    }
    
    // MARK: - Actual Data Counts
    
    private var actualKanjiCount: Int {
        learningDataService.kanji.count
    }
    
    private var actualVocabularyCount: Int {
        learningDataService.flashcards.filter { $0.category == "vocabulary" }.count
    }
    
    private var actualGrammarPointsCount: Int {
        learningDataService.grammarPoints.count
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Solid background behind status bar (clock, Wi‑Fi)
                Color.white
                    .ignoresSafeArea(edges: .top)
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Header Section
                        headerSection
                        
                        // Level Selection
                        levelSelectionSection
                        
                        // Today's Plan
                        todaysPlanSection
                        
                        // Study materials
                        studyMaterialsSection
                        
                        // Recommended tools
                        recommendedToolsSection
                            .padding(.bottom, 32)
                    }
                }
            }
            .background(AppTheme.background)
            .navigationBarHidden(true)
            .sheet(isPresented: $showKanaPractice) {
                KanaPracticeView()
            }
            .onAppear {
                AnalyticsService.shared.trackScreen("Home", screenClass: "HomeView")
            }
            .onChange(of: learningDataService.currentLevel) { newLevel in
                AppLogger.info("🏠 [HOME VIEW] Level changed to \(newLevel.rawValue) - updating counts")
                let vocabCount = learningDataService.flashcards.filter { $0.category == "vocabulary" }.count
                AppLogger.info("   Vocab: \(vocabCount)")
                AppLogger.info("   Kanji: \(learningDataService.kanji.count)")
                AppLogger.info("   Grammar: \(learningDataService.grammarPoints.count)")
                refreshID = UUID() // Force view refresh
            }
            .id(refreshID) // Attach ID to force view recreation when it changes
        }
    }
    
    // MARK: - Subsections
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Japanese Learning")
                    .font(AppTheme.Typography.largeTitle)
                    .foregroundColor(.primary)
                
                Spacer()
                
                NavigationLink {
                    ProfileView()
                } label: {
                    Circle()
                        .fill(AppTheme.brandPrimary.opacity(0.1))
                        .frame(width: 44, height: 44)
                        .overlay {
                            Image(systemName: "person.fill")
                                .font(.system(size: 20))
                                .foregroundColor(AppTheme.brandPrimary)
                        }
                }
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("New to Japanese?")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.primary)
                    
                    Text("Start with Kana practice")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.mutedText)
                }
                
                Spacer()
                
                Button {
                    showKanaPractice = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "book.fill")
                        Text("Practice")
                    }
                    .font(AppTheme.Typography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(AppTheme.brandPrimary)
                    .clipShape(Capsule())
                }
            }
            .padding()
            .background(AppTheme.brandPrimary.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius)
                    .stroke(AppTheme.brandPrimary.opacity(0.1), lineWidth: 1)
            )
        }
        .padding(.horizontal, AppTheme.Layout.horizontalPadding)
        .padding(.top, 8)
        .padding(.bottom, 24)
        .background(Color.white)
    }
    
    private var levelSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Level Selection")
                .font(AppTheme.Typography.title2)
                .foregroundColor(.primary)
                .padding(.horizontal, AppTheme.Layout.horizontalPadding)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(LearningLevel.allCases, id: \.self) { level in
                        LevelCard(
                            level: level,
                            isSelected: learningDataService.currentLevel == level
                        ) {
                            Task {
                                await learningDataService.setLevel(level)
                                Haptics.selection()
                            }
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Layout.horizontalPadding)
            }
        }
        .padding(.vertical, 24)
    }
    
    private var todaysPlanSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Plan")
                    .font(AppTheme.Typography.title2)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("Level \(learningDataService.currentLevel.rawValue)")
                    .font(AppTheme.Typography.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.brandPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppTheme.brandPrimary.opacity(0.08))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, AppTheme.Layout.horizontalPadding)
            
            HStack(spacing: 12) {
                NavigationLink {
                    VocabularyPracticeView()
                } label: {
                    TodayStatCard(
                        title: "Vocab Review",
                        value: todayVocabDue,
                        subtitle: "due cards",
                        color: AppTheme.vocabularyColor
                    )
                }
                
                NavigationLink {
                    KanjiPracticeView()
                } label: {
                    TodayStatCard(
                        title: "Kanji Review",
                        value: todayKanjiDue,
                        subtitle: "due cards",
                        color: AppTheme.kanjiColor
                    )
                }
                
                NavigationLink {
                    GrammarPracticeView()
                } label: {
                    TodayStatCard(
                        title: "Grammar",
                        value: todayGrammarCount,
                        subtitle: "points",
                        color: AppTheme.grammarColor
                    )
                }
            }
            .padding(.horizontal, AppTheme.Layout.horizontalPadding)
        }
        .padding(.bottom, 24)
    }
    
    private var studyMaterialsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Study Materials")
                    .font(AppTheme.Typography.title2)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("Level \(learningDataService.currentLevel.rawValue)")
                    .font(AppTheme.Typography.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.brandPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppTheme.brandPrimary.opacity(0.1))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, AppTheme.Layout.horizontalPadding)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                StudyMaterialCard(
                    title: "Kanji",
                    icon: "character.textbox",
                    color: AppTheme.kanjiColor,
                    count: "\(actualKanjiCount) characters",
                    destination: AnyView(KanjiPracticeView())
                )
                
                StudyMaterialCard(
                    title: "Vocabulary",
                    icon: "book.closed.fill",
                    color: AppTheme.vocabularyColor,
                    count: "\(actualVocabularyCount) words",
                    destination: AnyView(VocabularyPracticeView())
                )
                
                StudyMaterialCard(
                    title: "Grammar",
                    icon: "text.book.closed.fill",
                    color: AppTheme.grammarColor,
                    count: "\(actualGrammarPointsCount) points",
                    destination: AnyView(GrammarPracticeView())
                )
                
                StudyMaterialCard(
                    title: "Listening",
                    icon: "headphones",
                    color: AppTheme.listeningColor,
                    count: "30 exercises",
                    destination: AnyView(ListeningPracticeView())
                )
            }
            .padding(.horizontal, AppTheme.Layout.horizontalPadding)
        }
        .padding(.bottom, 24)
    }
    
    private var recommendedToolsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recommended Tools")
                    .font(AppTheme.Typography.title2)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, AppTheme.Layout.horizontalPadding)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                StudyMaterialCard(
                    title: "Auto Vocabulary",
                    icon: "wand.and.stars",
                    color: AppTheme.vocabularyColor,
                    count: "Generate level-based content",
                    destination: AnyView(AutoVocabularyView())
                )
                
                StudyMaterialCard(
                    title: "Web Search",
                    icon: "magnifyingglass.circle.fill",
                    color: AppTheme.brandSecondary,
                    count: "Search & import from web",
                    destination: AnyView(WebSearchView())
                )
                
                StudyMaterialCard(
                    title: "Translation",
                    icon: "text.bubble.fill",
                    color: AppTheme.listeningColor,
                    count: "Camera, photo & text",
                    destination: AnyView(TranslationView())
                )
            }
            .padding(.horizontal, AppTheme.Layout.horizontalPadding)
        }
    }
}

// MARK: - Level Card

struct LevelCard: View {
    let level: LearningLevel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Level Badge
                Text(level.rawValue)
                    .font(AppTheme.Typography.headline)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : AppTheme.brandPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(isSelected ? AppTheme.brandPrimary : AppTheme.brandPrimary.opacity(0.1))
                    .clipShape(Capsule())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.title)
                        .font(AppTheme.Typography.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(level.description)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.mutedText)
                }
            }
            .frame(width: 160)
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius)
                    .stroke(isSelected ? AppTheme.brandPrimary : Color.clear, lineWidth: 2)
            )
            .shadow(
                color: isSelected ? AppTheme.brandPrimary.opacity(0.2) : AppTheme.Shadows.elevation2.color,
                radius: AppTheme.Shadows.elevation2.radius,
                y: AppTheme.Shadows.elevation2.y
            )
        }
    }
}

// MARK: - Study Material Card

struct StudyMaterialCard: View {
    let title: String
    let icon: String
    let color: Color
    let count: String
    let destination: AnyView
    
    var body: some View {
        NavigationLink {
            destination
        } label: {
            VStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.primary)
                    
                    Text(count)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.mutedText)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
            .shadow(
                color: AppTheme.Shadows.elevation2.color,
                radius: AppTheme.Shadows.elevation2.radius,
                y: AppTheme.Shadows.elevation2.y
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Today Stat Card

private struct TodayStatCard: View {
    let title: String
    let value: Int
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Top: main number
            Text("\(value)")
                .font(AppTheme.Typography.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            // Bottom: description text
            Text("\(title) \(subtitle)")
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.mutedText)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
        .shadow(
            color: AppTheme.Shadows.elevation1.color,
            radius: AppTheme.Shadows.elevation1.radius,
            y: AppTheme.Shadows.elevation1.y
        )
    }
}

