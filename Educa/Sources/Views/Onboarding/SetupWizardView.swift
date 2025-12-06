//
//  SetupWizardView.swift
//  Educa
//
//  Professional setup wizard for collecting user preferences
//  Data-driven content based on user selections
//

import SwiftUI

struct SetupWizardView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataService: DataService
    @Binding var isComplete: Bool
    
    @State private var currentStep = 0
    @State private var userName = ""
    @State private var selectedHomeCountry: HomeCountry?
    @State private var selectedDestination: DestinationCountry?
    @State private var selectedDegree: TargetDegree?
    @State private var selectedField: StudyField?
    @State private var targetIntake = ""
    @State private var animateContent = false
    
    private let totalSteps = 5
    
    var body: some View {
        ZStack {
            // Background
            backgroundGradient
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Progress
                progressBar
                    .padding(.horizontal, Spacing.xl)
                    .padding(.top, Spacing.md)
                
                // Step Content
                TabView(selection: $currentStep) {
                    // Step 0: Welcome & Name
                    welcomeStep
                        .tag(0)
                    
                    // Step 1: Home Country
                    homeCountryStep
                        .tag(1)
                    
                    // Step 2: Destination Country
                    destinationStep
                        .tag(2)
                    
                    // Step 3: Degree Level
                    degreeStep
                        .tag(3)
                    
                    // Step 4: Study Field & Intake
                    fieldStep
                        .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentStep)
                
                // Bottom Navigation
                bottomNavigation
            }
        }
        .onAppear {
            loadExistingData()
            withAnimation(.easeOut(duration: 0.6)) {
                animateContent = true
            }
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.brand.opacity(0.08),
                Color.backgroundPrimary
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            if currentStep > 0 {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        currentStep -= 1
                    }
                    HapticManager.shared.tap()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.textSecondary)
                        .frame(width: 44, height: 44)
                        .background(Color.backgroundSecondary)
                        .clipShape(Circle())
                }
            } else {
                Color.clear.frame(width: 44, height: 44)
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text("Step \(currentStep + 1) of \(totalSteps)")
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
                Text(stepTitle)
                    .font(.appHeadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
            }
            
            Spacer()
            
            // Skip button (only for non-essential steps)
            if currentStep > 2 {
                Button {
                    completeSetup()
                } label: {
                    Text("Skip")
                        .font(.appSubheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.textSecondary)
                }
                .frame(width: 44)
            } else {
                Color.clear.frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.md)
    }
    
    private var stepTitle: String {
        switch currentStep {
        case 0: return "Welcome"
        case 1: return "Where are you from?"
        case 2: return "Choose Destination"
        case 3: return "Education Level"
        case 4: return "Your Goals"
        default: return ""
        }
    }
    
    // MARK: - Progress Bar
    
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                Capsule()
                    .fill(Color.brand.opacity(0.15))
                    .frame(height: 6)
                
                // Progress
                Capsule()
                    .fill(LinearGradient.brandGradient)
                    .frame(width: geometry.size.width * CGFloat(currentStep + 1) / CGFloat(totalSteps), height: 6)
                    .animation(.spring(response: 0.4), value: currentStep)
            }
        }
        .frame(height: 6)
    }
    
    // MARK: - Step 0: Welcome
    
    private var welcomeStep: some View {
        ScrollView {
            VStack(spacing: Spacing.xxl) {
                Spacer().frame(height: Spacing.xl)
                
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.brand.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 50))
                        .foregroundStyle(LinearGradient.brandGradient)
                }
                .scaleEffect(animateContent ? 1 : 0.8)
                .opacity(animateContent ? 1 : 0)
                
                VStack(spacing: Spacing.md) {
                    Text("Let's Get Started!")
                        .font(.appTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text("We'll personalize your experience based on your goals")
                        .font(.appBody)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.xl)
                }
                
                // Name Input
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Your Name")
                        .font(.appSubheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textSecondary)
                    
                    TextField("Enter your name", text: $userName)
                        .font(.appBody)
                        .padding(Spacing.md)
                        .background(Color.backgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.medium)
                                .stroke(userName.isEmpty ? Color.clear : Color.brand.opacity(0.5), lineWidth: 2)
                        )
                }
                .padding(.horizontal, Spacing.xl)
                
                Spacer()
            }
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Step 1: Home Country
    
    private var homeCountryStep: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                VStack(spacing: Spacing.md) {
                    Image(systemName: "globe.asia.australia.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(LinearGradient.brandGradient)
                    
                    Text("Where are you from?")
                        .font(.appTitle2)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text("We'll show relevant embassies, visa info, and local resources")
                        .font(.appSubheadline)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.lg)
                }
                .padding(.top, Spacing.xl)
                
                // Country Grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: Spacing.md),
                    GridItem(.flexible(), spacing: Spacing.md)
                ], spacing: Spacing.md) {
                    ForEach(HomeCountry.allCases.filter { $0 != .other }, id: \.id) { country in
                        HomeCountryCard(
                            country: country,
                            isSelected: selectedHomeCountry == country
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedHomeCountry = country
                            }
                            HapticManager.shared.selection()
                        }
                    }
                }
                .padding(.horizontal, Spacing.lg)
                
                // Other option
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedHomeCountry = .other
                    }
                    HapticManager.shared.selection()
                } label: {
                    HStack {
                        Text("🌍")
                            .font(.title2)
                        Text("Other Country")
                            .font(.appSubheadline)
                            .fontWeight(.medium)
                        Spacer()
                        if selectedHomeCountry == .other {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.brand)
                        }
                    }
                    .foregroundColor(.textPrimary)
                    .padding(Spacing.md)
                    .background(selectedHomeCountry == .other ? Color.brand.opacity(0.1) : Color.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.medium)
                            .stroke(selectedHomeCountry == .other ? Color.brand : Color.clear, lineWidth: 2)
                    )
                }
                .padding(.horizontal, Spacing.lg)
                
                Spacer().frame(height: 100)
            }
        }
    }
    
    // MARK: - Step 2: Destination
    
    private var destinationStep: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                VStack(spacing: Spacing.md) {
                    Image(systemName: "airplane.departure")
                        .font(.system(size: 40))
                        .foregroundStyle(LinearGradient.brandGradient)
                    
                    Text("Where do you want to study?")
                        .font(.appTitle2)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text("All content will be tailored to your chosen destination")
                        .font(.appSubheadline)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.lg)
                }
                .padding(.top, Spacing.xl)
                
                // Destination Grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: Spacing.md),
                    GridItem(.flexible(), spacing: Spacing.md)
                ], spacing: Spacing.md) {
                    ForEach(DestinationCountry.allCases, id: \.id) { country in
                        DestinationCountryCard(
                            country: country,
                            isSelected: selectedDestination == country
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedDestination = country
                            }
                            HapticManager.shared.selection()
                        }
                    }
                }
                .padding(.horizontal, Spacing.lg)
                
                Spacer().frame(height: 100)
            }
        }
    }
    
    // MARK: - Step 3: Degree Level
    
    private var degreeStep: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                VStack(spacing: Spacing.md) {
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(LinearGradient.brandGradient)
                    
                    Text("What degree are you targeting?")
                        .font(.appTitle2)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text("We'll show relevant programs and scholarships")
                        .font(.appSubheadline)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, Spacing.xl)
                
                // Degree Options
                VStack(spacing: Spacing.sm) {
                    ForEach(TargetDegree.allCases, id: \.id) { degree in
                        DegreeOptionCard(
                            degree: degree,
                            isSelected: selectedDegree == degree
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedDegree = degree
                            }
                            HapticManager.shared.selection()
                        }
                    }
                }
                .padding(.horizontal, Spacing.lg)
                
                Spacer().frame(height: 100)
            }
        }
    }
    
    // MARK: - Step 4: Field & Intake
    
    private var fieldStep: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                VStack(spacing: Spacing.md) {
                    Image(systemName: "target")
                        .font(.system(size: 40))
                        .foregroundStyle(LinearGradient.brandGradient)
                    
                    Text("Almost there!")
                        .font(.appTitle2)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text("What field interests you?")
                        .font(.appSubheadline)
                        .foregroundColor(.textSecondary)
                }
                .padding(.top, Spacing.lg)
                
                // Field Selection
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Study Field")
                        .font(.appSubheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textSecondary)
                        .padding(.horizontal, Spacing.lg)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.sm) {
                            ForEach(StudyField.allCases, id: \.id) { field in
                                FieldChip(
                                    field: field,
                                    isSelected: selectedField == field
                                ) {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedField = field
                                    }
                                    HapticManager.shared.selection()
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                    }
                }
                
                // Target Intake
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Target Intake (Optional)")
                        .font(.appSubheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textSecondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.sm) {
                            ForEach(intakeOptions, id: \.self) { intake in
                                IntakeChip(
                                    intake: intake,
                                    isSelected: targetIntake == intake
                                ) {
                                    withAnimation(.spring(response: 0.3)) {
                                        targetIntake = intake
                                    }
                                    HapticManager.shared.selection()
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, Spacing.lg)
                
                // Summary Card
                if selectedDestination != nil || selectedDegree != nil {
                    summaryCard
                        .padding(.horizontal, Spacing.lg)
                }
                
                Spacer().frame(height: 100)
            }
        }
    }
    
    private var intakeOptions: [String] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return [
            "Spring \(currentYear + 1)",
            "Fall \(currentYear + 1)",
            "Spring \(currentYear + 2)",
            "Fall \(currentYear + 2)",
            "Not Sure Yet"
        ]
    }
    
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Your Journey")
                    .font(.appHeadline)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.brand)
            }
            
            Divider()
            
            if let home = selectedHomeCountry {
                SummaryRow(label: "From", value: "\(home.flag) \(home.name)")
            }
            
            if let dest = selectedDestination {
                SummaryRow(label: "To", value: "\(dest.flag) \(dest.name)")
            }
            
            if let degree = selectedDegree {
                SummaryRow(label: "Degree", value: degree.name)
            }
            
            if let field = selectedField {
                SummaryRow(label: "Field", value: field.name)
            }
        }
        .padding(Spacing.lg)
        .background(Color.brand.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.large)
                .stroke(Color.brand.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Bottom Navigation
    
    private var bottomNavigation: some View {
        VStack(spacing: 0) {
            Divider()
            
            Button {
                handleNext()
            } label: {
                HStack(spacing: Spacing.sm) {
                    Text(currentStep == totalSteps - 1 ? "Start Your Journey" : "Continue")
                        .font(.appHeadline)
                        .fontWeight(.semibold)
                    
                    Image(systemName: currentStep == totalSteps - 1 ? "arrow.right.circle.fill" : "arrow.right")
                        .font(.body.weight(.semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(
                    Group {
                        if canProceed {
                            LinearGradient.brandGradient
                        } else {
                            Color.gray.opacity(0.3)
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
            }
            .disabled(!canProceed)
            .padding(.horizontal, Spacing.xl)
            .padding(.vertical, Spacing.lg)
        }
        .background(Color.backgroundPrimary)
    }
    
    // MARK: - Helpers
    
    private var canProceed: Bool {
        switch currentStep {
        case 0: return !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 1: return selectedHomeCountry != nil
        case 2: return selectedDestination != nil
        case 3: return selectedDegree != nil
        case 4: return true // Optional step
        default: return false
        }
    }
    
    private func handleNext() {
        guard canProceed else { return }
        HapticManager.shared.medium()
        
        if currentStep < totalSteps - 1 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                currentStep += 1
            }
        } else {
            completeSetup()
        }
    }
    
    private func completeSetup() {
        // Save all preferences
        appState.userName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        appState.homeCountry = selectedHomeCountry
        appState.selectedCountry = selectedDestination
        appState.targetDegree = selectedDegree
        appState.targetField = selectedField
        appState.targetIntake = targetIntake
        
        // Mark onboarding complete
        appState.hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // Load data for selected country
        if let destination = selectedDestination {
            Task {
                await dataService.loadCountryData(for: destination)
            }
        }
        
        HapticManager.shared.success()
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isComplete = true
        }
    }
    
    private func loadExistingData() {
        userName = appState.userName
        selectedHomeCountry = appState.homeCountry
        selectedDestination = appState.selectedCountry
        selectedDegree = appState.targetDegree
        selectedField = appState.targetField
        targetIntake = appState.targetIntake
    }
}

// MARK: - Supporting Views

struct HomeCountryCard: View {
    let country: HomeCountry
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.sm) {
                Text(country.flag)
                    .font(.system(size: 36))
                
                Text(country.name)
                    .font(.appCaption)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(isSelected ? Color.brand.opacity(0.1) : Color.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .stroke(isSelected ? Color.brand : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct DestinationCountryCard: View {
    let country: DestinationCountry
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.sm) {
                Text(country.flag)
                    .font(.system(size: 36))
                
                Text(country.name)
                    .font(.appCaption)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                // Highlight
                Text(country.primaryLanguageTest)
                    .font(.appCaption2)
                    .foregroundColor(.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .padding(.horizontal, Spacing.xs)
            .background(isSelected ? Color(hex: country.colorHex).opacity(0.1) : Color.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .stroke(isSelected ? Color(hex: country.colorHex) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct DegreeOptionCard: View {
    let degree: TargetDegree
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                Image(systemName: degree.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .brand : .textSecondary)
                    .frame(width: 44)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(degree.name)
                        .font(.appSubheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.brand)
                }
            }
            .padding(Spacing.md)
            .background(isSelected ? Color.brand.opacity(0.08) : Color.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .stroke(isSelected ? Color.brand : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct FieldChip: View {
    let field: StudyField
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: field.icon)
                    .font(.caption)
                Text(field.name)
                    .font(.appCaption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : .textPrimary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(isSelected ? Color.brand : Color.backgroundSecondary)
            .clipShape(Capsule())
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct IntakeChip: View {
    let intake: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(intake)
                .font(.appCaption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .textPrimary)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(isSelected ? Color.brand : Color.backgroundSecondary)
                .clipShape(Capsule())
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct SummaryRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.appCaption)
                .foregroundColor(.textSecondary)
            Spacer()
            Text(value)
                .font(.appSubheadline)
                .fontWeight(.medium)
                .foregroundColor(.textPrimary)
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    SetupWizardView(isComplete: .constant(false))
        .environmentObject(AppState())
        .environmentObject(DataService.shared)
}

