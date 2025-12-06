//
//  JourneyView.swift
//  Educa
//
//  Journey - Travel, Visa information, and Learning Path for students
//

import SwiftUI

struct JourneyView: View {
    @EnvironmentObject var dataService: DataService
    @State private var searchText = ""
    @State private var selectedTab = 0
    
    var filteredCountries: [Country] {
        var result = dataService.countries
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
        
        return result
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Selector
                Picker("View", selection: $selectedTab) {
                    Text("My Journey").tag(0)
                    Text("Countries").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                
                // Content
                if selectedTab == 0 {
                    journeyContent
                } else {
                    countriesContent
                }
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Journey")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ProfileMenuButton()
                }
            }
            .refreshable {
                await dataService.loadCountries()
            }
        }
    }
    
    // MARK: - Journey Content (Learning Path + Achievements)
    
    private var journeyContent: some View {
        ScrollView {
            VStack(spacing: Spacing.xxl) {
                // Progress Overview
                progressOverview
                
                // Learning Path
                LearningPathView()
                
                // Achievements
                AchievementsGridView()
            }
            .padding(Spacing.md)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Progress Overview
    
    private var progressOverview: some View {
        VStack(spacing: Spacing.md) {
            HStack {
                Text("Your Progress")
                    .font(.appTitle3)
                    .foregroundColor(.textPrimary)
                Spacer()
            }
            
            HStack(spacing: Spacing.lg) {
                // Steps Completed
                VStack(spacing: Spacing.xs) {
                    Text("\(completedSteps)/\(totalSteps)")
                        .font(.appTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.brand)
                    Text("Steps")
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(Spacing.md)
                .background(Color.brand.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                
                // Achievements Earned
                VStack(spacing: Spacing.xs) {
                    Text("\(unlockedAchievements)/\(totalAchievements)")
                        .font(.appTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    Text("Badges")
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(Spacing.md)
                .background(Color.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                
                // Progress Percentage
                VStack(spacing: Spacing.xs) {
                    Text("\(progressPercentage)%")
                        .font(.appTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.tertiary)
                    Text("Complete")
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(Spacing.md)
                .background(Color.tertiary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            }
        }
    }
    
    // MARK: - Computed Properties for Progress
    
    private var completedSteps: Int {
        dataService.learningSteps.filter { $0.status == .completed }.count
    }
    
    private var totalSteps: Int {
        dataService.learningSteps.count
    }
    
    private var unlockedAchievements: Int {
        dataService.achievements.filter { $0.isUnlocked }.count
    }
    
    private var totalAchievements: Int {
        dataService.achievements.count
    }
    
    private var progressPercentage: Int {
        guard totalSteps > 0 else { return 0 }
        return Int((Double(completedSteps) / Double(totalSteps)) * 100)
    }
    
    // MARK: - Countries Content
    
    private var countriesContent: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.textTertiary)
                TextField("Search countries...", text: $searchText)
            }
            .padding(Spacing.sm)
            .background(Color.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.sm)
            
            if dataService.isLoading {
                loadingView
            } else if filteredCountries.isEmpty {
                emptyView
            } else {
                countriesList
            }
        }
    }
    
    // MARK: - Countries List
    
    private var countriesList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                ForEach(filteredCountries) { country in
                    NavigationLink {
                        CountryDetailView(country: country)
                    } label: {
                        CountryCard(country: country)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(Spacing.md)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Loading & Empty Views
    
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
            Text("Loading countries...")
                .font(.appSubheadline)
                .foregroundColor(.textSecondary)
                .padding(.top, Spacing.md)
            Spacer()
        }
    }
    
    private var emptyView: some View {
        EmptyStateView(
            icon: "globe.americas",
            title: "No Countries Found",
            message: "Country information will appear here"
        )
    }
}

// MARK: - Country Card

struct CountryCard: View {
    let country: Country
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Flag
            Text(country.flag)
                .font(.system(size: 40))
                .frame(width: 60)
            
            // Info
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(country.name)
                    .font(.appHeadline)
                    .foregroundColor(.textPrimary)
                
                HStack(spacing: Spacing.md) {
                    Label(country.visaType, systemImage: "doc.text.fill")
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                    
                    Label(country.processingTime, systemImage: "clock.fill")
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                }
                
                HStack(spacing: Spacing.lg) {
                    // Success Rate
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("\(country.successRate)% success")
                            .font(.appCaption)
                            .foregroundColor(.textSecondary)
                    }
                    
                    // Visa Fee
                    Text("Fee: \(country.currency) \(Int(country.visaFee))")
                        .font(.appCaption)
                        .fontWeight(.medium)
                        .foregroundColor(.brand)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.textTertiary)
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

// MARK: - Preview

#Preview {
    JourneyView()
        .environmentObject(DataService.shared)
}
