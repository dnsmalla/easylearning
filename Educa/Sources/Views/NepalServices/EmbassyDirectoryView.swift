//
//  EmbassyDirectoryView.swift
//  Educa
//
//  Nepal Embassy & Consulate Directory worldwide
//  Emergency contacts for Nepali students abroad
//

import SwiftUI

struct EmbassyDirectoryView: View {
    @State private var searchText = ""
    @State private var selectedRegion = "All"
    
    let regions = ["All", "Asia Pacific", "Europe", "Americas", "Middle East"]
    
    let embassies: [(country: String, flag: String, city: String, region: String, phone: String, email: String, emergency: String?)] = [
        // Asia Pacific
        ("Australia", "🇦🇺", "Canberra", "Asia Pacific", "+61-2-6162-1554", "eoncan@mofa.gov.np", "+61-2-6162-1554"),
        ("Japan", "🇯🇵", "Tokyo", "Asia Pacific", "+81-3-3713-6241", "eonjpn@mofa.gov.np", "+81-3-3713-6241"),
        ("South Korea", "🇰🇷", "Seoul", "Asia Pacific", "+82-2-3789-9770", "eonrok@mofa.gov.np", "+82-2-3789-9770"),
        ("China", "🇨🇳", "Beijing", "Asia Pacific", "+86-10-6532-1795", "eonbej@mofa.gov.np", "+86-10-6532-1795"),
        ("Malaysia", "🇲🇾", "Kuala Lumpur", "Asia Pacific", "+60-3-2020-1899", "eonmal@mofa.gov.np", nil),
        ("Thailand", "🇹🇭", "Bangkok", "Asia Pacific", "+66-2-391-7240", "eonbkk@mofa.gov.np", nil),
        ("India", "🇮🇳", "New Delhi", "Asia Pacific", "+91-11-2347-6200", "eonind@mofa.gov.np", "+91-11-2347-6200"),
        
        // Europe
        ("United Kingdom", "🇬🇧", "London", "Europe", "+44-20-7229-1594", "eonuk@mofa.gov.np", "+44-7903-874-335"),
        ("Germany", "🇩🇪", "Berlin", "Europe", "+49-30-3435-9920", "eondeu@mofa.gov.np", nil),
        ("France", "🇫🇷", "Paris", "Europe", "+33-1-4622-4867", "eonfra@mofa.gov.np", nil),
        ("Belgium", "🇧🇪", "Brussels", "Europe", "+32-2-346-2658", "eonbel@mofa.gov.np", nil),
        
        // Americas
        ("United States", "🇺🇸", "Washington DC", "Americas", "+1-202-667-4550", "eonusa@mofa.gov.np", "+1-202-667-4550"),
        ("Canada", "🇨🇦", "Ottawa", "Americas", "+1-613-680-5513", "eoncan@mofa.gov.np", nil),
        
        // Middle East
        ("UAE", "🇦🇪", "Abu Dhabi", "Middle East", "+971-2-622-2385", "eonuae@mofa.gov.np", "+971-50-621-7749"),
        ("Qatar", "🇶🇦", "Doha", "Middle East", "+974-4467-7561", "eonqat@mofa.gov.np", "+974-5584-5999"),
        ("Saudi Arabia", "🇸🇦", "Riyadh", "Middle East", "+966-11-460-3312", "eonksa@mofa.gov.np", "+966-55-005-5972"),
        ("Kuwait", "🇰🇼", "Kuwait City", "Middle East", "+965-2256-4104", "eonkwt@mofa.gov.np", nil)
    ]
    
    var filteredEmbassies: [(country: String, flag: String, city: String, region: String, phone: String, email: String, emergency: String?)] {
        var result = embassies
        
        if selectedRegion != "All" {
            result = result.filter { $0.region == selectedRegion }
        }
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.country.lowercased().contains(searchText.lowercased()) ||
                $0.city.lowercased().contains(searchText.lowercased())
            }
        }
        
        return result
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Emergency Banner
                emergencyBanner
                
                // Region Filter
                regionFilter
                
                // Embassy List
                embassyList
                
                // Important Info
                importantInfoSection
            }
            .padding(Spacing.md)
            .padding(.bottom, 100)
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("Nepal Embassies")
        .searchable(text: $searchText, prompt: "Search country or city...")
    }
    
    // MARK: - Emergency Banner
    
    private var emergencyBanner: some View {
        VStack(spacing: Spacing.sm) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                Text("In Emergency?")
                    .font(.appHeadline)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
            }
            
            Text("Contact the nearest Nepal Embassy immediately. Keep embassy numbers saved on your phone.")
                .font(.appCaption)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            Button {
                if let url = URL(string: "tel:+977-1-4200182") {
                    UIApplication.shared.open(url)
                }
            } label: {
                HStack {
                    Image(systemName: "phone.fill")
                    Text("Nepal MoFA Hotline: +977-1-4200182")
                }
                .font(.appSubheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(Color.red)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            }
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(Color.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
    }
    
    // MARK: - Region Filter
    
    private var regionFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(regions, id: \.self) { region in
                    Button {
                        withAnimation {
                            selectedRegion = region
                        }
                        HapticManager.shared.selection()
                    } label: {
                        Text(region)
                            .font(.appSubheadline)
                            .fontWeight(selectedRegion == region ? .semibold : .regular)
                            .foregroundColor(selectedRegion == region ? .white : .textSecondary)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.xs)
                            .background(selectedRegion == region ? Color.brand : Color.backgroundSecondary)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }
    
    // MARK: - Embassy List
    
    private var embassyList: some View {
        VStack(spacing: Spacing.md) {
            ForEach(filteredEmbassies, id: \.country) { embassy in
                EmbassyCard(
                    country: embassy.country,
                    flag: embassy.flag,
                    city: embassy.city,
                    phone: embassy.phone,
                    email: embassy.email,
                    emergency: embassy.emergency
                )
            }
        }
    }
    
    // MARK: - Important Info
    
    private var importantInfoSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Important Information", icon: "info.circle.fill")
            
            VStack(alignment: .leading, spacing: Spacing.sm) {
                InfoItem(
                    icon: "clock",
                    text: "Embassy working hours: Monday-Friday, 9:00 AM - 5:00 PM (local time)"
                )
                
                InfoItem(
                    icon: "doc.text",
                    text: "Carry copies of your passport, visa, and enrollment letter when visiting"
                )
                
                InfoItem(
                    icon: "phone.badge.plus",
                    text: "Save emergency numbers of the country you're visiting"
                )
                
                InfoItem(
                    icon: "envelope",
                    text: "Register with the nearest embassy upon arrival in a new country"
                )
            }
            .padding(Spacing.md)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        }
    }
}

// MARK: - Embassy Card

struct EmbassyCard: View {
    let country: String
    let flag: String
    let city: String
    let phone: String
    let email: String
    let emergency: String?
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button {
                withAnimation(.spring(response: 0.3)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: Spacing.md) {
                    Text(flag)
                        .font(.largeTitle)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(country)
                            .font(.appHeadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                        
                        Text("Embassy in \(city)")
                            .font(.appCaption)
                            .foregroundColor(.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.textTertiary)
                }
                .padding(Spacing.md)
            }
            
            // Expanded Content
            if isExpanded {
                VStack(spacing: Spacing.sm) {
                    Divider()
                    
                    // Phone
                    Button {
                        if let url = URL(string: "tel:\(phone)") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "phone.fill")
                                .foregroundColor(.green)
                            Text(phone)
                                .font(.appSubheadline)
                                .foregroundColor(.textPrimary)
                            Spacer()
                            Text("Call")
                                .font(.appCaption)
                                .foregroundColor(.brand)
                        }
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.xs)
                    }
                    
                    // Email
                    Button {
                        if let url = URL(string: "mailto:\(email)") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.blue)
                            Text(email)
                                .font(.appSubheadline)
                                .foregroundColor(.textPrimary)
                            Spacer()
                            Text("Email")
                                .font(.appCaption)
                                .foregroundColor(.brand)
                        }
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.xs)
                    }
                    
                    // Emergency
                    if let emergencyNum = emergency {
                        Button {
                            if let url = URL(string: "tel:\(emergencyNum)") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text("Emergency: \(emergencyNum)")
                                    .font(.appSubheadline)
                                    .foregroundColor(.red)
                                Spacer()
                                Text("Call")
                                    .font(.appCaption)
                                    .foregroundColor(.red)
                            }
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.xs)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
                            .padding(.horizontal, Spacing.md)
                        }
                    }
                }
                .padding(.bottom, Spacing.md)
            }
        }
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

struct InfoItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            Image(systemName: icon)
                .foregroundColor(.brand)
                .frame(width: 20)
            
            Text(text)
                .font(.appCaption)
                .foregroundColor(.textSecondary)
        }
    }
}

