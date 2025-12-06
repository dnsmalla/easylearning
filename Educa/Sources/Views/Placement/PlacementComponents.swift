//
//  PlacementComponents.swift
//  Educa
//
//  Application Tracker and related components for Placement tab
//

import SwiftUI

// MARK: - Application Tracker View

struct ApplicationTrackerView: View {
    @EnvironmentObject var dataService: DataService
    @State private var selectedStatus: JobApplication.ApplicationStatus?
    
    var filteredApplications: [JobApplication] {
        if let status = selectedStatus {
            return dataService.applications.filter { $0.status == status }
        }
        return dataService.applications
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Application Tracker")
                .font(.appTitle3)
                .foregroundColor(.textPrimary)
            
            // Status Filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    StatusFilterChip(
                        title: "All",
                        count: dataService.applications.count,
                        isSelected: selectedStatus == nil,
                        color: .brand
                    ) {
                        selectedStatus = nil
                    }
                    
                    ForEach(applicationStatuses, id: \.self) { status in
                        StatusFilterChip(
                            title: status.displayName,
                            count: countForStatus(status),
                            isSelected: selectedStatus == status,
                            color: Color(hex: status.color)
                        ) {
                            selectedStatus = status
                        }
                    }
                }
            }
            
            // Applications List
            if filteredApplications.isEmpty {
                EmptyStateView(
                    icon: "doc.text",
                    title: "No Applications",
                    message: selectedStatus == nil 
                        ? "Track your job applications here" 
                        : "No applications with this status"
                )
                .frame(height: 150)
            } else {
                VStack(spacing: Spacing.md) {
                    ForEach(filteredApplications) { application in
                        ApplicationCard(application: application)
                    }
                }
            }
        }
    }
    
    private var applicationStatuses: [JobApplication.ApplicationStatus] {
        [.applied, .underReview, .interview, .offered, .rejected, .accepted]
    }
    
    private func countForStatus(_ status: JobApplication.ApplicationStatus) -> Int {
        dataService.applications.filter { $0.status == status }.count
    }
}

struct StatusFilterChip: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                Text(title)
                    .font(.appCaption)
                    .fontWeight(isSelected ? .semibold : .regular)
                
                if count > 0 {
                    Text("\(count)")
                        .font(.appCaption2)
                        .fontWeight(.bold)
                        .foregroundColor(isSelected ? .white : color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isSelected ? Color.white.opacity(0.3) : color.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            .foregroundColor(isSelected ? .white : .textPrimary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
            .background(isSelected ? color : Color.backgroundTertiary)
            .clipShape(Capsule())
        }
    }
}

struct ApplicationCard: View {
    let application: JobApplication
    @State private var isExpanded = false
    
    var statusColor: Color {
        Color(hex: application.status.color)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Header
            Button {
                withAnimation(.spring(response: 0.3)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(application.jobTitle)
                            .font(.appHeadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                            .lineLimit(1)
                        
                        Text(application.company)
                            .font(.appSubheadline)
                            .foregroundColor(.textSecondary)
                    }
                    
                    Spacer()
                    
                    // Status Badge
                    Text(application.status.displayName)
                        .font(.appCaption2)
                        .fontWeight(.semibold)
                        .foregroundColor(statusColor)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, 4)
                        .background(statusColor.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            
            // Applied Date
            HStack {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
                
                Text("Applied: \(application.appliedDate)")
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
            }
            
            // Expanded Content
            if isExpanded {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Divider()
                    
                    // Next Step
                    if let nextStep = application.nextStep {
                        HStack(alignment: .top, spacing: Spacing.sm) {
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(.brand)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Next Step")
                                    .font(.appCaption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.textSecondary)
                                
                                Text(nextStep)
                                    .font(.appSubheadline)
                                    .foregroundColor(.textPrimary)
                            }
                        }
                    }
                    
                    // Notes
                    if let notes = application.notes, !notes.isEmpty {
                        HStack(alignment: .top, spacing: Spacing.sm) {
                            Image(systemName: "note.text")
                                .foregroundColor(.orange)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Notes")
                                    .font(.appCaption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.textSecondary)
                                
                                Text(notes)
                                    .font(.appSubheadline)
                                    .foregroundColor(.textPrimary)
                            }
                        }
                    }
                    
                    // Timeline
                    ApplicationTimeline(status: application.status)
                }
                .padding(.top, Spacing.xs)
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

struct ApplicationTimeline: View {
    let status: JobApplication.ApplicationStatus
    
    private let stages: [JobApplication.ApplicationStatus] = [
        .applied, .underReview, .interview, .offered, .accepted
    ]
    
    private func stageIndex(_ stage: JobApplication.ApplicationStatus) -> Int {
        stages.firstIndex(of: stage) ?? 0
    }
    
    private var currentIndex: Int {
        if status == .rejected {
            return -1  // Rejected doesn't show in timeline
        }
        return stageIndex(status)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Progress")
                .font(.appCaption)
                .fontWeight(.semibold)
                .foregroundColor(.textSecondary)
            
            HStack(spacing: 0) {
                ForEach(Array(stages.enumerated()), id: \.element) { index, stage in
                    let isActive = index <= currentIndex
                    let isLast = index == stages.count - 1
                    
                    // Stage Dot
                    Circle()
                        .fill(isActive ? Color(hex: stage.color) : Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                    
                    // Connector Line
                    if !isLast {
                        Rectangle()
                            .fill(index < currentIndex ? Color.brand.opacity(0.5) : Color.gray.opacity(0.2))
                            .frame(height: 2)
                    }
                }
            }
            
            // Labels
            HStack(spacing: 0) {
                ForEach(stages, id: \.self) { stage in
                    Text(shortLabel(for: stage))
                        .font(.system(size: 8))
                        .foregroundColor(.textTertiary)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.top, Spacing.xs)
    }
    
    private func shortLabel(for stage: JobApplication.ApplicationStatus) -> String {
        switch stage {
        case .applied: return "Applied"
        case .underReview: return "Review"
        case .interview: return "Interview"
        case .offered: return "Offered"
        case .accepted: return "Accepted"
        case .rejected: return "Rejected"
        }
    }
}

// MARK: - Stat Card (Reusable)

extension PlacementView {
    struct StatCard: View {
        let icon: String
        let value: String
        let label: String
        
        var body: some View {
            VStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.brand)
                
                Text(value)
                    .font(.appTitle3)
                    .foregroundColor(.textPrimary)
                
                Text(label)
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(Spacing.md)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            .cardShadow()
        }
    }
}

