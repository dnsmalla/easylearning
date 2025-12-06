//
//  SavedItemsViews.swift
//  Educa
//
//  Views for displaying saved universities, courses, jobs, and guides
//

import SwiftUI

// MARK: - Saved Universities View

struct SavedUniversitiesView: View {
    @EnvironmentObject var dataService: DataService
    @ObservedObject private var userData = UserDataManager.shared
    
    var savedUniversities: [University] {
        dataService.universities.filter { userData.savedUniversities.contains($0.id) }
    }
    
    var body: some View {
        Group {
            if savedUniversities.isEmpty {
                EmptyStateView(
                    icon: "building.columns",
                    title: "No Saved Universities",
                    message: "Universities you save will appear here"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: Spacing.md) {
                        ForEach(savedUniversities) { university in
                            NavigationLink {
                                UniversityDetailView(university: university)
                            } label: {
                                SavedUniversityCard(university: university)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(Spacing.md)
                    .padding(.bottom, 100)
                }
            }
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("Saved Universities")
    }
}

struct SavedUniversityCard: View {
    let university: University
    @ObservedObject private var userData = UserDataManager.shared
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Image
            AsyncImage(url: URL(string: university.image)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    Rectangle()
                        .fill(Color.brand.opacity(0.1))
                        .overlay {
                            Image(systemName: "building.columns")
                                .foregroundColor(.brand.opacity(0.5))
                        }
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(university.title)
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                
                Text(university.location)
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
                
                HStack {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", university.rating))
                            .font(.appCaption)
                            .foregroundColor(.textSecondary)
                    }
                    
                    Text("•")
                        .foregroundColor(.textTertiary)
                    
                    Text(university.annualFee)
                        .font(.appCaption)
                        .fontWeight(.semibold)
                        .foregroundColor(.brand)
                }
            }
            
            Spacer()
            
            Button {
                userData.toggleUniversitySaved(university.id)
            } label: {
                Image(systemName: "bookmark.fill")
                    .foregroundColor(.brand)
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

// MARK: - Saved Courses View

struct SavedCoursesView: View {
    @EnvironmentObject var dataService: DataService
    @ObservedObject private var userData = UserDataManager.shared
    
    var savedCourses: [Course] {
        dataService.courses.filter { userData.savedCourses.contains($0.id) }
    }
    
    var body: some View {
        Group {
            if savedCourses.isEmpty {
                EmptyStateView(
                    icon: "book.fill",
                    title: "No Saved Courses",
                    message: "Courses you save will appear here"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: Spacing.md) {
                        ForEach(savedCourses) { course in
                            SavedCourseCard(course: course)
                        }
                    }
                    .padding(Spacing.md)
                    .padding(.bottom, 100)
                }
            }
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("Saved Courses")
    }
}

struct SavedCourseCard: View {
    let course: Course
    @ObservedObject private var userData = UserDataManager.shared
    @EnvironmentObject var dataService: DataService
    
    var university: University? {
        dataService.getUniversity(by: course.universityId)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(course.name)
                        .font(.appHeadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    
                    if let uni = university {
                        Text(uni.title)
                            .font(.appCaption)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                Spacer()
                
                Button {
                    userData.toggleCourseSaved(course.id)
                } label: {
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(.brand)
                }
            }
            
            HStack(spacing: Spacing.md) {
                Label(course.degreeLevel, systemImage: "graduationcap")
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
                
                Label("\(course.duration) months", systemImage: "clock")
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
            }
            
            Text("$\(Int(course.tuitionFee).formatted())")
                .font(.appSubheadline)
                .fontWeight(.semibold)
                .foregroundColor(.brand)
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

// MARK: - Saved Jobs View

struct SavedJobsView: View {
    @EnvironmentObject var dataService: DataService
    @ObservedObject private var userData = UserDataManager.shared
    
    var savedJobs: [JobListing] {
        dataService.jobs.filter { userData.savedJobs.contains($0.id) }
    }
    
    var body: some View {
        Group {
            if savedJobs.isEmpty {
                EmptyStateView(
                    icon: "briefcase.fill",
                    title: "No Saved Jobs",
                    message: "Jobs you save will appear here"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: Spacing.md) {
                        ForEach(savedJobs) { job in
                            NavigationLink {
                                JobDetailView(job: job)
                            } label: {
                                SavedJobCard(job: job)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(Spacing.md)
                    .padding(.bottom, 100)
                }
            }
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("Saved Jobs")
    }
}

struct SavedJobCard: View {
    let job: JobListing
    @ObservedObject private var userData = UserDataManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(alignment: .top) {
                // Logo placeholder
                if let logo = job.companyLogo, !logo.isEmpty {
                    AsyncImage(url: URL(string: logo)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        default:
                            companyPlaceholder
                        }
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    companyPlaceholder
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(job.title)
                        .font(.appHeadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    
                    Text(job.company)
                        .font(.appSubheadline)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Button {
                    userData.toggleJobSaved(job.id)
                } label: {
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(.brand)
                }
            }
            
            HStack(spacing: Spacing.sm) {
                JobTag(text: job.type, color: .brand)
                if job.isRemote {
                    JobTag(text: "Remote", color: .green)
                }
            }
            
            HStack {
                Label(job.location, systemImage: "mappin.circle.fill")
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                Text(job.salary)
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.brand)
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
    
    private var companyPlaceholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.brand.opacity(0.1))
            .frame(width: 50, height: 50)
            .overlay {
                Image(systemName: "building.2")
                    .foregroundColor(.brand)
            }
    }
}

// MARK: - Saved Guides View

struct SavedGuidesView: View {
    @EnvironmentObject var dataService: DataService
    @ObservedObject private var userData = UserDataManager.shared
    
    var savedGuides: [StudentGuide] {
        dataService.guides.filter { userData.savedGuides.contains($0.id) }
    }
    
    var body: some View {
        Group {
            if savedGuides.isEmpty {
                EmptyStateView(
                    icon: "doc.text.fill",
                    title: "No Saved Guides",
                    message: "Guides you save will appear here"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: Spacing.md) {
                        ForEach(savedGuides) { guide in
                            NavigationLink {
                                GuideDetailView(guide: guide)
                            } label: {
                                SavedGuideCard(guide: guide)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(Spacing.md)
                    .padding(.bottom, 100)
                }
            }
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("Saved Guides")
    }
}

struct SavedGuideCard: View {
    let guide: StudentGuide
    @ObservedObject private var userData = UserDataManager.shared
    
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
                }
            }
            
            Spacer()
            
            Button {
                userData.toggleGuideSaved(guide.id)
            } label: {
                Image(systemName: "bookmark.fill")
                    .foregroundColor(.brand)
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}


