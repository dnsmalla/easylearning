//
//  LevelSwitcherView.swift
//  JLearn
//
//  Reusable component for switching between JLPT levels
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

// MARK: - Level Badge (using consolidated version from ReusableCards)

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

