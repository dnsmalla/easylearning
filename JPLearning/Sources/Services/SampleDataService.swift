//
//  SampleDataService.swift
//  JLearn
//
//  Provides sample data for testing and demonstration
//

import Foundation

class SampleDataService {
    static let shared = SampleDataService()
    
    private init() {}
    
    // MARK: - Sample Flashcards
    
    func getSampleFlashcards(level: String = "N5") -> [Flashcard] {
        return [
            Flashcard(
                id: "1",
                front: "日",
                back: "ひ・にち・か",
                reading: "ひ・にち・か",
                meaning: "sun, day",
                level: level,
                category: "kanji",
                examples: ["今日 (きょう) - today", "日本 (にほん) - Japan"],
                audioURL: nil,
                isFavorite: false,
                lastReviewed: nil,
                nextReview: nil,
                reviewCount: 0,
                correctCount: 0
            ),
            Flashcard(
                id: "2",
                front: "月",
                back: "つき・げつ・がつ",
                reading: "つき・げつ・がつ",
                meaning: "moon, month",
                level: level,
                category: "kanji",
                examples: ["月曜日 (げつようび) - Monday", "一月 (いちがつ) - January"],
                audioURL: nil,
                isFavorite: false,
                lastReviewed: nil,
                nextReview: nil,
                reviewCount: 0,
                correctCount: 0
            ),
            Flashcard(
                id: "3",
                front: "火",
                back: "ひ・か",
                reading: "ひ・か",
                meaning: "fire",
                level: level,
                category: "kanji",
                examples: ["火曜日 (かようび) - Tuesday", "火事 (かじ) - fire"],
                audioURL: nil,
                isFavorite: false,
                lastReviewed: nil,
                nextReview: nil,
                reviewCount: 0,
                correctCount: 0
            ),
            Flashcard(
                id: "4",
                front: "こんにちは",
                back: "konnichiwa",
                reading: "こんにちは",
                meaning: "hello, good afternoon",
                level: level,
                category: "vocabulary",
                examples: ["こんにちは、元気ですか？ - Hello, how are you?"],
                audioURL: nil,
                isFavorite: true,
                lastReviewed: nil,
                nextReview: nil,
                reviewCount: 0,
                correctCount: 0
            ),
            Flashcard(
                id: "5",
                front: "ありがとう",
                back: "arigatou",
                reading: "ありがとう",
                meaning: "thank you",
                level: level,
                category: "vocabulary",
                examples: ["ありがとうございます - Thank you very much"],
                audioURL: nil,
                isFavorite: true,
                lastReviewed: nil,
                nextReview: nil,
                reviewCount: 0,
                correctCount: 0
            ),
            Flashcard(
                id: "6",
                front: "さようなら",
                back: "sayounara",
                reading: "さようなら",
                meaning: "goodbye",
                level: level,
                category: "vocabulary",
                examples: ["さようなら、また明日 - Goodbye, see you tomorrow"],
                audioURL: nil,
                isFavorite: false,
                lastReviewed: nil,
                nextReview: nil,
                reviewCount: 0,
                correctCount: 0
            )
        ]
    }
    
    // MARK: - Sample Grammar Points
    
    func getSampleGrammarPoints(level: String = "N5") -> [GrammarPoint] {
        return [
            GrammarPoint(
                id: "1",
                title: "です (desu)",
                pattern: "Noun + です",
                meaning: "to be (polite)",
                usage: "Used to state what something is in a polite way",
                examples: [
                    GrammarExample(
                        japanese: "私は学生です。",
                        reading: "わたしはがくせいです。",
                        english: "I am a student.",
                        audioURL: nil
                    ),
                    GrammarExample(
                        japanese: "これは本です。",
                        reading: "これはほんです。",
                        english: "This is a book.",
                        audioURL: nil
                    )
                ],
                level: level,
                notes: "The copula です is one of the most basic grammar patterns"
            ),
            GrammarPoint(
                id: "2",
                title: "～は～です (wa...desu)",
                pattern: "Topic + は + Noun + です",
                meaning: "As for [topic], it is [noun]",
                usage: "は marks the topic of the sentence",
                examples: [
                    GrammarExample(
                        japanese: "私は田中です。",
                        reading: "わたしはたなかです。",
                        english: "I am Tanaka.",
                        audioURL: nil
                    ),
                    GrammarExample(
                        japanese: "日本は国です。",
                        reading: "にほんはくにです。",
                        english: "Japan is a country.",
                        audioURL: nil
                    )
                ],
                level: level,
                notes: "は (wa) is the topic marker particle"
            ),
            GrammarPoint(
                id: "3",
                title: "～ます (masu)",
                pattern: "Verb stem + ます",
                meaning: "Polite verb ending",
                usage: "Makes verbs polite in present/future tense",
                examples: [
                    GrammarExample(
                        japanese: "食べます。",
                        reading: "たべます。",
                        english: "I eat. / I will eat.",
                        audioURL: nil
                    ),
                    GrammarExample(
                        japanese: "行きます。",
                        reading: "いきます。",
                        english: "I go. / I will go.",
                        audioURL: nil
                    )
                ],
                level: level,
                notes: "ます form is the polite present/future tense"
            )
        ]
    }
    
    // MARK: - Sample Practice Questions
    
    func getSamplePracticeQuestions(category: PracticeCategory, level: String = "N5") -> [PracticeQuestion] {
        switch category {
        case .kanji:
            return [
                PracticeQuestion(
                    id: "1",
                    question: "What is the reading of: 日",
                    options: ["ひ", "に", "か", "ほ"],
                    correctAnswer: "ひ",
                    explanation: "日 (ひ) means 'sun' or 'day'",
                    category: .kanji,
                    level: level
                ),
                PracticeQuestion(
                    id: "2",
                    question: "What is the reading of: 月",
                    options: ["つき", "き", "がつ", "くつ"],
                    correctAnswer: "つき",
                    explanation: "月 (つき) means 'moon' or 'month'",
                    category: .kanji,
                    level: level
                ),
                PracticeQuestion(
                    id: "3",
                    question: "What does 水 mean?",
                    options: ["water", "fire", "earth", "wind"],
                    correctAnswer: "water",
                    explanation: "水 (みず) means 'water'",
                    category: .kanji,
                    level: level
                )
            ]
            
        case .vocabulary:
            return [
                PracticeQuestion(
                    id: "1",
                    question: "What does こんにちは mean?",
                    options: ["hello", "goodbye", "thank you", "excuse me"],
                    correctAnswer: "hello",
                    explanation: "こんにちは is used as a greeting during the day",
                    category: .vocabulary,
                    level: level
                ),
                PracticeQuestion(
                    id: "2",
                    question: "What does ありがとう mean?",
                    options: ["thank you", "sorry", "please", "welcome"],
                    correctAnswer: "thank you",
                    explanation: "ありがとう means 'thank you'",
                    category: .vocabulary,
                    level: level
                ),
                PracticeQuestion(
                    id: "3",
                    question: "How do you say 'goodbye'?",
                    options: ["さようなら", "おはよう", "こんばんは", "おやすみ"],
                    correctAnswer: "さようなら",
                    explanation: "さようなら is used when parting",
                    category: .vocabulary,
                    level: level
                )
            ]
            
        case .grammar:
            return [
                PracticeQuestion(
                    id: "1",
                    question: "Fill in: 私_学生です。",
                    options: ["は", "を", "が", "に"],
                    correctAnswer: "は",
                    explanation: "は is the topic marker particle",
                    category: .grammar,
                    level: level
                ),
                PracticeQuestion(
                    id: "2",
                    question: "What is the polite form of 食べる?",
                    options: ["食べます", "食べる", "食べた", "食べない"],
                    correctAnswer: "食べます",
                    explanation: "食べます is the polite present/future form",
                    category: .grammar,
                    level: level
                ),
                PracticeQuestion(
                    id: "3",
                    question: "Which particle marks the object?",
                    options: ["を", "は", "が", "の"],
                    correctAnswer: "を",
                    explanation: "を (o) marks the direct object of a verb",
                    category: .grammar,
                    level: level
                )
            ]
            
        case .listening:
            return [
                PracticeQuestion(
                    id: "1",
                    question: "What does this mean?",
                    options: ["こんにちは", "ありがとう", "さようなら", "すみません"],
                    correctAnswer: "こんにちは",
                    explanation: "こんにちは (konnichiwa) is a daytime greeting meaning 'hello'",
                    category: .listening,
                    level: level
                ),
                PracticeQuestion(
                    id: "2",
                    question: "What greeting will you hear?",
                    options: ["おはよう", "こんばんは", "おやすみ", "さようなら"],
                    correctAnswer: "おはよう",
                    explanation: "おはよう (ohayou) means 'good morning'",
                    category: .listening,
                    level: level
                ),
                PracticeQuestion(
                    id: "3",
                    question: "Listen to this expression:",
                    options: ["ありがとう", "すみません", "ごめんなさい", "いただきます"],
                    correctAnswer: "ありがとう",
                    explanation: "ありがとう (arigatou) means 'thank you'",
                    category: .listening,
                    level: level
                ),
                PracticeQuestion(
                    id: "4",
                    question: "What number will you hear?",
                    options: ["いち", "に", "さん", "よん"],
                    correctAnswer: "いち",
                    explanation: "いち (ichi) means 'one'",
                    category: .listening,
                    level: level
                ),
                PracticeQuestion(
                    id: "5",
                    question: "Identify this word:",
                    options: ["がっこう", "いえ", "ともだち", "せんせい"],
                    correctAnswer: "がっこう",
                    explanation: "がっこう (gakkou) means 'school'",
                    category: .listening,
                    level: level
                )
            ]
            
        case .speaking:
            return [
                PracticeQuestion(
                    id: "1",
                    question: "Say: 'Hello' in Japanese",
                    options: ["こんにちは", "さようなら", "ありがとう", "すみません"],
                    correctAnswer: "こんにちは",
                    explanation: "Practice saying 'こんにちは' (konnichiwa)",
                    category: .speaking,
                    level: level
                )
            ]
            
        case .writing:
            return [
                PracticeQuestion(
                    id: "1",
                    question: "Write the hiragana for 'a'",
                    options: ["あ", "い", "う", "え"],
                    correctAnswer: "あ",
                    explanation: "あ (a) is the first character in hiragana",
                    category: .writing,
                    level: level
                )
            ]
        }
    }
    
    // MARK: - Sample Lessons
    
    func getSampleLessons(level: String = "N5") -> [Lesson] {
        return [
            Lesson(
                id: "1",
                title: "Introduction to Hiragana",
                description: "Learn the basics of the Japanese writing system",
                level: level,
                category: "kana",
                points: 100,
                isCompleted: false,
                duration: 30
            ),
            Lesson(
                id: "2",
                title: "Basic Greetings",
                description: "Essential Japanese greetings for daily conversation",
                level: level,
                category: "vocabulary",
                points: 150,
                isCompleted: false,
                duration: 20
            ),
            Lesson(
                id: "3",
                title: "Numbers 1-10",
                description: "Learn to count from one to ten in Japanese",
                level: level,
                category: "vocabulary",
                points: 120,
                isCompleted: false,
                duration: 25
            )
        ]
    }
    
    func getSampleExercises(level: String = "N5") -> [Exercise] {
        return [
            Exercise(
                id: "ex1",
                title: "Kanji Reading Practice",
                type: .multipleChoice,
                category: "kanji",
                level: level,
                questions: getSamplePracticeQuestions(category: .kanji, level: level),
                points: 100,
                duration: 10
            ),
            Exercise(
                id: "ex2",
                title: "Vocabulary Quiz",
                type: .multipleChoice,
                category: "vocabulary",
                level: level,
                questions: getSamplePracticeQuestions(category: .vocabulary, level: level),
                points: 150,
                duration: 15
            ),
            Exercise(
                id: "ex3",
                title: "Grammar Practice",
                type: .multipleChoice,
                category: "grammar",
                level: level,
                questions: getSamplePracticeQuestions(category: .grammar, level: level),
                points: 200,
                duration: 20
            )
        ]
    }
}

