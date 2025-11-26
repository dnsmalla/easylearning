//
//  FeaturesGuideView.swift
//  NPLearn
//
//  Comprehensive overview of all app features
//

import SwiftUI

// MARK: - Features Guide View

struct FeaturesGuideView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Hero Section
                VStack(spacing: 16) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 70))
                        .foregroundColor(AppTheme.brandPrimary)
                    
                    Text("App Features")
                        .font(AppTheme.Typography.largeTitle)
                    
                    Text("Everything you need to master Nepali")
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.mutedText)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 20)
                
                // Overview Stats
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    StatCard(value: "1500+", label: "Words", icon: "book.closed.fill", color: AppTheme.vocabularyColor)
                    StatCard(value: "6", label: "Skill Areas", icon: "star.fill", color: AppTheme.grammarColor)
                    StatCard(value: "3", label: "Levels", icon: "chart.line.uptrend.xyaxis", color: AppTheme.listeningColor)
                    StatCard(value: "100%", label: "Free", icon: "heart.fill", color: AppTheme.danger)
                }
                .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                
                // Core Features
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeaderView(
                        icon: "star.circle.fill",
                        title: "Core Learning Features",
                        subtitle: "Master all aspects of Nepali"
                    )
                    
                    VStack(spacing: 12) {
                        FeatureDetailCard(
                            icon: "book.closed.fill",
                            title: "Vocabulary Learning",
                            description: "Build your word power with 1500+ words across all levels",
                            benefits: [
                                "Common words and phrases",
                                "Native speaker audio",
                                "Example sentences",
                                "Context and usage notes",
                                "Visual associations"
                            ],
                            color: AppTheme.vocabularyColor
                        )
                        
                        FeatureDetailCard(
                            icon: "text.book.closed.fill",
                            title: "Grammar Mastery",
                            description: "Understand Nepali sentence structure and grammar rules",
                            benefits: [
                                "Verb conjugations",
                                "Sentence patterns",
                                "Grammar explanations",
                                "Practice exercises",
                                "Real-world examples"
                            ],
                            color: AppTheme.grammarColor
                        )
                        
                        FeatureDetailCard(
                            icon: "headphones",
                            title: "Listening Practice",
                            description: "Train your ear with authentic Nepali audio",
                            benefits: [
                                "Native speaker recordings",
                                "Various accents and speeds",
                                "Comprehension exercises",
                                "Repeat and slow-down options",
                                "Contextual listening"
                            ],
                            color: AppTheme.listeningColor
                        )
                        
                        FeatureDetailCard(
                            icon: "mic.fill",
                            title: "Speaking Practice",
                            description: "Improve pronunciation and speaking confidence",
                            benefits: [
                                "Pronunciation guides",
                                "Voice recording",
                                "Comparison with native audio",
                                "Common phrases practice",
                                "Conversational patterns"
                            ],
                            color: AppTheme.speakingColor
                        )
                        
                        FeatureDetailCard(
                            icon: "pencil.tip",
                            title: "Writing Practice",
                            description: "Master Devanagari script through practice",
                            benefits: [
                                "Character tracing",
                                "Interactive canvas",
                                "Stroke order guidance",
                                "All vowels and consonants",
                                "Practice mode with feedback"
                            ],
                            color: AppTheme.writingColor
                        )
                        
                        FeatureDetailCard(
                            icon: "doc.text.fill",
                            title: "Reading Comprehension",
                            description: "Read and understand Nepali texts",
                            benefits: [
                                "Progressive difficulty",
                                "Stories and articles",
                                "Comprehension questions",
                                "Vocabulary in context",
                                "Cultural insights"
                            ],
                            color: AppTheme.readingColor
                        )
                    }
                }
                .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                
                // Study Tools
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeaderView(
                        icon: "wrench.and.screwdriver.fill",
                        title: "Study Tools",
                        subtitle: "Powerful features to enhance learning"
                    )
                    
                    VStack(spacing: 12) {
                        StudyToolCard(
                            icon: "rectangle.stack.fill",
                            title: "Smart Flashcards",
                            description: "Spaced repetition system that adapts to your learning",
                            features: [
                                "🧠 Intelligent scheduling",
                                "📊 Progress tracking",
                                "✅ Mark as known/review",
                                "🔄 Auto-rotation of difficult words"
                            ],
                            color: AppTheme.vocabularyColor
                        )
                        
                        StudyToolCard(
                            icon: "gamecontroller.fill",
                            title: "Learning Games",
                            description: "Make learning fun with interactive games",
                            features: [
                                "🎯 Word Match - Pair words",
                                "🧩 Sentence Builder - Construct sentences",
                                "💭 Memory Cards - Test recall",
                                "⚡ Quick Quiz - Rapid practice"
                            ],
                            color: AppTheme.listeningColor
                        )
                        
                        StudyToolCard(
                            icon: "textformat.abc",
                            title: "Devanagari Master",
                            description: "Complete guide to Nepali script",
                            features: [
                                "🔤 All vowels (independent & dependent)",
                                "🔡 All consonants with pronunciation",
                                "🔢 Nepali numerals (०-९)",
                                "✍️ Writing practice canvas"
                            ],
                            color: AppTheme.writingColor
                        )
                    }
                }
                .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                
                // Progress Tracking
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeaderView(
                        icon: "chart.line.uptrend.xyaxis.circle.fill",
                        title: "Track Your Progress",
                        subtitle: "Stay motivated with detailed statistics"
                    )
                    
                    VStack(spacing: 12) {
                        ProgressFeatureCard(
                            icon: "star.fill",
                            title: "Points System",
                            description: "Earn points for every completed lesson, exercise, and game. Watch your total grow!",
                            color: AppTheme.brandGold
                        )
                        
                        ProgressFeatureCard(
                            icon: "flame.fill",
                            title: "Daily Streaks",
                            description: "Maintain your learning streak by practicing every day. Don't break the chain!",
                            color: .orange
                        )
                        
                        ProgressFeatureCard(
                            icon: "trophy.fill",
                            title: "Achievements",
                            description: "Unlock badges and achievements as you reach milestones in your learning journey.",
                            color: AppTheme.success
                        )
                        
                        ProgressFeatureCard(
                            icon: "chart.bar.fill",
                            title: "Detailed Stats",
                            description: "View completed lessons, vocabulary mastered, and category-wise progress.",
                            color: AppTheme.info
                        )
                    }
                }
                .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                
                // Personalization
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeaderView(
                        icon: "slider.horizontal.3",
                        title: "Personalization",
                        subtitle: "Customize your learning experience"
                    )
                    
                    VStack(spacing: 12) {
                        PersonalizationCard(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "3 Difficulty Levels",
                            options: [
                                "🔰 Beginner - Start from basics",
                                "🔶 Intermediate - Build on foundation",
                                "🔴 Advanced - Master the language"
                            ],
                            color: AppTheme.brandPrimary
                        )
                        
                        PersonalizationCard(
                            icon: "person.circle.fill",
                            title: "Flexible Learning",
                            options: [
                                "📱 Learn at your own pace",
                                "🔄 Switch levels anytime",
                                "✅ Choose your focus areas",
                                "📊 Personalized recommendations"
                            ],
                            color: AppTheme.vocabularyColor
                        )
                        
                        PersonalizationCard(
                            icon: "bookmark.fill",
                            title: "Save & Review",
                            options: [
                                "💾 Save favorite words",
                                "📝 Create custom lists",
                                "🔖 Bookmark lessons",
                                "📚 Build personal vocabulary"
                            ],
                            color: AppTheme.grammarColor
                        )
                    }
                }
                .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                
                // Accessibility
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeaderView(
                        icon: "accessibility.circle.fill",
                        title: "Accessible & User-Friendly",
                        subtitle: "Designed for everyone"
                    )
                    
                    VStack(spacing: 12) {
                        AccessibilityFeatureRow(icon: "network", title: "Works Offline", description: "Most features available without internet")
                        AccessibilityFeatureRow(icon: "iphone", title: "iPhone & iPad", description: "Optimized for all devices")
                        AccessibilityFeatureRow(icon: "paintbrush.fill", title: "Beautiful Design", description: "Clean, intuitive interface")
                        AccessibilityFeatureRow(icon: "speaker.wave.2.fill", title: "Audio Support", description: "Hear native pronunciations")
                        AccessibilityFeatureRow(icon: "eye.fill", title: "Clear Typography", description: "Easy to read text")
                        AccessibilityFeatureRow(icon: "hand.tap.fill", title: "Simple Navigation", description: "Easy to use tabs")
                    }
                }
                .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                
                // Coming Soon
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeaderView(
                        icon: "clock.arrow.circlepath",
                        title: "Coming Soon",
                        subtitle: "Features we're working on"
                    )
                    
                    VStack(spacing: 12) {
                        ComingSoonCard(icon: "person.2.fill", title: "Social Features", description: "Connect with other learners")
                        ComingSoonCard(icon: "message.fill", title: "Chat Practice", description: "Practice conversations with AI")
                        ComingSoonCard(icon: "book.pages.fill", title: "More Content", description: "Additional lessons and stories")
                        ComingSoonCard(icon: "arrow.down.circle.fill", title: "Offline Download", description: "Download lessons for offline use")
                    }
                }
                .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                
                // CTA
                VStack(spacing: 16) {
                    Text("Ready to Start Learning?")
                        .font(AppTheme.Typography.title2)
                    
                    Text("All features are free and available now!")
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.mutedText)
                    
                    NavigationLink {
                        HowToUseView()
                    } label: {
                        HStack {
                            Image(systemName: "book.fill")
                            Text("See How to Use")
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
        .navigationTitle("Features")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Stat Card (using CommonViews.StatCard)
// StatCard is now defined in CommonViews.swift and used here

// MARK: - Feature Detail Card

struct FeatureDetailCard: View {
    let icon: String
    let title: String
    let description: String
    let benefits: [String]
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
                        
                        if !isExpanded {
                            Text(description)
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.mutedText)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(color)
                }
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Text(description)
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.mutedText)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(benefits, id: \.self) { benefit in
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(color)
                                
                                Text(benefit)
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.mutedText)
                            }
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

// MARK: - Study Tool Card

struct StudyToolCard: View {
    let icon: String
    let title: String
    let description: String
    let features: [String]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
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
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                ForEach(features, id: \.self) { feature in
                    Text(feature)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.mutedText)
                }
            }
            .padding(.leading, 8)
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

// MARK: - Progress Feature Card

struct ProgressFeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTheme.Typography.subheadline)
                    .fontWeight(.semibold)
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

// MARK: - Personalization Card

struct PersonalizationCard: View {
    let icon: String
    let title: String
    let options: [String]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                
                Text(title)
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(.primary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Text(option)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.mutedText)
                }
            }
            .padding(.leading, 36)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }
}

// MARK: - Accessibility Feature Row

struct AccessibilityFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppTheme.success)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTheme.Typography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(AppTheme.Typography.caption2)
                    .foregroundColor(AppTheme.mutedText)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(AppTheme.success)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }
}

// MARK: - Coming Soon Card

struct ComingSoonCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.mutedText.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.mutedText)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTheme.Typography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(AppTheme.Typography.caption2)
                    .foregroundColor(AppTheme.mutedText)
            }
            
            Spacer()
            
            Text("Soon")
                .font(AppTheme.Typography.caption2)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.warning)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppTheme.warning.opacity(0.1))
                .clipShape(Capsule())
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }
}

#Preview {
    NavigationStack {
        FeaturesGuideView()
    }
}

