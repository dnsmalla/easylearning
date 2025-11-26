//
//  LevelSwitcherView.swift
//  NPLearn
//
//  Reusable component for switching between Nepali learning levels
//

import SwiftUI

// MARK: - Level Switcher Menu

struct LevelSwitcherMenu: View {
    @EnvironmentObject var learningDataService: LearningDataService
    
    var body: some View {
        Menu {
            ForEach(LearningLevel.allCases, id: \.self) { level in
                Button {
                    Task {
                        await learningDataService.setLevel(level)
                        Haptics.selection()
                    }
                } label: {
                    HStack {
                        Text(level.rawValue)
                        Text("-")
                        Text(level.title)
                        if level == learningDataService.currentLevel {
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundColor(AppTheme.brandPrimary)
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "book.fill")
                Text(learningDataService.currentLevel.rawValue)
                Image(systemName: "chevron.down")
            }
            .font(AppTheme.Typography.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(AppTheme.brandPrimary)
            .clipShape(Capsule())
        }
    }
}

// MARK: - Level Badge

struct LevelBadge: View {
    let level: LearningLevel
    var compact: Bool = true
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: levelIcon)
                .font(.caption)
            Text(compact ? level.rawValue : level.title)
                .font(AppTheme.Typography.caption)
                .fontWeight(.semibold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, compact ? 8 : 12)
        .padding(.vertical, 4)
        .background(levelColor)
        .clipShape(Capsule())
    }
    
    private var levelIcon: String {
        switch level {
        case .beginner: return "leaf"
        case .elementary: return "book"
        case .intermediate: return "graduationcap"
        case .advanced: return "star"
        case .proficient: return "crown"
        }
    }
    
    private var levelColor: Color {
        switch level {
        case .beginner: return AppTheme.success
        case .elementary: return AppTheme.info
        case .intermediate: return AppTheme.warning
        case .advanced: return AppTheme.brandPurple
        case .proficient: return AppTheme.brandGold
        }
    }
}

// MARK: - Level Indicator Bar

struct LevelIndicatorBar: View {
    @EnvironmentObject var learningDataService: LearningDataService
    let showSwitcher: Bool
    
    init(showSwitcher: Bool = true) {
        self.showSwitcher = showSwitcher
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Current Level")
                    .font(AppTheme.Typography.caption2)
                    .foregroundColor(.secondary)
                HStack(spacing: 6) {
                    LevelBadge(level: learningDataService.currentLevel, compact: false)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text("\(learningDataService.flashcards.count) flashcards")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if showSwitcher {
                LevelSwitcherMenu()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Compact Level Header

struct CompactLevelHeader: View {
    @EnvironmentObject var learningDataService: LearningDataService
    
    var body: some View {
        HStack {
            LevelBadge(level: learningDataService.currentLevel)
            
            Spacer()
            
            LevelSwitcherMenu()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
    }
}

// MARK: - Level Selection Grid

struct LevelSelectionGrid: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Select Your Level")
                .font(AppTheme.Typography.title2)
                .fontWeight(.bold)
            
            Text("Choose your Nepali proficiency level")
                .font(AppTheme.Typography.body)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(LearningLevel.allCases, id: \.self) { level in
                    LevelSwitcherCard(
                        level: level,
                        isSelected: level == learningDataService.currentLevel
                    ) {
                        Task {
                            await learningDataService.setLevel(level)
                            Haptics.success()
                            isPresented = false
                        }
                    }
                }
            }
        }
        .padding()
    }
}

// MARK: - Level Switcher Card

struct LevelSwitcherCard: View {
    let level: LearningLevel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: levelIcon)
                    .font(.title)
                    .foregroundColor(isSelected ? .white : levelColor)
                
                Text(level.rawValue)
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(level.description)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? levelColor : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? levelColor : Color.clear, lineWidth: 2)
            )
        }
    }
    
    private var levelIcon: String {
        switch level {
        case .beginner: return "leaf.fill"
        case .elementary: return "book.fill"
        case .intermediate: return "graduationcap.fill"
        case .advanced: return "star.fill"
        case .proficient: return "crown.fill"
        }
    }
    
    private var levelColor: Color {
        switch level {
        case .beginner: return AppTheme.success
        case .elementary: return AppTheme.info
        case .intermediate: return AppTheme.warning
        case .advanced: return AppTheme.brandPurple
        case .proficient: return AppTheme.brandGold
        }
    }
}

// MARK: - Level Change Reactive Modifier

/// View modifier that reloads data when level changes
struct LevelChangeReactive: ViewModifier {
    @EnvironmentObject var learningDataService: LearningDataService
    let reload: () async -> Void
    
    func body(content: Content) -> some View {
        content
            .onChange(of: learningDataService.currentLevel) { newLevel in
                AppLogger.info("🔄 [LEVEL CHANGE] Detected level change to: \(newLevel.rawValue)")
                Task {
                    await reload()
                }
            }
    }
}

extension View {
    /// Makes the view react to level changes by reloading data
    func reloadOnLevelChange(reload: @escaping () async -> Void) -> some View {
        modifier(LevelChangeReactive(reload: reload))
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        LevelSwitcherMenu()
        
        LevelBadge(level: .beginner)
        LevelBadge(level: .intermediate, compact: false)
        
        LevelIndicatorBar()
    }
    .padding()
    .environmentObject(LearningDataService.shared)
}

