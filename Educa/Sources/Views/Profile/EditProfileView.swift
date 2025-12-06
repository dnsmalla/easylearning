//
//  EditProfileView.swift
//  Educa
//
//  Comprehensive profile editing with personal info and country selection
//

import SwiftUI

// MARK: - Edit Profile View

struct EditProfileView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var targetIntake: String = ""
    @State private var selectedHomeCountry: HomeCountry?
    @State private var selectedDestinationCountry: DestinationCountry?
    @State private var selectedDegree: TargetDegree?
    @State private var selectedField: StudyField?
    
    @State private var showHomeCountryPicker = false
    @State private var showDestinationCountryPicker = false
    @State private var showDegreePicker = false
    @State private var showFieldPicker = false
    @State private var showIntakePicker = false
    
    let intakeOptions = ["April 2025", "July 2025", "October 2025", "January 2026", "April 2026", "July 2026", "October 2026"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Profile Avatar
                    avatarSection
                    
                    // Personal Information
                    personalInfoSection
                    
                    // Country Selection
                    countrySection
                    
                    // Study Preferences
                    studyPreferencesSection
                    
                    // Save Button
                    saveButton
                }
                .padding(Spacing.md)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
            .background(Color.backgroundPrimary)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.textSecondary)
                }
            }
            .onAppear {
                loadCurrentData()
            }
            .sheet(isPresented: $showHomeCountryPicker) {
                HomeCountryPickerSheet(selectedCountry: $selectedHomeCountry)
            }
            .sheet(isPresented: $showDestinationCountryPicker) {
                DestinationCountryPickerSheet(selectedCountry: $selectedDestinationCountry)
            }
            .sheet(isPresented: $showDegreePicker) {
                DegreePickerSheet(selectedDegree: $selectedDegree)
            }
            .sheet(isPresented: $showFieldPicker) {
                FieldPickerSheet(selectedField: $selectedField)
            }
        }
    }
    
    // MARK: - Avatar Section
    
    private var avatarSection: some View {
        VStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.brand, Color.brandLight, Color.premium],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 110, height: 110)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.brand, Color.brandDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 98, height: 98)
                    .overlay {
                        if !name.isEmpty {
                            Text(String(name.prefix(1)).uppercased())
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 40, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                
                // Camera Button
                Circle()
                    .fill(Color.backgroundSecondary)
                    .frame(width: 32, height: 32)
                    .overlay {
                        Image(systemName: "camera.fill")
                            .font(.caption)
                            .foregroundColor(.brand)
                    }
                    .offset(x: 38, y: 38)
            }
            
            Text("Tap to change photo")
                .font(.appCaption)
                .foregroundColor(.textTertiary)
        }
        .padding(.top, Spacing.md)
    }
    
    // MARK: - Personal Info Section
    
    private var personalInfoSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Personal Information", icon: "person.fill")
            
            VStack(spacing: Spacing.sm) {
                // Name
                ProfileTextField(
                    icon: "person",
                    placeholder: "Full Name",
                    text: $name
                )
                
                // Email
                ProfileTextField(
                    icon: "envelope",
                    placeholder: "Email Address",
                    text: $email,
                    keyboardType: .emailAddress
                )
                
                // Phone
                ProfileTextField(
                    icon: "phone",
                    placeholder: "Phone Number",
                    text: $phone,
                    keyboardType: .phonePad
                )
            }
            .padding(Spacing.md)
            .background(Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl, style: .continuous))
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - Country Section
    
    private var countrySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Countries", icon: "globe.asia.australia.fill")
            
            VStack(spacing: Spacing.sm) {
                // Home Country
                CountrySelectionRow(
                    label: "Where are you from?",
                    icon: "house.fill",
                    selectedFlag: selectedHomeCountry?.flag,
                    selectedName: selectedHomeCountry?.name ?? "Select your country",
                    accentColor: .green
                ) {
                    HapticManager.shared.tap()
                    showHomeCountryPicker = true
                }
                
                Divider()
                    .padding(.horizontal, Spacing.md)
                
                // Destination Country
                CountrySelectionRow(
                    label: "Where do you want to study?",
                    icon: "airplane.departure",
                    selectedFlag: selectedDestinationCountry?.flag,
                    selectedName: selectedDestinationCountry?.name ?? "Select destination",
                    accentColor: .brand
                ) {
                    HapticManager.shared.tap()
                    showDestinationCountryPicker = true
                }
            }
            .padding(.vertical, Spacing.sm)
            .background(Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl, style: .continuous))
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - Study Preferences Section
    
    private var studyPreferencesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Study Goals", icon: "graduationcap.fill")
            
            VStack(spacing: Spacing.sm) {
                // Target Degree
                ProfilePickerRow(
                    label: "Target Program",
                    icon: "scroll",
                    selectedValue: selectedDegree?.name ?? "Select program",
                    selectedIcon: selectedDegree?.icon ?? "plus.circle",
                    color: .tertiary
                ) {
                    HapticManager.shared.tap()
                    showDegreePicker = true
                }
                
                Divider()
                    .padding(.horizontal, Spacing.md)
                
                // Field of Study
                ProfilePickerRow(
                    label: "Field of Study",
                    icon: "book.closed",
                    selectedValue: selectedField?.name ?? "Select field",
                    selectedIcon: selectedField?.icon ?? "plus.circle",
                    color: .secondary
                ) {
                    HapticManager.shared.tap()
                    showFieldPicker = true
                }
                
                Divider()
                    .padding(.horizontal, Spacing.md)
                
                // Target Intake
                Menu {
                    ForEach(intakeOptions, id: \.self) { option in
                        Button(option) {
                            targetIntake = option
                        }
                    }
                } label: {
                    ProfilePickerRow(
                        label: "Target Intake",
                        icon: "calendar",
                        selectedValue: targetIntake.isEmpty ? "Select intake" : targetIntake,
                        selectedIcon: "calendar.badge.clock",
                        color: .premium
                    ) { }
                }
            }
            .padding(.vertical, Spacing.sm)
            .background(Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl, style: .continuous))
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - Save Button
    
    private var saveButton: some View {
        Button {
            saveProfile()
        } label: {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "checkmark.circle.fill")
                Text("Save Profile")
                    .fontWeight(.semibold)
            }
            .font(.appBody)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(
                LinearGradient(
                    colors: [Color.brand, Color.brandDark],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large, style: .continuous))
        }
        .padding(.top, Spacing.md)
    }
    
    // MARK: - Methods
    
    private func loadCurrentData() {
        name = appState.userName
        email = appState.userEmail
        phone = appState.userPhone
        targetIntake = appState.targetIntake
        selectedHomeCountry = appState.homeCountry
        selectedDestinationCountry = appState.selectedCountry
        selectedDegree = appState.targetDegree
        selectedField = appState.targetField
    }
    
    private func saveProfile() {
        HapticManager.shared.success()
        
        appState.userName = name
        appState.userEmail = email
        appState.userPhone = phone
        appState.targetIntake = targetIntake
        appState.homeCountry = selectedHomeCountry
        appState.selectedCountry = selectedDestinationCountry
        appState.targetDegree = selectedDegree
        appState.targetField = selectedField
        
        appState.showSuccess("Profile saved!")
        dismiss()
    }
}

// MARK: - Profile Text Field

struct ProfileTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.brand)
                .frame(width: 24)
            
            TextField(placeholder, text: $text)
                .font(.appBody)
                .foregroundColor(.textPrimary)
                .keyboardType(keyboardType)
                .autocapitalization(keyboardType == .emailAddress ? .none : .words)
        }
        .padding(Spacing.md)
        .background(Color.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium, style: .continuous))
    }
}

// MARK: - Country Selection Row

struct CountrySelectionRow: View {
    let label: String
    let icon: String
    let selectedFlag: String?
    let selectedName: String
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: CornerRadius.small, style: .continuous)
                        .fill(accentColor.opacity(0.12))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(accentColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                    
                    HStack(spacing: Spacing.xs) {
                        if let flag = selectedFlag {
                            Text(flag)
                                .font(.title2)
                        }
                        
                        Text(selectedName)
                            .font(.appSubheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedFlag != nil ? .textPrimary : .textTertiary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.textTertiary)
            }
            .padding(Spacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Profile Picker Row

struct ProfilePickerRow: View {
    let label: String
    let icon: String
    let selectedValue: String
    let selectedIcon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: CornerRadius.small, style: .continuous)
                        .fill(color.opacity(0.12))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.appCaption)
                        .foregroundColor(.textSecondary)
                    
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: selectedIcon)
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                        
                        Text(selectedValue)
                            .font(.appSubheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedValue.contains("Select") ? .textTertiary : .textPrimary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.textTertiary)
            }
            .padding(Spacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Home Country Picker Sheet

struct HomeCountryPickerSheet: View {
    @Binding var selectedCountry: HomeCountry?
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    var filteredCountries: [HomeCountry] {
        if searchText.isEmpty {
            return HomeCountry.allCases
        }
        return HomeCountry.allCases.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.textTertiary)
                    TextField("Search countries...", text: $searchText)
                        .font(.appBody)
                }
                .padding(Spacing.sm)
                .background(Color.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                
                // List
                ScrollView {
                    LazyVStack(spacing: Spacing.xs) {
                        ForEach(filteredCountries) { country in
                            Button {
                                HapticManager.shared.medium()
                                selectedCountry = country
                                dismiss()
                            } label: {
                                CountryPickerRow(
                                    flag: country.flag,
                                    name: country.name,
                                    subtitle: "Currency: \(country.currency)",
                                    isSelected: selectedCountry == country
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(Spacing.md)
                }
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Where are you from?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.brand)
                }
            }
        }
    }
}

// MARK: - Destination Country Picker Sheet

struct DestinationCountryPickerSheet: View {
    @Binding var selectedCountry: DestinationCountry?
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
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
            VStack(spacing: 0) {
                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.textTertiary)
                    TextField("Search destinations...", text: $searchText)
                        .font(.appBody)
                }
                .padding(Spacing.sm)
                .background(Color.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                
                // List
                ScrollView {
                    LazyVStack(spacing: Spacing.xs) {
                        ForEach(filteredCountries) { country in
                            Button {
                                HapticManager.shared.medium()
                                selectedCountry = country
                                dismiss()
                            } label: {
                                CountryPickerRow(
                                    flag: country.flag,
                                    name: country.name,
                                    subtitle: "\(country.primaryLanguageTest) • \(country.workHoursAllowed)",
                                    isSelected: selectedCountry == country
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(Spacing.md)
                }
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Study Destination")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.brand)
                }
            }
        }
    }
}

// MARK: - Country Picker Row

struct CountryPickerRow: View {
    let flag: String
    let name: String
    let subtitle: String
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            Text(flag)
                .font(.system(size: 32))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.appSubheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                
                Text(subtitle)
                    .font(.appCaption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.brand)
            }
        }
        .padding(Spacing.md)
        .background(isSelected ? Color.brand.opacity(0.08) : Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium, style: .continuous))
    }
}

// MARK: - Degree Picker Sheet

struct DegreePickerSheet: View {
    @Binding var selectedDegree: TargetDegree?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: Spacing.sm) {
                    ForEach(TargetDegree.allCases) { degree in
                        Button {
                            HapticManager.shared.medium()
                            selectedDegree = degree
                            dismiss()
                        } label: {
                            HStack(spacing: Spacing.md) {
                                ZStack {
                                    Circle()
                                        .fill(Color.tertiary.opacity(0.12))
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: degree.icon)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.tertiary)
                                }
                                
                                Text(degree.name)
                                    .font(.appSubheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.textPrimary)
                                
                                Spacer()
                                
                                if selectedDegree == degree {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.brand)
                                }
                            }
                            .padding(Spacing.md)
                            .background(selectedDegree == degree ? Color.brand.opacity(0.08) : Color.surface)
                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium, style: .continuous))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(Spacing.md)
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Select Program")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.brand)
                }
            }
        }
    }
}

// MARK: - Field Picker Sheet

struct FieldPickerSheet: View {
    @Binding var selectedField: StudyField?
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    var filteredFields: [StudyField] {
        if searchText.isEmpty {
            return StudyField.allCases
        }
        return StudyField.allCases.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.textTertiary)
                    TextField("Search fields...", text: $searchText)
                        .font(.appBody)
                }
                .padding(Spacing.sm)
                .background(Color.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                
                ScrollView {
                    LazyVStack(spacing: Spacing.sm) {
                        ForEach(filteredFields) { field in
                            Button {
                                HapticManager.shared.medium()
                                selectedField = field
                                dismiss()
                            } label: {
                                HStack(spacing: Spacing.md) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.secondary.opacity(0.12))
                                            .frame(width: 44, height: 44)
                                        
                                        Image(systemName: field.icon)
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Text(field.name)
                                        .font(.appSubheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.textPrimary)
                                    
                                    Spacer()
                                    
                                    if selectedField == field {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.title3)
                                            .foregroundColor(.brand)
                                    }
                                }
                                .padding(Spacing.md)
                                .background(selectedField == field ? Color.brand.opacity(0.08) : Color.surface)
                                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium, style: .continuous))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(Spacing.md)
                }
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Field of Study")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.brand)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    EditProfileView()
        .environmentObject(AppState())
}

