//
//  PlacementView.swift
//  Educa
//
//  Placement - Job listings, career opportunities, and application tracking
//

import SwiftUI

struct PlacementView: View {
    @EnvironmentObject var dataService: DataService
    @State private var searchText = ""
    @State private var selectedTab = 0
    @State private var selectedJobType = "All"
    
    let jobTypes = ["All", "Full-time", "Part-time", "Internship", "Remote"]
    
    var filteredJobs: [JobListing] {
        var result = dataService.searchJobs(searchText)
        
        if selectedJobType != "All" {
            result = result.filter { 
                $0.type.lowercased() == selectedJobType.lowercased() ||
                (selectedJobType == "Remote" && $0.isRemote)
            }
        }
        
        return result
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Selector
                Picker("View", selection: $selectedTab) {
                    Text("Jobs").tag(0)
                    Text("Applications").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                
                if selectedTab == 0 {
                    jobsContent
                } else {
                    applicationsContent
                }
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Placement")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ProfileMenuButton()
                }
            }
            .refreshable {
                await dataService.loadJobs()
            }
        }
    }
    
    // MARK: - Jobs Content
    
    private var jobsContent: some View {
        VStack(spacing: 0) {
            // Job Type Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(jobTypes, id: \.self) { type in
                        FilterPill(
                            title: type,
                            isSelected: selectedJobType == type
                        ) {
                            HapticManager.shared.selection()
                            withAnimation {
                                selectedJobType = type
                            }
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
            }
            .background(Color.backgroundSecondary)
            
            // Content
            if dataService.isLoading {
                loadingView
            } else {
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Featured Jobs Section
                        if !dataService.jobs.isEmpty {
                            featuredJobsSection
                        }
                        
                        // All Jobs
                        allJobsSection
                    }
                    .padding(.bottom, 100)
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search jobs...")
    }
    
    // MARK: - Featured Jobs Section
    
    private var featuredJobsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Featured Opportunities")
                .font(.appTitle3)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, Spacing.md)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(dataService.jobs.prefix(5)) { job in
                        NavigationLink {
                            JobDetailView(job: job)
                        } label: {
                            FeaturedJobCard(job: job)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, Spacing.md)
            }
        }
    }
    
    // MARK: - All Jobs Section
    
    private var allJobsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("All Jobs")
                    .font(.appTitle3)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text("\(filteredJobs.count) jobs")
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
            }
            .padding(.horizontal, Spacing.md)
            
            if filteredJobs.isEmpty {
                emptyView
            } else {
                LazyVStack(spacing: Spacing.md) {
                    ForEach(filteredJobs) { job in
                        NavigationLink {
                            JobDetailView(job: job)
                        } label: {
                            JobCard(job: job)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, Spacing.md)
            }
        }
    }
    
    // MARK: - Applications Content
    
    private var applicationsContent: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Application Stats
                applicationStats
                
                // Application Tracker
                ApplicationTrackerView()
            }
            .padding(Spacing.md)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Application Stats
    
    private var applicationStats: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Application Overview")
                .font(.appTitle3)
                .foregroundColor(.textPrimary)
            
            HStack(spacing: Spacing.md) {
                StatCard(
                    icon: "doc.text",
                    value: "\(dataService.applications.count)",
                    label: "Total"
                )
                
                StatCard(
                    icon: "clock",
                    value: "\(pendingCount)",
                    label: "Pending"
                )
                
                StatCard(
                    icon: "checkmark.circle",
                    value: "\(interviewCount)",
                    label: "Interview"
                )
            }
        }
    }
    
    private var pendingCount: Int {
        dataService.applications.filter { $0.status == .applied || $0.status == .underReview }.count
    }
    
    private var interviewCount: Int {
        dataService.applications.filter { $0.status == .interview }.count
    }
    
    // MARK: - Loading & Empty Views
    
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
            Text("Loading opportunities...")
                .font(.appSubheadline)
                .foregroundColor(.textSecondary)
                .padding(.top, Spacing.md)
            Spacer()
        }
    }
    
    private var emptyView: some View {
        EmptyStateView(
            icon: "briefcase",
            title: "No Jobs Found",
            message: searchText.isEmpty 
                ? "Job opportunities will appear here" 
                : "Try adjusting your search"
        )
        .padding(.top, Spacing.xxl)
    }
}

// MARK: - Featured Job Card

struct FeaturedJobCard: View {
    let job: JobListing
    @ObservedObject private var userData = UserDataManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Header
            HStack {
                // Company Logo
                if let logoURL = job.companyLogo, !logoURL.isEmpty {
                    AsyncImage(url: URL(string: logoURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        default:
                            companyPlaceholder
                        }
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    companyPlaceholder
                }
                
                Spacer()
                
                // Bookmark
                Button {
                    userData.toggleJobSaved(job.id)
                } label: {
                    Image(systemName: userData.isJobSaved(job.id) ? "bookmark.fill" : "bookmark")
                        .foregroundColor(userData.isJobSaved(job.id) ? .brand : .textTertiary)
                }
            }
            
            Text(job.title)
                .font(.appHeadline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
                .lineLimit(2)
            
            Text(job.company)
                .font(.appSubheadline)
                .foregroundColor(.textSecondary)
            
            Spacer()
            
            // Tags
            HStack(spacing: Spacing.xs) {
                JobTag(text: job.type, color: .brand)
                if job.isRemote {
                    JobTag(text: "Remote", color: .green)
                }
            }
            
            // Salary
            Text(job.salary)
                .font(.appSubheadline)
                .fontWeight(.semibold)
                .foregroundColor(.brand)
        }
        .padding(Spacing.md)
        .frame(width: 220, height: 200)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
    
    private var companyPlaceholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.brand.opacity(0.1))
            .frame(width: 40, height: 40)
            .overlay {
                Image(systemName: "building.2")
                    .foregroundColor(.brand)
            }
    }
}

// MARK: - Job Card

struct JobCard: View {
    let job: JobListing
    @ObservedObject private var userData = UserDataManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Header
            HStack(alignment: .top) {
                // Company Logo
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
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
                } else {
                    companyPlaceholder
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(job.title)
                        .font(.appHeadline)
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)
                    
                    Text(job.company)
                        .font(.appSubheadline)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                // Bookmark
                Button {
                    userData.toggleJobSaved(job.id)
                } label: {
                    Image(systemName: userData.isJobSaved(job.id) ? "bookmark.fill" : "bookmark")
                        .foregroundColor(userData.isJobSaved(job.id) ? .brand : .textTertiary)
                }
            }
            
            // Tags
            HStack(spacing: Spacing.sm) {
                JobTag(text: job.type, color: .brand)
                
                if job.isRemote {
                    JobTag(text: "Remote", color: .green)
                }
                
                JobTag(text: job.experienceLevel, color: .orange)
            }
            
            // Location & Salary
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
        RoundedRectangle(cornerRadius: CornerRadius.small)
            .fill(Color.brand.opacity(0.1))
            .frame(width: 50, height: 50)
            .overlay {
                Image(systemName: "building.2")
                    .foregroundColor(.brand)
            }
    }
}

// MARK: - Job Tag

struct JobTag: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.appCaption2)
            .fontWeight(.medium)
            .foregroundColor(color)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xxs)
            .background(color.opacity(0.1))
            .clipShape(Capsule())
    }
}

// MARK: - Preview

#Preview {
    PlacementView()
        .environmentObject(DataService.shared)
}
