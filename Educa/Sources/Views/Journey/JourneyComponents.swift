//
//  JourneyComponents.swift
//  Educa
//
//  Learning Path, Achievements, and Application Tracker components
//

import SwiftUI

// MARK: - Learning Path View

struct LearningPathView: View {
    @EnvironmentObject var dataService: DataService
    @State private var expandedStep: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Your Learning Path")
                .font(.appTitle3)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 0) {
                ForEach(Array(dataService.learningSteps.enumerated()), id: \.element.id) { index, step in
                    LearningStepCard(
                        step: step,
                        isExpanded: expandedStep == step.id,
                        isLast: index == dataService.learningSteps.count - 1,
                        onTap: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                if expandedStep == step.id {
                                    expandedStep = nil
                                } else {
                                    expandedStep = step.id
                                    HapticManager.shared.tap()
                                }
                            }
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Learning Step Card

struct LearningStepCard: View {
    let step: LearningStep
    let isExpanded: Bool
    let isLast: Bool
    let onTap: () -> Void
    
    var statusColor: Color {
        switch step.status {
        case .completed: return .green
        case .inProgress: return .brand
        case .upcoming: return .orange
        case .locked: return .gray
        }
    }
    
    var statusIcon: String {
        switch step.status {
        case .completed: return "checkmark.circle.fill"
        case .inProgress: return "arrow.right.circle.fill"
        case .upcoming: return "circle"
        case .locked: return "lock.circle.fill"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: Spacing.md) {
                // Step indicator with line
                VStack(spacing: 0) {
                    ZStack {
                        Circle()
                            .fill(statusColor.opacity(0.15))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: statusIcon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(statusColor)
                    }
                    
                    if !isLast {
                        Rectangle()
                            .fill(step.status == .completed ? Color.green.opacity(0.5) : Color.gray.opacity(0.2))
                            .frame(width: 2)
                            .frame(minHeight: isExpanded ? 120 : 40)
                    }
                }
                
                // Content
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Button(action: onTap) {
                        HStack {
                            VStack(alignment: .leading, spacing: Spacing.xxs) {
                                HStack {
                                    Text("Step \(step.stepNumber)")
                                        .font(.appCaption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(statusColor)
                                    
                                    if step.status == .inProgress {
                                        Text("IN PROGRESS")
                                            .font(.appCaption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.brand)
                                            .clipShape(Capsule())
                                    }
                                }
                                
                                Text(step.title)
                                    .font(.appHeadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(step.status == .locked ? .textTertiary : .textPrimary)
                                
                                Text(step.description)
                                    .font(.appCaption)
                                    .foregroundColor(.textSecondary)
                                    .lineLimit(isExpanded ? nil : 2)
                            }
                            
                            Spacer()
                            
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.caption)
                                .foregroundColor(.textTertiary)
                        }
                    }
                    .disabled(step.status == .locked)
                    
                    // Expanded Content
                    if isExpanded && step.status != .locked {
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            // Tasks
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text("Tasks")
                                    .font(.appCaption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.textSecondary)
                                
                                ForEach(step.tasks, id: \.self) { task in
                                    HStack(spacing: Spacing.sm) {
                                        Image(systemName: step.status == .completed ? "checkmark.circle.fill" : "circle")
                                            .font(.caption)
                                            .foregroundColor(step.status == .completed ? .green : .textTertiary)
                                        
                                        Text(task)
                                            .font(.appCaption)
                                            .foregroundColor(.textPrimary)
                                            .strikethrough(step.status == .completed)
                                    }
                                }
                            }
                            
                            // Resources
                            if let resources = step.resources, !resources.isEmpty {
                                VStack(alignment: .leading, spacing: Spacing.xs) {
                                    Text("Resources")
                                        .font(.appCaption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.textSecondary)
                                    
                                    FlowLayout(spacing: Spacing.xs) {
                                        ForEach(resources, id: \.self) { resource in
                                            Text(resource)
                                                .font(.appCaption2)
                                                .foregroundColor(.brand)
                                                .padding(.horizontal, Spacing.sm)
                                                .padding(.vertical, 4)
                                                .background(Color.brand.opacity(0.1))
                                                .clipShape(Capsule())
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.top, Spacing.sm)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(Spacing.md)
                .background(
                    step.status == .inProgress 
                        ? Color.brand.opacity(0.05) 
                        : Color.cardBackground
                )
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.large)
                        .stroke(step.status == .inProgress ? Color.brand.opacity(0.3) : Color.clear, lineWidth: 1)
                )
            }
            .padding(.bottom, isLast ? 0 : Spacing.sm)
        }
    }
}

// MARK: - Achievements Grid View

struct AchievementsGridView: View {
    @EnvironmentObject var dataService: DataService
    @State private var selectedAchievement: Achievement?
    
    var unlockedCount: Int {
        dataService.achievements.filter { $0.isUnlocked }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Achievements")
                    .font(.appTitle3)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text("\(unlockedCount)/\(dataService.achievements.count)")
                    .font(.appCaption)
                    .fontWeight(.semibold)
                    .foregroundColor(.brand)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, 4)
                    .background(Color.brand.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Spacing.md) {
                ForEach(dataService.achievements) { achievement in
                    AchievementBadge(achievement: achievement)
                        .onTapGesture {
                            if achievement.isUnlocked {
                                HapticManager.shared.tap()
                                selectedAchievement = achievement
                            }
                        }
                }
            }
        }
        .sheet(item: $selectedAchievement) { achievement in
            AchievementDetailSheet(achievement: achievement)
                .presentationDetents([.medium])
        }
    }
}

// MARK: - Achievement Badge

struct AchievementBadge: View {
    let achievement: Achievement
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            ZStack {
                Circle()
                    .fill(
                        achievement.isUnlocked 
                            ? LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 56, height: 56)
                    .shadow(color: achievement.isUnlocked ? Color.yellow.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(achievement.isUnlocked ? .white : .gray)
                
                if !achievement.isUnlocked {
                    Circle()
                        .fill(Color.black.opacity(0.3))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .scaleEffect(isAnimating && achievement.isUnlocked ? 1.1 : 1.0)
            .animation(.spring(response: 0.5, dampingFraction: 0.6).repeatCount(1), value: isAnimating)
            
            Text(achievement.title)
                .font(.appCaption2)
                .fontWeight(.medium)
                .foregroundColor(achievement.isUnlocked ? .textPrimary : .textTertiary)
                .lineLimit(1)
        }
        .onAppear {
            if achievement.isUnlocked {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.1...0.5)) {
                    isAnimating = true
                }
            }
        }
    }
}

// MARK: - Achievement Detail Sheet

struct AchievementDetailSheet: View {
    let achievement: Achievement
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: Spacing.xl) {
            // Badge
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: Color.yellow.opacity(0.4), radius: 20, x: 0, y: 10)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.top, Spacing.xl)
            
            VStack(spacing: Spacing.sm) {
                Text(achievement.title)
                    .font(.appTitle2)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                Text(achievement.description)
                    .font(.appSubheadline)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                
                if let dateEarned = achievement.dateEarned {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "calendar")
                            .foregroundColor(.brand)
                        Text("Earned on \(dateEarned)")
                            .font(.appCaption)
                            .foregroundColor(.textTertiary)
                    }
                    .padding(.top, Spacing.sm)
                }
            }
            
            Spacer()
            
            Button("Awesome!") {
                HapticManager.shared.success()
                dismiss()
            }
            .buttonStyle(PrimaryButtonStyle(isFullWidth: true))
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.xl)
        }
        .frame(maxWidth: .infinity)
        .background(Color.backgroundPrimary)
    }
}

// MARK: - Preview

struct JourneyComponents_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                LearningPathView()
                AchievementsGridView()
            }
            .padding()
        }
        .environmentObject(DataService.shared)
    }
}
