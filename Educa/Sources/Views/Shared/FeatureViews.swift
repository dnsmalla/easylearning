//
//  FeatureViews.swift
//  Educa
//
//  Feature-specific views for Updates, Scholarships, and Comparisons
//

import SwiftUI

// MARK: - Update Card

struct UpdateCard: View {
    let update: AppUpdate
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Type Icon
            Circle()
                .fill(Color(hex: update.type.color).opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: update.type.icon)
                        .font(.body)
                        .foregroundColor(Color(hex: update.type.color))
                }
            
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(update.title)
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                
                Text(update.description)
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
                
                HStack {
                    Text(update.category)
                        .font(.appCaption2)
                        .foregroundColor(Color(hex: update.type.color))
                    
                    Text("•")
                        .foregroundColor(.textTertiary)
                    
                    Text(update.timestamp)
                        .font(.appCaption2)
                        .foregroundColor(.textTertiary)
                }
            }
            
            Spacer()
            
            if update.isRead == false {
                Circle()
                    .fill(Color.brand)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

// MARK: - Scholarship Card

struct ScholarshipCard: View {
    let scholarship: Scholarship
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Header
            HStack {
                if scholarship.isFullyFunded {
                    Text("FULLY FUNDED")
                        .font(.appCaption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, 2)
                        .background(Color.green)
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                Text(scholarship.deadline)
                    .font(.appCaption2)
                    .foregroundColor(.textTertiary)
            }
            
            Text(scholarship.name)
                .font(.appHeadline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
                .lineLimit(2)
            
            Text(scholarship.provider)
                .font(.appSubheadline)
                .foregroundColor(.textSecondary)
            
            HStack(spacing: Spacing.sm) {
                Label(scholarship.amount, systemImage: "dollarsign.circle.fill")
                    .font(.appCaption)
                    .foregroundColor(.green)
                
                Spacer()
                
                Text(scholarship.countries.first ?? "")
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
            }
            
            // Degree Levels
            HStack(spacing: Spacing.xs) {
                ForEach(scholarship.degreeLevel.prefix(2), id: \.self) { level in
                    Text(level)
                        .font(.appCaption2)
                        .foregroundColor(.brand)
                        .padding(.horizontal, Spacing.xs)
                        .padding(.vertical, 2)
                        .background(Color.brand.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(Spacing.md)
        .frame(width: 260)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

// MARK: - Scholarship Detail View

struct ScholarshipDetailView: View {
    let scholarship: Scholarship
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Header
                VStack(spacing: Spacing.md) {
                    if scholarship.isFullyFunded {
                        Text("FULLY FUNDED")
                            .font(.appCaption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.xs)
                            .background(Color.green)
                            .clipShape(Capsule())
                    }
                    
                    Text(scholarship.name)
                        .font(.appTitle2)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text(scholarship.provider)
                        .font(.appHeadline)
                        .foregroundColor(.textSecondary)
                    
                    HStack(spacing: Spacing.lg) {
                        VStack {
                            Text(scholarship.amount)
                                .font(.appTitle3)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                            Text("Amount")
                                .font(.appCaption)
                                .foregroundColor(.textSecondary)
                        }
                        
                        Divider()
                            .frame(height: 40)
                        
                        VStack {
                            Text(scholarship.deadline)
                                .font(.appTitle3)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                            Text("Deadline")
                                .font(.appCaption)
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
                .padding(Spacing.lg)
                .frame(maxWidth: .infinity)
                .background(Color.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
                
                // Description
                InfoSection(title: "About") {
                    Text(scholarship.description)
                        .font(.appBody)
                        .foregroundColor(.textSecondary)
                }
                
                // Eligibility
                InfoSection(title: "Eligibility") {
                    ForEach(scholarship.eligibility, id: \.self) { item in
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(item)
                                .font(.appBody)
                                .foregroundColor(.textPrimary)
                        }
                    }
                }
                
                // Coverage
                InfoSection(title: "What's Covered") {
                    ForEach(scholarship.coverageDetails, id: \.self) { item in
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "gift.fill")
                                .foregroundColor(.brand)
                            Text(item)
                                .font(.appBody)
                                .foregroundColor(.textPrimary)
                        }
                    }
                }
                
                // Countries & Degree Levels
                InfoSection(title: "Details") {
                    InfoRow(label: "Countries", value: scholarship.countries.joined(separator: ", "))
                    InfoRow(label: "Degree Levels", value: scholarship.degreeLevel.joined(separator: ", "))
                    if let fields = scholarship.fieldOfStudy {
                        InfoRow(label: "Fields of Study", value: fields.joined(separator: ", "))
                    }
                }
                
                // Apply Button
                Link(destination: URL(string: scholarship.applicationUrl)!) {
                    Label("Apply Now", systemImage: "arrow.up.right")
                }
                .buttonStyle(PrimaryButtonStyle(isFullWidth: true))
            }
            .padding(Spacing.md)
            .padding(.bottom, 100)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Updates List View

struct UpdatesListView: View {
    @EnvironmentObject var dataService: DataService
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                ForEach(dataService.updates) { update in
                    UpdateCard(update: update)
                }
            }
            .padding(Spacing.md)
            .padding(.bottom, 100)
        }
        .navigationTitle("Updates")
        .background(Color.backgroundPrimary)
    }
}

// MARK: - Scholarships View

struct ScholarshipsView: View {
    @EnvironmentObject var dataService: DataService
    @State private var selectedFilter = "All"
    
    let filters = ["All", "Fully Funded", "Master's", "PhD"]
    
    var filteredScholarships: [Scholarship] {
        switch selectedFilter {
        case "Fully Funded":
            return dataService.scholarships.filter { $0.isFullyFunded }
        case "Master's":
            return dataService.scholarships.filter { $0.degreeLevel.contains("Master's") }
        case "PhD":
            return dataService.scholarships.filter { $0.degreeLevel.contains("PhD") }
        default:
            return dataService.scholarships
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(filters, id: \.self) { filter in
                        FilterPill(
                            title: filter,
                            isSelected: selectedFilter == filter
                        ) {
                            selectedFilter = filter
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
            }
            .background(Color.backgroundSecondary)
            
            // List
            ScrollView {
                LazyVStack(spacing: Spacing.md) {
                    ForEach(filteredScholarships) { scholarship in
                        NavigationLink {
                            ScholarshipDetailView(scholarship: scholarship)
                        } label: {
                            ScholarshipListCard(scholarship: scholarship)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(Spacing.md)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Scholarships")
        .background(Color.backgroundPrimary)
    }
}

struct ScholarshipListCard: View {
    let scholarship: Scholarship
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                if scholarship.isFullyFunded {
                    Text("FULLY FUNDED")
                        .font(.appCaption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, 2)
                        .background(Color.green)
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                Label(scholarship.deadline, systemImage: "calendar")
                    .font(.appCaption)
                    .foregroundColor(.orange)
            }
            
            Text(scholarship.name)
                .font(.appHeadline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            Text(scholarship.provider)
                .font(.appSubheadline)
                .foregroundColor(.textSecondary)
            
            HStack {
                Text(scholarship.amount)
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

// MARK: - Guides List View

struct GuidesListView: View {
    @EnvironmentObject var dataService: DataService
    @State private var selectedCategory = "All"
    
    var categories: [String] {
        var cats = ["All"]
        let uniqueCats = Set(dataService.guides.map { $0.category })
        cats.append(contentsOf: uniqueCats.sorted())
        return cats
    }
    
    var filteredGuides: [StudentGuide] {
        if selectedCategory == "All" {
            return dataService.guides
        }
        return dataService.guides.filter { $0.category == selectedCategory }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Category Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(categories, id: \.self) { category in
                        FilterPill(
                            title: category,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
            }
            .background(Color.backgroundSecondary)
            
            // Guides List
            ScrollView {
                LazyVStack(spacing: Spacing.md) {
                    ForEach(filteredGuides) { guide in
                        NavigationLink {
                            GuideDetailView(guide: guide)
                        } label: {
                            GuideListCard(guide: guide)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(Spacing.md)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Student Guides")
        .background(Color.backgroundPrimary)
    }
}

struct GuideListCard: View {
    let guide: StudentGuide
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Thumbnail
            AsyncImage(url: URL(string: guide.imageUrl)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    Rectangle()
                        .fill(Color.brand.opacity(0.1))
                        .overlay {
                            Image(systemName: "doc.text")
                                .foregroundColor(.brand.opacity(0.5))
                        }
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(guide.category)
                    .font(.appCaption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.brand)
                
                Text(guide.title)
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                
                HStack {
                    Label("\(guide.readTime) min read", systemImage: "clock")
                        .font(.appCaption)
                        .foregroundColor(.textTertiary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.textTertiary)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

// MARK: - University Comparison View

struct UniversityComparisonView: View {
    @EnvironmentObject var dataService: DataService
    @Environment(\.dismiss) private var dismiss
    @State private var selectedUniversities: [University] = []
    @State private var searchText = ""
    
    var availableUniversities: [University] {
        if searchText.isEmpty {
            return dataService.universities
        }
        return dataService.universities.filter {
            $0.title.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Selected Universities
                if !selectedUniversities.isEmpty {
                    selectedSection
                }
                
                // Search & Select
                selectionSection
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Compare")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !selectedUniversities.isEmpty {
                        Button("Clear") {
                            selectedUniversities.removeAll()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    private var selectedSection: some View {
        VStack(spacing: Spacing.md) {
            Text("Comparing \(selectedUniversities.count) universities")
                .font(.appHeadline)
                .foregroundColor(.textPrimary)
                .padding(.top, Spacing.md)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(selectedUniversities) { university in
                        ComparisonCard(
                            university: university,
                            onRemove: {
                                selectedUniversities.removeAll { $0.id == university.id }
                            }
                        )
                    }
                }
                .padding(.horizontal, Spacing.md)
            }
            .padding(.bottom, Spacing.md)
            
            Divider()
        }
        .background(Color.backgroundSecondary)
    }
    
    private var selectionSection: some View {
        VStack(spacing: 0) {
            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.textTertiary)
                TextField("Search universities to add...", text: $searchText)
            }
            .padding(Spacing.sm)
            .background(Color.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            .padding(Spacing.md)
            
            // List
            List {
                ForEach(availableUniversities) { university in
                    let isSelected = selectedUniversities.contains { $0.id == university.id }
                    
                    Button {
                        toggleSelection(university)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(university.title)
                                    .font(.appSubheadline)
                                    .foregroundColor(.textPrimary)
                                Text(university.location)
                                    .font(.appCaption)
                                    .foregroundColor(.textSecondary)
                            }
                            
                            Spacer()
                            
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.brand)
                            } else if selectedUniversities.count >= 3 {
                                Image(systemName: "circle")
                                    .foregroundColor(.textTertiary)
                            } else {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.brand)
                            }
                        }
                    }
                    .disabled(!isSelected && selectedUniversities.count >= 3)
                }
            }
            .listStyle(PlainListStyle())
        }
    }
    
    private func toggleSelection(_ university: University) {
        if let index = selectedUniversities.firstIndex(where: { $0.id == university.id }) {
            selectedUniversities.remove(at: index)
            HapticManager.shared.light()
        } else if selectedUniversities.count < 3 {
            selectedUniversities.append(university)
            HapticManager.shared.medium()
        }
    }
}

struct ComparisonCard: View {
    let university: University
    let onRemove: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Header with remove button
            HStack {
                Text(university.title)
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                
                Spacer()
                
                Button {
                    onRemove()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.textTertiary)
                }
            }
            
            // Stats
            VStack(alignment: .leading, spacing: Spacing.xs) {
                ComparisonRow(label: "Location", value: university.location)
                ComparisonRow(label: "Rating", value: String(format: "%.1f ⭐", university.rating))
                ComparisonRow(label: "Annual Fee", value: university.annualFee)
                if let students = university.studentCount {
                    ComparisonRow(label: "Students", value: "\(students.formatted())")
                }
                if let ranking = university.ranking {
                    ComparisonRow(label: "Ranking", value: "#\(ranking)")
                }
            }
        }
        .padding(Spacing.md)
        .frame(width: 200)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

struct ComparisonRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.appCaption)
                .foregroundColor(.textSecondary)
            Spacer()
            Text(value)
                .font(.appCaption)
                .fontWeight(.medium)
                .foregroundColor(.textPrimary)
        }
    }
}

// MARK: - Notification Bell Button

struct NotificationBellButton: View {
    @EnvironmentObject var notificationsManager: NotificationsManager
    @State private var showNotifications = false
    
    var body: some View {
        Button {
            HapticManager.shared.tap()
            showNotifications = true
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bell.fill")
                    .font(.title3)
                    .foregroundColor(.brand)
                
                if notificationsManager.showBadge {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                        .offset(x: 4, y: -4)
                }
            }
        }
        .sheet(isPresented: $showNotifications) {
            NotificationsView()
        }
    }
}

// MARK: - Notifications View

struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var notificationsManager: NotificationsManager
    
    var body: some View {
        NavigationStack {
            Group {
                if notificationsManager.notifications.isEmpty {
                    EmptyStateView(
                        icon: "bell.slash",
                        title: "No Notifications",
                        message: "You're all caught up!"
                    )
                } else {
                    List {
                        ForEach(notificationsManager.notifications) { notification in
                            NotificationRow(notification: notification)
                                .onTapGesture {
                                    notificationsManager.markAsRead(notification.id)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        notificationsManager.deleteNotification(notification.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !notificationsManager.notifications.isEmpty {
                        Button("Read All") {
                            notificationsManager.markAllAsRead()
                        }
                    }
                }
            }
        }
    }
}

struct NotificationRow: View {
    let notification: AppNotification
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Icon
            Circle()
                .fill(notification.type.color.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: notification.type.icon)
                        .foregroundColor(notification.type.color)
                }
            
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                HStack {
                    Text(notification.title)
                        .font(.appSubheadline)
                        .fontWeight(notification.isRead ? .regular : .semibold)
                        .foregroundColor(.textPrimary)
                    
                    if !notification.isRead {
                        Circle()
                            .fill(Color.brand)
                            .frame(width: 6, height: 6)
                    }
                }
                
                Text(notification.message)
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
                
                Text(notification.formattedTime)
                    .font(.appCaption2)
                    .foregroundColor(.textTertiary)
            }
        }
        .padding(.vertical, Spacing.xs)
        .opacity(notification.isRead ? 0.7 : 1)
    }
}

