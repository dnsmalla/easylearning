//
//  DetailViews.swift
//  Educa
//
//  Detail view screens for universities, countries, jobs, etc.
//

import SwiftUI

// MARK: - University Detail View

struct UniversityDetailView: View {
    let university: University
    @EnvironmentObject var dataService: DataService
    @ObservedObject private var userData = UserDataManager.shared
    
    var courses: [Course] {
        dataService.getCourses(for: university.id)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Hero Image
                ZStack(alignment: .bottomLeading) {
                    AsyncImage(url: URL(string: university.image)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        default:
                            Rectangle()
                                .fill(Color.brand.opacity(0.2))
                        }
                    }
                    .frame(height: 250)
                    .clipped()
                    .overlay {
                        LinearGradient.heroOverlay
                    }
                    
                    // Title overlay
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(university.title)
                            .font(.appTitle2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        HStack {
                            Label(university.location, systemImage: "mappin.circle.fill")
                            if let ranking = university.ranking {
                                Text("•")
                                Text("Rank #\(ranking)")
                            }
                        }
                        .font(.appSubheadline)
                        .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(Spacing.lg)
                }
                
                VStack(spacing: Spacing.lg) {
                    // Quick Stats
                    HStack(spacing: Spacing.md) {
                        StatBadge(icon: "star.fill", value: String(format: "%.1f", university.rating), label: "Rating")
                        StatBadge(icon: "dollarsign.circle", value: university.annualFee, label: "Annual Fee")
                        if let students = university.studentCount {
                            StatBadge(icon: "person.3.fill", value: "\(students/1000)k+", label: "Students")
                        }
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("About")
                            .font(.appTitle3)
                            .foregroundColor(.textPrimary)
                        
                        Text(university.description)
                            .font(.appBody)
                            .foregroundColor(.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Programs
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Programs Offered")
                            .font(.appTitle3)
                            .foregroundColor(.textPrimary)
                        
                        FlowLayout(spacing: Spacing.xs) {
                            ForEach(university.programs, id: \.self) { program in
                                Text(program)
                                    .font(.appCaption)
                                    .padding(.horizontal, Spacing.sm)
                                    .padding(.vertical, Spacing.xxs)
                                    .background(Color.brand.opacity(0.1))
                                    .foregroundColor(.brand)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Courses
                    if !courses.isEmpty {
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Available Courses")
                                .font(.appTitle3)
                                .foregroundColor(.textPrimary)
                            
                            ForEach(courses.prefix(5)) { course in
                                CourseRow(course: course)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Actions
                    HStack(spacing: Spacing.md) {
                        Button {
                            userData.toggleUniversitySaved(university.id)
                        } label: {
                            Label(
                                userData.isUniversitySaved(university.id) ? "Saved" : "Save",
                                systemImage: userData.isUniversitySaved(university.id) ? "bookmark.fill" : "bookmark"
                            )
                        }
                        .buttonStyle(SecondaryButtonStyle(isFullWidth: true))
                        
                        if let website = university.website {
                            Link(destination: URL(string: website)!) {
                                Label("Visit Website", systemImage: "globe")
                            }
                            .buttonStyle(PrimaryButtonStyle(isFullWidth: true))
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)
            }
            .padding(.bottom, 100)
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Country Detail View

struct CountryDetailView: View {
    let country: Country
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Header
                VStack(spacing: Spacing.md) {
                    Text(country.flag)
                        .font(.system(size: 80))
                    
                    Text(country.name)
                        .font(.appTitle)
                        .foregroundColor(.textPrimary)
                    
                    HStack(spacing: Spacing.lg) {
                        VStack {
                            Text("\(country.successRate)%")
                                .font(.appTitle2)
                                .foregroundColor(.green)
                            Text("Success Rate")
                                .font(.appCaption)
                                .foregroundColor(.textSecondary)
                        }
                        
                        VStack {
                            Text("\(country.currency) \(Int(country.visaFee))")
                                .font(.appTitle2)
                                .foregroundColor(.brand)
                            Text("Visa Fee")
                                .font(.appCaption)
                                .foregroundColor(.textSecondary)
                        }
                        
                        VStack {
                            Text(country.processingTime)
                                .font(.appTitle2)
                                .foregroundColor(.orange)
                            Text("Processing")
                                .font(.appCaption)
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
                .padding(Spacing.lg)
                .background(Color.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
                
                // Visa Info
                InfoSection(title: "Visa Information") {
                    InfoRow(label: "Visa Type", value: country.visaType)
                    InfoRow(label: "Validity", value: country.visaValidity)
                    InfoRow(label: "Work Permission", value: country.workPermission)
                }
                
                // Requirements
                InfoSection(title: "Requirements") {
                    Text(country.languageRequirements)
                        .font(.appBody)
                        .foregroundColor(.textSecondary)
                    
                    Text(country.financialRequirements)
                        .font(.appBody)
                        .foregroundColor(.textSecondary)
                        .padding(.top, Spacing.xs)
                }
                
                // Document Checklist
                InfoSection(title: "Document Checklist") {
                    ForEach(country.documentChecklist, id: \.self) { doc in
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(doc)
                                .font(.appBody)
                                .foregroundColor(.textPrimary)
                        }
                    }
                }
                
                // Student Benefits
                InfoSection(title: "Student Benefits") {
                    ForEach(country.studentBenefits, id: \.self) { benefit in
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(benefit)
                                .font(.appBody)
                                .foregroundColor(.textPrimary)
                        }
                    }
                }
                
                // Cost of Living
                InfoSection(title: "Cost of Living") {
                    Text(country.costOfLiving)
                        .font(.appBody)
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(Spacing.md)
            .padding(.bottom, 100)
        }
        .navigationTitle(country.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Job Detail View

struct JobDetailView: View {
    let job: JobListing
    @ObservedObject private var userData = UserDataManager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Header
                VStack(spacing: Spacing.md) {
                    if let logo = job.companyLogo, !logo.isEmpty {
                        AsyncImage(url: URL(string: logo)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            default:
                                Circle()
                                    .fill(Color.brand.opacity(0.1))
                                    .overlay {
                                        Image(systemName: "building.2")
                                            .font(.largeTitle)
                                            .foregroundColor(.brand)
                                    }
                            }
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                    }
                    
                    Text(job.title)
                        .font(.appTitle2)
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text(job.company)
                        .font(.appHeadline)
                        .foregroundColor(.textSecondary)
                    
                    HStack(spacing: Spacing.md) {
                        JobTag(text: job.type, color: .brand)
                        if job.isRemote {
                            JobTag(text: "Remote", color: .green)
                        }
                        JobTag(text: job.experienceLevel, color: .orange)
                    }
                    
                    Text(job.salary)
                        .font(.appTitle3)
                        .foregroundColor(.brand)
                }
                .padding(Spacing.lg)
                .frame(maxWidth: .infinity)
                .background(Color.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
                
                // Description
                InfoSection(title: "Description") {
                    Text(job.description)
                        .font(.appBody)
                        .foregroundColor(.textSecondary)
                }
                
                // Requirements
                InfoSection(title: "Requirements") {
                    ForEach(job.requirements, id: \.self) { req in
                        HStack(alignment: .top, spacing: Spacing.sm) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 6))
                                .foregroundColor(.brand)
                                .padding(.top, 6)
                            Text(req)
                                .font(.appBody)
                                .foregroundColor(.textPrimary)
                        }
                    }
                }
                
                // Benefits
                InfoSection(title: "Benefits") {
                    ForEach(job.benefits, id: \.self) { benefit in
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(benefit)
                                .font(.appBody)
                                .foregroundColor(.textPrimary)
                        }
                    }
                }
                
                // Actions
                HStack(spacing: Spacing.md) {
                    Button {
                        userData.toggleJobSaved(job.id)
                    } label: {
                        Label(
                            userData.isJobSaved(job.id) ? "Saved" : "Save",
                            systemImage: userData.isJobSaved(job.id) ? "bookmark.fill" : "bookmark"
                        )
                    }
                    .buttonStyle(SecondaryButtonStyle(isFullWidth: true))
                    
                    Link(destination: URL(string: job.applyUrl)!) {
                        Label("Apply Now", systemImage: "paperplane.fill")
                    }
                    .buttonStyle(PrimaryButtonStyle(isFullWidth: true))
                }
            }
            .padding(Spacing.md)
            .padding(.bottom, 100)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Guide Detail View

struct GuideDetailView: View {
    let guide: StudentGuide
    @ObservedObject private var userData = UserDataManager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Hero
                AsyncImage(url: URL(string: guide.imageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        Rectangle()
                            .fill(Color.brand.opacity(0.1))
                    }
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
                
                VStack(alignment: .leading, spacing: Spacing.md) {
                    // Category & Read Time
                    HStack {
                        Text(guide.category)
                            .font(.appCaption)
                            .fontWeight(.semibold)
                            .foregroundColor(.brand)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, Spacing.xxs)
                            .background(Color.brand.opacity(0.1))
                            .clipShape(Capsule())
                        
                        Spacer()
                        
                        Label("\(guide.readTime) min read", systemImage: "clock")
                            .font(.appCaption)
                            .foregroundColor(.textSecondary)
                    }
                    
                    // Title
                    Text(guide.title)
                        .font(.appTitle2)
                        .foregroundColor(.textPrimary)
                    
                    // Author & Date
                    if let author = guide.author {
                        HStack {
                            Text("By \(author)")
                            Text("•")
                            Text(guide.publishDate)
                        }
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                    }
                    
                    Divider()
                    
                    // Content
                    Text(guide.content)
                        .font(.appBody)
                        .foregroundColor(.textPrimary)
                        .lineSpacing(6)
                    
                    // Tags
                    FlowLayout(spacing: Spacing.xs) {
                        ForEach(guide.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.appCaption)
                                .foregroundColor(.brand)
                        }
                    }
                    .padding(.top, Spacing.md)
                }
            }
            .padding(Spacing.md)
            .padding(.bottom, 100)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    userData.toggleGuideSaved(guide.id)
                } label: {
                    Image(systemName: userData.isGuideSaved(guide.id) ? "bookmark.fill" : "bookmark")
                        .foregroundColor(.brand)
                }
            }
        }
    }
}

// MARK: - Helper Components

struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: Spacing.xxs) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.brand)
            Text(value)
                .font(.appSubheadline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            Text(label)
                .font(.appCaption2)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.sm)
        .background(Color.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

struct InfoSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(.appTitle3)
                .foregroundColor(.textPrimary)
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.md)
        .background(Color.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.appSubheadline)
                .foregroundColor(.textSecondary)
            Spacer()
            Text(value)
                .font(.appSubheadline)
                .foregroundColor(.textPrimary)
        }
    }
}

struct CourseRow: View {
    let course: Course
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(course.name)
                    .font(.appSubheadline)
                    .foregroundColor(.textPrimary)
                Text("\(course.degreeLevel) • \(course.duration) months")
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
            }
            Spacer()
            Text("$\(Int(course.tuitionFee))")
                .font(.appSubheadline)
                .foregroundColor(.brand)
        }
        .padding(Spacing.sm)
        .background(Color.backgroundTertiary)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
                
                self.size.width = max(self.size.width, x)
            }
            
            self.size.height = y + rowHeight
        }
    }
}

