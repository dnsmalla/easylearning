//
//  RemittanceView.swift
//  Educa
//
//  Comprehensive Remittance view - Money transfer providers comparison and calculator
//

import SwiftUI

// MARK: - Remittance Tab View (For Bottom Tab Bar)

struct RemittanceTabView: View {
    @EnvironmentObject var dataService: DataService
    @State private var selectedTab = 0
    @State private var sendAmount: String = "1000"
    @State private var selectedFromCurrency = "USD"
    @State private var selectedToCurrency = "NPR"
    @State private var searchText = ""
    @State private var selectedProvider: RemittanceProvider?
    
    let currencies = ["USD", "EUR", "GBP", "AUD", "CAD", "SGD", "JPY", "CHF"]
    let receiveCurrencies = ["NPR", "INR", "PKR", "BDT", "PHP", "MXN", "KES", "GHS"]
    
    var filteredProviders: [RemittanceProvider] {
        let providers = dataService.remittanceProviders
        if searchText.isEmpty {
            return providers.sorted { $0.rating > $1.rating }
        }
        return providers.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Selector
                Picker("View", selection: $selectedTab) {
                    Text("Compare").tag(0)
                    Text("Calculator").tag(1)
                    Text("Currency").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                
                // Content
                switch selectedTab {
                case 0:
                    providersListContent
                case 1:
                    calculatorView
                default:
                    currencyRatesView
                }
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Send Money")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ProfileMenuButton()
                }
            }
            .refreshable {
                await dataService.loadRemittanceProviders()
            }
            .sheet(item: $selectedProvider) { provider in
                RemittanceProviderDetailView(provider: provider)
            }
        }
    }
    
    // MARK: - Providers List
    
    private var providersListContent: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Hero Banner
                remittanceHero
                
                // Quick Stats
                quickStatsRow
                
                // Search
                searchBar
                
                // Best Rate Highlight
                if let bestProvider = filteredProviders.first {
                    bestRateCard(provider: bestProvider)
                }
                
                // All Providers
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text("All Providers")
                        .font(.appHeadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    
                    ForEach(filteredProviders) { provider in
                        Button {
                            selectedProvider = provider
                            HapticManager.shared.tap()
                        } label: {
                            ProviderCard(provider: provider, sendAmount: Double(sendAmount) ?? 1000)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(Spacing.md)
            .padding(.bottom, 100)
        }
    }
    
    private var remittanceHero: some View {
        VStack(spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Send Money Home 💸")
                        .font(.appTitle3)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text("Compare rates from top providers")
                        .font(.appSubheadline)
                        .foregroundColor(.textSecondary)
                }
                Spacer()
                
                Image(systemName: "arrow.left.arrow.right.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.green)
            }
        }
        .padding(Spacing.lg)
        .background(
            LinearGradient(
                colors: [Color.green.opacity(0.15), Color.green.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
    }
    
    private var quickStatsRow: some View {
        HStack(spacing: Spacing.md) {
            RemitStatBox(value: "\(filteredProviders.count)", label: "Providers", icon: "building.2.fill", color: .blue)
            RemitStatBox(value: "NPR 133.5", label: "Best Rate", icon: "chart.line.uptrend.xyaxis", color: .green)
            RemitStatBox(value: "Minutes", label: "Transfer", icon: "clock.fill", color: .orange)
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.textTertiary)
            TextField("Search providers...", text: $searchText)
        }
        .padding(Spacing.sm)
        .background(Color.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
    
    private func bestRateCard(provider: RemittanceProvider) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("🏆 Best Rate")
                    .font(.appCaption)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text(provider.name)
                        .font(.appHeadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    
                    Text("1 USD = \(String(format: "%.2f", provider.exchangeRate)) NPR")
                        .font(.appSubheadline)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                Button {
                    selectedProvider = provider
                } label: {
                    Text("Send")
                        .font(.appSubheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.xs)
                        .background(Color.green)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
    }
    
    // MARK: - Calculator View
    
    private var calculatorView: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                // Amount Input
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("You Send")
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                    
                    HStack {
                        TextField("1000", text: $sendAmount)
                            .font(.appLargeTitle)
                            .fontWeight(.bold)
                            .keyboardType(.decimalPad)
                        
                        Picker("Currency", selection: $selectedFromCurrency) {
                            ForEach(currencies, id: \.self) { currency in
                                Text(currency).tag(currency)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                .padding(Spacing.lg)
                .background(Color.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
                
                // Arrow
                Image(systemName: "arrow.down.circle.fill")
                    .font(.title)
                    .foregroundColor(.brand)
                
                // Receive Amount
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Recipient Gets")
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                    
                    HStack {
                        Text(calculateReceiveAmount())
                            .font(.appLargeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Spacer()
                        
                        Text("NPR")
                            .font(.appTitle3)
                            .foregroundColor(.textSecondary)
                    }
                }
                .padding(Spacing.lg)
                .background(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
                
                // Provider Comparison
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text("Compare Providers")
                        .font(.appHeadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    
                    ForEach(filteredProviders.prefix(5)) { provider in
                        ProviderCompareRow(
                            provider: provider,
                            sendAmount: Double(sendAmount) ?? 1000
                        )
                    }
                }
            }
            .padding(Spacing.md)
            .padding(.bottom, 100)
        }
    }
    
    private func calculateReceiveAmount() -> String {
        guard let amount = Double(sendAmount) else { return "0" }
        let rate = filteredProviders.first?.exchangeRate ?? 133.5
        let result = amount * rate
        return String(format: "%.2f", result)
    }
    
    // MARK: - Currency Rates View
    
    private var currencyRatesView: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // NPR Rates Header
                VStack(spacing: Spacing.sm) {
                    Text("🇳🇵 NPR Exchange Rates")
                        .font(.appTitle3)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text("Today's indicative rates")
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                }
                .padding(.top, Spacing.md)
                
                // Currency List
                VStack(spacing: Spacing.sm) {
                    CurrencyRateRow(flag: "🇺🇸", code: "USD", rate: "133.50")
                    CurrencyRateRow(flag: "🇦🇺", code: "AUD", rate: "87.20")
                    CurrencyRateRow(flag: "🇬🇧", code: "GBP", rate: "169.50")
                    CurrencyRateRow(flag: "🇪🇺", code: "EUR", rate: "141.20")
                    CurrencyRateRow(flag: "🇨🇦", code: "CAD", rate: "95.80")
                    CurrencyRateRow(flag: "🇯🇵", code: "JPY", rate: "0.89")
                    CurrencyRateRow(flag: "🇰🇷", code: "KRW", rate: "0.097")
                    CurrencyRateRow(flag: "🇸🇬", code: "SGD", rate: "99.80")
                    CurrencyRateRow(flag: "🇦🇪", code: "AED", rate: "36.35")
                    CurrencyRateRow(flag: "🇶🇦", code: "QAR", rate: "36.67")
                    CurrencyRateRow(flag: "🇲🇾", code: "MYR", rate: "30.05")
                }
                
                // Note
                Text("Rates are indicative and may vary at the time of transfer")
                    .font(.appCaption2)
                    .foregroundColor(.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.top, Spacing.md)
            }
            .padding(Spacing.md)
            .padding(.bottom, 100)
        }
    }
}

// MARK: - Supporting Components for Tab View

struct RemitStatBox: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.appSubheadline)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            Text(label)
                .font(.appCaption2)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.sm)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

struct ProviderCard: View {
    let provider: RemittanceProvider
    let sendAmount: Double
    
    var receiveAmount: Double {
        (sendAmount - provider.transferFee) * provider.exchangeRate
    }
    
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
                        .fill(Color.brand.opacity(0.1))
                        .overlay {
                            Text(String(provider.name.prefix(1)))
                                .font(.appHeadline)
                                .fontWeight(.bold)
                                .foregroundColor(.brand)
                        }
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(provider.name)
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                HStack(spacing: Spacing.sm) {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", provider.rating))
                            .font(.appCaption)
                            .foregroundColor(.textSecondary)
                    }
                    
                    Text("•")
                        .foregroundColor(.textTertiary)
                    
                    Text(provider.transferTime)
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                }
            }
            
            Spacer()
            
            // Rate & Amount
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.2f", receiveAmount))
                    .font(.appSubheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text("NPR")
                    .font(.appCaption2)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

struct ProviderCompareRow: View {
    let provider: RemittanceProvider
    let sendAmount: Double
    
    var receiveAmount: Double {
        (sendAmount - provider.transferFee) * provider.exchangeRate
    }
    
    var body: some View {
        HStack {
            Text(provider.name)
                .font(.appSubheadline)
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.2f NPR", receiveAmount))
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                
                Text("Fee: $\(String(format: "%.2f", provider.transferFee))")
                    .font(.appCaption2)
                    .foregroundColor(.textTertiary)
            }
        }
        .padding(Spacing.md)
        .background(Color.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

struct CurrencyRateRow: View {
    let flag: String
    let code: String
    let rate: String
    
    var body: some View {
        HStack {
            Text(flag)
                .font(.title2)
            
            Text(code)
                .font(.appSubheadline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Text("NPR \(rate)")
                .font(.appSubheadline)
                .fontWeight(.medium)
                .foregroundColor(.brand)
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

// MARK: - Original Remittance View (for Sheet presentation)

struct RemittanceView: View {
    @EnvironmentObject var dataService: DataService
    @State private var selectedTab = 0
    @State private var sendAmount: String = "1000"
    @State private var selectedFromCurrency = "USD"
    @State private var selectedToCurrency = "NPR"
    @State private var searchText = ""
    @State private var selectedProvider: RemittanceProvider?
    @State private var showProviderDetail = false
    
    let currencies = ["USD", "EUR", "GBP", "AUD", "CAD", "SGD", "JPY", "CHF"]
    let receiveCurrencies = ["NPR", "INR", "PKR", "BDT", "PHP", "MXN", "KES", "GHS"]
    
    var filteredProviders: [RemittanceProvider] {
        let providers = dataService.remittanceProviders
        if searchText.isEmpty {
            return providers.sorted { $0.rating > $1.rating }
        }
        return providers.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Selector
                Picker("View", selection: $selectedTab) {
                    Text("Compare").tag(0)
                    Text("Calculator").tag(1)
                    Text("History").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                
                // Content
                if selectedTab == 0 {
                    compareContent
                } else if selectedTab == 1 {
                    calculatorContent
                } else {
                    historyContent
                }
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Remittance")
            .refreshable {
                await dataService.loadRemittanceProviders()
            }
            .sheet(item: $selectedProvider) { provider in
                RemittanceProviderDetailView(provider: provider)
            }
        }
    }
    
    // MARK: - Compare Content
    
    private var compareContent: some View {
        VStack(spacing: 0) {
            // Quick Stats
            remittanceStats
            
            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.textTertiary)
                TextField("Search providers...", text: $searchText)
            }
            .padding(Spacing.sm)
            .background(Color.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.sm)
            
            // Providers List
            ScrollView {
                LazyVStack(spacing: Spacing.md) {
                    // Best Value Card
                    if let bestProvider = bestValueProvider {
                        BestValueProviderCard(provider: bestProvider)
                            .onTapGesture {
                                selectedProvider = bestProvider
                            }
                    }
                    
                    ForEach(filteredProviders) { provider in
                        RemittanceProviderCard(provider: provider)
                            .onTapGesture {
                                HapticManager.shared.tap()
                                selectedProvider = provider
                            }
                    }
                }
                .padding(Spacing.md)
                .padding(.bottom, 100)
            }
        }
    }
    
    // MARK: - Calculator Content
    
    private var calculatorContent: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Amount Input Card
                VStack(spacing: Spacing.lg) {
                    // Send Amount
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("You Send")
                            .font(.appCaption)
                            .foregroundColor(.textSecondary)
                        
                        HStack {
                            TextField("Amount", text: $sendAmount)
                                .font(.appTitle)
                                .keyboardType(.decimalPad)
                                .foregroundColor(.textPrimary)
                            
                            Spacer()
                            
                            Menu {
                                ForEach(currencies, id: \.self) { currency in
                                    Button(currency) {
                                        selectedFromCurrency = currency
                                    }
                                }
                            } label: {
                                HStack(spacing: Spacing.xxs) {
                                    Text(selectedFromCurrency)
                                        .font(.appHeadline)
                                        .fontWeight(.semibold)
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                }
                                .foregroundColor(.brand)
                                .padding(.horizontal, Spacing.md)
                                .padding(.vertical, Spacing.xs)
                                .background(Color.brand.opacity(0.1))
                                .clipShape(Capsule())
                            }
                        }
                        
                        Divider()
                    }
                    
                    // Arrow Indicator
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.title2)
                        .foregroundColor(.brand)
                    
                    // Receive Amount
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Recipient Gets")
                            .font(.appCaption)
                            .foregroundColor(.textSecondary)
                        
                        HStack {
                            Text(calculateReceivedAmount())
                                .font(.appTitle)
                                .foregroundColor(.green)
                            
                            Spacer()
                            
                            Menu {
                                ForEach(receiveCurrencies, id: \.self) { currency in
                                    Button(currency) {
                                        selectedToCurrency = currency
                                    }
                                }
                            } label: {
                                HStack(spacing: Spacing.xxs) {
                                    Text(selectedToCurrency)
                                        .font(.appHeadline)
                                        .fontWeight(.semibold)
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                }
                                .foregroundColor(.brand)
                                .padding(.horizontal, Spacing.md)
                                .padding(.vertical, Spacing.xs)
                                .background(Color.brand.opacity(0.1))
                                .clipShape(Capsule())
                            }
                        }
                        
                        Divider()
                    }
                }
                .padding(Spacing.lg)
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl))
                .cardShadow()
                
                // Provider Comparison Results
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text("Best Rates for Your Transfer")
                        .font(.appTitle3)
                        .foregroundColor(.textPrimary)
                    
                    ForEach(sortedProvidersByValue) { provider in
                        CalculatorProviderRow(
                            provider: provider,
                            sendAmount: Double(sendAmount) ?? 1000,
                            fromCurrency: selectedFromCurrency,
                            toCurrency: selectedToCurrency
                        )
                        .onTapGesture {
                            selectedProvider = provider
                        }
                    }
                }
                
                // Disclaimer
                Text("Exchange rates are indicative and may vary. Check with the provider for real-time rates.")
                    .font(.appCaption)
                    .foregroundColor(.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.lg)
            }
            .padding(Spacing.md)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - History Content
    
    private var historyContent: some View {
        VStack(spacing: Spacing.lg) {
            if dataService.transactions.isEmpty {
                Spacer()
                EmptyStateView(
                    icon: "clock.arrow.circlepath",
                    title: "No Transactions Yet",
                    message: "Your transfer history will appear here"
                )
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: Spacing.md) {
                        ForEach(dataService.transactions) { transaction in
                            TransactionCard(transaction: transaction)
                        }
                    }
                    .padding(Spacing.md)
                    .padding(.bottom, 100)
                }
            }
        }
    }
    
    // MARK: - Stats Section
    
    private var remittanceStats: some View {
        HStack(spacing: Spacing.md) {
            StatBox(
                icon: "building.2",
                value: "\(dataService.remittanceProviders.count)",
                label: "Providers"
            )
            
            StatBox(
                icon: "globe",
                value: "\(uniqueCountries)",
                label: "Countries"
            )
            
            StatBox(
                icon: "star.fill",
                value: String(format: "%.1f", averageRating),
                label: "Avg Rating"
            )
        }
        .padding(Spacing.md)
    }
    
    // MARK: - Computed Properties
    
    private var uniqueCountries: Int {
        let allCountries = dataService.remittanceProviders.flatMap { $0.supportedCountries }
        return Set(allCountries).count
    }
    
    private var averageRating: Double {
        guard !dataService.remittanceProviders.isEmpty else { return 0 }
        let total = dataService.remittanceProviders.reduce(0) { $0 + $1.rating }
        return total / Double(dataService.remittanceProviders.count)
    }
    
    private var bestValueProvider: RemittanceProvider? {
        dataService.remittanceProviders.sorted {
            // Lower fee + higher exchange rate = better value
            ($0.transferFee / $0.exchangeRate) < ($1.transferFee / $1.exchangeRate)
        }.first
    }
    
    private var sortedProvidersByValue: [RemittanceProvider] {
        dataService.remittanceProviders.sorted {
            // Sort by effective rate (exchange rate - fee impact)
            let amount = Double(sendAmount) ?? 1000
            let value1 = (amount - $0.transferFee) * $0.exchangeRate
            let value2 = (amount - $1.transferFee) * $1.exchangeRate
            return value1 > value2
        }
    }
    
    private func calculateReceivedAmount() -> String {
        guard let amount = Double(sendAmount) else { return "0.00" }
        // Using a sample exchange rate for NPR (this would come from real API)
        let sampleRate: Double = selectedToCurrency == "NPR" ? 133.5 : 83.0
        let received = amount * sampleRate
        return String(format: "%.2f", received)
    }
}

// MARK: - Best Value Provider Card

struct BestValueProviderCard: View {
    let provider: RemittanceProvider
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Badge
            HStack {
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "crown.fill")
                        .font(.caption)
                    Text("BEST VALUE")
                        .font(.appCaption2)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, 4)
                .background(LinearGradient.successGradient)
                .clipShape(Capsule())
                
                Spacer()
                
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", provider.rating))
                        .font(.appCaption)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                }
            }
            
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
                            .fill(Color.brand.opacity(0.1))
                            .overlay {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(.brand)
                            }
                    }
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(provider.name)
                        .font(.appHeadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    
                    Text("Transfer: \(provider.transferTime)")
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Fee: $\(String(format: "%.2f", provider.transferFee))")
                        .font(.appSubheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    Text("Mid-market rate")
                        .font(.appCaption2)
                        .foregroundColor(.textTertiary)
                }
            }
        }
        .padding(Spacing.md)
        .background(
            LinearGradient(
                colors: [Color.green.opacity(0.1), Color.green.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.large)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Remittance Provider Card

struct RemittanceProviderCard: View {
    let provider: RemittanceProvider
    @ObservedObject private var userData = UserDataManager.shared
    
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
                        .fill(Color.brand.opacity(0.1))
                        .overlay {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.brand)
                        }
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
            
            // Info
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                HStack {
                    Text(provider.name)
                        .font(.appHeadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", provider.rating))
                            .font(.appCaption)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                HStack(spacing: Spacing.md) {
                    Label("Fee: $\(String(format: "%.2f", provider.transferFee))", systemImage: "creditcard")
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                    
                    Label(provider.transferTime, systemImage: "clock")
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                }
                
                // Payment Methods
                HStack(spacing: Spacing.xs) {
                    ForEach(provider.paymentMethods.prefix(3), id: \.self) { method in
                        Text(method)
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

// MARK: - Calculator Provider Row

struct CalculatorProviderRow: View {
    let provider: RemittanceProvider
    let sendAmount: Double
    let fromCurrency: String
    let toCurrency: String
    
    var receivedAmount: Double {
        // Simulated calculation - in real app, use actual exchange rates
        let baseRate: Double = toCurrency == "NPR" ? 133.5 : 83.0
        let effectiveRate = baseRate * provider.exchangeRate
        return (sendAmount - provider.transferFee) * effectiveRate
    }
    
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
                        .fill(Color.brand.opacity(0.1))
                        .overlay {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.brand)
                        }
                }
            }
            .frame(width: 40, height: 40)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xs))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(provider.name)
                    .font(.appSubheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                
                Text("Fee: $\(String(format: "%.2f", provider.transferFee)) • \(provider.transferTime)")
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(String(format: "%.2f", receivedAmount)) \(toCurrency)")
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", provider.rating))
                        .font(.appCaption2)
                        .foregroundColor(.textTertiary)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

// MARK: - Transaction Card

struct TransactionCard: View {
    let transaction: Transaction
    
    var statusColor: Color {
        Color(hex: transaction.status.color)
    }
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Status Icon
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: statusIcon)
                    .foregroundColor(statusColor)
            }
            
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("To \(transaction.recipientName)")
                    .font(.appSubheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                
                Text("\(transaction.recipientCountry) • \(transaction.date)")
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: Spacing.xxs) {
                Text("\(transaction.currency) \(String(format: "%.2f", transaction.amount))")
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Text(transaction.status.rawValue.capitalized)
                    .font(.appCaption2)
                    .fontWeight(.medium)
                    .foregroundColor(statusColor)
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
    
    var statusIcon: String {
        switch transaction.status {
        case .pending: return "clock"
        case .processing: return "arrow.2.circlepath"
        case .completed: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        }
    }
}

// MARK: - Provider Detail View

struct RemittanceProviderDetailView: View {
    let provider: RemittanceProvider
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Header
                    VStack(spacing: Spacing.md) {
                        AsyncImage(url: URL(string: provider.logo)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            default:
                                Circle()
                                    .fill(Color.brand.opacity(0.1))
                                    .overlay {
                                        Image(systemName: "dollarsign.circle.fill")
                                            .font(.largeTitle)
                                            .foregroundColor(.brand)
                                    }
                            }
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                        
                        Text(provider.name)
                            .font(.appTitle2)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                        
                        HStack(spacing: Spacing.sm) {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", provider.rating))
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.textPrimary)
                            
                            Text("•")
                                .foregroundColor(.textTertiary)
                            
                            Text("\(provider.supportedCountries.count) countries")
                                .foregroundColor(.textSecondary)
                        }
                        .font(.appSubheadline)
                    }
                    .padding(Spacing.lg)
                    .frame(maxWidth: .infinity)
                    .background(Color.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
                    
                    // Key Stats
                    HStack(spacing: Spacing.md) {
                        ProviderStatBox(
                            title: "Transfer Fee",
                            value: "$\(String(format: "%.2f", provider.transferFee))",
                            icon: "creditcard",
                            color: .green
                        )
                        
                        ProviderStatBox(
                            title: "Delivery Time",
                            value: provider.transferTime,
                            icon: "clock",
                            color: .brand
                        )
                        
                        ProviderStatBox(
                            title: "Min Amount",
                            value: "$\(Int(provider.minAmount))",
                            icon: "arrow.down.circle",
                            color: .orange
                        )
                    }
                    
                    // Payment Methods
                    InfoSection(title: "Payment Methods") {
                        FlowLayout(spacing: Spacing.xs) {
                            ForEach(provider.paymentMethods, id: \.self) { method in
                                Text(method)
                                    .font(.appCaption)
                                    .padding(.horizontal, Spacing.sm)
                                    .padding(.vertical, Spacing.xxs)
                                    .background(Color.brand.opacity(0.1))
                                    .foregroundColor(.brand)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    
                    // Features
                    InfoSection(title: "Features") {
                        ForEach(provider.features, id: \.self) { feature in
                            HStack(spacing: Spacing.sm) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(feature)
                                    .font(.appBody)
                                    .foregroundColor(.textPrimary)
                            }
                        }
                    }
                    
                    // Supported Countries
                    InfoSection(title: "Supported Countries") {
                        Text(provider.supportedCountries.joined(separator: ", "))
                            .font(.appBody)
                            .foregroundColor(.textSecondary)
                    }
                    
                    // Actions
                    Link(destination: URL(string: provider.website)!) {
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

struct ProviderStatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.appSubheadline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            Text(title)
                .font(.appCaption2)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.md)
        .background(Color.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

// MARK: - Preview

#Preview {
    RemittanceView()
        .environmentObject(DataService.shared)
}

