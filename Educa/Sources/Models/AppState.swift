//
//  AppState.swift
//  Educa
//
//  Global app state management with country-based filtering
//

import SwiftUI

@MainActor
final class AppState: ObservableObject {
    // MARK: - Published Properties
    
    @Published var selectedTab: Tab = .home
    @Published var isDarkMode: Bool = false
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    @Published var hasCompletedOnboarding: Bool = false
    
    // Country Selection - Core feature for country-based content
    @Published var selectedCountry: DestinationCountry? {
        didSet {
            if let country = selectedCountry {
                saveSelectedCountry(country)
            }
        }
    }
    
    // Home Country - Where the student is from
    @Published var homeCountry: HomeCountry? {
        didSet {
            if let country = homeCountry {
                saveHomeCountry(country)
            }
        }
    }
    
    // Study Preferences
    @Published var targetDegree: TargetDegree? {
        didSet {
            if let degree = targetDegree {
                UserDefaults.standard.set(degree.rawValue, forKey: "targetDegree")
            }
        }
    }
    
    @Published var targetField: StudyField? {
        didSet {
            if let field = targetField {
                UserDefaults.standard.set(field.rawValue, forKey: "targetField")
            }
        }
    }
    
    @Published var userName: String = "" {
        didSet {
            UserDefaults.standard.set(userName, forKey: "userName")
        }
    }
    
    @Published var userEmail: String = "" {
        didSet {
            UserDefaults.standard.set(userEmail, forKey: "userEmail")
        }
    }
    
    @Published var userPhone: String = "" {
        didSet {
            UserDefaults.standard.set(userPhone, forKey: "userPhone")
        }
    }
    
    @Published var targetIntake: String = "" {
        didSet {
            UserDefaults.standard.set(targetIntake, forKey: "targetIntake")
        }
    }
    
    // Toast
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    @Published var toastType: ToastType = .info
    
    // Search
    @Published var searchQuery: String = ""
    @Published var isSearching: Bool = false
    
    // MARK: - Initialization
    
    init() {
        loadSelectedCountry()
        loadHomeCountry()
        loadUserPreferences()
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    // MARK: - Load User Preferences
    
    private func loadUserPreferences() {
        userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        userPhone = UserDefaults.standard.string(forKey: "userPhone") ?? ""
        targetIntake = UserDefaults.standard.string(forKey: "targetIntake") ?? ""
        
        if let degreeCode = UserDefaults.standard.string(forKey: "targetDegree"),
           let degree = TargetDegree(rawValue: degreeCode) {
            targetDegree = degree
        }
        
        if let fieldCode = UserDefaults.standard.string(forKey: "targetField"),
           let field = StudyField(rawValue: fieldCode) {
            targetField = field
        }
    }
    
    // MARK: - Tab Enum
    
    enum Tab: String, CaseIterable {
        case home = "Home"
        case studyHub = "Study"
        case journey = "Journey"
        case placement = "Jobs"
        case remittance = "Money"
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .studyHub: return "graduationcap.fill"
            case .journey: return "airplane"
            case .placement: return "briefcase.fill"
            case .remittance: return "yensign.circle"
            }
        }
        
        var activeIcon: String {
            switch self {
            case .home: return "house.fill"
            case .studyHub: return "graduationcap.fill"
            case .journey: return "airplane.departure"
            case .placement: return "briefcase.fill"
            case .remittance: return "yensign.circle.fill"
            }
        }
    }
    
    // MARK: - Country Persistence
    
    private func saveSelectedCountry(_ country: DestinationCountry) {
        UserDefaults.standard.set(country.rawValue, forKey: "selectedCountry")
        NotificationCenter.default.post(name: .countryChanged, object: country)
    }
    
    private func loadSelectedCountry() {
        if let countryCode = UserDefaults.standard.string(forKey: "selectedCountry"),
           let country = DestinationCountry(rawValue: countryCode) {
            selectedCountry = country
        }
    }
    
    private func saveHomeCountry(_ country: HomeCountry) {
        UserDefaults.standard.set(country.rawValue, forKey: "homeCountry")
    }
    
    private func loadHomeCountry() {
        if let countryCode = UserDefaults.standard.string(forKey: "homeCountry"),
           let country = HomeCountry(rawValue: countryCode) {
            homeCountry = country
        }
    }
    
    func completeOnboarding(with destinationCountry: DestinationCountry, from homeCountry: HomeCountry? = nil) {
        selectedCountry = destinationCountry
        if let home = homeCountry {
            self.homeCountry = home
        }
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
    
    // MARK: - Profile Completion Check
    
    var isProfileComplete: Bool {
        !userName.isEmpty && selectedCountry != nil && homeCountry != nil
    }
    
    var profileCompletionPercentage: Double {
        var completed = 0
        let total = 6
        
        if !userName.isEmpty { completed += 1 }
        if !userEmail.isEmpty { completed += 1 }
        if homeCountry != nil { completed += 1 }
        if selectedCountry != nil { completed += 1 }
        if targetDegree != nil { completed += 1 }
        if targetField != nil { completed += 1 }
        
        return Double(completed) / Double(total)
    }
    
    // MARK: - Toast Methods
    
    func showSuccess(_ message: String) {
        toastMessage = message
        toastType = .success
        showToast = true
        HapticManager.shared.success()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            withAnimation(.spring()) {
                self?.showToast = false
            }
        }
    }
    
    func showError(_ message: String) {
        toastMessage = message
        toastType = .error
        showToast = true
        HapticManager.shared.error()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            withAnimation(.spring()) {
                self?.showToast = false
            }
        }
    }
    
    func showInfo(_ message: String) {
        toastMessage = message
        toastType = .info
        showToast = true
        HapticManager.shared.tap()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            withAnimation(.spring()) {
                self?.showToast = false
            }
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let countryChanged = Notification.Name("countryChanged")
}

// MARK: - Toast Type

enum ToastType {
    case success
    case error
    case info
    case warning
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        case .info: return .blue
        case .warning: return .orange
        }
    }
}

// MARK: - Destination Country Enum

enum DestinationCountry: String, CaseIterable, Codable, Identifiable {
    case japan = "jpn"
    case australia = "aus"
    case canada = "can"
    case germany = "deu"
    case uk = "gbr"
    case usa = "usa"
    case singapore = "sgp"
    case southKorea = "kor"
    case newZealand = "nzl"
    case france = "fra"
    
    var id: String { rawValue }
    
    var name: String {
        switch self {
        case .japan: return "Japan"
        case .australia: return "Australia"
        case .canada: return "Canada"
        case .germany: return "Germany"
        case .uk: return "United Kingdom"
        case .usa: return "United States"
        case .singapore: return "Singapore"
        case .southKorea: return "South Korea"
        case .newZealand: return "New Zealand"
        case .france: return "France"
        }
    }
    
    var flag: String {
        switch self {
        case .japan: return "🇯🇵"
        case .australia: return "🇦🇺"
        case .canada: return "🇨🇦"
        case .germany: return "🇩🇪"
        case .uk: return "🇬🇧"
        case .usa: return "🇺🇸"
        case .singapore: return "🇸🇬"
        case .southKorea: return "🇰🇷"
        case .newZealand: return "🇳🇿"
        case .france: return "🇫🇷"
        }
    }
    
    var currency: String {
        switch self {
        case .japan: return "JPY"
        case .australia: return "AUD"
        case .canada: return "CAD"
        case .germany, .france: return "EUR"
        case .uk: return "GBP"
        case .usa: return "USD"
        case .singapore: return "SGD"
        case .southKorea: return "KRW"
        case .newZealand: return "NZD"
        }
    }
    
    var currencySymbol: String {
        switch self {
        case .japan: return "¥"
        case .australia, .canada, .usa, .singapore, .newZealand: return "$"
        case .germany, .france: return "€"
        case .uk: return "£"
        case .southKorea: return "₩"
        }
    }
    
    var primaryLanguageTest: String {
        switch self {
        case .japan: return "JLPT"
        case .southKorea: return "TOPIK"
        case .germany: return "TestDaF"
        case .france: return "DELF"
        case .australia, .canada, .uk, .usa, .singapore, .newZealand: return "IELTS"
        }
    }
    
    var visaType: String {
        switch self {
        case .japan: return "Student Visa (Ryugaku)"
        case .australia: return "Student Visa (Subclass 500)"
        case .canada: return "Study Permit"
        case .germany: return "Student Visa"
        case .uk: return "Student Visa (Tier 4)"
        case .usa: return "F-1 Student Visa"
        case .singapore: return "Student Pass"
        case .southKorea: return "D-2 Student Visa"
        case .newZealand: return "Student Visa"
        case .france: return "Long-Stay Student Visa"
        }
    }
    
    var workHoursAllowed: String {
        switch self {
        case .japan: return "28 hrs/week"
        case .australia: return "48 hrs/fortnight"
        case .canada: return "20 hrs/week"
        case .germany: return "120 full days/year"
        case .uk: return "20 hrs/week"
        case .usa: return "20 hrs/week (on-campus)"
        case .singapore: return "16 hrs/week"
        case .southKorea: return "20 hrs/week"
        case .newZealand: return "20 hrs/week"
        case .france: return "964 hrs/year"
        }
    }
    
    var colorHex: String {
        switch self {
        case .japan: return "BC002D"
        case .australia: return "00008B"
        case .canada: return "FF0000"
        case .germany: return "FFCC00"
        case .uk: return "012169"
        case .usa: return "3C3B6E"
        case .singapore: return "EF3340"
        case .southKorea: return "003478"
        case .newZealand: return "00247D"
        case .france: return "0055A4"
        }
    }
    
    var heroImage: String {
        switch self {
        case .japan: return "https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e"
        case .australia: return "https://images.unsplash.com/photo-1523482580672-f109ba8cb9be"
        case .canada: return "https://images.unsplash.com/photo-1517935706615-2717063c2225"
        case .germany: return "https://images.unsplash.com/photo-1467269204594-9661b134dd2b"
        case .uk: return "https://images.unsplash.com/photo-1513635269975-59663e0ac1ad"
        case .usa: return "https://images.unsplash.com/photo-1485738422979-f5c462d49f74"
        case .singapore: return "https://images.unsplash.com/photo-1525625293386-3f8f99389edd"
        case .southKorea: return "https://images.unsplash.com/photo-1538485399081-7191377e8241"
        case .newZealand: return "https://images.unsplash.com/photo-1507699622108-4be3abd695ad"
        case .france: return "https://images.unsplash.com/photo-1502602898657-3e91760cbb34"
        }
    }
    
    var highlights: [String] {
        switch self {
        case .japan:
            return ["Safe & clean cities", "Advanced technology", "Rich culture", "MEXT scholarships", "Part-time work allowed"]
        case .australia:
            return ["Quality education", "Post-study work visa", "Multicultural", "High wages", "Beautiful nature"]
        case .canada:
            return ["Affordable tuition", "Immigration pathways", "Safe environment", "Co-op programs", "Healthcare"]
        case .germany:
            return ["Free/low tuition", "Strong economy", "Engineering focus", "EU access", "Job seeker visa"]
        case .uk:
            return ["World-class unis", "Graduate visa", "Rich history", "Global recognition", "Research focus"]
        case .usa:
            return ["Top universities", "Innovation hub", "OPT/STEM OPT", "Diverse culture", "Research opportunities"]
        case .singapore:
            return ["Strategic location", "Safe city", "English medium", "Tech hub", "Asian gateway"]
        case .southKorea:
            return ["K-culture hub", "Tech innovation", "Affordable living", "Scholarships", "Modern cities"]
        case .newZealand:
            return ["Stunning nature", "Work-life balance", "Friendly people", "Post-study work", "Adventure sports"]
        case .france:
            return ["Art & culture", "Affordable tuition", "EU mobility", "Fashion capital", "Cuisine"]
        }
    }
}

// MARK: - Home Country Enum (Source Countries - Where students come from)

enum HomeCountry: String, CaseIterable, Codable, Identifiable {
    case nepal = "npl"
    case india = "ind"
    case bangladesh = "bgd"
    case sriLanka = "lka"
    case pakistan = "pak"
    case vietnam = "vnm"
    case philippines = "phl"
    case myanmar = "mmr"
    case indonesia = "idn"
    case china = "chn"
    case mongolia = "mng"
    case bhutan = "btn"
    case other = "oth"
    
    var id: String { rawValue }
    
    var name: String {
        switch self {
        case .nepal: return "Nepal"
        case .india: return "India"
        case .bangladesh: return "Bangladesh"
        case .sriLanka: return "Sri Lanka"
        case .pakistan: return "Pakistan"
        case .vietnam: return "Vietnam"
        case .philippines: return "Philippines"
        case .myanmar: return "Myanmar"
        case .indonesia: return "Indonesia"
        case .china: return "China"
        case .mongolia: return "Mongolia"
        case .bhutan: return "Bhutan"
        case .other: return "Other"
        }
    }
    
    var flag: String {
        switch self {
        case .nepal: return "🇳🇵"
        case .india: return "🇮🇳"
        case .bangladesh: return "🇧🇩"
        case .sriLanka: return "🇱🇰"
        case .pakistan: return "🇵🇰"
        case .vietnam: return "🇻🇳"
        case .philippines: return "🇵🇭"
        case .myanmar: return "🇲🇲"
        case .indonesia: return "🇮🇩"
        case .china: return "🇨🇳"
        case .mongolia: return "🇲🇳"
        case .bhutan: return "🇧🇹"
        case .other: return "🌍"
        }
    }
    
    var currency: String {
        switch self {
        case .nepal: return "NPR"
        case .india: return "INR"
        case .bangladesh: return "BDT"
        case .sriLanka: return "LKR"
        case .pakistan: return "PKR"
        case .vietnam: return "VND"
        case .philippines: return "PHP"
        case .myanmar: return "MMK"
        case .indonesia: return "IDR"
        case .china: return "CNY"
        case .mongolia: return "MNT"
        case .bhutan: return "BTN"
        case .other: return "USD"
        }
    }
}

// MARK: - Target Degree Enum

enum TargetDegree: String, CaseIterable, Codable, Identifiable {
    case languageSchool = "language"
    case bachelor = "bachelor"
    case master = "master"
    case phd = "phd"
    case diploma = "diploma"
    case vocational = "vocational"
    case research = "research"
    
    var id: String { rawValue }
    
    var name: String {
        switch self {
        case .languageSchool: return "Language School"
        case .bachelor: return "Bachelor's Degree"
        case .master: return "Master's Degree"
        case .phd: return "PhD / Doctorate"
        case .diploma: return "Diploma"
        case .vocational: return "Vocational Training"
        case .research: return "Research Program"
        }
    }
    
    var icon: String {
        switch self {
        case .languageSchool: return "character.book.closed"
        case .bachelor: return "graduationcap"
        case .master: return "graduationcap.fill"
        case .phd: return "books.vertical"
        case .diploma: return "scroll"
        case .vocational: return "wrench.and.screwdriver"
        case .research: return "magnifyingglass"
        }
    }
}

// MARK: - Study Field Enum

enum StudyField: String, CaseIterable, Codable, Identifiable {
    case engineering = "engineering"
    case computerScience = "cs"
    case business = "business"
    case medicine = "medicine"
    case nursing = "nursing"
    case hospitality = "hospitality"
    case arts = "arts"
    case science = "science"
    case law = "law"
    case agriculture = "agriculture"
    case japanese = "japanese"
    case socialScience = "social"
    case other = "other"
    
    var id: String { rawValue }
    
    var name: String {
        switch self {
        case .engineering: return "Engineering"
        case .computerScience: return "Computer Science & IT"
        case .business: return "Business & Management"
        case .medicine: return "Medicine"
        case .nursing: return "Nursing & Healthcare"
        case .hospitality: return "Hospitality & Tourism"
        case .arts: return "Arts & Design"
        case .science: return "Science"
        case .law: return "Law"
        case .agriculture: return "Agriculture"
        case .japanese: return "Japanese Studies"
        case .socialScience: return "Social Sciences"
        case .other: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .engineering: return "gearshape.2"
        case .computerScience: return "desktopcomputer"
        case .business: return "chart.line.uptrend.xyaxis"
        case .medicine: return "stethoscope"
        case .nursing: return "cross.case"
        case .hospitality: return "fork.knife"
        case .arts: return "paintpalette"
        case .science: return "atom"
        case .law: return "building.columns"
        case .agriculture: return "leaf"
        case .japanese: return "character.ja"
        case .socialScience: return "person.3"
        case .other: return "ellipsis"
        }
    }
}

// MARK: - User Model

struct User: Codable, Identifiable {
    let id: String
    var name: String
    var email: String
    var phone: String?
    var avatar: String?
    var selectedCountry: String?
    var homeCountry: String?
    var targetDegree: String?
    var targetField: String?
    var targetIntake: String?
    var dateOfBirth: String?
    var savedUniversities: [String]
    var savedCourses: [String]
    var savedJobs: [String]
    var savedScholarships: [String]
    var journeyProgress: JourneyProgress?
    
    init(id: String = UUID().uuidString, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = nil
        self.avatar = nil
        self.selectedCountry = nil
        self.homeCountry = "npl" // Nepal as default
        self.targetDegree = nil
        self.targetField = nil
        self.targetIntake = nil
        self.dateOfBirth = nil
        self.savedUniversities = []
        self.savedCourses = []
        self.savedJobs = []
        self.savedScholarships = []
        self.journeyProgress = nil
    }
}

// MARK: - Journey Progress

struct JourneyProgress: Codable {
    var currentStep: Int
    var completedSteps: [String]
    var languageTestScore: String?
    var languageTestDate: String?
    var targetIntake: String?
    var visaStatus: VisaApplicationStatus
    
    enum VisaApplicationStatus: String, Codable {
        case notStarted = "not_started"
        case preparing = "preparing"
        case documentsReady = "documents_ready"
        case applied = "applied"
        case approved = "approved"
        case rejected = "rejected"
    }
    
    init() {
        self.currentStep = 1
        self.completedSteps = []
        self.languageTestScore = nil
        self.languageTestDate = nil
        self.targetIntake = nil
        self.visaStatus = .notStarted
    }
}

