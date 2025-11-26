//
//  SampleDataService.swift
//  NPLearn
//
//  Created by User on 2024-01-01.
//

import Foundation

// Deprecated: This service has been replaced by JSONParserService and LearningDataService logic.
// The app now uses JSON-driven data from bundled files and remote GitHub repository.
// Keeping this file to satisfy Xcode project references until the project file is updated.
class SampleDataService {
    static let shared = SampleDataService()
    private init() {}
    
    func getSampleFlashcards(level: String) -> [Flashcard] { [] }
    func getSampleGrammarPoints(level: String) -> [GrammarPoint] { [] }
    func getSamplePracticeQuestions(category: PracticeCategory, level: String) -> [PracticeQuestion] { [] }
    func getSampleLessons(level: String) -> [Lesson] { [] }
    func getSampleExercises(level: String) -> [Exercise] { [] }
}
