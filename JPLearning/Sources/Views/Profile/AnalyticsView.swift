//
//  AnalyticsView.swift
//  JLearn
//
//  Progress analytics and statistics dashboard
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @EnvironmentObject var achievementService: AchievementService
    @EnvironmentObject var timerService: StudyTimerService
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Progress")
                        .font(AppTheme.Typography.largeTitle)
                    
                    Text("Track your learning journey")
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(AppTheme.mutedText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Daily Streak Card
                streakCard
                
                // Study Time Stats
                studyTimeCard
                
                // Weekly Activity
                weeklyActivityCard
                
                // Achievements Progress
                achievementsCard
                
                // Learning Progress
                learningProgressCard
            }
            .padding(AppTheme.Layout.horizontalPadding)
        }
        .background(AppTheme.background)
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Streak Card
    
    private var streakCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                Text("Daily Streak")
                    .font(AppTheme.Typography.headline)
                
                Spacer()
            }
            
            HStack(spacing: 24) {
                VStack(alignment: .leading) {
                    Text("\(achievementService.currentStreak)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(AppTheme.brandPrimary)
                    
                    Text("Current Streak")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.mutedText)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(achievementService.longestStreak)")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    Text("Best Streak")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.mutedText)
                }
            }
            
            // Last 7 days visualization
            HStack(spacing: 8) {
                ForEach(0..<7, id: \.self) { index in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(index < achievementService.currentStreak ? Color.orange : Color.gray.opacity(0.2))
                            .frame(height: 30)
                        
                        Text(dayLabel(for: index))
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.secondaryBackground)
        .cornerRadius(AppTheme.Layout.cornerRadius)
    }
    
    // MARK: - Study Time Card
    
    private var studyTimeCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                Text("Study Time")
                    .font(AppTheme.Typography.headline)
                
                Spacer()
            }
            
            HStack(spacing: 32) {
                StatColumn(
                    value: formatMinutes(achievementService.totalStudyMinutes),
                    label: "Total",
                    color: .blue
                )
                
                StatColumn(
                    value: timerService.getFormattedTime(timerService.getTodayStudyTime()),
                    label: "Today",
                    color: .green
                )
                
                StatColumn(
                    value: formatMinutes(achievementService.totalStudyMinutes / 7),
                    label: "Avg/Week",
                    color: .orange
                )
            }
        }
        .padding()
        .background(AppTheme.secondaryBackground)
        .cornerRadius(AppTheme.Layout.cornerRadius)
    }
    
    // MARK: - Weekly Activity Card
    
    private var weeklyActivityCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly Activity")
                .font(AppTheme.Typography.headline)
            
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(achievementService.getWeeklyActivity(), id: \.self) { minutes in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppTheme.brandPrimary)
                            .frame(height: CGFloat(minutes))
                            .frame(maxHeight: 100)
                        
                        Text("\(minutes)m")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 120)
        }
        .padding()
        .background(AppTheme.secondaryBackground)
        .cornerRadius(AppTheme.Layout.cornerRadius)
    }
    
    // MARK: - Achievements Card
    
    private var achievementsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements")
                .font(AppTheme.Typography.headline)
            
            let achievements = achievementService.getAvailableAchievements()
            let unlockedCount = achievements.filter { $0.isUnlocked }.count
            
            HStack {
                Text("\(unlockedCount) / \(achievements.count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.brandPrimary)
                
                Text("Unlocked")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            // Achievement grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(achievements.prefix(6)) { achievement in
                    VStack(spacing: 6) {
                        Image(systemName: achievement.icon)
                            .font(.title2)
                            .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
                        
                        Text(achievement.title)
                            .font(.system(size: 10))
                            .multilineTextAlignment(.center)
                            .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(achievement.isUnlocked ? Color.yellow.opacity(0.1) : Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(AppTheme.secondaryBackground)
        .cornerRadius(AppTheme.Layout.cornerRadius)
    }
    
    // MARK: - Learning Progress Card
    
    private var learningProgressCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Learning Progress")
                .font(AppTheme.Typography.headline)
            
            ProgressRow(
                title: "Vocabulary",
                current: learningDataService.flashcards.count,
                total: 1000,
                color: .blue
            )
            
            ProgressRow(
                title: "Kanji",
                current: learningDataService.kanji.count,
                total: 500,
                color: .purple
            )
            
            ProgressRow(
                title: "Grammar",
                current: learningDataService.grammarPoints.count,
                total: 200,
                color: .green
            )
        }
        .padding()
        .background(AppTheme.secondaryBackground)
        .cornerRadius(AppTheme.Layout.cornerRadius)
    }
    
    // MARK: - Helper Views
    
    private func dayLabel(for index: Int) -> String {
        let days = ["M", "T", "W", "T", "F", "S", "S"]
        let currentDay = Calendar.current.component(.weekday, from: Date()) - 1
        let dayIndex = (currentDay - 6 + index + 7) % 7
        return days[dayIndex]
    }
    
    private func formatMinutes(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        
        if hours > 0 {
            return "\(hours)h \(mins)m"
        } else {
            return "\(mins)m"
        }
    }
}

// MARK: - Supporting Views

struct StatColumn: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct ProgressRow: View {
    let title: String
    let current: Int
    let total: Int
    let color: Color
    
    var progress: Double {
        min(Double(current) / Double(total), 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                
                Spacer()
                
                Text("\(current) / \(total)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}
