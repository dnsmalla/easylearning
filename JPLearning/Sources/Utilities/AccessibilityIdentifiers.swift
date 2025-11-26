//
//  AccessibilityIdentifiers.swift
//  JLearn
//
//  Centralized accessibility identifiers for UI testing
//

import Foundation

enum AccessibilityIdentifiers {
    // MARK: - Authentication
    enum Auth {
        static let emailTextField = "auth.email.textfield"
        static let passwordTextField = "auth.password.textfield"
        static let signInButton = "auth.signin.button"
        static let signUpButton = "auth.signup.button"
        static let appleSignInButton = "auth.apple.button"
    }
    
    // MARK: - Home
    enum Home {
        static let levelSelector = "home.level.selector"
        static let practiceCard = "home.practice.card"
        static let streakBadge = "home.streak.badge"
        static let pointsBadge = "home.points.badge"
    }
    
    // MARK: - Practice
    enum Practice {
        static let categoryGrid = "practice.category.grid"
        static let vocabularyButton = "practice.vocabulary.button"
        static let grammarButton = "practice.grammar.button"
        static let listeningButton = "practice.listening.button"
        static let speakingButton = "practice.speaking.button"
        static let writingButton = "practice.writing.button"
        static let readingButton = "practice.reading.button"
    }
    
    // MARK: - Flashcards
    enum Flashcards {
        static let list = "flashcards.list"
        static let card = "flashcards.card"
        static let flipButton = "flashcards.flip.button"
        static let nextButton = "flashcards.next.button"
        static let favoriteButton = "flashcards.favorite.button"
    }
    
    // MARK: - Games
    enum Games {
        static let gamesList = "games.list"
        static let dailyQuestCard = "games.dailyquest.card"
        static let wordMatchCard = "games.wordmatch.card"
        static let timeAttackCard = "games.timeattack.card"
        static let sentenceBuilderCard = "games.sentencebuilder.card"
        static let quickQuizCard = "games.quickquiz.card"
    }
    
    // MARK: - Profile
    enum Profile {
        static let displayName = "profile.displayname"
        static let email = "profile.email"
        static let levelBadge = "profile.level.badge"
        static let editButton = "profile.edit.button"
        static let signOutButton = "profile.signout.button"
    }
    
    // MARK: - Quiz
    enum Quiz {
        static let question = "quiz.question"
        static let option = "quiz.option"
        static let submitButton = "quiz.submit.button"
        static let nextButton = "quiz.next.button"
        static let resultScreen = "quiz.result.screen"
    }
}

