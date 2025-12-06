//
//  TravelView.swift
//  Educa
//
//  Travel Services - Agencies, Visa Consultants, and Accommodation Providers
//

import SwiftUI

struct TravelView: View {
    @EnvironmentObject var dataService: DataService
    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var selectedAgency: TravelAgency?
    @State private var selectedConsultant: VisaConsultant?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Selector
                Picker("View", selection: $selectedTab) {
                    Text("Agencies").tag(0)
                    Text("Visa Help").tag(1)
                    Text("Accommodation").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                
                // Content
                if selectedTab == 0 {
                    travelAgenciesContent
                } else if selectedTab == 1 {
                    visaConsultantsContent
                } else {
                    accommodationContent
                }
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Travel Services")
            .refreshable {
                await dataService.loadTravelAgencies()
            }
            .sheet(item: $selectedAgency) { agency in
                TravelAgencyDetailView(agency: agency)
            }
            .sheet(item: $selectedConsultant) { consultant in
                VisaConsultantDetailView(consultant: consultant)
            }
        }
    }
    
    // MARK: - Travel Agencies Content
    
    private var travelAgenciesContent: some View {
        VStack(spacing: 0) {
            // Quick Stats
            travelStats
            
            // Search
            searchBar(placeholder: "Search travel agencies...")
            
            // Content
            if dataService.travelAgencies.isEmpty {
                Spacer()
                EmptyStateView(
                    icon: "airplane",
                    title: "No Agencies Found",
                    message: "Travel agencies will appear here"
                )
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: Spacing.md) {
                        // Featured Section
                        if let topAgency = topRatedAgency {
                            FeaturedAgencyCard(agency: topAgency)
                                .onTapGesture {
                                    selectedAgency = topAgency
                                }
                        }
                        
                        ForEach(filteredAgencies) { agency in
                            TravelAgencyCard(agency: agency)
                                .onTapGesture {
                                    HapticManager.shared.tap()
                                    selectedAgency = agency
                                }
                        }
                    }
                    .padding(Spacing.md)
                    .padding(.bottom, 100)
                }
            }
        }
    }
    
    // MARK: - Visa Consultants Content
    
    private var visaConsultantsContent: some View {
        VStack(spacing: 0) {
            // Stats
            visaStats
            
            // Search
            searchBar(placeholder: "Search visa consultants...")
            
            // Content
            if dataService.visaConsultants.isEmpty {
                Spacer()
                EmptyStateView(
                    icon: "doc.text.fill",
                    title: "No Consultants Found",
                    message: "Visa consultants will appear here"
                )
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: Spacing.md) {
                        ForEach(filteredConsultants) { consultant in
                            VisaConsultantCard(consultant: consultant)
                                .onTapGesture {
                                    HapticManager.shared.tap()
                                    selectedConsultant = consultant
                                }
                        }
                    }
                    .padding(Spacing.md)
                    .padding(.bottom, 100)
                }
            }
        }
    }
    
    // MARK: - Accommodation Content
    
    private var accommodationContent: some View {
        VStack(spacing: 0) {
            // Stats
            accommodationStats
            
            // Search
            searchBar(placeholder: "Search accommodation...")
            
            // Content
            if dataService.accommodationProviders.isEmpty {
                Spacer()
                EmptyStateView(
                    icon: "house.fill",
                    title: "No Providers Found",
                    message: "Accommodation providers will appear here"
                )
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: Spacing.md) {
                        ForEach(dataService.accommodationProviders) { provider in
                            AccommodationCard(provider: provider)
                        }
                    }
                    .padding(Spacing.md)
                    .padding(.bottom, 100)
                }
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func searchBar(placeholder: String) -> some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.textTertiary)
            TextField(placeholder, text: $searchText)
        }
        .padding(Spacing.sm)
        .background(Color.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        .padding(.horizontal, Spacing.md)
        .padding(.bottom, Spacing.sm)
    }
    
    private var travelStats: some View {
        HStack(spacing: Spacing.md) {
            StatBox(icon: "building.2", value: "\(dataService.travelAgencies.count)", label: "Agencies")
            StatBox(icon: "globe", value: "\(uniqueDestinations)", label: "Destinations")
            StatBox(icon: "checkmark.seal.fill", value: "\(verifiedAgencies)", label: "Verified")
        }
        .padding(Spacing.md)
    }
    
    private var visaStats: some View {
        HStack(spacing: Spacing.md) {
            StatBox(icon: "person.badge.shield.checkmark", value: "\(dataService.visaConsultants.count)", label: "Consultants")
            StatBox(icon: "percent", value: "\(avgSuccessRate)%", label: "Success Rate")
            StatBox(icon: "checkmark.seal.fill", value: "\(registeredConsultants)", label: "Registered")
        }
        .padding(Spacing.md)
    }
    
    private var accommodationStats: some View {
        HStack(spacing: Spacing.md) {
            StatBox(icon: "house.fill", value: "\(dataService.accommodationProviders.count)", label: "Providers")
            StatBox(icon: "mappin.circle", value: "\(uniqueLocations)", label: "Locations")
            StatBox(icon: "star.fill", value: String(format: "%.1f", avgAccommodationRating), label: "Avg Rating")
        }
        .padding(Spacing.md)
    }
    
    // MARK: - Computed Properties
    
    private var filteredAgencies: [TravelAgency] {
        if searchText.isEmpty {
            return dataService.travelAgencies.sorted { $0.rating > $1.rating }
        }
        return dataService.travelAgencies.filter {
            $0.name.lowercased().contains(searchText.lowercased()) ||
            $0.destinations.joined().lowercased().contains(searchText.lowercased())
        }
    }
    
    private var filteredConsultants: [VisaConsultant] {
        if searchText.isEmpty {
            return dataService.visaConsultants.sorted { $0.successRate > $1.successRate }
        }
        return dataService.visaConsultants.filter {
            $0.name.lowercased().contains(searchText.lowercased()) ||
            $0.countriesServed.joined().lowercased().contains(searchText.lowercased())
        }
    }
    
    private var topRatedAgency: TravelAgency? {
        dataService.travelAgencies.max { $0.rating < $1.rating }
    }
    
    private var uniqueDestinations: Int {
        Set(dataService.travelAgencies.flatMap { $0.destinations }).count
    }
    
    private var verifiedAgencies: Int {
        dataService.travelAgencies.filter { $0.isVerified }.count
    }
    
    private var avgSuccessRate: Int {
        guard !dataService.visaConsultants.isEmpty else { return 0 }
        let total = dataService.visaConsultants.reduce(0) { $0 + $1.successRate }
        return total / dataService.visaConsultants.count
    }
    
    private var registeredConsultants: Int {
        dataService.visaConsultants.filter { $0.isGovernmentRegistered }.count
    }
    
    private var uniqueLocations: Int {
        Set(dataService.accommodationProviders.flatMap { $0.locations }).count
    }
    
    private var avgAccommodationRating: Double {
        guard !dataService.accommodationProviders.isEmpty else { return 0 }
        let total = dataService.accommodationProviders.reduce(0) { $0 + $1.rating }
        return total / Double(dataService.accommodationProviders.count)
    }
}

// MARK: - Featured Agency Card

struct FeaturedAgencyCard: View {
    let agency: TravelAgency
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Badge
            HStack {
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                    Text("TOP RATED")
                        .font(.appCaption2)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, 4)
                .background(LinearGradient.premiumGradient)
                .clipShape(Capsule())
                
                Spacer()
                
                if agency.isVerified {
                    HStack(spacing: 3) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                        Text("Verified")
                            .font(.appCaption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            HStack(spacing: Spacing.md) {
                // Logo
                AsyncImage(url: URL(string: agency.logo)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    default:
                        Circle()
                            .fill(Color.premium.opacity(0.1))
                            .overlay {
                                Image(systemName: "airplane")
                                    .foregroundColor(.premium)
                            }
                    }
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(agency.name)
                        .font(.appHeadline)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    HStack(spacing: Spacing.sm) {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", agency.rating))
                                .fontWeight(.semibold)
                        }
                        .font(.appCaption)
                        .foregroundColor(.textPrimary)
                        
                        Text("•")
                            .foregroundColor(.textTertiary)
                        
                        Text("\(agency.reviewCount) reviews")
                            .font(.appCaption)
                            .foregroundColor(.textSecondary)
                    }
                    
                    Text(agency.destinations.prefix(3).joined(separator: ", "))
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(agency.priceRange)
                        .font(.appSubheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.brand)
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.textTertiary)
                }
            }
        }
        .padding(Spacing.md)
        .background(
            LinearGradient(
                colors: [Color.premium.opacity(0.1), Color.premium.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.large)
                .stroke(Color.premium.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Travel Agency Card

struct TravelAgencyCard: View {
    let agency: TravelAgency
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Logo
            AsyncImage(url: URL(string: agency.logo)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                default:
                    Circle()
                        .fill(Color.brand.opacity(0.1))
                        .overlay {
                            Image(systemName: "airplane")
                                .foregroundColor(.brand)
                        }
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
            
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                HStack {
                    Text(agency.name)
                        .font(.appSubheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    
                    if agency.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
                
                HStack(spacing: Spacing.sm) {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", agency.rating))
                            .font(.appCaption)
                            .foregroundColor(.textSecondary)
                    }
                    
                    Text("•")
                        .foregroundColor(.textTertiary)
                    
                    Text("\(agency.destinations.count) destinations")
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                }
                
                // Services
                HStack(spacing: Spacing.xs) {
                    ForEach(agency.services.prefix(2), id: \.self) { service in
                        Text(service)
                            .font(.appCaption2)
                            .foregroundColor(.brand)
                            .padding(.horizontal, Spacing.xs)
                            .padding(.vertical, 2)
                            .background(Color.brand.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(agency.priceRange)
                    .font(.appCaption)
                    .fontWeight(.medium)
                    .foregroundColor(.textSecondary)
                
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

// MARK: - Visa Consultant Card

struct VisaConsultantCard: View {
    let consultant: VisaConsultant
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Logo
            AsyncImage(url: URL(string: consultant.logo)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                default:
                    Circle()
                        .fill(Color.accent.opacity(0.1))
                        .overlay {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.accent)
                        }
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
            
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                HStack {
                    Text(consultant.name)
                        .font(.appSubheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    
                    if consultant.isGovernmentRegistered {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
                
                HStack(spacing: Spacing.md) {
                    HStack(spacing: 3) {
                        Image(systemName: "percent")
                            .font(.caption2)
                            .foregroundColor(.green)
                        Text("\(consultant.successRate)% success")
                            .font(.appCaption)
                            .foregroundColor(.green)
                    }
                    
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", consultant.rating))
                            .font(.appCaption)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                Text(consultant.countriesServed.prefix(3).joined(separator: ", "))
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(consultant.consultationFee)
                    .font(.appCaption)
                    .fontWeight(.medium)
                    .foregroundColor(.brand)
                
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

// MARK: - Accommodation Card

struct AccommodationCard: View {
    let provider: AccommodationProvider
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Logo
            AsyncImage(url: URL(string: provider.logo)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                default:
                    Circle()
                        .fill(Color.secondary.opacity(0.1))
                        .overlay {
                            Image(systemName: "house.fill")
                                .foregroundColor(.secondary)
                        }
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
            
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(provider.name)
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                HStack(spacing: Spacing.sm) {
                    Text(provider.accommodationType)
                        .font(.appCaption)
                        .foregroundColor(.brand)
                        .padding(.horizontal, Spacing.xs)
                        .padding(.vertical, 2)
                        .background(Color.brand.opacity(0.1))
                        .clipShape(Capsule())
                    
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", provider.rating))
                            .font(.appCaption)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                Text(provider.locations.prefix(2).joined(separator: ", "))
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(provider.priceRange)
                    .font(.appCaption)
                    .fontWeight(.medium)
                    .foregroundColor(.textSecondary)
                
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

// MARK: - Detail Views

struct TravelAgencyDetailView: View {
    let agency: TravelAgency
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Header
                    VStack(spacing: Spacing.md) {
                        AsyncImage(url: URL(string: agency.logo)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            default:
                                Circle()
                                    .fill(Color.brand.opacity(0.1))
                                    .overlay {
                                        Image(systemName: "airplane")
                                            .font(.largeTitle)
                                            .foregroundColor(.brand)
                                    }
                            }
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                        
                        HStack {
                            Text(agency.name)
                                .font(.appTitle2)
                                .fontWeight(.bold)
                            
                            if agency.isVerified {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .foregroundColor(.textPrimary)
                        
                        HStack(spacing: Spacing.lg) {
                            VStack {
                                HStack(spacing: 3) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                    Text(String(format: "%.1f", agency.rating))
                                        .fontWeight(.bold)
                                }
                                Text("\(agency.reviewCount) reviews")
                                    .font(.appCaption)
                                    .foregroundColor(.textSecondary)
                            }
                            
                            VStack {
                                Text("\(agency.destinations.count)")
                                    .fontWeight(.bold)
                                Text("Destinations")
                                    .font(.appCaption)
                                    .foregroundColor(.textSecondary)
                            }
                            
                            VStack {
                                Text(agency.priceRange)
                                    .fontWeight(.bold)
                                Text("Price Range")
                                    .font(.appCaption)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                        .font(.appSubheadline)
                        .foregroundColor(.textPrimary)
                    }
                    .padding(Spacing.lg)
                    .frame(maxWidth: .infinity)
                    .background(Color.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
                    
                    // Description
                    InfoSection(title: "About") {
                        Text(agency.description)
                            .font(.appBody)
                            .foregroundColor(.textSecondary)
                    }
                    
                    // Services
                    InfoSection(title: "Services") {
                        FlowLayout(spacing: Spacing.xs) {
                            ForEach(agency.services, id: \.self) { service in
                                Text(service)
                                    .font(.appCaption)
                                    .padding(.horizontal, Spacing.sm)
                                    .padding(.vertical, Spacing.xxs)
                                    .background(Color.brand.opacity(0.1))
                                    .foregroundColor(.brand)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    
                    // Destinations
                    InfoSection(title: "Destinations") {
                        FlowLayout(spacing: Spacing.xs) {
                            ForEach(agency.destinations, id: \.self) { destination in
                                Text(destination)
                                    .font(.appCaption)
                                    .padding(.horizontal, Spacing.sm)
                                    .padding(.vertical, Spacing.xxs)
                                    .background(Color.premium.opacity(0.1))
                                    .foregroundColor(.premium)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    
                    // Features
                    InfoSection(title: "Features") {
                        ForEach(agency.features, id: \.self) { feature in
                            HStack(spacing: Spacing.sm) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(feature)
                                    .font(.appBody)
                                    .foregroundColor(.textPrimary)
                            }
                        }
                    }
                    
                    // Contact
                    InfoSection(title: "Contact") {
                        if let email = agency.contactEmail {
                            InfoRow(label: "Email", value: email)
                        }
                        if let phone = agency.contactPhone {
                            InfoRow(label: "Phone", value: phone)
                        }
                        if let address = agency.address {
                            InfoRow(label: "Address", value: address)
                        }
                    }
                    
                    // Actions
                    Link(destination: URL(string: agency.website)!) {
                        Label("Visit Website", systemImage: "globe")
                    }
                    .buttonStyle(PrimaryButtonStyle(isFullWidth: true))
                }
                .padding(Spacing.md)
                .padding(.bottom, Spacing.xxl)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.brand)
                }
            }
        }
    }
}

struct VisaConsultantDetailView: View {
    let consultant: VisaConsultant
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Header
                    VStack(spacing: Spacing.md) {
                        AsyncImage(url: URL(string: consultant.logo)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            default:
                                Circle()
                                    .fill(Color.accent.opacity(0.1))
                                    .overlay {
                                        Image(systemName: "doc.text.fill")
                                            .font(.largeTitle)
                                            .foregroundColor(.accent)
                                    }
                            }
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                        
                        HStack {
                            Text(consultant.name)
                                .font(.appTitle2)
                                .fontWeight(.bold)
                            
                            if consultant.isGovernmentRegistered {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .foregroundColor(.textPrimary)
                        
                        HStack(spacing: Spacing.lg) {
                            VStack {
                                Text("\(consultant.successRate)%")
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                Text("Success Rate")
                                    .font(.appCaption)
                                    .foregroundColor(.textSecondary)
                            }
                            
                            VStack {
                                HStack(spacing: 3) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                    Text(String(format: "%.1f", consultant.rating))
                                        .fontWeight(.bold)
                                }
                                Text("\(consultant.reviewCount) reviews")
                                    .font(.appCaption)
                                    .foregroundColor(.textSecondary)
                            }
                            
                            VStack {
                                Text(consultant.consultationFee)
                                    .fontWeight(.bold)
                                    .foregroundColor(.brand)
                                Text("Consultation")
                                    .font(.appCaption)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                        .font(.appSubheadline)
                        .foregroundColor(.textPrimary)
                    }
                    .padding(Spacing.lg)
                    .frame(maxWidth: .infinity)
                    .background(Color.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
                    
                    // Description
                    InfoSection(title: "About") {
                        Text(consultant.description)
                            .font(.appBody)
                            .foregroundColor(.textSecondary)
                    }
                    
                    // Services
                    InfoSection(title: "Services Offered") {
                        ForEach(consultant.servicesOffered, id: \.self) { service in
                            HStack(spacing: Spacing.sm) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(service)
                                    .font(.appBody)
                                    .foregroundColor(.textPrimary)
                            }
                        }
                    }
                    
                    // Countries Served
                    InfoSection(title: "Countries Served") {
                        FlowLayout(spacing: Spacing.xs) {
                            ForEach(consultant.countriesServed, id: \.self) { country in
                                Text(country)
                                    .font(.appCaption)
                                    .padding(.horizontal, Spacing.sm)
                                    .padding(.vertical, Spacing.xxs)
                                    .background(Color.accent.opacity(0.1))
                                    .foregroundColor(.accent)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    
                    // Features
                    InfoSection(title: "Features") {
                        ForEach(consultant.features, id: \.self) { feature in
                            HStack(spacing: Spacing.sm) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(feature)
                                    .font(.appBody)
                                    .foregroundColor(.textPrimary)
                            }
                        }
                    }
                    
                    // Contact
                    InfoSection(title: "Contact") {
                        if let email = consultant.contactEmail {
                            InfoRow(label: "Email", value: email)
                        }
                        if let phone = consultant.contactPhone {
                            InfoRow(label: "Phone", value: phone)
                        }
                        if let address = consultant.address {
                            InfoRow(label: "Address", value: address)
                        }
                        InfoRow(label: "Processing Time", value: consultant.processingTime)
                    }
                    
                    // Actions
                    Link(destination: URL(string: consultant.website)!) {
                        Label("Visit Website", systemImage: "globe")
                    }
                    .buttonStyle(PrimaryButtonStyle(isFullWidth: true))
                }
                .padding(Spacing.md)
                .padding(.bottom, Spacing.xxl)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.brand)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    TravelView()
        .environmentObject(DataService.shared)
}

