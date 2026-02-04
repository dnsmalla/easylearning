//
//  HomeView.swift
//  SKLearn
//
//  Main home screen with level selection and study materials
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var learningDataService: LearningDataService
    @EnvironmentObject var authService: AuthService
    @State private var showDevanagariPractice = false
    
    /// Builds a count label from loaded content; shows actual count only (or "—" when none).
    private func countLabel(_ count: Int, unit: String) -> String {
        if count > 0 { return "\(count) \(unit)" }
        return "—"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header Section
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("नमस्ते!")
                                    .font(AppTheme.Typography.sanskritDisplay)
                                    .foregroundColor(AppTheme.brandPrimary)
                                
                                Text("Sanskrit Learning")
                                    .font(AppTheme.Typography.title2)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            // Profile Button
                            NavigationLink {
                                ProfileView()
                            } label: {
                                Circle()
                                    .fill(AppTheme.brandPrimary.opacity(0.1))
                                    .frame(width: 44, height: 44)
                                    .overlay {
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(AppTheme.brandPrimary)
                                    }
                            }
                        }
                        
                        // New to Sanskrit Card
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("New to Sanskrit?")
                                    .font(AppTheme.Typography.headline)
                                    .foregroundColor(.primary)
                                
                                Text("Begin your journey with Sanskrit alphabet")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.mutedText)
                            }
                            
                            Spacer()
                            
                            Button {
                                showDevanagariPractice = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "book.fill")
                                    Text("Practice")
                                }
                                .font(AppTheme.Typography.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(AppTheme.brandPrimary)
                                .clipShape(Capsule())
                            }
                        }
                        .padding()
                        .background(AppTheme.brandPrimary.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius)
                                .stroke(AppTheme.brandPrimary.opacity(0.1), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                    .background(Color.white)
                    
                    // Level Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Level Selection")
                            .font(AppTheme.Typography.title2)
                            .foregroundColor(.primary)
                            .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(LearningLevel.allCases, id: \.self) { level in
                                    LevelCard(
                                        level: level,
                                        isSelected: learningDataService.currentLevel == level
                                    ) {
                                        Task {
                                            await learningDataService.setLevel(level)
                                            Haptics.selection()
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                        }
                    }
                    .padding(.vertical, 24)
                    
                    // Study Materials Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Study Materials")
                                .font(AppTheme.Typography.title2)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            // Level Badge
                            Text("Level \(learningDataService.currentLevel.rawValue)")
                                .font(AppTheme.Typography.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(AppTheme.brandPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(AppTheme.brandPrimary.opacity(0.1))
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 12) {
                            StudyMaterialCard(
                                title: "Vocabulary",
                                icon: "book.closed.fill",
                                color: AppTheme.vocabularyColor,
                                count: countLabel(learningDataService.flashcards.count, unit: "words"),
                                destination: AnyView(CategoryPracticeView(category: .vocabulary))
                            )
                            
                            StudyMaterialCard(
                                title: "Grammar",
                                icon: "text.book.closed.fill",
                                color: AppTheme.grammarColor,
                                count: countLabel(learningDataService.grammarPoints.count, unit: "points"),
                                destination: AnyView(CategoryPracticeView(category: .grammar))
                            )
                            
                            StudyMaterialCard(
                                title: "Listening",
                                icon: "headphones",
                                color: AppTheme.listeningColor,
                                count: countLabel(learningDataService.practiceQuestions.filter { $0.category == .listening }.count, unit: "exercises"),
                                destination: AnyView(CategoryPracticeView(category: .listening))
                            )
                            
                            StudyMaterialCard(
                                title: "Speaking",
                                icon: "mic.fill",
                                color: AppTheme.speakingColor,
                                count: countLabel(learningDataService.speakingExercises.count, unit: "exercises"),
                                destination: AnyView(SpeakingPracticeView())
                            )
                            
                            StudyMaterialCard(
                                title: "Writing",
                                icon: "pencil",
                                color: AppTheme.writingColor,
                                count: countLabel(learningDataService.writingExercises.count, unit: "exercises"),
                                destination: AnyView(WritingSentencePracticeView())
                            )
                            
                            StudyMaterialCard(
                                title: "Reading",
                                icon: "doc.text.fill",
                                color: AppTheme.readingColor,
                                count: countLabel(learningDataService.readingPassages.count, unit: "texts"),
                                destination: AnyView(ReadingPracticeView())
                            )
                        }
                        .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                    }
                    .padding(.bottom, 24)
                    
                    // Tools Section (Translation & Search)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Tools")
                            .font(AppTheme.Typography.title2)
                            .foregroundColor(.primary)
                            .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 12) {
                            StudyMaterialCard(
                                title: "Translate",
                                icon: "globe",
                                color: AppTheme.brandAccent,
                                count: "Sanskrit ↔ English",
                                destination: AnyView(TranslationView())
                            )
                            
                            StudyMaterialCard(
                                title: "Search",
                                icon: "magnifyingglass",
                                color: AppTheme.brandPurple,
                                count: "Find Words",
                                destination: AnyView(WebSearchView())
                            )
                        }
                        .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                    }
                    .padding(.bottom, 24)
                }
            }
            .background(AppTheme.background)
            .navigationBarHidden(true)
            .sheet(isPresented: $showDevanagariPractice) {
                DevanagariPracticeView()
            }
        }
    }
}

// MARK: - Level Card

struct LevelCard: View {
    let level: LearningLevel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Level Badge
                Text(level.rawValue)
                    .font(AppTheme.Typography.headline)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : AppTheme.brandPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(isSelected ? AppTheme.brandPrimary : AppTheme.brandPrimary.opacity(0.1))
                    .clipShape(Capsule())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.title)
                        .font(AppTheme.Typography.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(level.description)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.mutedText)
                }
            }
            .frame(width: 160)
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius)
                    .stroke(isSelected ? AppTheme.brandPrimary : Color.clear, lineWidth: 2)
            )
            .shadow(
                color: isSelected ? AppTheme.brandPrimary.opacity(0.2) : Color.black.opacity(0.08),
                radius: 8,
                y: 4
            )
        }
    }
}

// MARK: - Study Material Card

struct StudyMaterialCard: View {
    let title: String
    let icon: String
    let color: Color
    let count: String
    let destination: AnyView
    
    var body: some View {
        NavigationLink {
            destination
        } label: {
            VStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.primary)
                    
                    Text(count)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.mutedText)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius))
            .shadow(
                color: Color.black.opacity(0.08),
                radius: 8,
                y: 4
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Devanagari Practice View

struct DevanagariPracticeView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab: DevanagariTab = .vowels
    @State private var selectedCharacter: DevanagariCharacter? = nil
    
    enum DevanagariTab: String, CaseIterable {
        case vowels = "Vowels"
        case consonants = "Consonants"
        case numerals = "Numerals"
        case practice = "Practice"
        
        var icon: String {
            switch self {
            case .vowels: return "a.circle.fill"
            case .consonants: return "k.circle.fill"
            case .numerals: return "number.circle.fill"
            case .practice: return "pencil.circle.fill"
            }
        }
        
        var sanskritName: String {
            switch self {
            case .vowels: return "स्वर"
            case .consonants: return "व्यंजन"
            case .numerals: return "अंक"
            case .practice: return "अभ्यास"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                Text("देवनागरी")
                    .font(AppTheme.Typography.sanskritDisplay)
                    .foregroundColor(AppTheme.brandPrimary)
                
                    Text("Devanagari Script")
                        .font(AppTheme.Typography.title3)
                        .foregroundColor(AppTheme.mutedText)
                }
                .padding(.top, 16)
                .padding(.bottom, 20)
                
                // Tab Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(DevanagariTab.allCases, id: \.self) { tab in
                            TabButton(
                                tab: tab,
                                isSelected: selectedTab == tab,
                                action: { selectedTab = tab }
                            )
                        }
                    }
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                }
                .padding(.bottom, 16)
                
                Divider()
                
                // Content
                ScrollView {
                    switch selectedTab {
                    case .vowels:
                        VowelsView(selectedCharacter: $selectedCharacter)
                    case .consonants:
                        ConsonantsView(selectedCharacter: $selectedCharacter)
                    case .numerals:
                        NumeralsView()
                    case .practice:
                        DevanagariPracticeTabView()
                    }
                }
            }
            .background(AppTheme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.brandPrimary)
                }
            }
        }
    }
}

// MARK: - Tab Button

struct TabButton: View {
    let tab: DevanagariPracticeView.DevanagariTab
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20))
                
                Text(tab.rawValue)
                    .font(AppTheme.Typography.caption)
                
                Text(tab.sanskritName)
                    .font(AppTheme.Typography.caption) // Changed from caption2 for better readability
            }
            .frame(width: 80)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? AppTheme.brandPrimary : AppTheme.secondaryBackground)
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
    }
}

// MARK: - Devanagari Character Model

struct DevanagariCharacter: Identifiable {
    let id = UUID()
    let character: String
    let romanization: String
    let type: CharacterType
    let description: String?
    
    enum CharacterType {
        case independentVowel
        case dependentVowel
        case consonant
        case numeral
    }
}

// MARK: - Vowels View

struct VowelsView: View {
    @Binding var selectedCharacter: DevanagariCharacter?
    @StateObject private var audioService = AudioService.shared
    
    // Sanskrit Devanagari alphabet
    let independentVowels: [(String, String)] = [
        ("अ", "a"), ("आ", "aa"), ("इ", "i"), ("ई", "ii"),
        ("उ", "u"), ("ऊ", "uu"), ("ऋ", "ri"), ("ॠ", "rr"),
        ("ए", "e"), ("ऐ", "ai"), ("ओ", "o"), ("औ", "au"),
        ("अं", "am"), ("अः", "ah")
    ]
    
    let dependentVowels: [(String, String)] = [
        ("ा", "aa"), ("ि", "i"), ("ी", "ii"), ("ु", "u"),
        ("ू", "uu"), ("ृ", "ri"), ("ॄ", "rr"), ("े", "e"),
        ("ै", "ai"), ("ो", "o"), ("ौ", "au"), ("ं", "m"), ("ः", "h")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Info Card
            VStack(alignment: .leading, spacing: 8) {
                Text("स्वर (Swar)")
                    .font(AppTheme.Typography.title2)
                    .foregroundColor(AppTheme.brandPrimary)
                
                Text("Vowels in Sanskrit")
                    .font(AppTheme.Typography.headline)
                
                Text("Tap any character to hear its pronunciation. Sanskrit vowels are fundamental to the language.")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.mutedText)
            }
            .cardStyle()
            .padding(.horizontal, AppTheme.Layout.horizontalPadding)
            .padding(.top, 16)
            
            // Independent Vowels
            VStack(alignment: .leading, spacing: 12) {
                Text("Independent Vowels")
                    .font(AppTheme.Typography.headline)
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 70), spacing: 12)
                ], spacing: 12) {
                    ForEach(independentVowels, id: \.0) { vowel in
                        CharacterCard(
                            character: vowel.0,
                            romanization: vowel.1,
                            color: AppTheme.vocabularyColor
                        ) {
                            Haptics.selection()
                            Task {
                                await audioService.speak(text: vowel.0, language: "sa")
                            }
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Layout.horizontalPadding)
            }
            
            // Dependent Vowels
            VStack(alignment: .leading, spacing: 12) {
                Text("Dependent Vowels")
                    .font(AppTheme.Typography.headline)
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                
                Text("These combine with consonants - tap to hear")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.mutedText)
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 70), spacing: 12)
                ], spacing: 12) {
                    ForEach(dependentVowels, id: \.0) { vowel in
                        CharacterCard(
                            character: "क\(vowel.0)",
                            romanization: "k\(vowel.1)",
                            color: AppTheme.vocabularyColor.opacity(0.7)
                        ) {
                            Haptics.selection()
                            Task {
                                // Speak the combined character
                                await audioService.speak(text: "क\(vowel.0)", language: "sa")
                            }
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Layout.horizontalPadding)
            }
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
    }
}

// MARK: - Consonants View

struct ConsonantsView: View {
    @Binding var selectedCharacter: DevanagariCharacter?
    @StateObject private var audioService = AudioService.shared
    
    // Sanskrit Devanagari alphabet
    let consonants: [(String, String)] = [
        ("क", "ka"), ("ख", "kha"), ("ग", "ga"), ("घ", "gha"), ("ङ", "nga"),
        ("च", "cha"), ("छ", "chha"), ("ज", "ja"), ("झ", "jha"), ("ञ", "nya"),
        ("ट", "ta"), ("ठ", "tha"), ("ड", "da"), ("ढ", "dha"), ("ण", "na"),
        ("त", "ta"), ("थ", "tha"), ("द", "da"), ("ध", "dha"), ("न", "na"),
        ("प", "pa"), ("फ", "pha"), ("ब", "ba"), ("भ", "bha"), ("म", "ma"),
        ("य", "ya"), ("र", "ra"), ("ल", "la"), ("व", "wa"),
        ("श", "sha"), ("ष", "shha"), ("स", "sa"), ("ह", "ha"),
        ("क्ष", "kshya"), ("त्र", "tra"), ("ज्ञ", "gya")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Info Card
            VStack(alignment: .leading, spacing: 8) {
                Text("व्यंजन (Vyanjan)")
                    .font(AppTheme.Typography.title2)
                    .foregroundColor(AppTheme.brandPrimary)
                
                Text("Consonants in Sanskrit")
                    .font(AppTheme.Typography.headline)
                
                Text("Tap any character to hear its pronunciation. Consonants have an inherent 'a' sound.")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.mutedText)
            }
            .cardStyle()
            .padding(.horizontal, AppTheme.Layout.horizontalPadding)
            .padding(.top, 16)
            
            // Consonants Grid
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 70), spacing: 12)
            ], spacing: 12) {
                ForEach(consonants, id: \.0) { consonant in
                    CharacterCard(
                        character: consonant.0,
                        romanization: consonant.1,
                        color: AppTheme.grammarColor
                    ) {
                        Haptics.selection()
                        Task {
                            await audioService.speak(text: consonant.0, language: "sa")
                        }
                    }
                }
            }
            .padding(.horizontal, AppTheme.Layout.horizontalPadding)
            .padding(.bottom, 24)
        }
    }
}

// MARK: - Numerals View

struct NumeralsView: View {
    @StateObject private var audioService = AudioService.shared
    
    // Sanskrit Devanagari alphabet
    // Sanskrit numerals: (Devanagari digit, romanization, Sanskrit word)
    let numerals: [(String, String, String)] = [
        ("०", "śūnya", "शून्य"),     // 0 - zero
        ("१", "eka", "एक"),          // 1 - one
        ("२", "dve", "द्वे"),         // 2 - two
        ("३", "trīṇi", "त्रीणि"),    // 3 - three
        ("४", "catvāri", "चत्वारि"), // 4 - four
        ("५", "pañca", "पञ्च"),      // 5 - five
        ("६", "ṣaṭ", "षट्"),          // 6 - six
        ("७", "sapta", "सप्त"),      // 7 - seven
        ("८", "aṣṭa", "अष्ट"),       // 8 - eight
        ("९", "nava", "नव")          // 9 - nine
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Info Card
            VStack(alignment: .leading, spacing: 8) {
                Text("अंक (Anka)")
                    .font(AppTheme.Typography.title2)
                    .foregroundColor(AppTheme.brandPrimary)
                
                Text("Sanskrit Numerals")
                    .font(AppTheme.Typography.headline)
                
                Text("Tap any number to hear its pronunciation. Sanskrit has its own numeral system written in Devanagari script.")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.mutedText)
            }
            .cardStyle()
            .padding(.horizontal, AppTheme.Layout.horizontalPadding)
            .padding(.top, 16)
            
            // Numerals Grid
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 80), spacing: 12)
            ], spacing: 12) {
                ForEach(numerals, id: \.0) { numeral in
                    CharacterCard(
                        character: numeral.0,
                        romanization: numeral.1,
                        color: AppTheme.listeningColor,
                        isNumeral: true
                    ) {
                        Haptics.selection()
                        Task {
                            // Speak the number name in Sanskrit/Hindi
                            await audioService.speak(text: numeral.2, language: "sa")
                        }
                    }
                }
            }
            .padding(.horizontal, AppTheme.Layout.horizontalPadding)
            
            // Practice Examples
            VStack(alignment: .leading, spacing: 16) {
                Text("Examples - Tap to hear")
                    .font(AppTheme.Typography.headline)
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                
                VStack(spacing: 12) {
                    NumberExampleRow(
                        sanskrit: "१२३", 
                        english: "123",
                        audioService: audioService,
                        spokenText: "एक द्वे त्रीणि"
                    )
                    NumberExampleRow(
                        sanskrit: "२०२५", 
                        english: "2025",
                        audioService: audioService,
                        spokenText: "द्वे शून्य द्वे पञ्च"
                    )
                    NumberExampleRow(
                        sanskrit: "९८७६५", 
                        english: "98765",
                        audioService: audioService,
                        spokenText: "नव अष्ट सप्त षट् पञ्च"
                    )
                }
                .padding(.horizontal, AppTheme.Layout.horizontalPadding)
            }
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
    }
}

// MARK: - Devanagari Practice Tab View

struct DevanagariPracticeTabView: View {
    @State private var navigateToWriting = false
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Text("Practice Writing")
                    .font(AppTheme.Typography.largeTitle)
                
                Text("Learn to write Sanskrit Devanagari script")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.mutedText)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            // Only Writing Practice Card
            NavigationLink(destination: DevanagariWritingPracticeView()) {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.writingColor.opacity(0.15))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "pencil.tip")
                            .font(.system(size: 36))
                            .foregroundColor(AppTheme.writingColor)
                    }
                    
                    VStack(spacing: 4) {
                        Text("Master Sanskrit Script")
                            .font(AppTheme.Typography.title2)
                            .foregroundColor(.primary)
                        
                        Text("Practice writing Devanagari letters")
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.mutedText)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(AppTheme.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.writingColor.opacity(0.3), lineWidth: 2)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, AppTheme.Layout.horizontalPadding)
            
            Spacer()
        }
        .padding(.vertical, 24)
    }
}

// MARK: - Devanagari Writing Practice View

struct DevanagariWritingPracticeView: View {
    @StateObject private var viewModel = WritingPracticeViewModel()
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with progress
                VStack(spacing: 8) {
                    HStack {
                        Text("Character Practice")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.mutedText)
                        
                        Spacer()
                        
                        Text("\(viewModel.practiceCount) practiced")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.brandPrimary)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                    
                    // Progress indicator
                    Rectangle()
                        .fill(AppTheme.brandPrimary)
                        .frame(height: 4)
                }
                .padding(.top, 8)
                .background(Color.white)
                
                // Character to Practice
                VStack(spacing: 20) {
                    Text("Write this character")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.mutedText)
                    
                    Text(viewModel.currentCharacter)
                        .font(.system(size: 80, weight: .medium))
                        .foregroundColor(AppTheme.brandPrimary)
                    
                    Text("(\(viewModel.currentRomanization))")
                        .font(AppTheme.Typography.title2)
                        .foregroundColor(AppTheme.mutedText.opacity(0.7))
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .background(AppTheme.secondaryBackground)
                
                Divider()
                
                // Drawing Area with lines
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Write on the lines below")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.mutedText)
                        
                        // Lined Canvas
                        ZStack(alignment: .topLeading) {
                            // Guidelines
                            VStack(spacing: 0) {
                                ForEach(0..<8) { index in
                                    HStack {
                                        Spacer()
                                    }
                                    .frame(height: 1)
                                    .background(AppTheme.separator)
                                    .padding(.vertical, 24)
                                }
                            }
                            
                            // Drawing Canvas
                            WritingDrawingCanvasView(
                                lines: $viewModel.lines,
                                currentLine: $viewModel.currentLine
                            )
                            .frame(height: 400)
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppTheme.brandPrimary.opacity(0.3), lineWidth: 2)
                        )
                        .shadow(
                            color: AppTheme.Shadows.elevation2.color,
                            radius: AppTheme.Shadows.elevation2.radius,
                            y: AppTheme.Shadows.elevation2.y
                        )
                    }
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                    .padding(.vertical, 16)
                }
                
                // Action Buttons
                HStack(spacing: 16) {
                    Button(action: {
                        viewModel.clearDrawing()
                        Haptics.selection()
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Clear")
                        }
                        .font(AppTheme.Typography.button)
                        .foregroundColor(AppTheme.mutedText)
                        .frame(maxWidth: .infinity)
                        .frame(height: AppTheme.Controls.buttonHeight)
                        .background(AppTheme.secondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button(action: {
                        viewModel.nextCharacter()
                        Haptics.success()
                    }) {
                        HStack {
                            Text("Next")
                            Image(systemName: "arrow.right")
                        }
                        .font(AppTheme.Typography.button)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: AppTheme.Controls.buttonHeight)
                        .background(AppTheme.brandPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Writing Practice")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Writing Practice ViewModel

class WritingPracticeViewModel: ObservableObject {
    @Published var currentCharacter: String = ""
    @Published var currentRomanization: String = ""
    @Published var lines: [WritingLine] = []
    @Published var currentLine: WritingLine = WritingLine(points: [], color: .black, lineWidth: 3)
    @Published var practiceCount: Int = 0
    
    // All Devanagari characters
    private let vowels: [(String, String)] = [
        ("अ", "a"), ("आ", "aa"), ("इ", "i"), ("ई", "ii"),
        ("उ", "u"), ("ऊ", "uu"), ("ऋ", "ri"), ("ॠ", "rr"),
        ("ए", "e"), ("ऐ", "ai"), ("ओ", "o"), ("औ", "au")
    ]
    
    private let consonants: [(String, String)] = [
        ("क", "ka"), ("ख", "kha"), ("ग", "ga"), ("घ", "gha"), ("ङ", "nga"),
        ("च", "cha"), ("छ", "chha"), ("ज", "ja"), ("झ", "jha"), ("ञ", "nya"),
        ("ट", "ta"), ("ठ", "tha"), ("ड", "da"), ("ढ", "dha"), ("ण", "na"),
        ("त", "ta"), ("थ", "tha"), ("द", "da"), ("ध", "dha"), ("न", "na"),
        ("प", "pa"), ("फ", "pha"), ("ब", "ba"), ("भ", "bha"), ("म", "ma"),
        ("य", "ya"), ("र", "ra"), ("ल", "la"), ("व", "wa"),
        ("श", "sha"), ("ष", "shha"), ("स", "sa"), ("ह", "ha")
    ]
    
    private var allCharacters: [(String, String)] = []
    
    init() {
        allCharacters = vowels + consonants
        selectRandomCharacter()
    }
    
    func selectRandomCharacter() {
        if let random = allCharacters.randomElement() {
            currentCharacter = random.0
            currentRomanization = random.1
        }
    }
    
    func clearDrawing() {
        lines.removeAll()
        currentLine = WritingLine(points: [], color: .black, lineWidth: 3)
    }
    
    func nextCharacter() {
        practiceCount += 1
        clearDrawing()
        selectRandomCharacter()
    }
}

// MARK: - Supporting Views

struct CharacterCard: View {
    let character: String
    let romanization: String
    let color: Color
    var isNumeral: Bool = false
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { action?() }) {
            VStack(spacing: 6) {
                Text(character)
                    .font(.system(size: isNumeral ? 36 : 32))
                    .foregroundColor(.primary)
                
                Text(romanization)
                    .font(AppTheme.Typography.callout) // Changed from caption2 for better readability
                    .foregroundColor(AppTheme.mutedText)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct NumberExampleRow: View {
    let sanskrit: String
    let english: String
    let audioService: AudioService
    let spokenText: String
    
    var body: some View {
        Button(action: {
            Haptics.selection()
            Task {
                await audioService.speak(text: spokenText, language: "sa")
            }
        }) {
            HStack {
                Text(sanskrit)
                    .font(.system(size: 28))
                    .foregroundColor(AppTheme.brandPrimary)
                
                Spacer()
                
                Image(systemName: "speaker.wave.2.fill")
                    .foregroundColor(AppTheme.brandPrimary.opacity(0.6))
                    .font(.system(size: 20))
                
                Spacer()
                
                Text(english)
                    .font(AppTheme.Typography.title3)
                    .foregroundColor(AppTheme.mutedText)
            }
            .padding()
            .background(AppTheme.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FeaturePreviewRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.success)
                .font(.system(size: 20))
            
            Text(text)
                .font(AppTheme.Typography.body)
            
            Spacer()
        }
        .padding()
        .background(AppTheme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HomeView()
        .environmentObject(LearningDataService.shared)
        .environmentObject(AuthService.shared)
}
