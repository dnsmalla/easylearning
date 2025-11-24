//
//  ReusableCards.swift
//  JLearn
//
//  Reusable card components used throughout the app
//  Consolidates duplicated card patterns
//

import SwiftUI

// MARK: - Study Material Card

/// Card for displaying study materials (Kanji, Vocabulary, Grammar, etc.)
struct StudyMaterialCard: View {
    let title: String
    let icon: String
    let color: Color
    let count: String
    let destination: AnyView
    
    var body: some View {
        NavigationLink(destination: destination) {
            VStack(alignment: .leading, spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
                
                // Title and Count
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.primary)
                    
                    Text(count)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.mutedText)
                }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius)
                    .fill(AppTheme.background)
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Practice Category Card

/// Card for practice category selection
struct PracticeCategoryCard: View {
    let title: String
    let icon: String
    let color: Color
    let description: String
    let destination: AnyView
    
    var body: some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 16) {
                // Icon with gradient background
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.2), color.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: icon)
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(color)
                }
                
                // Text
                VStack(spacing: 4) {
                    Text(title)
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.mutedText)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 160)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius)
                    .fill(AppTheme.background)
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Stat Card

/// Card for displaying statistics
struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    let trend: TrendDirection?
    
    enum TrendDirection {
        case up
        case down
        case neutral
        
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .neutral: return "minus"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .red
            case .neutral: return .gray
            }
        }
    }
    
    init(icon: String, value: String, label: String, color: Color, trend: TrendDirection? = nil) {
        self.icon = icon
        self.value = value
        self.label = label
        self.color = color
        self.trend = trend
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            // Value
            HStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                if let trend = trend {
                    Image(systemName: trend.icon)
                        .font(.system(size: 12))
                        .foregroundColor(trend.color)
                }
            }
            
            // Label
            Text(label)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.mutedText)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius)
                .fill(AppTheme.background)
                .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
        )
    }
}

// MARK: - Progress Card

/// Card showing progress with bar
struct ProgressCard: View {
    let title: String
    let subtitle: String?
    let progress: Double
    let total: Double
    let color: Color
    let icon: String?
    
    init(
        title: String,
        subtitle: String? = nil,
        progress: Double,
        total: Double = 1.0,
        color: Color = AppTheme.brandPrimary,
        icon: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.progress = progress
        self.total = total
        self.color = color
        self.icon = icon
    }
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return min(max(progress / total, 0), 1)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.mutedText)
                    }
                }
                
                Spacer()
                
                Text("\(Int(percentage * 100))%")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(color)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * percentage)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: percentage)
                }
            }
            .frame(height: 8)
            
            // Stats
            HStack {
                Text("\(Int(progress))/\(Int(total))")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.mutedText)
                
                Spacer()
                
                Text("\(Int(total - progress)) remaining")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.mutedText)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius)
                .fill(AppTheme.background)
                .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        )
    }
}

// MARK: - Achievement Card

/// Card for displaying achievements
struct AchievementCard: View {
    let achievement: Achievement
    let isUnlocked: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(isUnlocked ? AppTheme.brandPrimary.opacity(0.15) : AppTheme.mutedText.opacity(0.1))
                    .frame(width: 56, height: 56)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 28))
                    .foregroundColor(isUnlocked ? AppTheme.brandPrimary : AppTheme.mutedText)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(.primary)
                
                Text(achievement.description)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.mutedText)
                    .lineLimit(2)
                
                if !isUnlocked {
                    // Progress
                    HStack(spacing: 8) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(AppTheme.separator)
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(AppTheme.brandPrimary)
                                    .frame(width: geometry.size.width * achievement.progressPercentage)
                            }
                        }
                        .frame(height: 4)
                        
                        Text("\(achievement.progress)/\(achievement.requirement)")
                            .font(AppTheme.Typography.caption2)
                            .foregroundColor(AppTheme.mutedText)
                    }
                } else {
                    // Rewards
                    HStack(spacing: 12) {
                        Label("\(achievement.rewardStars)", systemImage: "star.fill")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.orange)
                        
                        Label("\(achievement.rewardCoins)", systemImage: "circle.fill")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.yellow)
                    }
                }
            }
            
            Spacer()
            
            // Lock/Checkmark
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
            } else {
                Image(systemName: "lock.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.mutedText)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius)
                .fill(AppTheme.background)
                .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
        )
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}

// MARK: - Level Badge

/// Badge showing JLPT level
struct LevelBadge: View {
    let level: LearningLevel
    let compact: Bool
    
    init(level: LearningLevel, compact: Bool = false) {
        self.level = level
        self.compact = compact
    }
    
    var body: some View {
        HStack(spacing: compact ? 4 : 6) {
            Text(level.rawValue)
                .font(compact ? AppTheme.Typography.caption2 : AppTheme.Typography.caption)
                .fontWeight(.bold)
            
            if !compact {
                Text(level.title)
                    .font(AppTheme.Typography.caption2)
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, compact ? 8 : 12)
        .padding(.vertical, compact ? 4 : 6)
        .background(
            Capsule()
                .fill(levelColor(for: level))
        )
    }
    
    private func levelColor(for level: LearningLevel) -> Color {
        switch level {
        case .n5: return .green
        case .n4: return .blue
        case .n3: return .orange
        case .n2: return .purple
        case .n1: return .red
        }
    }
}

// MARK: - Filter Chip

/// Chip for filtering/selection
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
            Haptics.selection()
        }) {
            Text(title)
                .font(AppTheme.Typography.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : AppTheme.brandPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? AppTheme.brandPrimary : AppTheme.brandPrimary.opacity(0.15))
                )
        }
    }
}


