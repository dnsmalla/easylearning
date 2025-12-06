//
//  VisaGuideView.swift
//  Educa
//
//  Comprehensive visa guide for Nepali students
//  Step-by-step visa requirements for popular destinations
//

import SwiftUI

// MARK: - Visa Guide Main View

struct VisaGuideView: View {
    @EnvironmentObject var dataService: DataService
    @State private var selectedCountry: String?
    @State private var searchText = ""
    
    let popularCountries = [
        ("Australia", "🇦🇺", "Student Visa 500"),
        ("Japan", "🇯🇵", "Student Visa"),
        ("South Korea", "🇰🇷", "D-2 Visa"),
        ("USA", "🇺🇸", "F-1 Visa"),
        ("UK", "🇬🇧", "Student Route"),
        ("Canada", "🇨🇦", "Study Permit"),
        ("Germany", "🇩🇪", "Student Visa"),
        ("New Zealand", "🇳🇿", "Student Visa")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Warning Banner
                    warningBanner
                    
                    // Popular Destinations
                    popularDestinationsSection
                    
                    // Embassy Quick Contact
                    embassyQuickContact
                    
                    // General Tips
                    generalTipsSection
                    
                    // Document Checklist
                    documentChecklistSection
                }
                .padding(Spacing.md)
                .padding(.bottom, 100)
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Visa Guide")
            .searchable(text: $searchText, prompt: "Search countries...")
        }
    }
    
    // MARK: - Warning Banner
    
    private var warningBanner: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Important Notice")
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Text("Visa requirements change frequently. Always verify with the official embassy website before applying.")
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(Spacing.md)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
    
    // MARK: - Popular Destinations
    
    private var popularDestinationsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Popular Destinations", icon: "globe.asia.australia.fill")
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.md) {
                ForEach(popularCountries, id: \.0) { country, flag, visaType in
                    NavigationLink {
                        CountryVisaDetailView(country: country, flag: flag, visaType: visaType)
                    } label: {
                        VisaCountryCard(country: country, flag: flag, visaType: visaType)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: - Embassy Quick Contact
    
    private var embassyQuickContact: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Embassies in Kathmandu", icon: "building.columns.fill")
            
            VStack(spacing: Spacing.sm) {
                EmbassyContactRow(
                    country: "Australia",
                    flag: "🇦🇺",
                    address: "Bansbari, Kathmandu",
                    phone: "+977-1-4371678"
                )
                
                EmbassyContactRow(
                    country: "Japan",
                    flag: "🇯🇵",
                    address: "Panipokhari, Kathmandu",
                    phone: "+977-1-4426680"
                )
                
                EmbassyContactRow(
                    country: "South Korea",
                    flag: "🇰🇷",
                    address: "Tahachal, Kathmandu",
                    phone: "+977-1-4270172"
                )
                
                EmbassyContactRow(
                    country: "USA",
                    flag: "🇺🇸",
                    address: "Maharajgunj, Kathmandu",
                    phone: "+977-1-4234000"
                )
                
                EmbassyContactRow(
                    country: "UK",
                    flag: "🇬🇧",
                    address: "Lainchaur, Kathmandu",
                    phone: "+977-1-4237100"
                )
            }
            
            NavigationLink {
                EmbassyDirectoryView()
            } label: {
                HStack {
                    Text("View All Embassies")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .font(.appSubheadline)
                .fontWeight(.medium)
                .foregroundColor(.brand)
                .padding(Spacing.md)
                .background(Color.brand.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            }
        }
    }
    
    // MARK: - General Tips
    
    private var generalTipsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Visa Application Tips", icon: "lightbulb.fill")
            
            VStack(spacing: Spacing.sm) {
                VisaTipRow(
                    icon: "clock.fill",
                    title: "Apply Early",
                    description: "Start your visa process at least 3 months before your course starts"
                )
                
                VisaTipRow(
                    icon: "doc.text.fill",
                    title: "Complete Documents",
                    description: "Ensure all documents are properly attested and translated"
                )
                
                VisaTipRow(
                    icon: "dollarsign.circle.fill",
                    title: "Show Funds",
                    description: "Maintain sufficient balance in your bank account for 6+ months"
                )
                
                VisaTipRow(
                    icon: "person.fill.checkmark",
                    title: "Genuine Intent",
                    description: "Clearly demonstrate your intention to study and return to Nepal"
                )
                
                VisaTipRow(
                    icon: "checkmark.shield.fill",
                    title: "Use Authorized Agents",
                    description: "Only use licensed education consultants for visa assistance"
                )
            }
        }
    }
    
    // MARK: - Document Checklist
    
    private var documentChecklistSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Common Documents Required", icon: "doc.on.doc.fill")
            
            VStack(spacing: Spacing.sm) {
                DocumentRow(name: "Valid Passport (min. 6 months validity)", isMandatory: true)
                DocumentRow(name: "Offer Letter / CoE from University", isMandatory: true)
                DocumentRow(name: "English Language Test Score (IELTS/TOEFL/PTE)", isMandatory: true)
                DocumentRow(name: "Academic Transcripts & Certificates", isMandatory: true)
                DocumentRow(name: "Bank Statements (6-12 months)", isMandatory: true)
                DocumentRow(name: "Sponsorship Letter (if sponsored)", isMandatory: false)
                DocumentRow(name: "Relationship Proof (for sponsor)", isMandatory: false)
                DocumentRow(name: "Statement of Purpose (SOP)", isMandatory: true)
                DocumentRow(name: "CV / Resume", isMandatory: false)
                DocumentRow(name: "Police Clearance Certificate", isMandatory: true)
                DocumentRow(name: "Medical Examination Report", isMandatory: true)
                DocumentRow(name: "Passport Size Photos", isMandatory: true)
            }
        }
    }
}

// MARK: - Country Visa Detail View

struct CountryVisaDetailView: View {
    let country: String
    let flag: String
    let visaType: String
    
    @State private var selectedTab = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Header
                countryHeader
                
                // Tab Selector
                Picker("Section", selection: $selectedTab) {
                    Text("Requirements").tag(0)
                    Text("Process").tag(1)
                    Text("Costs").tag(2)
                    Text("Tips").tag(3)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, Spacing.md)
                
                // Content
                switch selectedTab {
                case 0: requirementsSection
                case 1: processSection
                case 2: costsSection
                default: tipsSection
                }
            }
            .padding(.bottom, 100)
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("\(flag) \(country)")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var countryHeader: some View {
        VStack(spacing: Spacing.md) {
            Text(flag)
                .font(.system(size: 60))
            
            Text(visaType)
                .font(.appTitle3)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            HStack(spacing: Spacing.lg) {
                VStack {
                    Text(getProcessingTime())
                        .font(.appHeadline)
                        .fontWeight(.bold)
                        .foregroundColor(.brand)
                    Text("Processing")
                        .font(.appCaption2)
                        .foregroundColor(.textSecondary)
                }
                
                Divider()
                    .frame(height: 30)
                
                VStack {
                    Text(getVisaFee())
                        .font(.appHeadline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Visa Fee")
                        .font(.appCaption2)
                        .foregroundColor(.textSecondary)
                }
                
                Divider()
                    .frame(height: 30)
                
                VStack {
                    Text(getWorkHours())
                        .font(.appHeadline)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("Work/Week")
                        .font(.appCaption2)
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(Color.backgroundSecondary)
    }
    
    private var requirementsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            // Eligibility
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Eligibility Criteria")
                    .font(.appTitle3)
                    .foregroundColor(.textPrimary)
                
                ForEach(getEligibility(), id: \.self) { item in
                    HStack(alignment: .top) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(item)
                            .font(.appBody)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .padding(Spacing.md)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
            
            // Documents
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Required Documents")
                    .font(.appTitle3)
                    .foregroundColor(.textPrimary)
                
                ForEach(getRequiredDocuments(), id: \.self) { doc in
                    HStack(alignment: .top) {
                        Image(systemName: "doc.fill")
                            .foregroundColor(.brand)
                        Text(doc)
                            .font(.appBody)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .padding(Spacing.md)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
            
            // Financial Requirements
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Financial Requirements")
                    .font(.appTitle3)
                    .foregroundColor(.textPrimary)
                
                Text(getFinancialRequirement())
                    .font(.appBody)
                    .foregroundColor(.textSecondary)
            }
            .padding(Spacing.md)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        }
        .padding(.horizontal, Spacing.md)
    }
    
    private var processSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Step-by-Step Process")
                .font(.appTitle3)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, Spacing.md)
            
            ForEach(Array(getVisaProcess().enumerated()), id: \.offset) { index, step in
                VisaStepCard(stepNumber: index + 1, step: step)
            }
        }
        .padding(.horizontal, Spacing.md)
    }
    
    private var costsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            // Visa Fees
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Visa Application Costs")
                    .font(.appTitle3)
                    .foregroundColor(.textPrimary)
                
                VStack(spacing: Spacing.sm) {
                    CostRow(item: "Visa Application Fee", cost: getVisaFee())
                    CostRow(item: "OSHC/Health Insurance", cost: getInsuranceCost())
                    CostRow(item: "Biometrics (if required)", cost: getBiometricsCost())
                    CostRow(item: "Medical Examination", cost: "NPR 10,000 - 15,000")
                    CostRow(item: "Police Report", cost: "NPR 500")
                    
                    Divider()
                    
                    HStack {
                        Text("Estimated Total")
                            .font(.appHeadline)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                        Spacer()
                        Text(getTotalCost())
                            .font(.appHeadline)
                            .fontWeight(.bold)
                            .foregroundColor(.brand)
                    }
                }
            }
            .padding(Spacing.md)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
            
            // Living Costs
            NavigationLink {
                CostOfLivingView()
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Cost of Living Calculator")
                            .font(.appSubheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                        Text("Calculate monthly expenses in \(country)")
                            .font(.appCaption)
                            .foregroundColor(.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.brand)
                }
                .padding(Spacing.md)
                .background(Color.brand.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            }
        }
        .padding(.horizontal, Spacing.md)
    }
    
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            ForEach(Array(getCountryTips().enumerated()), id: \.offset) { index, tip in
                TipCard(number: index + 1, tip: tip)
            }
        }
        .padding(.horizontal, Spacing.md)
    }
    
    // Helper functions for country-specific data
    private func getProcessingTime() -> String {
        switch country {
        case "Australia": return "4-8 weeks"
        case "Japan": return "5-10 days"
        case "South Korea": return "2-4 weeks"
        case "USA": return "2-4 weeks"
        case "UK": return "3 weeks"
        case "Canada": return "8-16 weeks"
        default: return "4-8 weeks"
        }
    }
    
    private func getVisaFee() -> String {
        switch country {
        case "Australia": return "AUD 710"
        case "Japan": return "NPR 4,200"
        case "South Korea": return "NPR 8,500"
        case "USA": return "USD 185"
        case "UK": return "GBP 490"
        case "Canada": return "CAD 150"
        default: return "Varies"
        }
    }
    
    private func getWorkHours() -> String {
        switch country {
        case "Australia": return "48 hrs/fortnight"
        case "Japan": return "28 hrs"
        case "South Korea": return "20 hrs"
        case "USA": return "20 hrs"
        case "UK": return "20 hrs"
        case "Canada": return "20 hrs"
        default: return "20 hrs"
        }
    }
    
    private func getEligibility() -> [String] {
        switch country {
        case "Australia":
            return [
                "Enrolled in a CRICOS registered course",
                "Genuine Temporary Entrant (GTE) requirement",
                "English language proficiency (IELTS 5.5+)",
                "Sufficient funds for tuition and living",
                "Overseas Student Health Cover (OSHC)",
                "No previous visa cancellations or refusals"
            ]
        case "Japan":
            return [
                "Certificate of Eligibility (CoE) from school",
                "Japanese language proficiency for language schools",
                "High school or above education level",
                "Financial capacity proof",
                "No criminal record"
            ]
        default:
            return [
                "Valid offer letter from recognized institution",
                "Meet language requirements",
                "Show sufficient funds",
                "Clear background check"
            ]
        }
    }
    
    private func getRequiredDocuments() -> [String] {
        switch country {
        case "Australia":
            return [
                "Valid Passport",
                "Confirmation of Enrolment (CoE)",
                "IELTS/PTE/TOEFL Score",
                "GTE Statement",
                "Financial Evidence",
                "OSHC Certificate",
                "Academic Documents",
                "English Translations"
            ]
        case "Japan":
            return [
                "Valid Passport",
                "Certificate of Eligibility (CoE)",
                "Visa Application Form",
                "Passport Photo (4.5 x 4.5 cm)",
                "Academic Certificates",
                "Financial Documents"
            ]
        default:
            return [
                "Valid Passport",
                "Offer Letter / CoE",
                "Language Test Score",
                "Financial Documents",
                "Academic Certificates"
            ]
        }
    }
    
    private func getFinancialRequirement() -> String {
        switch country {
        case "Australia":
            return "You must show AUD 24,505/year for living costs + tuition fees + return airfare. Bank statements should show consistent balance for 3+ months."
        case "Japan":
            return "JPY 2,000,000 (approx. NPR 18 lakhs) in bank account. Sponsor letter required if funded by family."
        case "South Korea":
            return "USD 10,000 minimum bank balance. Additional proof of sponsor's income if sponsored."
        default:
            return "Sufficient funds to cover tuition fees and living expenses for the duration of study."
        }
    }
    
    private func getVisaProcess() -> [String] {
        switch country {
        case "Australia":
            return [
                "Receive CoE from your university after fee payment",
                "Purchase OSHC (Overseas Student Health Cover)",
                "Create ImmiAccount on the Department of Home Affairs website",
                "Complete online visa application form (Form 157A)",
                "Upload all required documents",
                "Pay visa application fee (AUD 710)",
                "Complete health examination at approved panel physician",
                "Submit biometrics (if requested)",
                "Wait for visa decision (4-8 weeks)",
                "Receive visa grant notification via email"
            ]
        case "Japan":
            return [
                "Get accepted by a Japanese educational institution",
                "School applies for Certificate of Eligibility (CoE)",
                "Receive CoE (takes 1-3 months)",
                "Gather required documents",
                "Submit visa application at Japanese Embassy",
                "Pay visa fee (NPR 4,200)",
                "Collect visa (5-10 business days)"
            ]
        default:
            return [
                "Receive offer letter from institution",
                "Pay tuition deposit",
                "Gather all required documents",
                "Submit visa application",
                "Complete biometrics/interview if required",
                "Wait for processing",
                "Receive visa"
            ]
        }
    }
    
    private func getInsuranceCost() -> String {
        switch country {
        case "Australia": return "AUD 500-600/year"
        case "UK": return "GBP 470/year"
        default: return "Varies"
        }
    }
    
    private func getBiometricsCost() -> String {
        switch country {
        case "UK": return "NPR 8,000"
        case "Canada": return "CAD 85"
        default: return "N/A"
        }
    }
    
    private func getTotalCost() -> String {
        switch country {
        case "Australia": return "NPR 1,50,000 - 2,00,000"
        case "Japan": return "NPR 30,000 - 50,000"
        case "South Korea": return "NPR 40,000 - 60,000"
        case "USA": return "NPR 50,000 - 80,000"
        case "UK": return "NPR 1,20,000 - 1,50,000"
        default: return "Varies"
        }
    }
    
    private func getCountryTips() -> [String] {
        switch country {
        case "Australia":
            return [
                "Write a strong GTE statement explaining why you chose Australia and your plans after graduation",
                "Show consistent savings in your bank account, not sudden large deposits",
                "If sponsored, clearly show the relationship and sponsor's financial capacity",
                "Apply through a MARA-registered agent for professional guidance",
                "Complete your health examination promptly when requested",
                "Keep all original documents ready for verification"
            ]
        case "Japan":
            return [
                "Start learning basic Japanese before applying - it shows genuine interest",
                "CoE processing takes 1-3 months, so plan ahead",
                "Maintain minimum Japanese language ability (JLPT N5) for language schools",
                "Financial sponsor should have stable income and clear relationship proof",
                "Part-time work is allowed but requires separate permission"
            ]
        default:
            return [
                "Apply well in advance of your intended start date",
                "Prepare all documents carefully and get them attested",
                "Show clear intention to study and return to Nepal",
                "Use authorized education consultants only"
            ]
        }
    }
}

// MARK: - Supporting Components

struct VisaCountryCard: View {
    let country: String
    let flag: String
    let visaType: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(flag)
                .font(.system(size: 36))
            
            Text(country)
                .font(.appHeadline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            Text(visaType)
                .font(.appCaption)
                .foregroundColor(.brand)
            
            HStack {
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(.brand)
                Text("View Guide")
                    .font(.appCaption)
                    .foregroundColor(.brand)
            }
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .cardShadow()
    }
}

struct EmbassyContactRow: View {
    let country: String
    let flag: String
    let address: String
    let phone: String
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            Text(flag)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(country)
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Text(address)
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Button {
                if let url = URL(string: "tel:\(phone)") {
                    UIApplication.shared.open(url)
                }
            } label: {
                Image(systemName: "phone.fill")
                    .foregroundColor(.brand)
                    .padding(Spacing.xs)
                    .background(Color.brand.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

struct VisaTipRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.brand)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.appSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Text(description)
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

struct DocumentRow: View {
    let name: String
    let isMandatory: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isMandatory ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isMandatory ? .green : .textTertiary)
            
            Text(name)
                .font(.appSubheadline)
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            if isMandatory {
                Text("Required")
                    .font(.appCaption2)
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, Spacing.xs)
    }
}

struct VisaStepCard: View {
    let stepNumber: Int
    let step: String
    
    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Text("\(stepNumber)")
                .font(.appHeadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Color.brand)
                .clipShape(Circle())
            
            Text(step)
                .font(.appBody)
                .foregroundColor(.textPrimary)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

struct CostRow: View {
    let item: String
    let cost: String
    
    var body: some View {
        HStack {
            Text(item)
                .font(.appSubheadline)
                .foregroundColor(.textSecondary)
            
            Spacer()
            
            Text(cost)
                .font(.appSubheadline)
                .fontWeight(.medium)
                .foregroundColor(.textPrimary)
        }
        .padding(.vertical, Spacing.xxs)
    }
}

