//
//  CurrencyConverterView.swift
//  Educa
//
//  Currency converter with NPR base rates
//  Helps Nepali students understand costs in destination currencies
//

import SwiftUI

struct CurrencyConverterView: View {
    @EnvironmentObject var dataService: DataService
    @State private var amount: String = "100000"
    @State private var fromCurrency = "NPR"
    @State private var toCurrency = "AUD"
    @FocusState private var isAmountFocused: Bool
    
    let currencies = [
        ("NPR", "🇳🇵", "Nepali Rupee", 1.0),
        ("USD", "🇺🇸", "US Dollar", 133.50),
        ("AUD", "🇦🇺", "Australian Dollar", 87.20),
        ("GBP", "🇬🇧", "British Pound", 169.50),
        ("EUR", "🇪🇺", "Euro", 141.20),
        ("CAD", "🇨🇦", "Canadian Dollar", 95.80),
        ("JPY", "🇯🇵", "Japanese Yen", 0.89),
        ("KRW", "🇰🇷", "South Korean Won", 0.097),
        ("NZD", "🇳🇿", "New Zealand Dollar", 80.50),
        ("SGD", "🇸🇬", "Singapore Dollar", 99.80),
        ("INR", "🇮🇳", "Indian Rupee", 1.60)
    ]
    
    var convertedAmount: String {
        guard let inputAmount = Double(amount.replacingOccurrences(of: ",", with: "")) else { return "0" }
        
        let fromRate = currencies.first { $0.0 == fromCurrency }?.3 ?? 1.0
        let toRate = currencies.first { $0.0 == toCurrency }?.3 ?? 1.0
        
        // Convert to NPR first, then to target currency
        let nprAmount = fromCurrency == "NPR" ? inputAmount : inputAmount * fromRate
        let result = toCurrency == "NPR" ? nprAmount : nprAmount / toRate
        
        if result >= 1000000 {
            return String(format: "%.2f M", result / 1000000)
        } else if result >= 1000 {
            return String(format: "%.2f", result)
        } else {
            return String(format: "%.2f", result)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                // Converter Card
                converterCard
                
                // Quick Conversions
                quickConversionsSection
                
                // Exchange Rates Table
                exchangeRatesSection
                
                // Tips Section
                tipsSection
            }
            .padding(Spacing.md)
            .padding(.bottom, 100)
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("Currency Converter")
        .onTapGesture {
            isAmountFocused = false
        }
    }
    
    // MARK: - Converter Card
    
    private var converterCard: some View {
        VStack(spacing: Spacing.lg) {
            // From Currency
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Amount")
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
                
                HStack {
                    Menu {
                        ForEach(currencies, id: \.0) { code, flag, name, _ in
                            Button {
                                fromCurrency = code
                            } label: {
                                HStack {
                                    Text(flag)
                                    Text(code)
                                    if fromCurrency == code {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(currencies.first { $0.0 == fromCurrency }?.1 ?? "")
                            Text(fromCurrency)
                                .fontWeight(.semibold)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .background(Color.backgroundTertiary)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
                    }
                    
                    TextField("Enter amount", text: $amount)
                        .font(.appTitle2)
                        .fontWeight(.semibold)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .focused($isAmountFocused)
                }
            }
            
            // Swap Button
            Button {
                let temp = fromCurrency
                fromCurrency = toCurrency
                toCurrency = temp
                HapticManager.shared.tap()
            } label: {
                Image(systemName: "arrow.up.arrow.down.circle.fill")
                    .font(.title)
                    .foregroundColor(.brand)
            }
            
            // To Currency
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Converted Amount")
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
                
                HStack {
                    Menu {
                        ForEach(currencies, id: \.0) { code, flag, name, _ in
                            Button {
                                toCurrency = code
                            } label: {
                                HStack {
                                    Text(flag)
                                    Text(code)
                                    if toCurrency == code {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(currencies.first { $0.0 == toCurrency }?.1 ?? "")
                            Text(toCurrency)
                                .fontWeight(.semibold)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .background(Color.backgroundTertiary)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
                    }
                    
                    Spacer()
                    
                    Text(convertedAmount)
                        .font(.appTitle2)
                        .fontWeight(.bold)
                        .foregroundColor(.brand)
                }
            }
            
            // Rate Info
            if let fromRate = currencies.first(where: { $0.0 == fromCurrency })?.3,
               let toRate = currencies.first(where: { $0.0 == toCurrency })?.3 {
                let rate = fromCurrency == "NPR" ? (1 / toRate) : (toRate == 1.0 ? fromRate : fromRate / toRate)
                
                Text("1 \(fromCurrency) = \(String(format: "%.4f", rate)) \(toCurrency)")
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
                    .padding(.top, Spacing.xs)
            }
        }
        .padding(Spacing.lg)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
    
    // MARK: - Quick Conversions
    
    private var quickConversionsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Quick Reference (NPR)", icon: "bolt.fill")
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
                QuickConversionCard(nprAmount: "10,000", audAmount: "115", usdAmount: "75")
                QuickConversionCard(nprAmount: "50,000", audAmount: "575", usdAmount: "375")
                QuickConversionCard(nprAmount: "1,00,000", audAmount: "1,150", usdAmount: "750")
                QuickConversionCard(nprAmount: "10,00,000", audAmount: "11,500", usdAmount: "7,500")
            }
        }
    }
    
    // MARK: - Exchange Rates
    
    private var exchangeRatesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                SectionHeader(title: "Today's Rates (1 NPR =)", icon: "chart.line.uptrend.xyaxis")
                Spacer()
                Text("Dec 5, 2024")
                    .font(.appCaption2)
                    .foregroundColor(.textTertiary)
            }
            
            VStack(spacing: 0) {
                ForEach(currencies.filter { $0.0 != "NPR" }, id: \.0) { code, flag, name, rate in
                    HStack {
                        Text(flag)
                            .font(.title2)
                        
                        VStack(alignment: .leading) {
                            Text(code)
                                .font(.appSubheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.textPrimary)
                            Text(name)
                                .font(.appCaption2)
                                .foregroundColor(.textSecondary)
                        }
                        
                        Spacer()
                        
                        Text(String(format: "%.4f", 1.0 / rate))
                            .font(.appSubheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.brand)
                    }
                    .padding(.vertical, Spacing.sm)
                    
                    if code != "INR" {
                        Divider()
                    }
                }
            }
            .padding(Spacing.md)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        }
    }
    
    // MARK: - Tips Section
    
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Money Transfer Tips", icon: "lightbulb.fill")
            
            VStack(spacing: Spacing.sm) {
                TipRow(tip: "Compare rates across multiple remittance services before transferring")
                TipRow(tip: "Transfer larger amounts less frequently to save on fees")
                TipRow(tip: "Set rate alerts to transfer when rates are favorable")
                TipRow(tip: "Consider services like Wise, Remitly, or Western Union for best rates")
                TipRow(tip: "Keep receipts of all international transfers for visa documentation")
            }
        }
    }
}

// MARK: - Supporting Components

struct QuickConversionCard: View {
    let nprAmount: String
    let audAmount: String
    let usdAmount: String
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text("NPR \(nprAmount)")
                .font(.appSubheadline)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            HStack(spacing: Spacing.md) {
                VStack {
                    Text("🇦🇺")
                    Text("$\(audAmount)")
                        .font(.appCaption)
                        .foregroundColor(.brand)
                }
                
                VStack {
                    Text("🇺🇸")
                    Text("$\(usdAmount)")
                        .font(.appCaption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

struct TipRow: View {
    let tip: String
    
    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.caption)
            
            Text(tip)
                .font(.appCaption)
                .foregroundColor(.textSecondary)
        }
    }
}

