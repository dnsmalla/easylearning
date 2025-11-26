//
//  HelpSupportView.swift
//  NPLearn
//
//  Help and support with FAQs and contact options
//

import SwiftUI

// MARK: - Help & Support View

struct HelpSupportView: View {
    @State private var selectedSection: HelpSection? = nil
    @State private var searchText = ""
    
    enum HelpSection: String, CaseIterable {
        case gettingStarted = "Getting Started"
        case features = "Features"
        case account = "Account"
        case learning = "Learning Tips"
        case technical = "Technical"
        case privacy = "Privacy & Safety"
        
        var icon: String {
            switch self {
            case .gettingStarted: return "flag.fill"
            case .features: return "star.fill"
            case .account: return "person.fill"
            case .learning: return "brain.head.profile"
            case .technical: return "wrench.fill"
            case .privacy: return "lock.shield.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .gettingStarted: return AppTheme.success
            case .features: return AppTheme.brandPrimary
            case .account: return AppTheme.vocabularyColor
            case .learning: return AppTheme.grammarColor
            case .technical: return AppTheme.info
            case .privacy: return AppTheme.warning
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppTheme.brandPrimary)
                    
                    Text("How can we help?")
                        .font(AppTheme.Typography.title)
                    
                    Text("Find answers to common questions")
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.mutedText)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 20)
                
                // Quick Actions
                VStack(spacing: 12) {
                    NavigationLink {
                        HowToUseView()
                    } label: {
                        QuickActionCard(
                            icon: "book.fill",
                            title: "How to Use",
                            subtitle: "Step-by-step guide",
                            color: AppTheme.vocabularyColor
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink {
                        FeaturesGuideView()
                    } label: {
                        QuickActionCard(
                            icon: "sparkles",
                            title: "App Features",
                            subtitle: "Explore what you can do",
                            color: AppTheme.brandPrimary
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                
                // Help Sections
                VStack(alignment: .leading, spacing: 16) {
                    Text("Browse by Topic")
                        .font(AppTheme.Typography.title2)
                        .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 12) {
                        ForEach(HelpSection.allCases, id: \.self) { section in
                            NavigationLink {
                                HelpSectionDetailView(section: section)
                            } label: {
                                HelpSectionCard(section: section)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                }
                
                // Contact Support
                VStack(spacing: 16) {
                    Text("Still Need Help?")
                        .font(AppTheme.Typography.title2)
                    
                    ContactSupportCard()
                }
                .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                .padding(.top, 8)
            }
            .padding(.vertical, 24)
        }
        .background(AppTheme.background)
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Quick Action Card

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.mutedText)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.mutedText)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }
}

// MARK: - Help Section Card

struct HelpSectionCard: View {
    let section: HelpSupportView.HelpSection
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(section.color.opacity(0.15))
                    .frame(width: 60, height: 60)
                
                Image(systemName: section.icon)
                    .font(.system(size: 28))
                    .foregroundColor(section.color)
            }
            
            Text(section.rawValue)
                .font(AppTheme.Typography.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }
}

// MARK: - Contact Support Card

struct ContactSupportCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("We're here to help!")
                .font(AppTheme.Typography.headline)
            
            Text("Have a question that's not answered here? Get in touch with our support team.")
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.mutedText)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                Button(action: {
                    // Open email
                    if let url = URL(string: "mailto:support@nplearn.app") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "envelope.fill")
                        Text("Email Support")
                    }
                    .font(AppTheme.Typography.button)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: AppTheme.Controls.buttonHeight)
                    .background(AppTheme.brandPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Text("support@nplearn.app")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.mutedText)
            }
        }
        .padding()
        .background(AppTheme.brandPrimary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.brandPrimary.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Help Section Detail View

struct HelpSectionDetailView: View {
    let section: HelpSupportView.HelpSection
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Section Header
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(section.color.opacity(0.15))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: section.icon)
                            .font(.system(size: 28))
                            .foregroundColor(section.color)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(section.rawValue)
                            .font(AppTheme.Typography.title2)
                        
                        Text(sectionDescription)
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.mutedText)
                    }
                }
                .padding(.horizontal, AppTheme.Layout.horizontalPadding)
                .padding(.top, 16)
                
                // FAQs
                VStack(spacing: 12) {
                    ForEach(getFAQs(), id: \.question) { faq in
                        FAQCard(faq: faq)
                    }
                }
                .padding(.horizontal, AppTheme.Layout.horizontalPadding)
            }
            .padding(.vertical, 24)
        }
        .background(AppTheme.background)
        .navigationTitle(section.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var sectionDescription: String {
        switch section {
        case .gettingStarted: return "Start your Nepali learning journey"
        case .features: return "Discover all app features"
        case .account: return "Manage your account"
        case .learning: return "Tips for effective learning"
        case .technical: return "Troubleshoot issues"
        case .privacy: return "Your data and privacy"
        }
    }
    
    func getFAQs() -> [FAQ] {
        switch section {
        case .gettingStarted:
            return [
                FAQ(question: "How do I start learning Nepali?",
                    answer: "Welcome! Start by:\n1. Complete the onboarding if you haven't\n2. Go to Home tab and select your level (Beginner, Intermediate, or Advanced)\n3. Choose a category (Vocabulary, Grammar, etc.)\n4. Start practicing!\n\nFor complete beginners, we recommend starting with the Devanagari practice to learn the Nepali script."),
                
                FAQ(question: "What's the best way to begin as a complete beginner?",
                    answer: "For complete beginners:\n1. Start with Devanagari Practice (Home → New to Nepali?)\n2. Learn vowels and consonants first\n3. Practice writing characters\n4. Move to Beginner level vocabulary\n5. Practice 10-15 minutes daily\n\nConsistency is more important than long study sessions!"),
                
                FAQ(question: "Do I need to create an account?",
                    answer: "No! You can use the app in Guest Mode. However, creating an account lets you:\n• Sync progress across devices\n• Track your learning streak\n• Earn achievements\n• Save favorite words\n\nYou can sign up with email or Apple Sign In."),
                
                FAQ(question: "Can I use the app offline?",
                    answer: "Yes! Most features work offline:\n✓ Vocabulary practice\n✓ Grammar lessons\n✓ Flashcards\n✓ Games\n✓ Devanagari practice\n\nFeatures requiring internet:\n• Audio pronunciation (first time)\n• Account sync\n• Updates")
            ]
            
        case .features:
            return [
                FAQ(question: "What learning features are available?",
                    answer: "NPLearn offers comprehensive features:\n\n📚 Vocabulary\n• 500+ words per level\n• Audio pronunciations\n• Example sentences\n• Spaced repetition\n\n📖 Grammar\n• Sentence structures\n• Verb conjugations\n• Grammar points\n• Practice exercises\n\n🎧 Listening\n• Native speaker audio\n• Comprehension exercises\n• Speed control\n\n🗣️ Speaking\n• Pronunciation practice\n• Voice recording\n• Feedback\n\n✍️ Writing\n• Devanagari practice\n• Character tracing\n• Sentence writing\n\n📄 Reading\n• Stories and texts\n• Progressive difficulty\n• Comprehension questions"),
                
                FAQ(question: "How do the games work?",
                    answer: "Games make learning fun!\n\n🎮 Available Games:\n• Word Match - Match Nepali with English\n• Sentence Builder - Construct sentences\n• Memory Cards - Test your memory\n• Quick Quiz - Rapid-fire questions\n\nGames help reinforce what you've learned through interactive play!"),
                
                FAQ(question: "What are flashcards?",
                    answer: "Flashcards use spaced repetition for effective memorization:\n\n• Tap to flip and reveal meaning\n• Mark as 'Got it' or 'Need review'\n• Cards you struggle with appear more often\n• Track your mastery progress\n\nBest practice: Review flashcards daily for 5-10 minutes!"),
                
                FAQ(question: "How does progress tracking work?",
                    answer: "Track your journey:\n\n⭐ Points - Earn points for completing lessons\n🔥 Streak - Maintain daily study streak\n✅ Lessons - See completed lessons\n🏆 Achievements - Unlock milestones\n📊 Progress - View category progress\n\nCheck your Profile tab to see all stats!")
            ]
            
        case .account:
            return [
                FAQ(question: "How do I create an account?",
                    answer: "Create an account easily:\n\n1. From sign-in screen, choose:\n   • Email & Password (tap Sign Up)\n   • Sign in with Apple\n\n2. Fill in details\n3. Start learning!\n\nOr use Guest Mode to try the app first."),
                
                FAQ(question: "How do I change my password?",
                    answer: "To change your password:\n\n1. Sign out of your account\n2. On sign-in screen, tap 'Forgot Password'\n3. Enter your email\n4. Check email for reset link\n5. Create new password\n\nNote: Apple Sign In users don't have a password to change."),
                
                FAQ(question: "How do I delete my account?",
                    answer: "To permanently delete your account:\n\n1. Go to Profile tab\n2. Scroll to Account section\n3. Tap 'Delete Account'\n4. Confirm deletion\n\n⚠️ Warning: This action is permanent and will delete:\n• All progress\n• Saved words\n• Achievements\n• Learning history\n\nYou can create a new account anytime."),
                
                FAQ(question: "Can I use the same account on multiple devices?",
                    answer: "Yes! If you sign in with email or Apple ID:\n\n✓ Progress syncs automatically\n✓ Works on iPhone and iPad\n✓ Same account, all devices\n\nGuest Mode data stays on one device only.")
            ]
            
        case .learning:
            return [
                FAQ(question: "How much should I practice daily?",
                    answer: "Recommended practice:\n\n🌟 Beginner: 10-15 minutes daily\n🌟 Intermediate: 15-25 minutes daily\n🌟 Advanced: 20-30 minutes daily\n\nQuality over quantity! Consistent short sessions beat occasional long ones.\n\nTry this routine:\n• 5 min - Review flashcards\n• 5 min - New lesson\n• 5 min - Practice game\n• 5 min - Writing practice"),
                
                FAQ(question: "What's the best learning strategy?",
                    answer: "Effective learning tips:\n\n1️⃣ Start with Devanagari\n   Learn the script first!\n\n2️⃣ Use spaced repetition\n   Review regularly, not all at once\n\n3️⃣ Practice all skills\n   Don't just focus on vocabulary\n\n4️⃣ Listen actively\n   Use audio features often\n\n5️⃣ Write by hand\n   Use writing practice feature\n\n6️⃣ Stay consistent\n   Daily practice > long sessions\n\n7️⃣ Use games\n   Make learning fun!"),
                
                FAQ(question: "How do I stay motivated?",
                    answer: "Stay motivated:\n\n🔥 Build a streak\n   Don't break the chain!\n\n🎯 Set small goals\n   One lesson a day is enough\n\n🏆 Track achievements\n   Watch your progress grow\n\n🎮 Play games\n   Learning should be fun\n\n👥 Imagine conversations\n   Think about using Nepali in real life\n\n⏰ Same time daily\n   Make it a habit"),
                
                FAQ(question: "Which level should I choose?",
                    answer: "Choose your level:\n\n🔰 Beginner\n• Never learned Nepali\n• Don't know Devanagari\n• Want to start from basics\n\n🔶 Intermediate\n• Know basic vocabulary (100+ words)\n• Can read Devanagari\n• Understand simple sentences\n\n🔴 Advanced\n• Conversational ability\n• Know grammar structures\n• Want to refine skills\n\nYou can change levels anytime!")
            ]
            
        case .technical:
            return [
                FAQ(question: "The app won't load. What should I do?",
                    answer: "Try these steps:\n\n1. Check internet connection\n2. Force close and reopen app\n3. Restart your device\n4. Update to latest iOS version\n5. Update app from App Store\n6. Reinstall app (data will be saved if you have an account)\n\nStill having issues? Contact support@nplearn.app"),
                
                FAQ(question: "Audio isn't working",
                    answer: "Audio troubleshooting:\n\n✓ Check device volume\n✓ Turn off silent mode\n✓ Check app permissions (Settings → NPLearn)\n✓ Try headphones\n✓ Restart app\n✓ Ensure internet connection (first time)\n\nAudio is downloaded for offline use after first play."),
                
                FAQ(question: "My progress isn't syncing",
                    answer: "Progress sync issues:\n\n1. Check internet connection\n2. Verify you're signed in (not Guest Mode)\n3. Force close and reopen app\n4. Sign out and sign back in\n5. Wait a few minutes for sync\n\nGuest Mode data doesn't sync. Create an account to sync across devices."),
                
                FAQ(question: "App is slow or crashing",
                    answer: "Performance tips:\n\n1. Close other apps\n2. Restart your device\n3. Free up storage space\n4. Update iOS\n5. Update app\n6. Reinstall app\n\nMinimum requirements:\n• iOS 15.0 or later\n• 100MB free space\n• iPhone 8 or newer recommended")
            ]
            
        case .privacy:
            return [
                FAQ(question: "What data do you collect?",
                    answer: "We collect minimal data:\n\n📊 Learning Data:\n• Progress and scores\n• Completed lessons\n• Practice history\n• Preferences\n\n👤 Account Data:\n• Email (if provided)\n• Display name\n• Sign-in method\n\n🚫 We DON'T collect:\n• Location data\n• Contacts\n• Photos\n• Personal messages\n• Payment info (app is free)"),
                
                FAQ(question: "Is my data secure?",
                    answer: "Yes! We prioritize security:\n\n🔒 Encryption\n   All data is encrypted\n\n🔐 Firebase Security\n   Industry-standard protection\n\n📱 Local Storage\n   Most data stored on your device\n\n🚫 No Selling\n   We never sell your data\n\n✅ Apple Guidelines\n   Following all privacy rules"),
                
                FAQ(question: "Can I export my data?",
                    answer: "Currently, you can:\n\n✓ View progress in Profile\n✓ Screenshot your stats\n✓ See all saved words\n\nFull data export feature coming soon! You'll be able to download all your learning data."),
                
                FAQ(question: "What happens when I delete my account?",
                    answer: "Account deletion:\n\n🗑️ Immediately Deleted:\n• Account credentials\n• Profile information\n• All progress data\n• Saved vocabulary\n• Achievements\n\n⚠️ This is permanent and cannot be undone!\n\nYou can create a new account anytime, but will start fresh.")
            ]
        }
    }
}

// MARK: - FAQ Model & Card

struct FAQ {
    let question: String
    let answer: String
}

struct FAQCard: View {
    let faq: FAQ
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(faq.question)
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.brandPrimary)
                }
            }
            
            if isExpanded {
                Text(faq.answer)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.mutedText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }
}

#Preview {
    NavigationStack {
        HelpSupportView()
    }
}

