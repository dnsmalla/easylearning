//
//  HowToUseView.swift
//  NPLearn
//
//  Step-by-step guide on how to use the app
//

import SwiftUI

// MARK: - How to Use View

struct HowToUseView: View {
    @State private var currentPage = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Hero Section
                VStack(spacing: 16) {
                    Image(systemName: "book.circle.fill")
                        .font(.system(size: 70))
                        .foregroundColor(AppTheme.brandPrimary)
                    
                    Text("How to Use NPLearn")
                        .font(AppTheme.Typography.largeTitle)
                    
                    Text("Your complete guide to mastering Nepali")
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.mutedText)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 20)
                
                // Quick Start
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeaderView(
                        icon: "flag.checkered.circle.fill",
                        title: "Quick Start",
                        subtitle: "Get started in 3 easy steps"
                    )
                    
                    VStack(spacing: 12) {
                        QuickStartStep(
                            number: 1,
                            title: "Choose Your Level",
                            description: "Select Beginner, Intermediate, or Advanced based on your current knowledge",
                            icon: "1.circle.fill",
                            color: AppTheme.vocabularyColor
                        )
                        
                        QuickStartStep(
                            number: 2,
                            title: "Pick a Category",
                            description: "Start with Vocabulary, Grammar, Listening, Speaking, Writing, or Reading",
                            icon: "2.circle.fill",
                            color: AppTheme.grammarColor
                        )
                        
                        QuickStartStep(
                            number: 3,
                            title: "Start Learning!",
                            description: "Complete lessons, practice exercises, and track your progress",
                            icon: "3.circle.fill",
                            color: AppTheme.brandPrimary
                        )
                    }
                }
                .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                
                // Navigation Guide
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeaderView(
                        icon: "map.circle.fill",
                        title: "Navigation Guide",
                        subtitle: "Explore the app's main sections"
                    )
                    
                    VStack(spacing: 12) {
                        NavigationTabCard(
                            icon: "house.fill",
                            title: "Home",
                            description: "Select your level, access Devanagari practice, and browse study materials by category",
                            color: AppTheme.brandPrimary
                        )
                        
                        NavigationTabCard(
                            icon: "book.fill",
                            title: "Practice",
                            description: "Practice all six skills: Vocabulary, Grammar, Listening, Speaking, Writing, and Reading",
                            color: AppTheme.vocabularyColor
                        )
                        
                        NavigationTabCard(
                            icon: "rectangle.stack.fill",
                            title: "Flashcards",
                            description: "Review words with spaced repetition. Mark cards as 'Got it' or 'Need review' to optimize learning",
                            color: AppTheme.grammarColor
                        )
                        
                        NavigationTabCard(
                            icon: "gamecontroller.fill",
                            title: "Games",
                            description: "Play fun games like Word Match, Sentence Builder, and Quick Quiz to reinforce learning",
                            color: AppTheme.listeningColor
                        )
                        
                        NavigationTabCard(
                            icon: "person.fill",
                            title: "Profile",
                            description: "View your progress, manage settings, check achievements, and access help & support",
                            color: AppTheme.speakingColor
                        )
                    }
                }
                .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                
                // Feature Tutorials
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeaderView(
                        icon: "lightbulb.circle.fill",
                        title: "Feature Tutorials",
                        subtitle: "Master each learning tool"
                    )
                    
                    VStack(spacing: 12) {
                        FeatureTutorialCard(
                            icon: "textformat.abc",
                            title: "Devanagari Practice",
                            steps: [
                                "Tap 'New to Nepali?' on Home screen",
                                "Choose Vowels, Consonants, or Numerals",
                                "Tap any character to hear pronunciation",
                                "Go to Practice tab for writing practice",
                                "Draw characters on the canvas",
                                "Use 'Clear' to try again, 'Next' for new character"
                            ],
                            color: AppTheme.vocabularyColor
                        )
                        
                        FeatureTutorialCard(
                            icon: "rectangle.stack",
                            title: "Using Flashcards",
                            steps: [
                                "Go to Flashcards tab",
                                "Tap a flashcard to flip and see meaning",
                                "Think about whether you know the word",
                                "Swipe or tap 'Got it' if you know it",
                                "Tap 'Need review' if you need more practice",
                                "Cards you struggle with appear more often",
                                "Review daily for best results!"
                            ],
                            color: AppTheme.grammarColor
                        )
                        
                        FeatureTutorialCard(
                            icon: "book.closed",
                            title: "Completing Lessons",
                            steps: [
                                "Select a category from Home or Practice",
                                "Choose a lesson from the list",
                                "Read the content or vocabulary",
                                "Listen to pronunciations (tap speaker icons)",
                                "Complete practice exercises",
                                "Answer questions to test understanding",
                                "Earn points upon completion!",
                                "Review incorrect answers to learn"
                            ],
                            color: AppTheme.listeningColor
                        )
                        
                        FeatureTutorialCard(
                            icon: "gamecontroller",
                            title: "Playing Games",
                            steps: [
                                "Go to Games tab",
                                "Choose a game (Word Match, Sentence Builder, etc.)",
                                "Read the instructions",
                                "Complete the challenge",
                                "Check your score",
                                "Play again to improve!",
                                "Games use words from your current level"
                            ],
                            color: AppTheme.speakingColor
                        )
                    }
                }
                .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                
                // Pro Tips
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeaderView(
                        icon: "star.circle.fill",
                        title: "Pro Tips",
                        subtitle: "Learn faster with these strategies"
                    )
                    
                    VStack(spacing: 12) {
                        ProTipCard(
                            icon: "flame.fill",
                            title: "Build a Daily Streak",
                            tip: "Practice every day, even if just for 5 minutes. Consistency is more important than long sessions!",
                            color: .orange
                        )
                        
                        ProTipCard(
                            icon: "speaker.wave.2.fill",
                            title: "Use Audio Features",
                            tip: "Always listen to pronunciations. Hearing native speakers helps you learn the correct sounds and intonation.",
                            color: AppTheme.listeningColor
                        )
                        
                        ProTipCard(
                            icon: "pencil.tip",
                            title: "Practice Writing",
                            tip: "Don't skip writing practice! Writing Devanagari characters by hand helps you remember them better.",
                            color: AppTheme.writingColor
                        )
                        
                        ProTipCard(
                            icon: "arrow.triangle.2.circlepath",
                            title: "Review Regularly",
                            tip: "Use flashcards daily to review. Spaced repetition is scientifically proven to improve long-term memory.",
                            color: AppTheme.grammarColor
                        )
                        
                        ProTipCard(
                            icon: "trophy.fill",
                            title: "Track Progress",
                            tip: "Check your Profile regularly to see your achievements and progress. Seeing improvement keeps you motivated!",
                            color: AppTheme.brandGold
                        )
                        
                        ProTipCard(
                            icon: "figure.walk",
                            title: "Practice All Skills",
                            tip: "Don't just focus on one category. Balance vocabulary, grammar, listening, speaking, writing, and reading for well-rounded skills.",
                            color: AppTheme.success
                        )
                    }
                }
                .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                
                // Study Routine
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeaderView(
                        icon: "calendar.circle.fill",
                        title: "Recommended Study Routine",
                        subtitle: "A balanced daily practice plan"
                    )
                    
                    StudyRoutineCard()
                }
                .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                
                // Need More Help
                VStack(spacing: 16) {
                    Text("Need More Help?")
                        .font(AppTheme.Typography.title2)
                    
                    NavigationLink {
                        HelpSupportView()
                    } label: {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                            Text("Visit Help & Support")
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
                .padding(.top, 8)
            }
            .padding(.vertical, 24)
        }
        .background(AppTheme.background)
        .navigationTitle("How to Use")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Section Header

struct SectionHeaderView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(AppTheme.brandPrimary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTheme.Typography.title2)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.mutedText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Quick Start Step

struct QuickStartStep: View {
    let number: Int
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.mutedText)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }
}

// MARK: - Navigation Tab Card

struct NavigationTabCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.mutedText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }
}

// MARK: - Feature Tutorial Card

struct FeatureTutorialCard: View {
    let icon: String
    let title: String
    let steps: [String]
    let color: Color
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.15))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: icon)
                            .font(.system(size: 20))
                            .foregroundColor(color)
                    }
                    
                    Text(title)
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(color)
                }
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1).")
                                .font(AppTheme.Typography.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(color)
                                .frame(width: 20, alignment: .leading)
                            
                            Text(step)
                                .font(AppTheme.Typography.body)
                                .foregroundColor(AppTheme.mutedText)
                            
                            Spacer()
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }
}

// MARK: - Pro Tip Card

struct ProTipCard: View {
    let icon: String
    let title: String
    let tip: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTheme.Typography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(tip)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.mutedText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(color.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Study Routine Card

struct StudyRoutineCard: View {
    let routines = [
        ("Morning", [
            ("5 min", "Review yesterday's flashcards", "rectangle.stack.fill"),
            ("5 min", "Learn 5 new words", "book.closed.fill")
        ]),
        ("Afternoon", [
            ("10 min", "Complete one lesson", "book.fill"),
            ("5 min", "Practice writing", "pencil.tip")
        ]),
        ("Evening", [
            ("5 min", "Play a learning game", "gamecontroller.fill"),
            ("5 min", "Review today's new words", "arrow.triangle.2.circlepath")
        ])
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(routines, id: \.0) { routine in
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: timeIcon(for: routine.0))
                            .foregroundColor(AppTheme.brandPrimary)
                        Text(routine.0)
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(.primary)
                    }
                    
                    VStack(spacing: 8) {
                        ForEach(routine.1, id: \.0) { activity in
                            HStack(spacing: 12) {
                                Image(systemName: activity.2)
                                    .font(.system(size: 16))
                                    .foregroundColor(AppTheme.vocabularyColor)
                                    .frame(width: 20)
                                
                                Text(activity.0)
                                    .font(AppTheme.Typography.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppTheme.brandPrimary)
                                    .frame(width: 50, alignment: .leading)
                                
                                Text(activity.1)
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.mutedText)
                                
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
            }
            
            // Total time
            HStack {
                Spacer()
                VStack(spacing: 4) {
                    Text("Total Daily Time")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.mutedText)
                    
                    Text("30 minutes")
                        .font(AppTheme.Typography.title3)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.brandPrimary)
                }
                Spacer()
            }
            .padding()
            .background(AppTheme.brandPrimary.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    func timeIcon(for time: String) -> String {
        switch time {
        case "Morning": return "sunrise.fill"
        case "Afternoon": return "sun.max.fill"
        case "Evening": return "moon.stars.fill"
        default: return "clock.fill"
        }
    }
}

#Preview {
    NavigationStack {
        HowToUseView()
    }
}

