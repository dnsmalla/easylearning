//
//  Models.swift
//  Educa
//
//  Data models for the student information aggregator
//  Comprehensive models for Education, Jobs, Remittance, and Travel companies
//

import Foundation

// MARK: - Company Provider Protocol
/// Base protocol for all company/service providers in the app

protocol CompanyProvider: Identifiable, Codable, Hashable {
    var id: String { get }
    var name: String { get }
    var logo: String { get }
    var website: String { get }
    var rating: Double { get }
    var features: [String] { get }
}

// MARK: - Service Type Enum

enum ServiceType: String, Codable, CaseIterable {
    case education = "education"
    case jobs = "jobs"
    case remittance = "remittance"
    case travel = "travel"
    case visa = "visa"
    case accommodation = "accommodation"
    
    var icon: String {
        switch self {
        case .education: return "graduationcap.fill"
        case .jobs: return "briefcase.fill"
        case .remittance: return "dollarsign.circle.fill"
        case .travel: return "airplane"
        case .visa: return "doc.text.fill"
        case .accommodation: return "house.fill"
        }
    }
    
    var displayName: String {
        switch self {
        case .education: return "Education"
        case .jobs: return "Jobs & Career"
        case .remittance: return "Money Transfer"
        case .travel: return "Travel"
        case .visa: return "Visa Services"
        case .accommodation: return "Accommodation"
        }
    }
    
    var color: String {
        switch self {
        case .education: return "0A84FF"
        case .jobs: return "FF9F0A"
        case .remittance: return "34C759"
        case .travel: return "BF5AF2"
        case .visa: return "FF6B6B"
        case .accommodation: return "5AC8FA"
        }
    }
}

// MARK: - University

struct University: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let location: String
    let country: String
    let description: String
    let image: String
    let rating: Double
    let programs: [String]
    let annualFee: String
    let ranking: Int?
    let website: String?
    let accreditation: String?
    let studentCount: Int?
    let foundedYear: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, title, location, country, description, image, rating, programs
        case annualFee = "annual_fee"
        case ranking, website, accreditation
        case studentCount = "student_count"
        case foundedYear = "founded_year"
    }
}

// MARK: - Country

struct Country: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let flag: String
    let visaType: String
    let visaFee: Double
    let processingTime: String
    let successRate: Int
    let currency: String
    let languageRequirements: String
    let financialRequirements: String
    let documentChecklist: [String]
    let healthInsurance: String
    let workPermission: String
    let costOfLiving: String
    let studentBenefits: [String]
    let visaValidity: String
    let embassyWebsite: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, flag, currency
        case visaType = "visa_type"
        case visaFee = "visa_fee"
        case processingTime = "processing_time"
        case successRate = "success_rate"
        case languageRequirements = "language_requirements"
        case financialRequirements = "financial_requirements"
        case documentChecklist = "document_checklist"
        case healthInsurance = "health_insurance"
        case workPermission = "work_permission"
        case costOfLiving = "cost_of_living"
        case studentBenefits = "student_benefits"
        case visaValidity = "visa_validity"
        case embassyWebsite = "embassy_website"
    }
}

// MARK: - Course

struct Course: Identifiable, Codable, Hashable {
    let id: String
    let universityId: String
    let name: String
    let duration: Int // in months
    let degreeLevel: String
    let tuitionFee: Double
    let language: String
    let description: String
    let careerProspects: String
    let prerequisites: String
    let availability: String
    let accreditation: String?
    let courseStructure: [String]
    let internshipIncluded: Bool
    let startDates: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, duration, language, description, availability, accreditation
        case universityId = "university_id"
        case degreeLevel = "degree_level"
        case tuitionFee = "tuition_fee"
        case careerProspects = "career_prospects"
        case prerequisites
        case courseStructure = "course_structure"
        case internshipIncluded = "internship_included"
        case startDates = "start_dates"
    }
}

// MARK: - StudentGuide

struct StudentGuide: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let content: String
    let imageUrl: String
    let category: String
    let tags: [String]
    let author: String?
    let publishDate: String
    let readTime: Int // in minutes
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, content, category, tags, author
        case imageUrl = "image_url"
        case publishDate = "publish_date"
        case readTime = "read_time"
    }
}

// MARK: - RemittanceProvider

struct RemittanceProvider: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let logo: String
    let exchangeRate: Double
    let transferFee: Double
    let transferTime: String
    let minAmount: Double
    let maxAmount: Double
    let supportedCountries: [String]
    let paymentMethods: [String]
    let features: [String]
    let website: String
    let rating: Double
    
    enum CodingKeys: String, CodingKey {
        case id, name, logo, features, website, rating
        case exchangeRate = "exchange_rate"
        case transferFee = "transfer_fee"
        case transferTime = "transfer_time"
        case minAmount = "min_amount"
        case maxAmount = "max_amount"
        case supportedCountries = "supported_countries"
        case paymentMethods = "payment_methods"
    }
}

// MARK: - JobListing

struct JobListing: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let company: String
    let location: String
    let type: String // full-time, part-time, internship
    let salary: String
    let description: String
    let requirements: [String]
    let benefits: [String]
    let postedDate: String
    let deadline: String?
    let applyUrl: String
    let companyLogo: String?
    let isRemote: Bool
    let experienceLevel: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, company, location, type, salary, description, requirements, benefits, deadline
        case postedDate = "posted_date"
        case applyUrl = "apply_url"
        case companyLogo = "company_logo"
        case isRemote = "is_remote"
        case experienceLevel = "experience_level"
    }
}

// MARK: - Service Category

struct ServiceCategory: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let icon: String
    let description: String
    let image: String
    let route: String
    let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, title, icon, description, image, route
        case isActive = "is_active"
    }
}

// MARK: - Manifest

struct Manifest: Codable {
    let version: String
    let appName: String
    let lastUpdated: String
    let files: ManifestFiles
    
    enum CodingKeys: String, CodingKey {
        case version
        case appName = "app_name"
        case lastUpdated = "last_updated"
        case files
    }
}

struct ManifestFiles: Codable {
    let universities: String
    let countries: String
    let courses: String
    let guides: String
    let remittance: String
    let jobs: String
    let services: String
}

// MARK: - Response Wrappers

struct UniversitiesResponse: Codable {
    let version: String
    let universities: [University]
}

struct CountriesResponse: Codable {
    let version: String
    let countries: [Country]
}

struct CoursesResponse: Codable {
    let version: String
    let courses: [Course]
}

struct GuidesResponse: Codable {
    let version: String
    let guides: [StudentGuide]
}

struct RemittanceResponse: Codable {
    let version: String
    let providers: [RemittanceProvider]
}

struct JobsResponse: Codable {
    let version: String
    let jobs: [JobListing]
}

struct ServicesResponse: Codable {
    let version: String
    let services: [ServiceCategory]
}

// MARK: - Update/News

struct AppUpdate: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let content: String?
    let timestamp: String
    let type: UpdateType
    let category: String
    let imageUrl: String?
    let actionUrl: String?
    let isRead: Bool?
    
    enum UpdateType: String, Codable {
        case news = "news"
        case announcement = "announcement"
        case scholarship = "scholarship"
        case deadline = "deadline"
        case event = "event"
        
        var icon: String {
            switch self {
            case .news: return "newspaper"
            case .announcement: return "megaphone"
            case .scholarship: return "dollarsign.circle"
            case .deadline: return "clock.badge.exclamationmark"
            case .event: return "calendar"
            }
        }
        
        var color: String {
            switch self {
            case .news: return "2196F3"
            case .announcement: return "FF9800"
            case .scholarship: return "4CAF50"
            case .deadline: return "F44336"
            case .event: return "9C27B0"
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, content, timestamp, type, category
        case imageUrl = "image_url"
        case actionUrl = "action_url"
        case isRead = "is_read"
    }
}

struct UpdatesResponse: Codable {
    let version: String
    let updates: [AppUpdate]
}

// MARK: - Scholarship

struct Scholarship: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let provider: String
    let amount: String
    let currency: String
    let eligibility: [String]
    let deadline: String
    let description: String
    let coverageDetails: [String]
    let applicationUrl: String
    let countries: [String]
    let degreeLevel: [String]
    let fieldOfStudy: [String]?
    let isFullyFunded: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, provider, amount, currency, eligibility, deadline, description, countries
        case coverageDetails = "coverage_details"
        case applicationUrl = "application_url"
        case degreeLevel = "degree_level"
        case fieldOfStudy = "field_of_study"
        case isFullyFunded = "is_fully_funded"
    }
}

struct ScholarshipsResponse: Codable {
    let version: String
    let scholarships: [Scholarship]
}

// MARK: - Transaction (for Remittance)

struct Transaction: Identifiable, Codable, Hashable {
    let id: String
    let amount: Double
    let currency: String
    let recipientName: String
    let recipientCountry: String
    let status: TransactionStatus
    let date: String
    let provider: String
    let exchangeRate: Double
    let fee: Double
    
    enum TransactionStatus: String, Codable {
        case pending = "pending"
        case processing = "processing"
        case completed = "completed"
        case failed = "failed"
        
        var color: String {
            switch self {
            case .pending: return "FFC107"
            case .processing: return "2196F3"
            case .completed: return "4CAF50"
            case .failed: return "F44336"
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, amount, currency, status, date, provider, fee
        case recipientName = "recipient_name"
        case recipientCountry = "recipient_country"
        case exchangeRate = "exchange_rate"
    }
}

// MARK: - Learning Path (for Journey)

struct LearningStep: Identifiable, Codable, Hashable {
    let id: String
    let stepNumber: Int
    let title: String
    let description: String
    let status: StepStatus
    let tasks: [String]
    let resources: [String]?
    
    enum StepStatus: String, Codable {
        case completed = "completed"
        case inProgress = "in_progress"
        case upcoming = "upcoming"
        case locked = "locked"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, status, tasks, resources
        case stepNumber = "step_number"
    }
}

struct Achievement: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let dateEarned: String?
    let isUnlocked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, icon
        case dateEarned = "date_earned"
        case isUnlocked = "is_unlocked"
    }
}

// MARK: - Application Tracking

struct JobApplication: Identifiable, Codable, Hashable {
    let id: String
    let jobId: String
    let jobTitle: String
    let company: String
    let appliedDate: String
    let status: ApplicationStatus
    let nextStep: String?
    let notes: String?
    
    enum ApplicationStatus: String, Codable {
        case applied = "applied"
        case underReview = "under_review"
        case interview = "interview"
        case offered = "offered"
        case rejected = "rejected"
        case accepted = "accepted"
        
        var color: String {
            switch self {
            case .applied: return "2196F3"
            case .underReview: return "FFC107"
            case .interview: return "9C27B0"
            case .offered: return "4CAF50"
            case .rejected: return "F44336"
            case .accepted: return "00BCD4"
            }
        }
        
        var displayName: String {
            switch self {
            case .applied: return "Applied"
            case .underReview: return "Under Review"
            case .interview: return "Interview"
            case .offered: return "Offered"
            case .rejected: return "Rejected"
            case .accepted: return "Accepted"
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, company, status, notes
        case jobId = "job_id"
        case jobTitle = "job_title"
        case appliedDate = "applied_date"
        case nextStep = "next_step"
    }
}

// MARK: - Travel Agency

struct TravelAgency: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let logo: String
    let description: String
    let website: String
    let rating: Double
    let services: [String]
    let destinations: [String]
    let contactEmail: String?
    let contactPhone: String?
    let address: String?
    let priceRange: String
    let specializations: [String]
    let languages: [String]
    let isVerified: Bool
    let reviewCount: Int
    let responseTime: String?
    let features: [String]
    
    enum CodingKeys: String, CodingKey {
        case id, name, logo, description, website, rating, services, destinations
        case contactEmail = "contact_email"
        case contactPhone = "contact_phone"
        case address
        case priceRange = "price_range"
        case specializations, languages
        case isVerified = "is_verified"
        case reviewCount = "review_count"
        case responseTime = "response_time"
        case features
    }
}

struct TravelAgenciesResponse: Codable {
    let version: String
    let agencies: [TravelAgency]
}

// MARK: - Visa Consultant

struct VisaConsultant: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let logo: String
    let description: String
    let website: String
    let rating: Double
    let servicesOffered: [String]
    let countriesServed: [String]
    let successRate: Int
    let contactEmail: String?
    let contactPhone: String?
    let address: String?
    let consultationFee: String
    let processingTime: String
    let isGovernmentRegistered: Bool
    let reviewCount: Int
    let features: [String]
    let testimonials: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, logo, description, website, rating, address, features, testimonials
        case servicesOffered = "services_offered"
        case countriesServed = "countries_served"
        case successRate = "success_rate"
        case contactEmail = "contact_email"
        case contactPhone = "contact_phone"
        case consultationFee = "consultation_fee"
        case processingTime = "processing_time"
        case isGovernmentRegistered = "is_government_registered"
        case reviewCount = "review_count"
    }
}

struct VisaConsultantsResponse: Codable {
    let version: String
    let consultants: [VisaConsultant]
}

// MARK: - Accommodation Provider

struct AccommodationProvider: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let logo: String
    let description: String
    let website: String
    let rating: Double
    let accommodationType: String
    let priceRange: String
    let locations: [String]
    let amenities: [String]
    let targetAudience: [String]
    let bookingMethods: [String]
    let contactEmail: String?
    let contactPhone: String?
    let reviewCount: Int
    let features: [String]
    
    enum CodingKeys: String, CodingKey {
        case id, name, logo, description, website, rating, locations, amenities, features
        case accommodationType = "accommodation_type"
        case priceRange = "price_range"
        case targetAudience = "target_audience"
        case bookingMethods = "booking_methods"
        case contactEmail = "contact_email"
        case contactPhone = "contact_phone"
        case reviewCount = "review_count"
    }
}

struct AccommodationResponse: Codable {
    let version: String
    let providers: [AccommodationProvider]
}

// MARK: - Education Consultant

struct EducationConsultant: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let logo: String
    let description: String
    let website: String
    let rating: Double
    let servicesOffered: [String]
    let countriesServed: [String]
    let universitiesPartnered: Int
    let studentsPlaced: Int
    let contactEmail: String?
    let contactPhone: String?
    let address: String?
    let consultationFee: String
    let isRegistered: Bool
    let reviewCount: Int
    let features: [String]
    let successStories: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, logo, description, website, rating, address, features
        case servicesOffered = "services_offered"
        case countriesServed = "countries_served"
        case universitiesPartnered = "universities_partnered"
        case studentsPlaced = "students_placed"
        case contactEmail = "contact_email"
        case contactPhone = "contact_phone"
        case consultationFee = "consultation_fee"
        case isRegistered = "is_registered"
        case reviewCount = "review_count"
        case successStories = "success_stories"
    }
}

struct EducationConsultantsResponse: Codable {
    let version: String
    let consultants: [EducationConsultant]
}

// MARK: - Recruitment Agency

struct RecruitmentAgency: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let logo: String
    let description: String
    let website: String
    let rating: Double
    let industries: [String]
    let locations: [String]
    let jobTypes: [String]
    let contactEmail: String?
    let contactPhone: String?
    let address: String?
    let placementFee: String
    let isLicensed: Bool
    let reviewCount: Int
    let features: [String]
    let partneredCompanies: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, logo, description, website, rating, industries, locations, address, features
        case jobTypes = "job_types"
        case contactEmail = "contact_email"
        case contactPhone = "contact_phone"
        case placementFee = "placement_fee"
        case isLicensed = "is_licensed"
        case reviewCount = "review_count"
        case partneredCompanies = "partnered_companies"
    }
}

struct RecruitmentAgenciesResponse: Codable {
    let version: String
    let agencies: [RecruitmentAgency]
}

// MARK: - Currency Exchange Rate

struct ExchangeRate: Identifiable, Codable, Hashable {
    let id: String
    let fromCurrency: String
    let toCurrency: String
    let rate: Double
    let lastUpdated: String
    let provider: String?
    
    enum CodingKeys: String, CodingKey {
        case id, rate, provider
        case fromCurrency = "from_currency"
        case toCurrency = "to_currency"
        case lastUpdated = "last_updated"
    }
}

// MARK: - Saved Provider (for user favorites)

struct SavedProvider: Identifiable, Codable, Hashable {
    let id: String
    let providerId: String
    let providerType: ServiceType
    let savedDate: String
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id, notes
        case providerId = "provider_id"
        case providerType = "provider_type"
        case savedDate = "saved_date"
    }
}

// MARK: - Review

struct Review: Identifiable, Codable, Hashable {
    let id: String
    let providerId: String
    let providerType: ServiceType
    let userId: String
    let userName: String
    let rating: Int
    let title: String
    let content: String
    let date: String
    let isVerified: Bool
    let helpfulCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id, rating, title, content, date
        case providerId = "provider_id"
        case providerType = "provider_type"
        case userId = "user_id"
        case userName = "user_name"
        case isVerified = "is_verified"
        case helpfulCount = "helpful_count"
    }
}

// MARK: - ============================================
// MARK: - NEPAL STUDENT SPECIFIC FEATURES
// MARK: - ============================================

// MARK: - Language Test

enum LanguageTestType: String, Codable, CaseIterable {
    case ielts = "IELTS"
    case toefl = "TOEFL"
    case pte = "PTE"
    case jlpt = "JLPT"
    case topik = "TOPIK"
    case gre = "GRE"
    case sat = "SAT"
    case goethe = "Goethe"
    case delf = "DELF"
    case nat = "NAT"
    
    var fullName: String {
        switch self {
        case .ielts: return "International English Language Testing System"
        case .toefl: return "Test of English as a Foreign Language"
        case .pte: return "Pearson Test of English"
        case .jlpt: return "Japanese Language Proficiency Test"
        case .topik: return "Test of Proficiency in Korean"
        case .gre: return "Graduate Record Examination"
        case .sat: return "Scholastic Assessment Test"
        case .goethe: return "Goethe-Zertifikat (German)"
        case .delf: return "Diplôme d'études en langue française"
        case .nat: return "Nihongo Achievement Test"
        }
    }
    
    var icon: String {
        switch self {
        case .ielts, .toefl, .pte: return "textformat.abc"
        case .jlpt, .nat: return "character.ja"
        case .topik: return "character.ko"
        case .gre, .sat: return "graduationcap"
        case .goethe: return "character.de"
        case .delf: return "character.fr"
        }
    }
    
    var color: String {
        switch self {
        case .ielts: return "DC143C"
        case .toefl: return "0066CC"
        case .pte: return "FF6B00"
        case .jlpt: return "BC002D"
        case .topik: return "003478"
        case .gre: return "00A651"
        case .sat: return "1A237E"
        case .goethe: return "FFCC00"
        case .delf: return "0055A4"
        case .nat: return "BC002D"
        }
    }
    
    var targetCountries: [String] {
        switch self {
        case .ielts: return ["UK", "Australia", "Canada", "New Zealand"]
        case .toefl: return ["USA", "Canada", "Australia"]
        case .pte: return ["Australia", "UK", "New Zealand"]
        case .jlpt, .nat: return ["Japan"]
        case .topik: return ["South Korea"]
        case .gre: return ["USA", "Canada", "UK"]
        case .sat: return ["USA"]
        case .goethe: return ["Germany", "Austria", "Switzerland"]
        case .delf: return ["France", "Canada", "Belgium"]
        }
    }
}

struct LanguageTest: Identifiable, Codable, Hashable {
    let id: String
    let type: LanguageTestType
    let description: String
    let sections: [TestSection]
    let totalDuration: Int // in minutes
    let scoringSystem: String
    let minimumScores: [String: String] // country -> minimum score
    let testFee: TestFee
    let testCenters: [TestCenter]
    let preparationTips: [String]
    let resources: [StudyResource]
    let nextTestDates: [String]
    
    enum CodingKeys: String, CodingKey {
        case id, type, description, sections
        case totalDuration = "total_duration"
        case scoringSystem = "scoring_system"
        case minimumScores = "minimum_scores"
        case testFee = "test_fee"
        case testCenters = "test_centers"
        case preparationTips = "preparation_tips"
        case resources
        case nextTestDates = "next_test_dates"
    }
}

struct TestSection: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let duration: Int // minutes
    let description: String
    let tips: [String]
    let sampleQuestions: Int
}

struct TestFee: Codable, Hashable {
    let amount: Double
    let currency: String
    let nprEquivalent: Double
    
    enum CodingKeys: String, CodingKey {
        case amount, currency
        case nprEquivalent = "npr_equivalent"
    }
}

struct TestCenter: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let address: String
    let city: String
    let phone: String?
    let email: String?
    let website: String?
}

struct StudyResource: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let type: String // book, website, app, youtube
    let url: String?
    let isFree: Bool
    let rating: Double?
    
    enum CodingKeys: String, CodingKey {
        case id, title, type, url, rating
        case isFree = "is_free"
    }
}

struct LanguageTestsResponse: Codable {
    let version: String
    let tests: [LanguageTest]
}

// MARK: - Visa Requirements

struct VisaRequirement: Identifiable, Codable, Hashable {
    let id: String
    let country: String
    let countryCode: String
    let flag: String
    let visaTypes: [VisaType]
    let generalRequirements: [String]
    let processingTime: String
    let embassyInfo: EmbassyInfo
    let importantNotes: [String]
    let faqs: [FAQ]
    
    enum CodingKeys: String, CodingKey {
        case id, country, flag
        case countryCode = "country_code"
        case visaTypes = "visa_types"
        case generalRequirements = "general_requirements"
        case processingTime = "processing_time"
        case embassyInfo = "embassy_info"
        case importantNotes = "important_notes"
        case faqs
    }
}

struct VisaType: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let code: String
    let description: String
    let duration: String
    let fee: VisaFee
    let requirements: [DocumentRequirement]
    let eligibility: [String]
    let allowsWork: Bool
    let workHoursPerWeek: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, name, code, description, duration, fee, requirements, eligibility
        case allowsWork = "allows_work"
        case workHoursPerWeek = "work_hours_per_week"
    }
}

struct VisaFee: Codable, Hashable {
    let amount: Double
    let currency: String
    let nprEquivalent: Double
    let additionalFees: [String: Double]?
    
    enum CodingKeys: String, CodingKey {
        case amount, currency
        case nprEquivalent = "npr_equivalent"
        case additionalFees = "additional_fees"
    }
}

struct DocumentRequirement: Identifiable, Codable, Hashable {
    let id: String
    let document: String
    let description: String
    let isMandatory: Bool
    let tips: String?
    let whereToGet: String?
    
    enum CodingKeys: String, CodingKey {
        case id, document, description, tips
        case isMandatory = "is_mandatory"
        case whereToGet = "where_to_get"
    }
}

struct EmbassyInfo: Codable, Hashable {
    let name: String
    let address: String
    let city: String
    let phone: String
    let email: String?
    let website: String
    let appointmentUrl: String?
    let workingHours: String
    let googleMapsUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case name, address, city, phone, email, website
        case appointmentUrl = "appointment_url"
        case workingHours = "working_hours"
        case googleMapsUrl = "google_maps_url"
    }
}

struct FAQ: Identifiable, Codable, Hashable {
    let id: String
    let question: String
    let answer: String
}

struct VisaRequirementsResponse: Codable {
    let version: String
    let countries: [VisaRequirement]
}

// MARK: - Cost of Living

struct CostOfLiving: Identifiable, Codable, Hashable {
    let id: String
    let country: String
    let city: String
    let currency: String
    let monthlyExpenses: MonthlyExpenses
    let comparison: CostComparison
    let tips: [String]
    let lastUpdated: String
    
    enum CodingKeys: String, CodingKey {
        case id, country, city, currency, tips
        case monthlyExpenses = "monthly_expenses"
        case comparison
        case lastUpdated = "last_updated"
    }
}

struct MonthlyExpenses: Codable, Hashable {
    let accommodation: ExpenseRange
    let food: ExpenseRange
    let transportation: ExpenseRange
    let utilities: ExpenseRange
    let internet: ExpenseRange
    let phone: ExpenseRange
    let entertainment: ExpenseRange
    let healthInsurance: ExpenseRange
    let miscellaneous: ExpenseRange
    
    enum CodingKeys: String, CodingKey {
        case accommodation, food, transportation, utilities, internet, phone, entertainment, miscellaneous
        case healthInsurance = "health_insurance"
    }
    
    var totalMinimum: Double {
        accommodation.min + food.min + transportation.min + utilities.min +
        internet.min + phone.min + entertainment.min + healthInsurance.min + miscellaneous.min
    }
    
    var totalMaximum: Double {
        accommodation.max + food.max + transportation.max + utilities.max +
        internet.max + phone.max + entertainment.max + healthInsurance.max + miscellaneous.max
    }
}

struct ExpenseRange: Codable, Hashable {
    let min: Double
    let max: Double
    let typical: Double
    let notes: String?
}

struct CostComparison: Codable, Hashable {
    let vsKathmandu: Double // percentage difference
    let vsUSA: Double
    let affordabilityRank: Int // 1 = most affordable
    
    enum CodingKeys: String, CodingKey {
        case vsKathmandu = "vs_kathmandu"
        case vsUSA = "vs_usa"
        case affordabilityRank = "affordability_rank"
    }
}

struct CostOfLivingResponse: Codable {
    let version: String
    let cities: [CostOfLiving]
}

// MARK: - Pre-Departure Checklist

struct PreDepartureChecklist: Identifiable, Codable, Hashable {
    let id: String
    let country: String
    let categories: [ChecklistCategory]
    let timeline: [TimelineItem]
    let emergencyContacts: [EmergencyContact]
    
    enum CodingKeys: String, CodingKey {
        case id, country, categories, timeline
        case emergencyContacts = "emergency_contacts"
    }
}

struct ChecklistCategory: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let icon: String
    let items: [ChecklistItem]
}

struct ChecklistItem: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let priority: String // high, medium, low
    let tips: String?
    let links: [String]?
}

struct TimelineItem: Identifiable, Codable, Hashable {
    let id: String
    let period: String // "3 months before", "1 week before", etc.
    let tasks: [String]
}

struct EmergencyContact: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let type: String // embassy, emergency services, helpline
    let phone: String
    let email: String?
    let description: String
    let available24x7: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, type, phone, email, description
        case available24x7 = "available_24x7"
    }
}

struct PreDepartureResponse: Codable {
    let version: String
    let checklists: [PreDepartureChecklist]
}

// MARK: - Scholarship (Enhanced)

struct ScholarshipDetailed: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let provider: String
    let providerLogo: String?
    let country: String
    let targetCountries: [String] // countries where students can apply from
    let coverage: ScholarshipCoverage
    let amount: String
    let deadline: String
    let eligibility: [String]
    let requiredDocuments: [String]
    let applicationProcess: [String]
    let selectionCriteria: [String]
    let website: String
    let contactEmail: String?
    let tips: [String]
    let successRate: String?
    let alumniCount: Int?
    let isFullyFunded: Bool
    let forNepalese: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, provider, country, coverage, amount, deadline, eligibility, website, tips
        case providerLogo = "provider_logo"
        case targetCountries = "target_countries"
        case requiredDocuments = "required_documents"
        case applicationProcess = "application_process"
        case selectionCriteria = "selection_criteria"
        case contactEmail = "contact_email"
        case successRate = "success_rate"
        case alumniCount = "alumni_count"
        case isFullyFunded = "is_fully_funded"
        case forNepalese = "for_nepalese"
    }
}

struct ScholarshipCoverage: Codable, Hashable {
    let tuition: Bool
    let accommodation: Bool
    let travel: Bool
    let stipend: Bool
    let healthInsurance: Bool
    let books: Bool
    let visa: Bool
    
    enum CodingKeys: String, CodingKey {
        case tuition, accommodation, travel, stipend, books, visa
        case healthInsurance = "health_insurance"
    }
}

struct ScholarshipsDetailedResponse: Codable {
    let version: String
    let scholarships: [ScholarshipDetailed]
}

// MARK: - Education Loan

struct EducationLoan: Identifiable, Codable, Hashable {
    let id: String
    let bankName: String
    let bankLogo: String
    let loanName: String
    let maxAmount: Double
    let currency: String
    let interestRate: InterestRate
    let tenure: LoanTenure
    let eligibility: [String]
    let requiredDocuments: [String]
    let collateralRequired: Bool
    let collateralDetails: String?
    let processingFee: String
    let disbursementTime: String
    let moratoriumPeriod: String
    let countries: [String] // eligible destination countries
    let website: String
    let contactNumber: String?
    let benefits: [String]
    
    enum CodingKeys: String, CodingKey {
        case id, bankName = "bank_name", bankLogo = "bank_logo", loanName = "loan_name"
        case maxAmount = "max_amount", currency, interestRate = "interest_rate"
        case tenure, eligibility, requiredDocuments = "required_documents"
        case collateralRequired = "collateral_required", collateralDetails = "collateral_details"
        case processingFee = "processing_fee", disbursementTime = "disbursement_time"
        case moratoriumPeriod = "moratorium_period", countries, website
        case contactNumber = "contact_number", benefits
    }
}

struct InterestRate: Codable, Hashable {
    let type: String // fixed, floating
    let rate: Double
    let baseRate: String?
    
    enum CodingKeys: String, CodingKey {
        case type, rate
        case baseRate = "base_rate"
    }
}

struct LoanTenure: Codable, Hashable {
    let minYears: Int
    let maxYears: Int
    
    enum CodingKeys: String, CodingKey {
        case minYears = "min_years"
        case maxYears = "max_years"
    }
}

struct EducationLoansResponse: Codable {
    let version: String
    let loans: [EducationLoan]
}

// MARK: - Nepal Embassy Directory

struct NepalEmbassy: Identifiable, Codable, Hashable {
    let id: String
    let country: String
    let city: String
    let type: String // embassy, consulate, honorary consulate
    let address: String
    let phone: [String]
    let fax: String?
    let email: String
    let website: String?
    let ambassador: String?
    let workingHours: String
    let emergencyNumber: String?
    let services: [String]
    let nearestAirport: String?
    let googleMapsUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, country, city, type, address, phone, fax, email, website, ambassador, services
        case workingHours = "working_hours"
        case emergencyNumber = "emergency_number"
        case nearestAirport = "nearest_airport"
        case googleMapsUrl = "google_maps_url"
    }
}

struct NepalEmbassiesResponse: Codable {
    let version: String
    let embassies: [NepalEmbassy]
}

// MARK: - Student Community Post

struct CommunityPost: Identifiable, Codable, Hashable {
    let id: String
    let authorId: String
    let authorName: String
    let authorAvatar: String?
    let authorCountry: String
    let authorUniversity: String?
    let title: String
    let content: String
    let category: PostCategory
    let tags: [String]
    let createdAt: String
    let likes: Int
    let comments: Int
    let isVerified: Bool
    let isPinned: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, title, content, category, tags, likes, comments
        case authorId = "author_id"
        case authorName = "author_name"
        case authorAvatar = "author_avatar"
        case authorCountry = "author_country"
        case authorUniversity = "author_university"
        case createdAt = "created_at"
        case isVerified = "is_verified"
        case isPinned = "is_pinned"
    }
}

enum PostCategory: String, Codable, CaseIterable {
    case general = "general"
    case visaExperience = "visa_experience"
    case universityReview = "university_review"
    case jobSearch = "job_search"
    case accommodation = "accommodation"
    case financeTips = "finance_tips"
    case travelTips = "travel_tips"
    case homesickness = "homesickness"
    case successStory = "success_story"
    case question = "question"
    
    var displayName: String {
        switch self {
        case .general: return "General"
        case .visaExperience: return "Visa Experience"
        case .universityReview: return "University Review"
        case .jobSearch: return "Job Search"
        case .accommodation: return "Accommodation"
        case .financeTips: return "Finance Tips"
        case .travelTips: return "Travel Tips"
        case .homesickness: return "Homesickness & Support"
        case .successStory: return "Success Story"
        case .question: return "Question"
        }
    }
    
    var icon: String {
        switch self {
        case .general: return "bubble.left.and.bubble.right"
        case .visaExperience: return "doc.text"
        case .universityReview: return "building.columns"
        case .jobSearch: return "briefcase"
        case .accommodation: return "house"
        case .financeTips: return "dollarsign.circle"
        case .travelTips: return "airplane"
        case .homesickness: return "heart"
        case .successStory: return "star.fill"
        case .question: return "questionmark.circle"
        }
    }
}

// MARK: - Currency Converter

struct CurrencyRate: Identifiable, Codable, Hashable {
    let id: String
    let code: String
    let name: String
    let symbol: String
    let flag: String
    let buyRate: Double
    let sellRate: Double
    let lastUpdated: String
    
    enum CodingKeys: String, CodingKey {
        case id, code, name, symbol, flag
        case buyRate = "buy_rate"
        case sellRate = "sell_rate"
        case lastUpdated = "last_updated"
    }
}

struct CurrencyRatesResponse: Codable {
    let version: String
    let baseCurrency: String
    let rates: [CurrencyRate]
    
    enum CodingKeys: String, CodingKey {
        case version, rates
        case baseCurrency = "base_currency"
    }
}

// MARK: - Part-time Job Listing (for students)

struct PartTimeJob: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let company: String
    let companyLogo: String?
    let location: String
    let country: String
    let hourlyRate: String
    let currency: String
    let hoursPerWeek: String
    let description: String
    let requirements: [String]
    let benefits: [String]
    let isStudentFriendly: Bool
    let visaCompatible: Bool
    let postedDate: String
    let applicationUrl: String?
    let contactEmail: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, company, location, country, currency, description, requirements, benefits
        case companyLogo = "company_logo"
        case hourlyRate = "hourly_rate"
        case hoursPerWeek = "hours_per_week"
        case isStudentFriendly = "is_student_friendly"
        case visaCompatible = "visa_compatible"
        case postedDate = "posted_date"
        case applicationUrl = "application_url"
        case contactEmail = "contact_email"
    }
}

struct PartTimeJobsResponse: Codable {
    let version: String
    let jobs: [PartTimeJob]
}

// MARK: - ============================================
// MARK: - COUNTRY-SPECIFIC DATA MODELS
// MARK: - ============================================

// MARK: - Country Data Container

struct CountryData: Codable {
    let version: String
    let countryCode: String
    let countryName: String
    let lastUpdated: String
    let overview: CountryOverview
    let universities: [CountryUniversity]
    let scholarships: [CountryScholarship]
    let languageTests: [CountryLanguageTest]
    let visaInfo: CountryVisaInfo
    let costOfLiving: CountryCostOfLiving
    let partTimeJobs: CountryPartTimeJobInfo
    let accommodation: CountryAccommodation
    let cultureTips: CountryCultureTips
    let emergencyContacts: CountryEmergencyContacts
    let remittance: CountryRemittance?
    
    enum CodingKeys: String, CodingKey {
        case version
        case countryCode = "country_code"
        case countryName = "country_name"
        case lastUpdated = "last_updated"
        case overview, universities, scholarships
        case languageTests = "language_tests"
        case visaInfo = "visa_info"
        case costOfLiving = "cost_of_living"
        case partTimeJobs = "part_time_jobs"
        case accommodation
        case cultureTips = "culture_tips"
        case emergencyContacts = "emergency_contacts"
        case remittance
    }
}

// MARK: - Country Overview

struct CountryOverview: Codable {
    let flag: String
    let capital: String
    let currency: String
    let currencySymbol: String
    let officialLanguage: String
    let timezone: String
    let countryCodePhone: String
    let academicYear: String
    let popularIntakes: [String]
    let internationalStudents: Int
    let universitiesCount: Int
    let description: String
    let whyStudyHere: [String]
    
    enum CodingKeys: String, CodingKey {
        case flag, capital, currency, timezone, description
        case currencySymbol = "currency_symbol"
        case officialLanguage = "official_language"
        case countryCodePhone = "country_code_phone"
        case academicYear = "academic_year"
        case popularIntakes = "popular_intakes"
        case internationalStudents = "international_students"
        case universitiesCount = "universities_count"
        case whyStudyHere = "why_study_here"
    }
}

// MARK: - Country University

struct CountryUniversity: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let japaneseName: String?
    let location: String
    let country: String
    let type: String
    let description: String
    let image: String
    let rating: Double
    let programs: [String]
    let annualFee: String
    let annualFeeUsd: String?
    let ranking: Int?
    let website: String?
    let accreditation: String?
    let studentCount: Int?
    let internationalStudents: Int?
    let foundedYear: Int?
    let englishPrograms: Bool?
    let scholarshipAvailable: Bool?
    let dormitoryAvailable: Bool?
    let applicationDeadlines: ApplicationDeadlines?
    let entryRequirements: EntryRequirements?
    
    enum CodingKeys: String, CodingKey {
        case id, title, location, country, type, description, image, rating, programs, ranking, website, accreditation
        case japaneseName = "japanese_name"
        case annualFee = "annual_fee"
        case annualFeeUsd = "annual_fee_usd"
        case studentCount = "student_count"
        case internationalStudents = "international_students"
        case foundedYear = "founded_year"
        case englishPrograms = "english_programs"
        case scholarshipAvailable = "scholarship_available"
        case dormitoryAvailable = "dormitory_available"
        case applicationDeadlines = "application_deadlines"
        case entryRequirements = "entry_requirements"
    }
}

struct ApplicationDeadlines: Codable, Hashable {
    let aprilIntake: String?
    let octoberIntake: String?
    let septemberIntake: String?
    
    enum CodingKeys: String, CodingKey {
        case aprilIntake = "april_intake"
        case octoberIntake = "october_intake"
        case septemberIntake = "september_intake"
    }
}

struct EntryRequirements: Codable, Hashable {
    let undergraduate: String?
    let graduate: String?
}

// MARK: - Country Scholarship

struct CountryScholarship: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let provider: String
    let providerLogo: String?
    let amount: String
    let amountDescription: String?
    let currency: String
    let deadline: String
    let deadlineType: String?
    let description: String
    let eligibility: [String]
    let coverageDetails: [String]
    let applicationProcess: [String]?
    let requiredDocuments: [String]?
    let selectionCriteria: [String]?
    let website: String?
    let countries: [String]
    let degreeLevel: [String]
    let fieldOfStudy: [String]?
    let isFullyFunded: Bool
    let forNepalese: Bool?
    let successTips: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, provider, amount, currency, deadline, description, eligibility, countries, website
        case providerLogo = "provider_logo"
        case amountDescription = "amount_description"
        case deadlineType = "deadline_type"
        case coverageDetails = "coverage_details"
        case applicationProcess = "application_process"
        case requiredDocuments = "required_documents"
        case selectionCriteria = "selection_criteria"
        case degreeLevel = "degree_level"
        case fieldOfStudy = "field_of_study"
        case isFullyFunded = "is_fully_funded"
        case forNepalese = "for_nepalese"
        case successTips = "success_tips"
    }
}

// MARK: - Country Language Test

struct CountryLanguageTest: Identifiable, Codable, Hashable {
    let id: String
    let type: String
    let fullName: String
    let description: String
    let levels: [TestLevel]?
    let testFee: String
    let testFeeNpr: String?
    let testDates: [String]
    let testCentersNepal: [NepalTestCenter]?
    let sections: [CountryTestSection]?
    let preparationTips: [String]
    let resources: [TestResource]?
    let universityRequirements: UniversityRequirements?
    
    enum CodingKeys: String, CodingKey {
        case id, type, description, levels, sections, resources
        case fullName = "full_name"
        case testFee = "test_fee"
        case testFeeNpr = "test_fee_npr"
        case testDates = "test_dates"
        case testCentersNepal = "test_centers_nepal"
        case preparationTips = "preparation_tips"
        case universityRequirements = "university_requirements"
    }
}

struct TestLevel: Codable, Hashable {
    let level: String
    let description: String
    let hoursNeeded: String?
    let vocabulary: String?
    let kanji: String?
    
    enum CodingKeys: String, CodingKey {
        case level, description, vocabulary, kanji
        case hoursNeeded = "hours_needed"
    }
}

struct NepalTestCenter: Codable, Hashable {
    let name: String
    let address: String
    let contact: String?
}

struct CountryTestSection: Identifiable, Codable, Hashable {
    var id: String { name }
    let name: String
    let duration: String?
    let description: String
}

struct TestResource: Identifiable, Codable, Hashable {
    var id: String { name }
    let name: String
    let url: String?
    let type: String
    let isFree: Bool?
    
    enum CodingKeys: String, CodingKey {
        case name, url, type
        case isFree = "is_free"
    }
}

struct UniversityRequirements: Codable, Hashable {
    let undergraduate: String?
    let graduate: String?
    let englishPrograms: String?
    
    enum CodingKeys: String, CodingKey {
        case undergraduate, graduate
        case englishPrograms = "english_programs"
    }
}

// MARK: - Country Visa Info

struct CountryVisaInfo: Codable, Hashable {
    let visaType: String
    let visaFee: String
    let visaFeeUsd: String?
    let processingTime: String
    let validity: String
    let coeProcessingTime: String?
    let workPermission: String
    let embassyNepal: EmbassyInfo?
    let applicationProcess: [VisaStep]
    let requiredDocuments: VisaDocuments?
    let tips: [String]
    let commonRejectionReasons: [String]?
    
    enum CodingKeys: String, CodingKey {
        case validity, tips
        case visaType = "visa_type"
        case visaFee = "visa_fee"
        case visaFeeUsd = "visa_fee_usd"
        case processingTime = "processing_time"
        case coeProcessingTime = "coe_processing_time"
        case workPermission = "work_permission"
        case embassyNepal = "embassy_nepal"
        case applicationProcess = "application_process"
        case requiredDocuments = "required_documents"
        case commonRejectionReasons = "common_rejection_reasons"
    }
}

struct VisaStep: Identifiable, Codable, Hashable {
    var id: Int { step }
    let step: Int
    let title: String
    let description: String
    let duration: String?
    let documents: [String]?
}

struct VisaDocuments: Codable, Hashable {
    let forCoe: [String]?
    let forVisa: [String]?
    
    enum CodingKeys: String, CodingKey {
        case forCoe = "for_coe"
        case forVisa = "for_visa"
    }
}

// MARK: - Country Cost of Living

struct CountryCostOfLiving: Codable, Hashable {
    let currency: String
    let monthlyEstimate: [String: CostEstimate]
    let breakdown: CostBreakdown
    let moneySavingTips: [String]
    
    enum CodingKeys: String, CodingKey {
        case currency, breakdown
        case monthlyEstimate = "monthly_estimate"
        case moneySavingTips = "money_saving_tips"
    }
}

struct CostEstimate: Codable, Hashable {
    let min: Int
    let max: Int
    let typical: Int
    let inUsd: String?
    
    enum CodingKeys: String, CodingKey {
        case min, max, typical
        case inUsd = "in_usd"
    }
}

struct CostBreakdown: Codable, Hashable {
    let accommodation: CostCategory?
    let food: CostCategory?
    let transportation: CostCategory?
    let utilities: CostCategory?
    let healthInsurance: CostCategory?
    let entertainmentPersonal: CostCategory?
    
    enum CodingKeys: String, CodingKey {
        case accommodation, food, transportation, utilities
        case healthInsurance = "health_insurance"
        case entertainmentPersonal = "entertainment_personal"
    }
}

struct CostCategory: Codable, Hashable {
    let dormitory: CostRange?
    let sharedApartment: CostRange?
    let privateApartment: CostRange?
    let cookingAtHome: CostRange?
    let eatingOutBudget: CostRange?
    let trainPass: CostRange?
    let bicycle: CostRange?
    let electricityGasWater: CostRange?
    let internet: CostRange?
    let phone: CostRange?
    let nationalHealthInsurance: CostRange?
    let min: Int?
    let max: Int?
    let typical: Int?
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case dormitory, notes, min, max, typical, internet, phone, bicycle
        case sharedApartment = "shared_apartment"
        case privateApartment = "private_apartment"
        case cookingAtHome = "cooking_at_home"
        case eatingOutBudget = "eating_out_budget"
        case trainPass = "train_pass"
        case electricityGasWater = "electricity_gas_water"
        case nationalHealthInsurance = "national_health_insurance"
    }
}

struct CostRange: Codable, Hashable {
    let min: Int
    let max: Int
    let typical: Int
}

// MARK: - Country Part-time Job Info

struct CountryPartTimeJobInfo: Codable, Hashable {
    let workPermission: String
    let permitRequired: Bool
    let permitProcess: String?
    let averageHourlyWage: String
    let minimumWageTokyo: String?
    let commonJobs: [CommonPartTimeJob]
    let jobSearchResources: [JobResource]
    let tips: [String]
    
    enum CodingKeys: String, CodingKey {
        case tips
        case workPermission = "work_permission"
        case permitRequired = "permit_required"
        case permitProcess = "permit_process"
        case averageHourlyWage = "average_hourly_wage"
        case minimumWageTokyo = "minimum_wage_tokyo"
        case commonJobs = "common_jobs"
        case jobSearchResources = "job_search_resources"
    }
}

struct CommonPartTimeJob: Identifiable, Codable, Hashable {
    var id: String { title }
    let title: String
    let wageRange: String
    let japaneseRequired: String?
    let description: String
    let pros: [String]?
    let cons: [String]?
    
    enum CodingKeys: String, CodingKey {
        case title, description, pros, cons
        case wageRange = "wage_range"
        case japaneseRequired = "japanese_required"
    }
}

struct JobResource: Identifiable, Codable, Hashable {
    var id: String { name }
    let name: String
    let url: String?
    let description: String
}

// MARK: - Country Accommodation

struct CountryAccommodation: Codable, Hashable {
    let types: [AccommodationType]
    let searchWebsites: [AccommodationWebsite]
    let tips: [String]
}

struct AccommodationType: Identifiable, Codable, Hashable {
    var id: String { type }
    let type: String
    let japanese: String?
    let costRange: String
    let pros: [String]
    let cons: [String]
    let howToApply: String?
    let recommendedFor: String?
    let popularProviders: [String]?
    let upfrontCosts: String?
    
    enum CodingKeys: String, CodingKey {
        case type, japanese, pros, cons
        case costRange = "cost_range"
        case howToApply = "how_to_apply"
        case recommendedFor = "recommended_for"
        case popularProviders = "popular_providers"
        case upfrontCosts = "upfront_costs"
    }
}

struct AccommodationWebsite: Identifiable, Codable, Hashable {
    var id: String { name }
    let name: String
    let url: String
}

// MARK: - Country Culture Tips

struct CountryCultureTips: Codable, Hashable {
    let etiquette: [String]
    let usefulApps: [UsefulApp]
    let importantPhrases: [ImportantPhrase]?
    
    enum CodingKeys: String, CodingKey {
        case etiquette
        case usefulApps = "useful_apps"
        case importantPhrases = "important_phrases"
    }
}

struct UsefulApp: Identifiable, Codable, Hashable {
    var id: String { name }
    let name: String
    let use: String
}

struct ImportantPhrase: Identifiable, Codable, Hashable {
    var id: String { japanese }
    let japanese: String
    let meaning: String
}

// MARK: - Country Emergency Contacts

struct CountryEmergencyContacts: Codable, Hashable {
    let police: String
    let fireAmbulance: String
    let nepalEmbassyTokyo: EmbassyContactInfo?
    let jntoTouristHotline: String?
    let immigrationInfo: String?
    let usefulNumbers: [UsefulNumber]?
    
    enum CodingKeys: String, CodingKey {
        case police
        case fireAmbulance = "fire_ambulance"
        case nepalEmbassyTokyo = "nepal_embassy_tokyo"
        case jntoTouristHotline = "jnto_tourist_hotline"
        case immigrationInfo = "immigration_info"
        case usefulNumbers = "useful_numbers"
    }
}

struct EmbassyContactInfo: Codable, Hashable {
    let address: String
    let phone: String
    let email: String?
    let website: String?
}

struct UsefulNumber: Identifiable, Codable, Hashable {
    var id: String { service }
    let service: String
    let number: String
}

// MARK: - Country Remittance

struct CountryRemittance: Codable, Hashable {
    let sendingToNepal: RemittanceToNepal?
    
    enum CodingKeys: String, CodingKey {
        case sendingToNepal = "sending_to_nepal"
    }
}

struct RemittanceToNepal: Codable, Hashable {
    let popularServices: [RemittanceService]
    let tips: [String]
}

struct RemittanceService: Identifiable, Codable, Hashable {
    var id: String { name }
    let name: String
    let fee: String
    let rateType: String
    let transferTime: String
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case name, fee, notes
        case rateType = "rate_type"
        case transferTime = "transfer_time"
    }
}

