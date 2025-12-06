//
//  CostOfLivingView.swift
//  Educa
//
//  Cost of Living Calculator for Nepali students
//  Compare expenses across different study destinations
//

import SwiftUI

struct CostOfLivingView: View {
    @EnvironmentObject var dataService: DataService
    @State private var selectedCountry = "Australia"
    @State private var selectedCity = "Sydney"
    @State private var lifestyleLevel: Double = 1 // 0: Budget, 1: Moderate, 2: Comfortable
    
    let countries = ["Australia", "Japan", "South Korea", "USA", "UK", "Canada", "Germany", "New Zealand"]
    
    var cityOptions: [String] {
        switch selectedCountry {
        case "Australia": return ["Sydney", "Melbourne", "Brisbane", "Perth", "Adelaide"]
        case "Japan": return ["Tokyo", "Osaka", "Kyoto", "Nagoya", "Fukuoka"]
        case "South Korea": return ["Seoul", "Busan", "Daegu", "Incheon"]
        case "USA": return ["New York", "Los Angeles", "Chicago", "Boston", "San Francisco"]
        case "UK": return ["London", "Manchester", "Birmingham", "Edinburgh", "Glasgow"]
        case "Canada": return ["Toronto", "Vancouver", "Montreal", "Calgary", "Ottawa"]
        case "Germany": return ["Berlin", "Munich", "Frankfurt", "Hamburg", "Cologne"]
        default: return ["Auckland", "Wellington", "Christchurch"]
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                // Selector Section
                selectorSection
                
                // Monthly Budget Overview
                budgetOverview
                
                // Expense Breakdown
                expenseBreakdown
                
                // NPR Conversion
                nprConversion
                
                // Money Saving Tips
                savingTipsSection
                
                // Comparison Chart
                comparisonSection
            }
            .padding(Spacing.md)
            .padding(.bottom, 100)
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("Cost of Living")
    }
    
    // MARK: - Selector Section
    
    private var selectorSection: some View {
        VStack(spacing: Spacing.md) {
            // Country Picker
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Select Country")
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
                
                Picker("Country", selection: $selectedCountry) {
                    ForEach(countries, id: \.self) { country in
                        Text(country).tag(country)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity)
                .padding(Spacing.sm)
                .background(Color.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            }
            
            // City Picker
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Select City")
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
                
                Picker("City", selection: $selectedCity) {
                    ForEach(cityOptions, id: \.self) { city in
                        Text(city).tag(city)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity)
                .padding(Spacing.sm)
                .background(Color.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                .onChange(of: selectedCountry) { _, _ in
                    selectedCity = cityOptions.first ?? ""
                }
            }
            
            // Lifestyle Slider
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text("Lifestyle")
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                    Spacer()
                    Text(getLifestyleLabel())
                        .font(.appCaption)
                        .fontWeight(.semibold)
                        .foregroundColor(.brand)
                }
                
                Slider(value: $lifestyleLevel, in: 0...2, step: 1)
                    .tint(.brand)
                
                HStack {
                    Text("Budget")
                        .font(.appCaption2)
                        .foregroundColor(.textTertiary)
                    Spacer()
                    Text("Moderate")
                        .font(.appCaption2)
                        .foregroundColor(.textTertiary)
                    Spacer()
                    Text("Comfortable")
                        .font(.appCaption2)
                        .foregroundColor(.textTertiary)
                }
            }
        }
        .padding(Spacing.lg)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
    
    // MARK: - Budget Overview
    
    private var budgetOverview: some View {
        VStack(spacing: Spacing.md) {
            Text("Estimated Monthly Budget")
                .font(.appTitle3)
                .foregroundColor(.textPrimary)
            
            HStack(spacing: Spacing.lg) {
                VStack {
                    Text(getMonthlyBudget())
                        .font(.appLargeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.brand)
                    
                    Text(getCurrency())
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                }
                
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("Essential: \(getEssentialPercentage())%")
                            .font(.appCaption)
                            .foregroundColor(.textSecondary)
                    }
                    
                    HStack {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 8, height: 8)
                        Text("Lifestyle: \(100 - getEssentialPercentage())%")
                            .font(.appCaption)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            
            // Quick comparison
            HStack(spacing: Spacing.md) {
                CompareStatBox(
                    label: "vs Kathmandu",
                    value: "+\(getKathmanduComparison())%",
                    icon: "arrow.up.right",
                    color: .red
                )
                
                CompareStatBox(
                    label: "Affordability",
                    value: getAffordabilityRank(),
                    icon: "chart.bar.fill",
                    color: .green
                )
            }
        }
        .padding(Spacing.lg)
        .background(
            LinearGradient(
                colors: [Color.brand.opacity(0.1), Color.brand.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
    }
    
    // MARK: - Expense Breakdown
    
    private var expenseBreakdown: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Monthly Expense Breakdown", icon: "chart.pie.fill")
            
            VStack(spacing: Spacing.sm) {
                ExpenseRow(
                    icon: "house.fill",
                    category: "Accommodation",
                    amount: getAccommodation(),
                    currency: getCurrency(),
                    percentage: 40,
                    color: .blue
                )
                
                ExpenseRow(
                    icon: "fork.knife",
                    category: "Food & Groceries",
                    amount: getFood(),
                    currency: getCurrency(),
                    percentage: 25,
                    color: .orange
                )
                
                ExpenseRow(
                    icon: "bus.fill",
                    category: "Transportation",
                    amount: getTransport(),
                    currency: getCurrency(),
                    percentage: 10,
                    color: .green
                )
                
                ExpenseRow(
                    icon: "bolt.fill",
                    category: "Utilities & Internet",
                    amount: getUtilities(),
                    currency: getCurrency(),
                    percentage: 8,
                    color: .yellow
                )
                
                ExpenseRow(
                    icon: "iphone",
                    category: "Phone & Mobile",
                    amount: getPhone(),
                    currency: getCurrency(),
                    percentage: 3,
                    color: .purple
                )
                
                ExpenseRow(
                    icon: "heart.fill",
                    category: "Health Insurance",
                    amount: getInsurance(),
                    currency: getCurrency(),
                    percentage: 7,
                    color: .red
                )
                
                ExpenseRow(
                    icon: "theatermasks.fill",
                    category: "Entertainment",
                    amount: getEntertainment(),
                    currency: getCurrency(),
                    percentage: 7,
                    color: .pink
                )
            }
        }
    }
    
    // MARK: - NPR Conversion
    
    private var nprConversion: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "In Nepali Rupees (NPR)", icon: "dollarsign.circle.fill")
            
            VStack(spacing: Spacing.sm) {
                HStack {
                    Text("Monthly Total")
                        .font(.appSubheadline)
                        .foregroundColor(.textSecondary)
                    Spacer()
                    Text(getNPRMonthly())
                        .font(.appHeadline)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                }
                
                Divider()
                
                HStack {
                    Text("Yearly Estimate")
                        .font(.appSubheadline)
                        .foregroundColor(.textSecondary)
                    Spacer()
                    Text(getNPRYearly())
                        .font(.appHeadline)
                        .fontWeight(.bold)
                        .foregroundColor(.brand)
                }
                
                Text("Exchange rate as of Dec 2024. Actual costs may vary.")
                    .font(.appCaption2)
                    .foregroundColor(.textTertiary)
                    .padding(.top, Spacing.xs)
            }
            .padding(Spacing.md)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        }
    }
    
    // MARK: - Saving Tips
    
    private var savingTipsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Money Saving Tips for \(selectedCountry)", icon: "lightbulb.fill")
            
            VStack(spacing: Spacing.sm) {
                ForEach(getSavingTips(), id: \.self) { tip in
                    HStack(alignment: .top, spacing: Spacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        
                        Text(tip)
                            .font(.appSubheadline)
                            .foregroundColor(.textPrimary)
                    }
                    .padding(Spacing.sm)
                    .background(Color.green.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
                }
            }
        }
    }
    
    // MARK: - Comparison Section
    
    private var comparisonSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Compare Destinations", icon: "chart.bar.xaxis")
            
            VStack(spacing: Spacing.sm) {
                ComparisonBar(city: "Sydney", amount: 2800, maxAmount: 3500, currency: "AUD")
                ComparisonBar(city: "Tokyo", amount: 180000, maxAmount: 250000, currency: "JPY")
                ComparisonBar(city: "Seoul", amount: 1500000, maxAmount: 2000000, currency: "KRW")
                ComparisonBar(city: "London", amount: 1800, maxAmount: 2500, currency: "GBP")
                ComparisonBar(city: "Toronto", amount: 2200, maxAmount: 3000, currency: "CAD")
            }
            
            Text("Monthly living costs (moderate lifestyle)")
                .font(.appCaption2)
                .foregroundColor(.textTertiary)
        }
    }
    
    // MARK: - Helper Functions
    
    private func getLifestyleLabel() -> String {
        switch Int(lifestyleLevel) {
        case 0: return "Budget"
        case 1: return "Moderate"
        default: return "Comfortable"
        }
    }
    
    private func getCurrency() -> String {
        switch selectedCountry {
        case "Australia": return "AUD"
        case "Japan": return "JPY"
        case "South Korea": return "KRW"
        case "USA": return "USD"
        case "UK": return "GBP"
        case "Canada": return "CAD"
        case "Germany": return "EUR"
        default: return "NZD"
        }
    }
    
    private func getMonthlyBudget() -> String {
        let lifestyle = Int(lifestyleLevel)
        switch selectedCountry {
        case "Australia":
            return ["1,800", "2,500", "3,500"][lifestyle]
        case "Japan":
            return ["120,000", "180,000", "250,000"][lifestyle]
        case "South Korea":
            return ["1,000,000", "1,500,000", "2,200,000"][lifestyle]
        case "USA":
            return ["1,500", "2,500", "4,000"][lifestyle]
        case "UK":
            return ["1,200", "1,800", "2,800"][lifestyle]
        case "Canada":
            return ["1,500", "2,200", "3,200"][lifestyle]
        default:
            return ["1,400", "2,000", "3,000"][lifestyle]
        }
    }
    
    private func getEssentialPercentage() -> Int {
        switch Int(lifestyleLevel) {
        case 0: return 85
        case 1: return 75
        default: return 65
        }
    }
    
    private func getKathmanduComparison() -> Int {
        switch selectedCountry {
        case "Australia": return 350
        case "Japan": return 280
        case "South Korea": return 220
        case "USA": return 400
        case "UK": return 380
        default: return 300
        }
    }
    
    private func getAffordabilityRank() -> String {
        switch selectedCountry {
        case "Germany": return "#1"
        case "South Korea": return "#2"
        case "Japan": return "#3"
        case "Canada": return "#4"
        case "New Zealand": return "#5"
        case "Australia": return "#6"
        case "UK": return "#7"
        default: return "#8"
        }
    }
    
    private func getAccommodation() -> String {
        let lifestyle = Int(lifestyleLevel)
        switch selectedCountry {
        case "Australia": return ["800", "1,200", "1,800"][lifestyle]
        case "Japan": return ["50,000", "80,000", "120,000"][lifestyle]
        default: return ["600", "1,000", "1,500"][lifestyle]
        }
    }
    
    private func getFood() -> String {
        let lifestyle = Int(lifestyleLevel)
        switch selectedCountry {
        case "Australia": return ["300", "500", "800"][lifestyle]
        case "Japan": return ["30,000", "50,000", "80,000"][lifestyle]
        default: return ["250", "400", "600"][lifestyle]
        }
    }
    
    private func getTransport() -> String {
        let lifestyle = Int(lifestyleLevel)
        switch selectedCountry {
        case "Australia": return ["150", "200", "300"][lifestyle]
        case "Japan": return ["10,000", "15,000", "25,000"][lifestyle]
        default: return ["100", "150", "250"][lifestyle]
        }
    }
    
    private func getUtilities() -> String {
        switch selectedCountry {
        case "Australia": return "150"
        case "Japan": return "15,000"
        default: return "120"
        }
    }
    
    private func getPhone() -> String {
        switch selectedCountry {
        case "Australia": return "30"
        case "Japan": return "3,000"
        default: return "25"
        }
    }
    
    private func getInsurance() -> String {
        switch selectedCountry {
        case "Australia": return "50"
        case "Japan": return "2,000"
        default: return "40"
        }
    }
    
    private func getEntertainment() -> String {
        let lifestyle = Int(lifestyleLevel)
        switch selectedCountry {
        case "Australia": return ["100", "200", "400"][lifestyle]
        case "Japan": return ["10,000", "20,000", "40,000"][lifestyle]
        default: return ["80", "150", "300"][lifestyle]
        }
    }
    
    private func getNPRMonthly() -> String {
        let lifestyle = Int(lifestyleLevel)
        switch selectedCountry {
        case "Australia": return ["NPR 1,57,000", "NPR 2,18,000", "NPR 3,05,000"][lifestyle]
        case "Japan": return ["NPR 1,07,000", "NPR 1,60,000", "NPR 2,23,000"][lifestyle]
        case "South Korea": return ["NPR 97,000", "NPR 1,46,000", "NPR 2,14,000"][lifestyle]
        default: return ["NPR 1,50,000", "NPR 2,00,000", "NPR 3,00,000"][lifestyle]
        }
    }
    
    private func getNPRYearly() -> String {
        let lifestyle = Int(lifestyleLevel)
        switch selectedCountry {
        case "Australia": return ["NPR 18.8 Lakhs", "NPR 26.2 Lakhs", "NPR 36.6 Lakhs"][lifestyle]
        case "Japan": return ["NPR 12.8 Lakhs", "NPR 19.2 Lakhs", "NPR 26.8 Lakhs"][lifestyle]
        default: return ["NPR 18 Lakhs", "NPR 24 Lakhs", "NPR 36 Lakhs"][lifestyle]
        }
    }
    
    private func getSavingTips() -> [String] {
        switch selectedCountry {
        case "Australia":
            return [
                "Share accommodation - save up to AUD 600/month",
                "Get an Opal card for discounted public transport",
                "Shop at Aldi or local markets instead of Woolworths/Coles",
                "Use student discounts with your ID everywhere",
                "Work part-time (48 hrs/fortnight allowed on student visa)"
            ]
        case "Japan":
            return [
                "Live in share houses or 'gaijin houses' to save on rent",
                "Get a Suica/Pasmo card for transport discounts",
                "Shop at 100 yen stores and supermarket evening sales",
                "Apply for National Health Insurance reduction",
                "Use free entertainment like parks and festivals"
            ]
        case "South Korea":
            return [
                "Live in a 'goshiwon' (small study room) to save on rent",
                "Eat at university cafeterias - meals under 5,000 KRW",
                "Use T-money card for transport discounts",
                "Shop at Daiso for affordable daily items",
                "Part-time work in convenience stores or tutoring"
            ]
        default:
            return [
                "Share accommodation with other students",
                "Cook at home instead of eating out",
                "Use student discounts wherever available",
                "Buy second-hand textbooks and furniture",
                "Use public transport instead of taxis"
            ]
        }
    }
}

// MARK: - Supporting Components

struct CompareStatBox: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                Text(value)
                    .font(.appHeadline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Text(label)
                .font(.appCaption2)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.sm)
        .background(Color.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
    }
}

struct ExpenseRow: View {
    let icon: String
    let category: String
    let amount: String
    let currency: String
    let percentage: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category)
                    .font(.appSubheadline)
                    .foregroundColor(.textPrimary)
                
                GeometryReader { geometry in
                    Rectangle()
                        .fill(color.opacity(0.3))
                        .frame(width: geometry.size.width * CGFloat(percentage) / 100, height: 4)
                        .clipShape(Capsule())
                }
                .frame(height: 4)
            }
            
            Spacer()
            
            Text("\(currency) \(amount)")
                .font(.appSubheadline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

struct ComparisonBar: View {
    let city: String
    let amount: Int
    let maxAmount: Int
    let currency: String
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            Text(city)
                .font(.appCaption)
                .foregroundColor(.textSecondary)
                .frame(width: 60, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.backgroundTertiary)
                    
                    Rectangle()
                        .fill(LinearGradient.brandGradient)
                        .frame(width: geometry.size.width * CGFloat(amount) / CGFloat(maxAmount))
                }
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .frame(height: 20)
            
            Text("\(currency) \(amount.formatted())")
                .font(.appCaption)
                .fontWeight(.medium)
                .foregroundColor(.textPrimary)
                .frame(width: 90, alignment: .trailing)
        }
    }
}

