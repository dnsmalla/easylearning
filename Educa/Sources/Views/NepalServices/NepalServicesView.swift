//
//  NepalServicesView.swift
//  Educa
//
//  Main hub for all Nepal-specific student services
//  Comprehensive tools for Nepali students studying abroad
//

import SwiftUI

struct NepalServicesView: View {
    @EnvironmentObject var dataService: DataService
    @State private var selectedCategory: ServiceCategory? = nil
    
    enum ServiceCategory: String, CaseIterable {
        case testPrep = "Test Prep"
        case visa = "Visa Guide"
        case cost = "Cost Calculator"
        case currency = "Currency"
        case embassy = "Embassies"
        case loans = "Education Loans"
        case checklist = "Checklist"
        case community = "Community"
        
        var icon: String {
            switch self {
            case .testPrep: return "doc.text.fill"
            case .visa: return "doc.badge.plus"
            case .cost: return "banknote.fill"
            case .currency: return "dollarsign.arrow.circlepath"
            case .embassy: return "building.columns.fill"
            case .loans: return "creditcard.fill"
            case .checklist: return "checklist"
            case .community: return "person.3.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .testPrep: return .red
            case .visa: return .blue
            case .cost: return .green
            case .currency: return .orange
            case .embassy: return .purple
            case .loans: return .pink
            case .checklist: return .teal
            case .community: return .indigo
            }
        }
        
        var description: String {
            switch self {
            case .testPrep: return "IELTS, TOEFL, JLPT & more"
            case .visa: return "Step-by-step visa guides"
            case .cost: return "Living expenses calculator"
            case .currency: return "NPR exchange rates"
            case .embassy: return "Emergency contacts"
            case .loans: return "Bank loans & scholarships"
            case .checklist: return "Pre-departure preparation"
            case .community: return "Connect with students"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Welcome Header
                    welcomeHeader
                    
                    // Quick Actions Grid
                    quickActionsGrid
                    
                    // Featured Section
                    featuredSection
                    
                    // Popular Destinations
                    popularDestinations
                    
                    // Recent Updates
                    recentUpdates
                }
                .padding(Spacing.md)
                .padding(.bottom, 100)
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Nepal Services")
        }
    }
    
    // MARK: - Welcome Header
    
    private var welcomeHeader: some View {
        VStack(spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack {
                        Text("🇳🇵")
                            .font(.title)
                        Text("Namaste!")
                            .font(.appTitle2)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                    }
                    
                    Text("Your complete guide to studying abroad from Nepal")
                        .font(.appSubheadline)
                        .foregroundColor(.textSecondary)
                }
                Spacer()
            }
            
            // Quick Stats
            HStack(spacing: Spacing.md) {
                QuickStatPill(value: "10+", label: "Countries", icon: "globe")
                QuickStatPill(value: "500+", label: "Universities", icon: "building.columns")
                QuickStatPill(value: "50+", label: "Scholarships", icon: "gift")
            }
        }
        .padding(Spacing.lg)
        .background(
            LinearGradient(
                colors: [Color(hex: "DC143C").opacity(0.15), Color(hex: "003893").opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
    }
    
    // MARK: - Quick Actions Grid
    
    private var quickActionsGrid: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Quick Services", icon: "square.grid.2x2.fill")
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Spacing.md) {
                ForEach(ServiceCategory.allCases, id: \.self) { category in
                    NavigationLink {
                        destinationView(for: category)
                    } label: {
                        ServiceGridItem(
                            title: category.rawValue,
                            icon: category.icon,
                            color: category.color
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: - Featured Section
    
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Featured Tools", icon: "star.fill")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    NavigationLink {
                        TestPrepView()
                    } label: {
                        FeaturedToolCard(
                            title: "Test Preparation",
                            subtitle: "Prepare for IELTS, TOEFL, JLPT",
                            icon: "doc.text.fill",
                            color: .red,
                            badge: "Most Popular"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink {
                        VisaGuideView()
                    } label: {
                        FeaturedToolCard(
                            title: "Visa Guide",
                            subtitle: "Step-by-step visa process",
                            icon: "doc.badge.plus",
                            color: .blue,
                            badge: "Updated"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink {
                        CostOfLivingView()
                    } label: {
                        FeaturedToolCard(
                            title: "Cost Calculator",
                            subtitle: "Compare living costs",
                            icon: "banknote.fill",
                            color: .green,
                            badge: nil
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: - Popular Destinations
    
    private var popularDestinations: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Popular Destinations", icon: "airplane")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    DestinationCard(flag: "🇦🇺", country: "Australia", students: "45,000+")
                    DestinationCard(flag: "🇯🇵", country: "Japan", students: "35,000+")
                    DestinationCard(flag: "🇰🇷", country: "South Korea", students: "8,000+")
                    DestinationCard(flag: "🇺🇸", country: "USA", students: "15,000+")
                    DestinationCard(flag: "🇬🇧", country: "UK", students: "12,000+")
                    DestinationCard(flag: "🇨🇦", country: "Canada", students: "20,000+")
                }
            }
        }
    }
    
    // MARK: - Recent Updates
    
    private var recentUpdates: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Recent Updates", icon: "bell.badge.fill")
            
            VStack(spacing: Spacing.sm) {
                UpdateRow(
                    icon: "exclamationmark.triangle.fill",
                    iconColor: .orange,
                    title: "Australia Student Visa Update",
                    subtitle: "New GTE requirements effective Jan 2025",
                    date: "2 days ago"
                )
                
                UpdateRow(
                    icon: "doc.text.fill",
                    iconColor: .blue,
                    title: "JLPT Results Released",
                    subtitle: "December 2024 results now available",
                    date: "1 week ago"
                )
                
                UpdateRow(
                    icon: "dollarsign.circle.fill",
                    iconColor: .green,
                    title: "Scholarship Deadline",
                    subtitle: "MEXT Scholarship applications closing soon",
                    date: "2 weeks ago"
                )
            }
        }
    }
    
    // MARK: - Destination View Router
    
    @ViewBuilder
    private func destinationView(for category: ServiceCategory) -> some View {
        switch category {
        case .testPrep:
            TestPrepView()
        case .visa:
            VisaGuideView()
        case .cost:
            CostOfLivingView()
        case .currency:
            CurrencyConverterView()
        case .embassy:
            EmbassyDirectoryView()
        case .loans:
            EducationLoansView()
        case .checklist:
            PreDepartureChecklistView()
        case .community:
            CommunityView()
        }
    }
}

// MARK: - Supporting Components

struct QuickStatPill: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.brand)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.appCaption)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                Text(label)
                    .font(.appCaption2)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(Color.backgroundSecondary)
        .clipShape(Capsule())
    }
}

struct ServiceGridItem: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.appCaption2)
                .fontWeight(.medium)
                .foregroundColor(.textPrimary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.sm)
    }
}

struct FeaturedToolCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let badge: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                }
                
                Spacer()
                
                if let badge = badge {
                    Text(badge)
                        .font(.appCaption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(color)
                        .clipShape(Capsule())
                }
            }
            
            Text(title)
                .font(.appHeadline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            Text(subtitle)
                .font(.appCaption)
                .foregroundColor(.textSecondary)
                .lineLimit(2)
        }
        .padding(Spacing.md)
        .frame(width: 180)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

struct DestinationCard: View {
    let flag: String
    let country: String
    let students: String
    
    var body: some View {
        VStack(spacing: Spacing.sm) {
            Text(flag)
                .font(.system(size: 40))
            
            Text(country)
                .font(.appSubheadline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            Text("\(students) students")
                .font(.appCaption2)
                .foregroundColor(.textSecondary)
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

struct UpdateRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let date: String
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Text(subtitle)
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text(date)
                .font(.appCaption2)
                .foregroundColor(.textTertiary)
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

// MARK: - Placeholder Views

struct EducationLoansView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                // Header
                VStack(spacing: Spacing.md) {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.pink)
                    
                    Text("Education Loans")
                        .font(.appTitle2)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text("Compare loans from Nepali banks for studying abroad")
                        .font(.appSubheadline)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(Spacing.xl)
                
                // Bank Cards
                VStack(spacing: Spacing.md) {
                    LoanProviderCard(
                        bankName: "Nepal Bank Limited",
                        maxLoan: "Up to NPR 50 Lakhs",
                        interestRate: "10.5% - 12%",
                        tenure: "10 Years"
                    )
                    
                    LoanProviderCard(
                        bankName: "Rastriya Banijya Bank",
                        maxLoan: "Up to NPR 40 Lakhs",
                        interestRate: "11% - 13%",
                        tenure: "8 Years"
                    )
                    
                    LoanProviderCard(
                        bankName: "Nabil Bank",
                        maxLoan: "Up to NPR 75 Lakhs",
                        interestRate: "10% - 11.5%",
                        tenure: "12 Years"
                    )
                    
                    LoanProviderCard(
                        bankName: "NIC Asia Bank",
                        maxLoan: "Up to NPR 60 Lakhs",
                        interestRate: "10.25% - 12%",
                        tenure: "10 Years"
                    )
                }
                .padding(.horizontal, Spacing.md)
            }
            .padding(.bottom, 100)
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("Education Loans")
    }
}

struct LoanProviderCard: View {
    let bankName: String
    let maxLoan: String
    let interestRate: String
    let tenure: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(bankName)
                .font(.appHeadline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            HStack(spacing: Spacing.lg) {
                VStack(alignment: .leading) {
                    Text("Max Loan")
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                    Text(maxLoan)
                        .font(.appSubheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.brand)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Interest")
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                    Text(interestRate)
                        .font(.appSubheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Tenure")
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                    Text(tenure)
                        .font(.appSubheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)
                }
            }
            
            Button {
                // Apply action
            } label: {
                Text("Learn More")
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.brand)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.sm)
                    .background(Color.brand.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

struct PreDepartureChecklistView: View {
    @State private var checkedItems: Set<String> = []
    
    let checklistItems = [
        ("📄", "Documents", ["Passport (valid 6+ months)", "Visa", "Offer Letter / CoE", "Insurance", "Academic Transcripts", "Bank Statements"]),
        ("💰", "Finance", ["Open foreign currency account", "Get forex card", "Inform bank about travel", "Carry some local currency"]),
        ("🏥", "Health", ["Medical checkup", "Vaccination records", "Prescription medicines", "Health insurance card"]),
        ("🎒", "Packing", ["Appropriate clothing", "Laptop & chargers", "Adapters (different plug types)", "Important documents copies"]),
        ("📱", "Communication", ["International SIM/roaming", "Download offline maps", "Save emergency contacts", "Install useful apps"])
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                ForEach(checklistItems, id: \.1) { emoji, category, items in
                    ChecklistSection(
                        emoji: emoji,
                        category: category,
                        items: items,
                        checkedItems: $checkedItems
                    )
                }
            }
            .padding(Spacing.md)
            .padding(.bottom, 100)
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("Pre-Departure Checklist")
    }
}

struct ChecklistSection: View {
    let emoji: String
    let category: String
    let items: [String]
    @Binding var checkedItems: Set<String>
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text(emoji)
                Text(category)
                    .font(.appHeadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text("\(items.filter { checkedItems.contains($0) }.count)/\(items.count)")
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
            }
            
            VStack(spacing: Spacing.xs) {
                ForEach(items, id: \.self) { item in
                    ChecklistRow(
                        item: item,
                        isChecked: checkedItems.contains(item)
                    ) {
                        if checkedItems.contains(item) {
                            checkedItems.remove(item)
                        } else {
                            checkedItems.insert(item)
                            HapticManager.shared.success()
                        }
                    }
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
    }
}

struct ChecklistRow: View {
    let item: String
    let isChecked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isChecked ? .green : .textTertiary)
                
                Text(item)
                    .font(.appSubheadline)
                    .foregroundColor(isChecked ? .textSecondary : .textPrimary)
                    .strikethrough(isChecked)
                
                Spacer()
            }
            .padding(.vertical, Spacing.xxs)
        }
    }
}

struct CommunityView: View {
    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()
            
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(.indigo)
            
            Text("Community Coming Soon!")
                .font(.appTitle2)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            Text("Connect with other Nepali students studying abroad.\nShare experiences, ask questions, and help each other.")
                .font(.appSubheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundPrimary)
        .navigationTitle("Community")
    }
}

