//
//  CountrySelectionView.swift
//  Educa
//
//  Country selection for onboarding and profile
//

import SwiftUI

struct CountrySelectionView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataService: DataService
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCountry: DestinationCountry?
    @State private var searchText = ""
    @State private var animateContent = false
    
    var isOnboarding: Bool = false
    var onSelect: ((DestinationCountry) -> Void)?
    
    var filteredCountries: [DestinationCountry] {
        if searchText.isEmpty {
            return DestinationCountry.allCases
        }
        return DestinationCountry.allCases.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color.backgroundPrimary, Color.brand.opacity(0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    if isOnboarding {
                        onboardingHeader
                    }
                    
                    // Search
                    searchBar
                    
                    // Countries Grid
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: Spacing.md),
                            GridItem(.flexible(), spacing: Spacing.md)
                        ], spacing: Spacing.md) {
                            ForEach(Array(filteredCountries.enumerated()), id: \.element.id) { index, country in
                                CountrySelectionCard(
                                    country: country,
                                    isSelected: selectedCountry == country
                                )
                                .onTapGesture {
                                    HapticManager.shared.selection()
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedCountry = country
                                    }
                                }
                                .opacity(animateContent ? 1 : 0)
                                .offset(y: animateContent ? 0 : 20)
                                .animation(
                                    .spring(response: 0.4, dampingFraction: 0.8)
                                    .delay(Double(index) * 0.05),
                                    value: animateContent
                                )
                            }
                        }
                        .padding(Spacing.md)
                        .padding(.bottom, 120)
                    }
                    
                    // Continue Button
                    if selectedCountry != nil {
                        continueButton
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle(isOnboarding ? "" : "Select Country")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !isOnboarding {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.brand)
                    }
                }
            }
        }
        .onAppear {
            selectedCountry = appState.selectedCountry
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                animateContent = true
            }
        }
    }
    
    // MARK: - Onboarding Header
    
    private var onboardingHeader: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "graduationcap.fill")
                .font(.system(size: 50))
                .foregroundStyle(LinearGradient.brandGradient)
            
            Text("Where do you want\nto study?")
                .font(.appTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(.textPrimary)
            
            Text("Select your dream destination and we'll personalize\neverything for you")
                .font(.appSubheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, Spacing.xl)
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : -20)
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.body)
                .foregroundColor(.textTertiary)
            
            TextField("Search countries...", text: $searchText)
                .font(.appBody)
        }
        .padding(Spacing.md)
        .background(Color.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large, style: .continuous))
        .padding(.horizontal, Spacing.md)
        .padding(.bottom, Spacing.sm)
    }
    
    // MARK: - Continue Button
    
    private var continueButton: some View {
        VStack(spacing: 0) {
            Divider()
            
            Button {
                guard let country = selectedCountry else { return }
                HapticManager.shared.success()
                
                if isOnboarding {
                    appState.completeOnboarding(with: country)
                    Task {
                        await dataService.loadCountryData(for: country)
                    }
                } else {
                    appState.selectedCountry = country
                    Task {
                        await dataService.loadCountryData(for: country)
                    }
                    onSelect?(country)
                    dismiss()
                }
            } label: {
                HStack(spacing: Spacing.sm) {
                    if let country = selectedCountry {
                        Text(country.flag)
                            .font(.title2)
                        Text("Continue with \(country.name)")
                            .fontWeight(.semibold)
                    }
                    
                    Image(systemName: "arrow.right")
                        .font(.body.weight(.semibold))
                }
            }
            .buttonStyle(PrimaryButtonStyle(isFullWidth: true))
            .padding(Spacing.md)
        }
        .background(Color.backgroundPrimary)
    }
}

// MARK: - Country Selection Card

struct CountrySelectionCard: View {
    let country: DestinationCountry
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Flag and selection indicator
            HStack {
                Text(country.flag)
                    .font(.system(size: 36))
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.brand)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            // Country name
            Text(country.name)
                .font(.appHeadline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            // Key info
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text(country.workHoursAllowed)
                        .font(.appCaption2)
                }
                .foregroundColor(.textSecondary)
                
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "doc.text")
                        .font(.caption2)
                    Text(country.primaryLanguageTest)
                        .font(.appCaption2)
                }
                .foregroundColor(.textSecondary)
            }
            
            // Highlights preview
            if !country.highlights.isEmpty {
                HStack(spacing: Spacing.xxs) {
                    ForEach(country.highlights.prefix(2), id: \.self) { highlight in
                        Text(highlight)
                            .font(.appCaption2)
                            .foregroundColor(.brand)
                            .padding(.horizontal, Spacing.xs)
                            .padding(.vertical, 2)
                            .background(Color.brand.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.xl, style: .continuous)
                .fill(Color.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.xl, style: .continuous)
                        .stroke(isSelected ? Color.brand : Color.clear, lineWidth: 2)
                )
        )
        .shadow(
            color: isSelected ? Color.brand.opacity(0.2) : Color.black.opacity(0.05),
            radius: isSelected ? 12 : 8,
            x: 0,
            y: isSelected ? 6 : 4
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Welcome View

struct WelcomeView: View {
    var onContinue: () -> Void
    @State private var animateContent = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "0A84FF").opacity(0.1),
                    Color(hex: "5AC8FA").opacity(0.05),
                    Color.backgroundPrimary
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: Spacing.xxl) {
                Spacer()
                
                // Logo and title
                VStack(spacing: Spacing.lg) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient.brandGradient)
                            .frame(width: 120, height: 120)
                            .shadow(color: Color.brand.opacity(0.3), radius: 20, x: 0, y: 10)
                        
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 50, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .opacity(animateContent ? 1 : 0)
                    .scaleEffect(animateContent ? 1 : 0.5)
                    
                    Text("Educa")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimary)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                    
                    Text("Your Study Abroad Journey\nStarts Here")
                        .font(.appTitle3)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                }
                
                Spacer()
                
                // Features
                VStack(spacing: Spacing.md) {
                    WelcomeFeatureRow(icon: "building.columns.fill", title: "Universities", description: "Explore top universities worldwide")
                    WelcomeFeatureRow(icon: "doc.text.fill", title: "Visa Guidance", description: "Step-by-step visa application help")
                    WelcomeFeatureRow(icon: "briefcase.fill", title: "Jobs", description: "Find part-time & career opportunities")
                    WelcomeFeatureRow(icon: "dollarsign.circle.fill", title: "Finance", description: "Scholarships & money transfer")
                }
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 30)
                
                Spacer()
                
                // Get Started Button
                Button {
                    HapticManager.shared.medium()
                    onContinue()
                } label: {
                    HStack {
                        Text("Get Started")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                }
                .buttonStyle(PrimaryButtonStyle(isFullWidth: true))
                .padding(.horizontal, Spacing.lg)
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
            }
            .padding(.bottom, Spacing.xxl)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                animateContent = true
            }
        }
    }
}

struct WelcomeFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.brand.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(.brand)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Text(description)
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, Spacing.lg)
    }
}

// MARK: - Preview

#Preview {
    CountrySelectionView(isOnboarding: true)
        .environmentObject(AppState())
        .environmentObject(DataService.shared)
}

