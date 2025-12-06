//
//  DataService.swift
//  Educa
//
//  Central data service for loading and managing all app content
//  Implements manifest-based updates from GitHub
//

import Foundation

// MARK: - Remote Manifest Models

struct RemoteManifest: Codable {
    let version: String
    let appName: String
    let lastUpdated: String
    let minAppVersion: String
    let baseUrl: String
    let files: [String: RemoteFileInfo]
    let images: RemoteImagesInfo
    let changelog: [ChangelogEntry]
    
    enum CodingKeys: String, CodingKey {
        case version
        case appName = "app_name"
        case lastUpdated = "last_updated"
        case minAppVersion = "min_app_version"
        case baseUrl = "base_url"
        case files, images, changelog
    }
}

struct RemoteFileInfo: Codable {
    let filename: String
    let path: String
    let version: String
    let size: Int
    let hash: String
}

struct RemoteImagesInfo: Codable {
    let baseUrl: String
    let categories: [String]
    
    enum CodingKeys: String, CodingKey {
        case baseUrl = "base_url"
        case categories
    }
}

struct ChangelogEntry: Codable {
    let version: String
    let date: String
    let changes: [String]
}

// MARK: - Data Service

@MainActor
final class DataService: ObservableObject {
    static let shared = DataService()
    
    // MARK: - GitHub Configuration
    // ✅ Update this URL to your GitHub repository
    private let githubBaseURL = "https://raw.githubusercontent.com/dnsmalla/educa-data/main"
    private let manifestPath = "/manifest.json"
    
    // MARK: - Published Properties
    
    @Published var universities: [University] = []
    @Published var countries: [Country] = []
    @Published var courses: [Course] = []
    @Published var guides: [StudentGuide] = []
    @Published var remittanceProviders: [RemittanceProvider] = []
    @Published var jobs: [JobListing] = []
    @Published var services: [ServiceCategory] = []
    @Published var updates: [AppUpdate] = []
    @Published var scholarships: [Scholarship] = []
    @Published var learningSteps: [LearningStep] = []
    @Published var achievements: [Achievement] = []
    @Published var applications: [JobApplication] = []
    @Published var transactions: [Transaction] = []
    
    // New company providers
    @Published var travelAgencies: [TravelAgency] = []
    @Published var visaConsultants: [VisaConsultant] = []
    @Published var accommodationProviders: [AccommodationProvider] = []
    @Published var educationConsultants: [EducationConsultant] = []
    @Published var recruitmentAgencies: [RecruitmentAgency] = []
    
    // Nepal Student Specific Features
    @Published var languageTests: [LanguageTest] = []
    @Published var visaRequirements: [VisaRequirement] = []
    @Published var costOfLiving: [CostOfLiving] = []
    @Published var preDepartureChecklists: [PreDepartureChecklist] = []
    @Published var detailedScholarships: [ScholarshipDetailed] = []
    @Published var educationLoans: [EducationLoan] = []
    @Published var nepalEmbassies: [NepalEmbassy] = []
    @Published var currencyRates: [CurrencyRate] = []
    @Published var partTimeJobs: [PartTimeJob] = []
    
    // MARK: - Country-Specific Data
    @Published var selectedCountryData: CountryData?
    @Published var countryUniversities: [CountryUniversity] = []
    @Published var countryScholarships: [CountryScholarship] = []
    @Published var countryLanguageTests: [CountryLanguageTest] = []
    @Published var countryVisaInfo: CountryVisaInfo?
    @Published var countryCostOfLiving: CountryCostOfLiving?
    @Published var countryPartTimeJobs: CountryPartTimeJobInfo?
    @Published var countryAccommodation: CountryAccommodation?
    @Published var countryCultureTips: CountryCultureTips?
    @Published var countryOverview: CountryOverview?
    @Published var countryEmergencyContacts: CountryEmergencyContacts?
    @Published var countryRemittance: CountryRemittance?
    
    @Published var isLoading = false
    @Published var isOffline = false
    @Published var error: String?
    @Published var dataVersion: String = "1.0.0"
    @Published var lastSyncDate: Date?
    @Published var hasUpdates = false
    @Published var currentCountry: DestinationCountry?
    
    // MARK: - Cache & Version Management
    
    private let cacheDir: URL = {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("EducaData")
    }()
    
    private let versionKey = "educa_data_version"
    private let lastSyncKey = "educa_last_sync"
    private let fileVersionsKey = "educa_file_versions"
    
    private var cachedManifest: RemoteManifest?
    private var fileVersions: [String: String] = [:]
    
    private init() {
        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        loadVersionInfo()
    }
    
    // MARK: - Version Info
    
    private func loadVersionInfo() {
        dataVersion = UserDefaults.standard.string(forKey: versionKey) ?? "1.0.0"
        if let lastSync = UserDefaults.standard.object(forKey: lastSyncKey) as? Date {
            lastSyncDate = lastSync
        }
        if let versions = UserDefaults.standard.dictionary(forKey: fileVersionsKey) as? [String: String] {
            fileVersions = versions
        }
    }
    
    private func saveVersionInfo() {
        UserDefaults.standard.set(dataVersion, forKey: versionKey)
        UserDefaults.standard.set(lastSyncDate, forKey: lastSyncKey)
        UserDefaults.standard.set(fileVersions, forKey: fileVersionsKey)
    }
    
    // MARK: - Load All Data
    
    func loadAllData() async {
        isLoading = true
        error = nil
        
        // Load from bundle (no network calls)
        await loadBundleData()
        
        isLoading = false
        lastSyncDate = Date()
    }
    
    // MARK: - Load Data Based on User Preferences
    
    /// Loads all relevant data based on user's selected destination country
    func loadDataForUserPreferences(destination: DestinationCountry?, homeCountry: HomeCountry?) async {
        isLoading = true
        error = nil
        
        // Load base data first
        await loadBundleData()
        
        // If destination is selected, load country-specific data
        if let destination = destination {
            await loadCountryData(for: destination)
            currentCountry = destination
        }
        
        isLoading = false
        lastSyncDate = Date()
        
        print("✅ Loaded data for: \(destination?.name ?? "No destination") from \(homeCountry?.name ?? "No home country")")
    }
    
    /// Get filtered universities based on user's destination
    func getFilteredUniversities(for destination: DestinationCountry? = nil) -> [University] {
        let country = destination ?? currentCountry
        guard let country = country else { return universities }
        return universities.filter { $0.country.lowercased() == country.name.lowercased() }
    }
    
    /// Get filtered scholarships based on user's destination
    func getFilteredScholarships(for destination: DestinationCountry? = nil) -> [Scholarship] {
        let country = destination ?? currentCountry
        guard let country = country else { return scholarships }
        return scholarships.filter { 
            $0.countries.contains(country.name) || 
            $0.countries.contains("All countries") ||
            $0.countries.isEmpty
        }
    }
    
    /// Get filtered jobs based on user's destination
    func getFilteredJobs(for destination: DestinationCountry? = nil) -> [JobListing] {
        let country = destination ?? currentCountry
        guard let country = country else { return jobs }
        return jobs.filter { $0.location.lowercased().contains(country.name.lowercased()) }
    }
    
    /// Get relevant language tests for destination
    func getRelevantLanguageTests(for destination: DestinationCountry? = nil) -> [CountryLanguageTest] {
        return countryLanguageTests
    }
    
    /// Check if user has selected a destination
    var hasDestinationSelected: Bool {
        currentCountry != nil
    }
    
    // MARK: - Load Bundle Data (Fast, No Network)
    
    private func loadBundleData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadUniversitiesFromBundle() }
            group.addTask { await self.loadCountriesFromBundle() }
            group.addTask { await self.loadCoursesFromBundle() }
            group.addTask { await self.loadGuidesFromBundle() }
            group.addTask { await self.loadRemittanceFromBundle() }
            group.addTask { await self.loadJobsFromBundle() }
            group.addTask { await self.loadServicesFromBundle() }
            group.addTask { await self.loadUpdatesFromBundle() }
            group.addTask { await self.loadScholarshipsFromBundle() }
            group.addTask { await self.loadLearningPath() }
            group.addTask { await self.loadCurrencyRates(fromRemote: false) }
        }
    }
    
    // MARK: - Simple Bundle Loaders
    
    private func loadUniversitiesFromBundle() async {
        if let data = loadDataFromBundle("universities"),
           let response = try? JSONDecoder().decode(UniversitiesResponse.self, from: data) {
            universities = response.universities
        }
    }
    
    private func loadCountriesFromBundle() async {
        if let data = loadDataFromBundle("countries"),
           let response = try? JSONDecoder().decode(CountriesResponse.self, from: data) {
            countries = response.countries
        }
    }
    
    private func loadCoursesFromBundle() async {
        if let data = loadDataFromBundle("courses"),
           let response = try? JSONDecoder().decode(CoursesResponse.self, from: data) {
            courses = response.courses
        }
    }
    
    private func loadGuidesFromBundle() async {
        if let data = loadDataFromBundle("guides"),
           let response = try? JSONDecoder().decode(GuidesResponse.self, from: data) {
            guides = response.guides
        }
    }
    
    private func loadRemittanceFromBundle() async {
        if let data = loadDataFromBundle("remittance"),
           let response = try? JSONDecoder().decode(RemittanceResponse.self, from: data) {
            remittanceProviders = response.providers
        }
    }
    
    private func loadJobsFromBundle() async {
        if let data = loadDataFromBundle("jobs"),
           let response = try? JSONDecoder().decode(JobsResponse.self, from: data) {
            jobs = response.jobs
        }
    }
    
    private func loadServicesFromBundle() async {
        if let data = loadDataFromBundle("services"),
           let response = try? JSONDecoder().decode(ServicesResponse.self, from: data) {
            services = response.services
        } else {
            loadDefaultServices()
        }
    }
    
    private func loadUpdatesFromBundle() async {
        if let data = loadDataFromBundle("updates"),
           let response = try? JSONDecoder().decode(UpdatesResponse.self, from: data) {
            updates = response.updates
        } else {
            loadDefaultUpdates()
        }
    }
    
    private func loadScholarshipsFromBundle() async {
        if let data = loadDataFromBundle("scholarships"),
           let response = try? JSONDecoder().decode(ScholarshipsResponse.self, from: data) {
            scholarships = response.scholarships
        } else {
            loadDefaultScholarships()
        }
    }
    
    // MARK: - Check for Updates (Disabled - using bundle only)
    
    func checkForUpdates() async {
        // Network updates disabled - using bundle data only
    }
    
    private func fetchManifest() async throws -> RemoteManifest {
        guard let url = URL(string: "\(githubBaseURL)\(manifestPath)") else {
            throw DataError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(RemoteManifest.self, from: data)
    }
    
    private func downloadUpdatedFiles(manifest: RemoteManifest) async {
        await withTaskGroup(of: Void.self) { group in
            for (fileKey, fileInfo) in manifest.files {
                let localVersion = fileVersions[fileKey] ?? "0.0.0"
                
                if fileInfo.version > localVersion {
                    group.addTask {
                        await self.downloadAndLoadFile(fileKey: fileKey, fileInfo: fileInfo)
                    }
                }
            }
        }
    }
    
    private func downloadAndLoadFile(fileKey: String, fileInfo: RemoteFileInfo) async {
        guard let url = URL(string: "\(githubBaseURL)/\(fileInfo.path)") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // Cache the data
            let cacheURL = cacheDir.appendingPathComponent(fileInfo.filename)
            try data.write(to: cacheURL)
            
            // Update version tracking
            fileVersions[fileKey] = fileInfo.version
            
            // Reload this specific data
            await reloadDataForKey(fileKey, data: data)
            
            print("✅ Downloaded \(fileKey) v\(fileInfo.version)")
        } catch {
            print("⚠️ Failed to download \(fileKey): \(error)")
        }
    }
    
    private func reloadDataForKey(_ key: String, data: Data) async {
        do {
            switch key {
            case "universities":
                let response = try JSONDecoder().decode(UniversitiesResponse.self, from: data)
                universities = response.universities
            case "countries":
                let response = try JSONDecoder().decode(CountriesResponse.self, from: data)
                countries = response.countries
            case "courses":
                let response = try JSONDecoder().decode(CoursesResponse.self, from: data)
                courses = response.courses
            case "guides":
                let response = try JSONDecoder().decode(GuidesResponse.self, from: data)
                guides = response.guides
            case "remittance":
                let response = try JSONDecoder().decode(RemittanceResponse.self, from: data)
                remittanceProviders = response.providers
            case "jobs":
                let response = try JSONDecoder().decode(JobsResponse.self, from: data)
                jobs = response.jobs
            case "services":
                let response = try JSONDecoder().decode(ServicesResponse.self, from: data)
                services = response.services
            case "scholarships":
                let response = try JSONDecoder().decode(ScholarshipsResponse.self, from: data)
                scholarships = response.scholarships
            case "updates":
                let response = try JSONDecoder().decode(UpdatesResponse.self, from: data)
                updates = response.updates
            default:
                break
            }
        } catch {
            print("⚠️ Failed to decode \(key): \(error)")
        }
    }
    
    // MARK: - Individual Loaders
    
    func loadUniversities(fromRemote: Bool = true) async {
        do {
            let response: UniversitiesResponse = try await fetchJSON(filename: "universities.json", fromRemote: fromRemote)
            universities = response.universities
        } catch {
            print("⚠️ Failed to load universities: \(error)")
        }
    }
    
    func loadCountries(fromRemote: Bool = true) async {
        do {
            let response: CountriesResponse = try await fetchJSON(filename: "countries.json", fromRemote: fromRemote)
            countries = response.countries
        } catch {
            print("⚠️ Failed to load countries: \(error)")
        }
    }
    
    func loadCourses(fromRemote: Bool = true) async {
        do {
            let response: CoursesResponse = try await fetchJSON(filename: "courses.json", fromRemote: fromRemote)
            courses = response.courses
        } catch {
            print("⚠️ Failed to load courses: \(error)")
        }
    }
    
    func loadGuides(fromRemote: Bool = true) async {
        do {
            let response: GuidesResponse = try await fetchJSON(filename: "guides.json", fromRemote: fromRemote)
            guides = response.guides
        } catch {
            print("⚠️ Failed to load guides: \(error)")
        }
    }
    
    func loadRemittanceProviders(fromRemote: Bool = true) async {
        do {
            let response: RemittanceResponse = try await fetchJSON(filename: "remittance.json", fromRemote: fromRemote)
            remittanceProviders = response.providers
        } catch {
            print("⚠️ Failed to load remittance providers: \(error)")
        }
    }
    
    func loadJobs(fromRemote: Bool = true) async {
        do {
            let response: JobsResponse = try await fetchJSON(filename: "jobs.json", fromRemote: fromRemote)
            jobs = response.jobs
        } catch {
            print("⚠️ Failed to load jobs: \(error)")
        }
    }
    
    func loadServices(fromRemote: Bool = true) async {
        do {
            let response: ServicesResponse = try await fetchJSON(filename: "services.json", fromRemote: fromRemote)
            services = response.services
        } catch {
            print("⚠️ Failed to load services: \(error)")
            loadDefaultServices()
        }
    }
    
    func loadUpdates(fromRemote: Bool = true) async {
        do {
            let response: UpdatesResponse = try await fetchJSON(filename: "updates.json", fromRemote: fromRemote)
            updates = response.updates
        } catch {
            print("⚠️ Failed to load updates: \(error)")
            loadDefaultUpdates()
        }
    }
    
    func loadScholarships(fromRemote: Bool = true) async {
        do {
            let response: ScholarshipsResponse = try await fetchJSON(filename: "scholarships.json", fromRemote: fromRemote)
            scholarships = response.scholarships
        } catch {
            print("⚠️ Failed to load scholarships: \(error)")
            loadDefaultScholarships()
        }
    }
    
    func loadLearningPath() async {
        loadDefaultLearningPath()
    }
    
    // MARK: - New Company Provider Loaders
    
    func loadTravelAgencies(fromRemote: Bool = true) async {
        do {
            let response: TravelAgenciesResponse = try await fetchJSON(filename: "travel_agencies.json", fromRemote: fromRemote)
            travelAgencies = response.agencies
        } catch {
            print("⚠️ Failed to load travel agencies: \(error)")
            loadDefaultTravelAgencies()
        }
    }
    
    func loadVisaConsultants(fromRemote: Bool = true) async {
        do {
            let response: VisaConsultantsResponse = try await fetchJSON(filename: "visa_consultants.json", fromRemote: fromRemote)
            visaConsultants = response.consultants
        } catch {
            print("⚠️ Failed to load visa consultants: \(error)")
            loadDefaultVisaConsultants()
        }
    }
    
    func loadAccommodationProviders(fromRemote: Bool = true) async {
        do {
            let response: AccommodationResponse = try await fetchJSON(filename: "accommodation.json", fromRemote: fromRemote)
            accommodationProviders = response.providers
        } catch {
            print("⚠️ Failed to load accommodation providers: \(error)")
            loadDefaultAccommodationProviders()
        }
    }
    
    func loadEducationConsultants(fromRemote: Bool = true) async {
        do {
            let response: EducationConsultantsResponse = try await fetchJSON(filename: "education_consultants.json", fromRemote: fromRemote)
            educationConsultants = response.consultants
        } catch {
            print("⚠️ Failed to load education consultants: \(error)")
            loadDefaultEducationConsultants()
        }
    }
    
    func loadRecruitmentAgencies(fromRemote: Bool = true) async {
        do {
            let response: RecruitmentAgenciesResponse = try await fetchJSON(filename: "recruitment_agencies.json", fromRemote: fromRemote)
            recruitmentAgencies = response.agencies
        } catch {
            print("⚠️ Failed to load recruitment agencies: \(error)")
            loadDefaultRecruitmentAgencies()
        }
    }
    
    // MARK: - Fetch with Fallback (Cache → Bundle → Remote)
    
    private func fetchJSON<T: Decodable>(filename: String, fromRemote: Bool = true) async throws -> T {
        // 1. Try cache first (always, for fast loading)
        let cacheURL = cacheDir.appendingPathComponent(filename)
        if let cachedData = try? Data(contentsOf: cacheURL) {
            do {
                let result = try JSONDecoder().decode(T.self, from: cachedData)
                print("📱 Loaded \(filename) from cache")
                return result
            } catch {
                print("⚠️ Cache decode failed for \(filename), trying other sources")
            }
        }
        
        // 2. Try bundle (for initial install before any network fetch)
        let resourceName = filename.replacingOccurrences(of: ".json", with: "")
        if let bundleURL = Bundle.main.url(forResource: resourceName, withExtension: "json"),
           let bundledData = try? Data(contentsOf: bundleURL) {
            do {
                let result = try JSONDecoder().decode(T.self, from: bundledData)
                print("📦 Loaded \(filename) from bundle")
                isOffline = true
                return result
            } catch {
                print("⚠️ Bundle decode failed for \(filename)")
            }
        }
        
        // 3. Try remote (if enabled)
        if fromRemote {
            let urlString = "\(githubBaseURL)/data/\(filename)"
            if let url = URL(string: urlString) {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    
                    // Cache the data
                    try? data.write(to: cacheURL)
                    
                    let result = try JSONDecoder().decode(T.self, from: data)
                    print("🌐 Loaded \(filename) from remote")
                    isOffline = false
                    return result
                } catch {
                    print("⚠️ Remote fetch failed for \(filename): \(error)")
                }
            }
        }
        
        throw DataError.notFound
    }
    
    // MARK: - Image URL Helper
    
    func imageURL(for path: String) -> URL? {
        // If it's already a full URL, return as-is
        if path.hasPrefix("http://") || path.hasPrefix("https://") {
            return URL(string: path)
        }
        
        // Otherwise, construct from GitHub base URL
        let fullPath = "\(githubBaseURL)/images/\(path)"
        return URL(string: fullPath)
    }
    
    // MARK: - Bundle Data Loader Helper
    
    private func loadDataFromBundle(_ resourceName: String) -> Data? {
        // Try to load from bundle first
        if let bundleURL = Bundle.main.url(forResource: resourceName, withExtension: "json"),
           let data = try? Data(contentsOf: bundleURL) {
            return data
        }
        
        // Try to load from cache directory
        let cacheURL = cacheDir.appendingPathComponent("\(resourceName).json")
        if let data = try? Data(contentsOf: cacheURL) {
            return data
        }
        
        return nil
    }
    
    // MARK: - Force Refresh
    
    func forceRefresh() async {
        // Reload from bundle
        await loadAllData()
    }
    
    // MARK: - Default Data Loaders
    
    private func loadDefaultUpdates() {
        updates = [
            AppUpdate(
                id: "update-1",
                title: "New Scholarship Opportunities Available!",
                description: "Check out the latest fully-funded scholarships for 2025.",
                content: nil,
                timestamp: "2024-12-05",
                type: .scholarship,
                category: "Scholarships",
                imageUrl: nil,
                actionUrl: nil,
                isRead: false
            ),
            AppUpdate(
                id: "update-2",
                title: "Application Deadline Reminder",
                description: "University of Melbourne applications close on January 31st.",
                content: nil,
                timestamp: "2024-12-04",
                type: .deadline,
                category: "Deadlines",
                imageUrl: nil,
                actionUrl: nil,
                isRead: false
            )
        ]
    }
    
    private func loadDefaultScholarships() {
        scholarships = [
            Scholarship(
                id: "sch-1",
                name: "Chevening Scholarship",
                provider: "UK Government",
                amount: "Full Funding",
                currency: "GBP",
                eligibility: ["Bachelor's degree", "2+ years work experience"],
                deadline: "2025-11-01",
                description: "The UK Government's global scholarship programme.",
                coverageDetails: ["Full tuition fees", "Monthly stipend", "Travel costs"],
                applicationUrl: "https://www.chevening.org",
                countries: ["United Kingdom"],
                degreeLevel: ["Master's"],
                fieldOfStudy: nil,
                isFullyFunded: true
            )
        ]
    }
    
    private func loadDefaultLearningPath() {
        learningSteps = [
            LearningStep(
                id: "step-1",
                stepNumber: 1,
                title: "Research Destinations",
                description: "Explore different countries and their education systems",
                status: .completed,
                tasks: ["Browse country guides", "Compare living costs", "Check visa requirements"],
                resources: ["Journey section", "Country comparison tool"]
            ),
            LearningStep(
                id: "step-2",
                stepNumber: 2,
                title: "Select Universities",
                description: "Find universities that match your goals and budget",
                status: .completed,
                tasks: ["Search universities", "Compare programs", "Check rankings"],
                resources: ["Study Hub", "University comparison"]
            ),
            LearningStep(
                id: "step-3",
                stepNumber: 3,
                title: "Prepare Documents",
                description: "Gather and prepare all required documents",
                status: .inProgress,
                tasks: ["Academic transcripts", "Language test scores", "Statement of purpose"],
                resources: ["Document checklist", "SOP guide"]
            ),
            LearningStep(
                id: "step-4",
                stepNumber: 4,
                title: "Apply for Scholarships",
                description: "Search and apply for funding opportunities",
                status: .upcoming,
                tasks: ["Find scholarships", "Check eligibility", "Submit applications"],
                resources: ["Scholarship database"]
            ),
            LearningStep(
                id: "step-5",
                stepNumber: 5,
                title: "Submit Applications",
                description: "Complete and submit university applications",
                status: .locked,
                tasks: ["Fill application forms", "Upload documents", "Pay fees"],
                resources: nil
            ),
            LearningStep(
                id: "step-6",
                stepNumber: 6,
                title: "Visa Process",
                description: "Apply for student visa after receiving admission",
                status: .locked,
                tasks: ["Gather visa documents", "Book appointment", "Attend interview"],
                resources: nil
            )
        ]
        
        achievements = [
            Achievement(id: "ach-1", title: "Explorer", description: "Viewed 5 countries", icon: "globe.americas.fill", dateEarned: "2024-12-01", isUnlocked: true),
            Achievement(id: "ach-2", title: "Researcher", description: "Saved 3 universities", icon: "building.columns.fill", dateEarned: "2024-12-03", isUnlocked: true),
            Achievement(id: "ach-3", title: "Planner", description: "Completed step 1", icon: "checkmark.circle.fill", dateEarned: "2024-12-02", isUnlocked: true),
            Achievement(id: "ach-4", title: "Scholar", description: "Applied to scholarship", icon: "graduationcap.fill", dateEarned: nil, isUnlocked: false)
        ]
    }
    
    private func loadDefaultServices() {
        services = [
            ServiceCategory(
                id: "study-hub",
                title: "Study Hub",
                icon: "📚",
                description: "GlobalStudy Hub is a one-stop platform for education consultants.",
                image: "services/study-hub.jpg",
                route: "/study-hub",
                isActive: true
            ),
            ServiceCategory(
                id: "journey",
                title: "Journey",
                icon: "✈️",
                description: "We help you find the most affordable and efficient path.",
                image: "services/journey.jpg",
                route: "/journey",
                isActive: true
            ),
            ServiceCategory(
                id: "placement",
                title: "Placement",
                icon: "💼",
                description: "We guide you to the best opportunities for starting your career.",
                image: "services/placement.jpg",
                route: "/placement",
                isActive: true
            ),
            ServiceCategory(
                id: "remittance",
                title: "Remittance",
                icon: "💸",
                description: "We ensure your money transfers are both easy and affordable.",
                image: "services/remittance.jpg",
                route: "/remittance",
                isActive: true
            )
        ]
    }
    
    // MARK: - Default Data for New Company Providers
    
    private func loadDefaultTravelAgencies() {
        travelAgencies = [
            TravelAgency(
                id: "travel-001",
                name: "Global Student Travel",
                logo: "travel/global-student.png",
                description: "Specialized travel services for international students with exclusive discounts and support.",
                website: "https://globalstudenttravel.com",
                rating: 4.8,
                services: ["Flight Booking", "Travel Insurance", "Airport Pickup", "Visa Assistance"],
                destinations: ["Australia", "Canada", "UK", "USA", "Germany", "New Zealand"],
                contactEmail: "info@globalstudenttravel.com",
                contactPhone: "+1 800 123 4567",
                address: "123 Travel Street, Sydney",
                priceRange: "$$",
                specializations: ["Student Travel", "Group Tours", "Visa Support"],
                languages: ["English", "Hindi", "Nepali"],
                isVerified: true,
                reviewCount: 1250,
                responseTime: "Within 24 hours",
                features: ["24/7 Support", "Best Price Guarantee", "Free Cancellation", "Student Discounts"]
            ),
            TravelAgency(
                id: "travel-002",
                name: "EduTravel Connect",
                logo: "travel/edutravel.png",
                description: "Your trusted partner for educational travel worldwide.",
                website: "https://edutravelconnect.com",
                rating: 4.6,
                services: ["Flight Booking", "Accommodation", "Travel Insurance"],
                destinations: ["Canada", "Australia", "UK", "Singapore"],
                contactEmail: "support@edutravelconnect.com",
                contactPhone: "+1 800 987 6543",
                address: "456 Education Ave, Toronto",
                priceRange: "$$$",
                specializations: ["University Tours", "Student Exchange"],
                languages: ["English", "French"],
                isVerified: true,
                reviewCount: 890,
                responseTime: "Same day",
                features: ["Group Discounts", "Flexible Booking", "Dedicated Support"]
            )
        ]
    }
    
    private func loadDefaultVisaConsultants() {
        visaConsultants = [
            VisaConsultant(
                id: "visa-001",
                name: "Premier Visa Services",
                logo: "visa/premier.png",
                description: "Expert visa consultation with highest success rates for student visas worldwide.",
                website: "https://premiervisaservices.com",
                rating: 4.9,
                servicesOffered: ["Student Visa", "Work Permit", "PR Application", "Visa Extension", "Document Verification"],
                countriesServed: ["Australia", "Canada", "UK", "USA", "Germany", "New Zealand", "Singapore"],
                successRate: 98,
                contactEmail: "apply@premiervisaservices.com",
                contactPhone: "+1 800 VISA 123",
                address: "789 Visa Plaza, Melbourne",
                consultationFee: "Free Initial",
                processingTime: "2-4 weeks",
                isGovernmentRegistered: true,
                reviewCount: 2500,
                features: ["Free Assessment", "Document Review", "Interview Prep", "Post-landing Support"],
                testimonials: ["Got my visa in just 3 weeks!", "Best visa service I've used"]
            ),
            VisaConsultant(
                id: "visa-002",
                name: "EasyVisa Solutions",
                logo: "visa/easyvisa.png",
                description: "Making visa applications simple and stress-free.",
                website: "https://easyvisasolutions.com",
                rating: 4.7,
                servicesOffered: ["Student Visa", "Tourist Visa", "Document Preparation"],
                countriesServed: ["Canada", "UK", "Australia"],
                successRate: 95,
                contactEmail: "info@easyvisasolutions.com",
                contactPhone: "+1 800 EASY VIS",
                address: "321 Immigration St, Vancouver",
                consultationFee: "$50",
                processingTime: "3-5 weeks",
                isGovernmentRegistered: true,
                reviewCount: 1200,
                features: ["Online Application Tracking", "24/7 Support", "Money-back Guarantee"],
                testimonials: nil
            )
        ]
    }
    
    private func loadDefaultAccommodationProviders() {
        accommodationProviders = [
            AccommodationProvider(
                id: "acc-001",
                name: "Student Housing Global",
                logo: "accommodation/shg.png",
                description: "Premium student accommodation worldwide with all-inclusive amenities.",
                website: "https://studenthousingglobal.com",
                rating: 4.7,
                accommodationType: "Student Residences",
                priceRange: "$800-1500/month",
                locations: ["Sydney", "Melbourne", "Toronto", "London", "Singapore"],
                amenities: ["WiFi", "Gym", "Study Rooms", "Laundry", "24/7 Security"],
                targetAudience: ["International Students", "Graduate Students"],
                bookingMethods: ["Online", "Phone", "Agent"],
                contactEmail: "booking@shg.com",
                contactPhone: "+1 800 STU DENT",
                reviewCount: 3500,
                features: ["Furnished Rooms", "Bills Included", "Flexible Lease", "Community Events"]
            ),
            AccommodationProvider(
                id: "acc-002",
                name: "UniStay",
                logo: "accommodation/unistay.png",
                description: "Affordable and safe accommodation near top universities.",
                website: "https://unistay.com",
                rating: 4.5,
                accommodationType: "Shared Apartments",
                priceRange: "$500-900/month",
                locations: ["Melbourne", "Brisbane", "Auckland", "Dublin"],
                amenities: ["WiFi", "Kitchen", "Common Areas", "Security"],
                targetAudience: ["Undergraduate Students", "Budget Travelers"],
                bookingMethods: ["Online", "App"],
                contactEmail: "hello@unistay.com",
                contactPhone: nil,
                reviewCount: 2100,
                features: ["Near Campus", "Roommate Matching", "Short-term Available"]
            )
        ]
    }
    
    private func loadDefaultEducationConsultants() {
        educationConsultants = [
            EducationConsultant(
                id: "edu-001",
                name: "Global Education Partners",
                logo: "education/gep.png",
                description: "Expert guidance for your international education journey with partnerships across 500+ universities.",
                website: "https://globaledupartners.com",
                rating: 4.8,
                servicesOffered: ["University Selection", "Application Assistance", "Scholarship Guidance", "SOP Review", "Interview Preparation"],
                countriesServed: ["Australia", "Canada", "UK", "USA", "Germany", "Ireland", "New Zealand"],
                universitiesPartnered: 500,
                studentsPlaced: 15000,
                contactEmail: "info@globaledupartners.com",
                contactPhone: "+1 800 EDU HELP",
                address: "Education Tower, Floor 10, Sydney",
                consultationFee: "Free",
                isRegistered: true,
                reviewCount: 4500,
                features: ["Free Counseling", "Visa Support", "Pre-departure Briefing", "Post-arrival Support"],
                successStories: ["Placed at Oxford!", "Full scholarship to MIT"]
            ),
            EducationConsultant(
                id: "edu-002",
                name: "Study Abroad Experts",
                logo: "education/sae.png",
                description: "Your pathway to world-class education.",
                website: "https://studyabroadexperts.com",
                rating: 4.6,
                servicesOffered: ["Counseling", "Application Support", "Test Preparation"],
                countriesServed: ["Canada", "Australia", "UK"],
                universitiesPartnered: 200,
                studentsPlaced: 8000,
                contactEmail: "hello@sae.com",
                contactPhone: "+1 800 SAE 1234",
                address: nil,
                consultationFee: "Free Initial",
                isRegistered: true,
                reviewCount: 2200,
                features: ["IELTS Coaching", "Scholarship Search", "Document Assistance"],
                successStories: nil
            )
        ]
    }
    
    private func loadDefaultRecruitmentAgencies() {
        recruitmentAgencies = [
            RecruitmentAgency(
                id: "rec-001",
                name: "Graduate Careers International",
                logo: "recruitment/gci.png",
                description: "Connecting international graduates with top employers worldwide.",
                website: "https://graduatecareers.com",
                rating: 4.7,
                industries: ["Technology", "Finance", "Healthcare", "Engineering", "Marketing"],
                locations: ["Australia", "UK", "Canada", "Singapore", "UAE"],
                jobTypes: ["Full-time", "Graduate Programs", "Internships"],
                contactEmail: "careers@gci.com",
                contactPhone: "+1 800 GCI JOBS",
                address: "Career Hub, Sydney CBD",
                placementFee: "Free for Candidates",
                isLicensed: true,
                reviewCount: 3200,
                features: ["Resume Review", "Interview Coaching", "Salary Negotiation", "Visa Sponsorship Jobs"],
                partneredCompanies: ["Google", "Microsoft", "Amazon", "Big 4 Accounting"]
            ),
            RecruitmentAgency(
                id: "rec-002",
                name: "Student2Career",
                logo: "recruitment/s2c.png",
                description: "Specialized in placing students and fresh graduates.",
                website: "https://student2career.com",
                rating: 4.5,
                industries: ["IT", "Business", "Science", "Arts"],
                locations: ["Australia", "New Zealand", "Canada"],
                jobTypes: ["Part-time", "Internships", "Entry Level"],
                contactEmail: "jobs@s2c.com",
                contactPhone: "+1 800 S2C WORK",
                address: nil,
                placementFee: "Free",
                isLicensed: true,
                reviewCount: 1800,
                features: ["Student-friendly Jobs", "Flexible Hours", "Work Rights Advice"],
                partneredCompanies: nil
            )
        ]
    }
    
    // MARK: - Nepal Student Specific Data Loaders
    
    func loadLanguageTests(fromRemote: Bool = false) async {
        if let data = loadDataFromBundle("language_tests"),
           let response = try? JSONDecoder().decode(LanguageTestsResponse.self, from: data) {
            languageTests = response.tests
            print("📚 Loaded \(languageTests.count) language tests")
        } else {
            loadDefaultLanguageTests()
        }
    }
    
    func loadVisaRequirements(fromRemote: Bool = false) async {
        if let data = loadDataFromBundle("visa_requirements"),
           let response = try? JSONDecoder().decode(VisaRequirementsResponse.self, from: data) {
            visaRequirements = response.countries
            print("📄 Loaded \(visaRequirements.count) visa requirement entries")
        } else {
            loadDefaultVisaRequirements()
        }
    }
    
    func loadCostOfLiving(fromRemote: Bool = false) async {
        if let data = loadDataFromBundle("cost_of_living"),
           let response = try? JSONDecoder().decode(CostOfLivingResponse.self, from: data) {
            costOfLiving = response.cities
            print("💰 Loaded \(costOfLiving.count) cost of living entries")
        } else {
            loadDefaultCostOfLiving()
        }
    }
    
    func loadPreDepartureChecklists(fromRemote: Bool = false) async {
        if let data = loadDataFromBundle("predeparture"),
           let response = try? JSONDecoder().decode(PreDepartureResponse.self, from: data) {
            preDepartureChecklists = response.checklists
            print("✅ Loaded \(preDepartureChecklists.count) pre-departure checklists")
        }
    }
    
    func loadDetailedScholarships(fromRemote: Bool = false) async {
        if let data = loadDataFromBundle("scholarships_detailed"),
           let response = try? JSONDecoder().decode(ScholarshipsDetailedResponse.self, from: data) {
            detailedScholarships = response.scholarships
            print("🎓 Loaded \(detailedScholarships.count) detailed scholarships")
        } else {
            loadDefaultDetailedScholarships()
        }
    }
    
    func loadEducationLoans(fromRemote: Bool = false) async {
        if let data = loadDataFromBundle("education_loans"),
           let response = try? JSONDecoder().decode(EducationLoansResponse.self, from: data) {
            educationLoans = response.loans
            print("🏦 Loaded \(educationLoans.count) education loans")
        } else {
            loadDefaultEducationLoans()
        }
    }
    
    func loadNepalEmbassies(fromRemote: Bool = false) async {
        if let data = loadDataFromBundle("nepal_embassies"),
           let response = try? JSONDecoder().decode(NepalEmbassiesResponse.self, from: data) {
            nepalEmbassies = response.embassies
            print("🏛️ Loaded \(nepalEmbassies.count) Nepal embassies")
        } else {
            loadDefaultNepalEmbassies()
        }
    }
    
    func loadCurrencyRates(fromRemote: Bool = false) async {
        if let data = loadDataFromBundle("currency_rates"),
           let response = try? JSONDecoder().decode(CurrencyRatesResponse.self, from: data) {
            currencyRates = response.rates
            print("💱 Loaded \(currencyRates.count) currency rates")
        } else {
            loadDefaultCurrencyRates()
        }
    }
    
    // MARK: - Default Nepal Student Data
    
    private func loadDefaultLanguageTests() {
        // Will be populated from JSON
        languageTests = []
    }
    
    private func loadDefaultVisaRequirements() {
        // Will be populated from JSON
        visaRequirements = []
    }
    
    private func loadDefaultCostOfLiving() {
        // Will be populated from JSON
        costOfLiving = []
    }
    
    private func loadDefaultDetailedScholarships() {
        // Will be populated from JSON
        detailedScholarships = []
    }
    
    private func loadDefaultEducationLoans() {
        // Will be populated from JSON
        educationLoans = []
    }
    
    private func loadDefaultNepalEmbassies() {
        // Will be populated from JSON
        nepalEmbassies = []
    }
    
    private func loadDefaultCurrencyRates() {
        // Default NPR exchange rates
        currencyRates = [
            CurrencyRate(id: "usd", code: "USD", name: "US Dollar", symbol: "$", flag: "🇺🇸", buyRate: 133.50, sellRate: 134.10, lastUpdated: "2024-12-05"),
            CurrencyRate(id: "aud", code: "AUD", name: "Australian Dollar", symbol: "A$", flag: "🇦🇺", buyRate: 87.20, sellRate: 87.80, lastUpdated: "2024-12-05"),
            CurrencyRate(id: "gbp", code: "GBP", name: "British Pound", symbol: "£", flag: "🇬🇧", buyRate: 169.50, sellRate: 170.30, lastUpdated: "2024-12-05"),
            CurrencyRate(id: "eur", code: "EUR", name: "Euro", symbol: "€", flag: "🇪🇺", buyRate: 141.20, sellRate: 141.90, lastUpdated: "2024-12-05"),
            CurrencyRate(id: "cad", code: "CAD", name: "Canadian Dollar", symbol: "C$", flag: "🇨🇦", buyRate: 95.80, sellRate: 96.40, lastUpdated: "2024-12-05"),
            CurrencyRate(id: "jpy", code: "JPY", name: "Japanese Yen", symbol: "¥", flag: "🇯🇵", buyRate: 0.89, sellRate: 0.90, lastUpdated: "2024-12-05"),
            CurrencyRate(id: "krw", code: "KRW", name: "South Korean Won", symbol: "₩", flag: "🇰🇷", buyRate: 0.097, sellRate: 0.099, lastUpdated: "2024-12-05"),
            CurrencyRate(id: "inr", code: "INR", name: "Indian Rupee", symbol: "₹", flag: "🇮🇳", buyRate: 1.60, sellRate: 1.60, lastUpdated: "2024-12-05")
        ]
    }
    
    // MARK: - Data Access Methods
    
    func getUniversity(by id: String) -> University? {
        universities.first { $0.id == id }
    }
    
    func getCountry(by id: String) -> Country? {
        countries.first { $0.id == id }
    }
    
    func getCourses(for universityId: String) -> [Course] {
        courses.filter { $0.universityId == universityId }
    }
    
    func getGuides(by category: String) -> [StudentGuide] {
        guides.filter { $0.category.lowercased() == category.lowercased() }
    }
    
    // MARK: - Search
    
    func searchUniversities(_ query: String) -> [University] {
        guard !query.isEmpty else { return universities }
        let lowercased = query.lowercased()
        return universities.filter {
            $0.title.lowercased().contains(lowercased) ||
            $0.location.lowercased().contains(lowercased) ||
            $0.country.lowercased().contains(lowercased)
        }
    }
    
    func searchCourses(_ query: String) -> [Course] {
        guard !query.isEmpty else { return courses }
        let lowercased = query.lowercased()
        return courses.filter {
            $0.name.lowercased().contains(lowercased) ||
            $0.degreeLevel.lowercased().contains(lowercased)
        }
    }
    
    func searchJobs(_ query: String) -> [JobListing] {
        guard !query.isEmpty else { return jobs }
        let lowercased = query.lowercased()
        return jobs.filter {
            $0.title.lowercased().contains(lowercased) ||
            $0.company.lowercased().contains(lowercased) ||
            $0.location.lowercased().contains(lowercased)
        }
    }
    
    // MARK: - Refresh
    
    func refresh() async {
        await loadAllData()
    }
    
    // MARK: - ==========================================
    // MARK: - COUNTRY-SPECIFIC DATA LOADING
    // MARK: - ==========================================
    
    /// Load all data for a specific country
    func loadCountryData(for country: DestinationCountry) async {
        isLoading = true
        currentCountry = country
        
        // First try to load from bundle
        if let data = loadDataFromBundle(country.rawValue),
           let countryData = try? JSONDecoder().decode(CountryData.self, from: data) {
            selectedCountryData = countryData
            countryOverview = countryData.overview
            countryUniversities = countryData.universities
            countryScholarships = countryData.scholarships
            countryLanguageTests = countryData.languageTests
            countryVisaInfo = countryData.visaInfo
            countryCostOfLiving = countryData.costOfLiving
            countryPartTimeJobs = countryData.partTimeJobs
            countryAccommodation = countryData.accommodation
            countryCultureTips = countryData.cultureTips
            countryEmergencyContacts = countryData.emergencyContacts
            countryRemittance = countryData.remittance
            print("✅ Loaded country data for \(country.name)")
        } else {
            // Load default/fallback data
            await loadDefaultCountryData(for: country)
            print("⚠️ Using default data for \(country.name)")
        }
        
        isLoading = false
    }
    
    /// Clear country-specific data
    func clearCountryData() {
        selectedCountryData = nil
        countryUniversities = []
        countryScholarships = []
        countryLanguageTests = []
        countryVisaInfo = nil
        countryCostOfLiving = nil
        countryPartTimeJobs = nil
        countryAccommodation = nil
        countryCultureTips = nil
        countryOverview = nil
        countryEmergencyContacts = nil
        countryRemittance = nil
        currentCountry = nil
    }
    
    /// Get universities filtered by current country
    func getUniversitiesForCurrentCountry() -> [University] {
        guard let country = currentCountry else { return universities }
        return universities.filter { $0.country.lowercased() == country.name.lowercased() }
    }
    
    /// Get scholarships filtered by current country
    func getScholarshipsForCurrentCountry() -> [Scholarship] {
        guard let country = currentCountry else { return scholarships }
        return scholarships.filter { $0.countries.contains(country.name) }
    }
    
    /// Get jobs filtered by current country
    func getJobsForCurrentCountry() -> [JobListing] {
        guard let country = currentCountry else { return jobs }
        return jobs.filter { $0.location.lowercased().contains(country.name.lowercased()) }
    }
    
    /// Get country info by ID
    func getCountryInfo(by countryCode: String) -> Country? {
        countries.first { $0.id == countryCode }
    }
    
    /// Load default country data as fallback
    private func loadDefaultCountryData(for country: DestinationCountry) async {
        switch country {
        case .japan:
            await loadDefaultJapanData()
        case .australia:
            await loadDefaultAustraliaData()
        case .canada:
            await loadDefaultCanadaData()
        case .germany:
            await loadDefaultGermanyData()
        case .uk:
            await loadDefaultUKData()
        case .usa:
            await loadDefaultUSAData()
        default:
            // For other countries, use generic data
            countryUniversities = universities.filter { 
                $0.country.lowercased() == country.name.lowercased() 
            }.map { uni in
                CountryUniversity(
                    id: uni.id,
                    title: uni.title,
                    japaneseName: nil,
                    location: uni.location,
                    country: uni.country,
                    type: "University",
                    description: uni.description,
                    image: uni.image,
                    rating: uni.rating,
                    programs: uni.programs,
                    annualFee: uni.annualFee,
                    annualFeeUsd: nil,
                    ranking: uni.ranking,
                    website: uni.website,
                    accreditation: uni.accreditation,
                    studentCount: uni.studentCount,
                    internationalStudents: nil,
                    foundedYear: uni.foundedYear,
                    englishPrograms: true,
                    scholarshipAvailable: true,
                    dormitoryAvailable: true,
                    applicationDeadlines: nil,
                    entryRequirements: nil
                )
            }
        }
    }
    
    // MARK: - Default Japan Data
    
    private func loadDefaultJapanData() async {
        countryOverview = CountryOverview(
            flag: "🇯🇵",
            capital: "Tokyo",
            currency: "JPY",
            currencySymbol: "¥",
            officialLanguage: "Japanese",
            timezone: "JST (UTC+9)",
            countryCodePhone: "+81",
            academicYear: "April - March",
            popularIntakes: ["April", "October"],
            internationalStudents: 312000,
            universitiesCount: 800,
            description: "Japan offers world-class education with cutting-edge technology, rich cultural experiences, and excellent career opportunities.",
            whyStudyHere: [
                "World-renowned universities",
                "Cutting-edge technology",
                "Safe environment",
                "MEXT scholarships",
                "Part-time work (28 hrs/week)"
            ]
        )
        
        // Convert existing Japan universities to CountryUniversity format
        countryUniversities = universities.filter { $0.country == "Japan" }.map { uni in
            CountryUniversity(
                id: uni.id,
                title: uni.title,
                japaneseName: nil,
                location: uni.location,
                country: uni.country,
                type: "National",
                description: uni.description,
                image: uni.image,
                rating: uni.rating,
                programs: uni.programs,
                annualFee: uni.annualFee,
                annualFeeUsd: "$3,600",
                ranking: uni.ranking,
                website: uni.website,
                accreditation: uni.accreditation,
                studentCount: uni.studentCount,
                internationalStudents: nil,
                foundedYear: uni.foundedYear,
                englishPrograms: true,
                scholarshipAvailable: true,
                dormitoryAvailable: true,
                applicationDeadlines: ApplicationDeadlines(
                    aprilIntake: "November",
                    octoberIntake: "April",
                    septemberIntake: nil
                ),
                entryRequirements: EntryRequirements(
                    undergraduate: "12 years education, EJU/JLPT N2",
                    graduate: "16 years education, research plan"
                )
            )
        }
    }
    
    private func loadDefaultAustraliaData() async {
        countryOverview = CountryOverview(
            flag: "🇦🇺",
            capital: "Canberra",
            currency: "AUD",
            currencySymbol: "$",
            officialLanguage: "English",
            timezone: "AEST (UTC+10)",
            countryCodePhone: "+61",
            academicYear: "February - November",
            popularIntakes: ["February", "July"],
            internationalStudents: 758000,
            universitiesCount: 43,
            description: "Australia offers world-class education, beautiful landscapes, and excellent post-study work opportunities.",
            whyStudyHere: [
                "World-class universities",
                "Post-study work visa (2-4 years)",
                "Multicultural environment",
                "High living standards",
                "Part-time work allowed"
            ]
        )
        
        countryUniversities = universities.filter { $0.country == "Australia" }.map { uni in
            CountryUniversity(
                id: uni.id,
                title: uni.title,
                japaneseName: nil,
                location: uni.location,
                country: uni.country,
                type: uni.accreditation ?? "University",
                description: uni.description,
                image: uni.image,
                rating: uni.rating,
                programs: uni.programs,
                annualFee: uni.annualFee,
                annualFeeUsd: nil,
                ranking: uni.ranking,
                website: uni.website,
                accreditation: uni.accreditation,
                studentCount: uni.studentCount,
                internationalStudents: nil,
                foundedYear: uni.foundedYear,
                englishPrograms: true,
                scholarshipAvailable: true,
                dormitoryAvailable: true,
                applicationDeadlines: nil,
                entryRequirements: nil
            )
        }
    }
    
    private func loadDefaultCanadaData() async {
        countryOverview = CountryOverview(
            flag: "🇨🇦",
            capital: "Ottawa",
            currency: "CAD",
            currencySymbol: "$",
            officialLanguage: "English, French",
            timezone: "Multiple zones",
            countryCodePhone: "+1",
            academicYear: "September - April",
            popularIntakes: ["September", "January"],
            internationalStudents: 807000,
            universitiesCount: 100,
            description: "Canada offers affordable, high-quality education with excellent immigration pathways.",
            whyStudyHere: [
                "Affordable tuition",
                "Immigration pathways (PGWP)",
                "Safe and welcoming",
                "Co-op programs",
                "Work during study (20 hrs/week)"
            ]
        )
        
        countryUniversities = universities.filter { $0.country == "Canada" }.map { uni in
            CountryUniversity(
                id: uni.id,
                title: uni.title,
                japaneseName: nil,
                location: uni.location,
                country: uni.country,
                type: "University",
                description: uni.description,
                image: uni.image,
                rating: uni.rating,
                programs: uni.programs,
                annualFee: uni.annualFee,
                annualFeeUsd: nil,
                ranking: uni.ranking,
                website: uni.website,
                accreditation: uni.accreditation,
                studentCount: uni.studentCount,
                internationalStudents: nil,
                foundedYear: uni.foundedYear,
                englishPrograms: true,
                scholarshipAvailable: true,
                dormitoryAvailable: true,
                applicationDeadlines: nil,
                entryRequirements: nil
            )
        }
    }
    
    private func loadDefaultGermanyData() async {
        countryOverview = CountryOverview(
            flag: "🇩🇪",
            capital: "Berlin",
            currency: "EUR",
            currencySymbol: "€",
            officialLanguage: "German",
            timezone: "CET (UTC+1)",
            countryCodePhone: "+49",
            academicYear: "October - July",
            popularIntakes: ["October", "April"],
            internationalStudents: 416000,
            universitiesCount: 400,
            description: "Germany offers free or low-cost education at world-class universities.",
            whyStudyHere: [
                "Free/low tuition",
                "Strong economy",
                "Engineering excellence",
                "18-month job seeker visa",
                "Central European location"
            ]
        )
        
        countryUniversities = universities.filter { $0.country == "Germany" }.map { uni in
            CountryUniversity(
                id: uni.id,
                title: uni.title,
                japaneseName: nil,
                location: uni.location,
                country: uni.country,
                type: "Technical University",
                description: uni.description,
                image: uni.image,
                rating: uni.rating,
                programs: uni.programs,
                annualFee: uni.annualFee,
                annualFeeUsd: nil,
                ranking: uni.ranking,
                website: uni.website,
                accreditation: uni.accreditation,
                studentCount: uni.studentCount,
                internationalStudents: nil,
                foundedYear: uni.foundedYear,
                englishPrograms: true,
                scholarshipAvailable: true,
                dormitoryAvailable: true,
                applicationDeadlines: nil,
                entryRequirements: nil
            )
        }
    }
    
    private func loadDefaultUKData() async {
        countryOverview = CountryOverview(
            flag: "🇬🇧",
            capital: "London",
            currency: "GBP",
            currencySymbol: "£",
            officialLanguage: "English",
            timezone: "GMT/BST",
            countryCodePhone: "+44",
            academicYear: "September - June",
            popularIntakes: ["September", "January"],
            internationalStudents: 679000,
            universitiesCount: 160,
            description: "The UK offers world-renowned education with globally recognized degrees.",
            whyStudyHere: [
                "World-class universities",
                "2-year Graduate Route visa",
                "Global degree recognition",
                "Rich cultural heritage",
                "Research opportunities"
            ]
        )
        
        countryUniversities = universities.filter { $0.country == "United Kingdom" }.map { uni in
            CountryUniversity(
                id: uni.id,
                title: uni.title,
                japaneseName: nil,
                location: uni.location,
                country: uni.country,
                type: uni.accreditation ?? "University",
                description: uni.description,
                image: uni.image,
                rating: uni.rating,
                programs: uni.programs,
                annualFee: uni.annualFee,
                annualFeeUsd: nil,
                ranking: uni.ranking,
                website: uni.website,
                accreditation: uni.accreditation,
                studentCount: uni.studentCount,
                internationalStudents: nil,
                foundedYear: uni.foundedYear,
                englishPrograms: true,
                scholarshipAvailable: true,
                dormitoryAvailable: true,
                applicationDeadlines: nil,
                entryRequirements: nil
            )
        }
    }
    
    private func loadDefaultUSAData() async {
        countryOverview = CountryOverview(
            flag: "🇺🇸",
            capital: "Washington D.C.",
            currency: "USD",
            currencySymbol: "$",
            officialLanguage: "English",
            timezone: "Multiple zones",
            countryCodePhone: "+1",
            academicYear: "August - May",
            popularIntakes: ["Fall (August)", "Spring (January)"],
            internationalStudents: 1057000,
            universitiesCount: 4000,
            description: "The USA has the world's largest higher education system with top-ranked universities.",
            whyStudyHere: [
                "Top-ranked universities",
                "Innovation hub",
                "OPT/STEM OPT work options",
                "Diverse campuses",
                "Research excellence"
            ]
        )
        
        countryUniversities = universities.filter { $0.country == "United States" || $0.country == "USA" }.map { uni in
            CountryUniversity(
                id: uni.id,
                title: uni.title,
                japaneseName: nil,
                location: uni.location,
                country: uni.country,
                type: "University",
                description: uni.description,
                image: uni.image,
                rating: uni.rating,
                programs: uni.programs,
                annualFee: uni.annualFee,
                annualFeeUsd: nil,
                ranking: uni.ranking,
                website: uni.website,
                accreditation: uni.accreditation,
                studentCount: uni.studentCount,
                internationalStudents: nil,
                foundedYear: uni.foundedYear,
                englishPrograms: true,
                scholarshipAvailable: true,
                dormitoryAvailable: true,
                applicationDeadlines: nil,
                entryRequirements: nil
            )
        }
    }
}

// MARK: - Data Error

enum DataError: Error {
    case invalidURL
    case networkError
    case parseError
    case notFound
    
    var localizedDescription: String {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .networkError: return "Network error occurred"
        case .parseError: return "Failed to parse data"
        case .notFound: return "Data not found"
        }
    }
}
