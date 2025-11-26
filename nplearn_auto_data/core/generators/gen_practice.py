#!/usr/bin/env python3
"""
Practice Questions Generator for NPLearn
=========================================
Generates practice questions for all levels
"""

import json
import random

def generate_vocab_questions(vocab_dict, level, prefix):
    """Generate vocabulary practice questions from vocab dictionary"""
    questions = []
    idx = 1
    
    for category, words in vocab_dict.items():
        for word, meaning, roman, desc in words:
            # Get 3 wrong answers from same category
            other_meanings = [w[1] for w in words if w[0] != word][:3]
            if len(other_meanings) < 3:
                other_meanings.extend(["Unknown", "Something else", "None of these"])
            
            options = [meaning] + other_meanings[:3]
            random.shuffle(options)
            
            questions.append({
                "id": f"{prefix}_prac_{idx:03d}",
                "question": f"What does '{word}' mean?",
                "options": options,
                "correctAnswer": meaning,
                "explanation": f"{word} ({roman}) means {meaning}",
                "category": "vocabulary",
                "level": level
            })
            idx += 1
    
    return questions

PRACTICE_DATA = {
    "practice": [
        # BEGINNER PRACTICE
        {"id": "b_prac_001", "question": "What does 'नमस्ते' mean?", "options": ["Hello", "Goodbye", "Thank you", "Sorry"], "correctAnswer": "Hello", "explanation": "नमस्ते (namaste) is the traditional Nepali greeting meaning Hello", "category": "vocabulary", "level": "Beginner"},
        {"id": "b_prac_002", "question": "How do you say 'water' in Nepali?", "options": ["दूध", "चिया", "पानी", "भात"], "correctAnswer": "पानी", "explanation": "पानी (pani) means water", "category": "vocabulary", "level": "Beginner"},
        {"id": "b_prac_003", "question": "What is 'बुबा' in English?", "options": ["Mother", "Father", "Brother", "Sister"], "correctAnswer": "Father", "explanation": "बुबा (buba) means Father", "category": "vocabulary", "level": "Beginner"},
        {"id": "b_prac_004", "question": "What color is 'रातो'?", "options": ["Blue", "Green", "Red", "Yellow"], "correctAnswer": "Red", "explanation": "रातो (rato) means Red", "category": "vocabulary", "level": "Beginner"},
        {"id": "b_prac_005", "question": "What number is 'पाँच'?", "options": ["3", "4", "5", "6"], "correctAnswer": "5", "explanation": "पाँच (panch) is 5", "category": "vocabulary", "level": "Beginner"},
        {"id": "b_prac_006", "question": "Which ending is for 'I' in present tense?", "options": ["छ", "छु", "छन्", "छौ"], "correctAnswer": "छु", "explanation": "छु is used with म (I) in present tense", "category": "grammar", "level": "Beginner"},
        {"id": "b_prac_007", "question": "Complete: म घर ___", "options": ["जान्छ", "जान्छु", "जान्छन्", "जान्छौ"], "correctAnswer": "जान्छु", "explanation": "जान्छु (janchhu) means 'I go'", "category": "grammar", "level": "Beginner"},
        {"id": "b_prac_008", "question": "Which postposition means 'in/at'?", "options": ["बाट", "सँग", "मा", "लाई"], "correctAnswer": "मा", "explanation": "मा means in/at (e.g., घरमा = at home)", "category": "grammar", "level": "Beginner"},
        {"id": "b_prac_009", "question": "What day is 'शनिबार'?", "options": ["Sunday", "Friday", "Saturday", "Monday"], "correctAnswer": "Saturday", "explanation": "शनिबार (sanibar) is Saturday", "category": "vocabulary", "level": "Beginner"},
        {"id": "b_prac_010", "question": "What does 'खानु' mean?", "options": ["To drink", "To eat", "To go", "To come"], "correctAnswer": "To eat", "explanation": "खानु (khanu) means to eat", "category": "vocabulary", "level": "Beginner"},
        {"id": "b_prac_011", "question": "What does 'राम्रो' mean?", "options": ["Bad", "Big", "Good", "Small"], "correctAnswer": "Good", "explanation": "राम्रो (ramro) means good/nice", "category": "vocabulary", "level": "Beginner"},
        {"id": "b_prac_012", "question": "What is 'हात' in English?", "options": ["Head", "Foot", "Hand", "Eye"], "correctAnswer": "Hand", "explanation": "हात (haat) means hand", "category": "vocabulary", "level": "Beginner"},
        {"id": "b_prac_013", "question": "What does 'म नेपाली हुँ' mean?", "options": ["I am Indian", "I am Nepali", "I am American", "You are Nepali"], "correctAnswer": "I am Nepali", "explanation": "म नेपाली हुँ = I am Nepali", "category": "reading", "level": "Beginner"},
        {"id": "b_prac_014", "question": "What is 'घर' in English?", "options": ["School", "Market", "House", "Office"], "correctAnswer": "House", "explanation": "घर (ghar) means house/home", "category": "vocabulary", "level": "Beginner"},
        {"id": "b_prac_015", "question": "How do you say 'Thank you' in Nepali?", "options": ["नमस्ते", "धन्यवाद", "माफ गर्नुहोस्", "कृपया"], "correctAnswer": "धन्यवाद", "explanation": "धन्यवाद (dhanyabad) means Thank you", "category": "vocabulary", "level": "Beginner"},
        
        # ELEMENTARY PRACTICE
        {"id": "e_prac_001", "question": "What does 'कुकुर' mean?", "options": ["Cat", "Dog", "Cow", "Bird"], "correctAnswer": "Dog", "explanation": "कुकुर (kukur) means dog", "category": "vocabulary", "level": "Elementary"},
        {"id": "e_prac_002", "question": "What is 'मौसम' in English?", "options": ["Time", "Weather", "Place", "Day"], "correctAnswer": "Weather", "explanation": "मौसम (mausam) means weather", "category": "vocabulary", "level": "Elementary"},
        {"id": "e_prac_003", "question": "What does 'यात्रा' mean?", "options": ["Travel", "Food", "Work", "Study"], "correctAnswer": "Travel", "explanation": "यात्रा (yatra) means travel/journey", "category": "vocabulary", "level": "Elementary"},
        {"id": "e_prac_004", "question": "How do you express 'I was eating' in Nepali?", "options": ["म खान्छु", "म खाँदै थिएँ", "म खाएँ", "म खानेछु"], "correctAnswer": "म खाँदै थिएँ", "explanation": "खाँदै थिएँ is past continuous", "category": "grammar", "level": "Elementary"},
        {"id": "e_prac_005", "question": "What does 'भन्दा' mean?", "options": ["And", "But", "Than", "Or"], "correctAnswer": "Than", "explanation": "भन्दा is used for comparisons (than)", "category": "grammar", "level": "Elementary"},
        {"id": "e_prac_006", "question": "What is 'हात्ती' in English?", "options": ["Tiger", "Lion", "Elephant", "Horse"], "correctAnswer": "Elephant", "explanation": "हात्ती (hatti) means elephant", "category": "vocabulary", "level": "Elementary"},
        {"id": "e_prac_007", "question": "What does 'बिहान' mean?", "options": ["Night", "Afternoon", "Morning", "Evening"], "correctAnswer": "Morning", "explanation": "बिहान (bihan) means morning", "category": "vocabulary", "level": "Elementary"},
        {"id": "e_prac_008", "question": "How do you say 'I have to go' in Nepali?", "options": ["म जान्छु", "म जानुपर्छ", "म जाने", "म गएँ"], "correctAnswer": "म जानुपर्छ", "explanation": "जानुपर्छ expresses obligation", "category": "grammar", "level": "Elementary"},
        
        # INTERMEDIATE PRACTICE
        {"id": "i_prac_001", "question": "What does 'कार्यालय' mean?", "options": ["School", "Office", "Hospital", "Market"], "correctAnswer": "Office", "explanation": "कार्यालय (karyalaya) means office", "category": "vocabulary", "level": "Intermediate"},
        {"id": "i_prac_002", "question": "What is 'स्वास्थ्य' in English?", "options": ["Wealth", "Health", "Strength", "Food"], "correctAnswer": "Health", "explanation": "स्वास्थ्य (swasthya) means health", "category": "vocabulary", "level": "Intermediate"},
        {"id": "i_prac_003", "question": "What does 'यदि...भने' express?", "options": ["Because", "Although", "If...then", "While"], "correctAnswer": "If...then", "explanation": "यदि...भने is the conditional structure", "category": "grammar", "level": "Intermediate"},
        {"id": "i_prac_004", "question": "What does 'संस्कृति' mean?", "options": ["History", "Culture", "Language", "Religion"], "correctAnswer": "Culture", "explanation": "संस्कृति (sanskriti) means culture", "category": "vocabulary", "level": "Intermediate"},
        {"id": "i_prac_005", "question": "What is 'परीक्षा' in English?", "options": ["Class", "Book", "Exam", "Teacher"], "correctAnswer": "Exam", "explanation": "परीक्षा (pariksha) means exam/test", "category": "vocabulary", "level": "Intermediate"},
        
        # ADVANCED PRACTICE
        {"id": "a_prac_001", "question": "What does 'सरकार' mean?", "options": ["Parliament", "Government", "Court", "Law"], "correctAnswer": "Government", "explanation": "सरकार (sarkar) means government", "category": "vocabulary", "level": "Advanced"},
        {"id": "a_prac_002", "question": "What is 'अर्थतन्त्र' in English?", "options": ["Politics", "Economy", "Society", "Culture"], "correctAnswer": "Economy", "explanation": "अर्थतन्त्र (arthatantra) means economy", "category": "vocabulary", "level": "Advanced"},
        {"id": "a_prac_003", "question": "What does 'इन्टरनेट' mean?", "options": ["Computer", "Internet", "Phone", "Television"], "correctAnswer": "Internet", "explanation": "इन्टरनेट (internet) means internet", "category": "vocabulary", "level": "Advanced"},
        {"id": "a_prac_004", "question": "What is the causative form of 'खानु'?", "options": ["खाएको", "खुवाउनु", "खाइन्छ", "खान"], "correctAnswer": "खुवाउनु", "explanation": "खुवाउनु is the causative (to make someone eat)", "category": "grammar", "level": "Advanced"},
        
        # PROFICIENT PRACTICE
        {"id": "p_prac_001", "question": "Who is called 'आदिकवि' of Nepali literature?", "options": ["Devkota", "Bhanubhakta", "Moteram", "Parijat"], "correctAnswer": "Bhanubhakta", "explanation": "Bhanubhakta Acharya is the first poet (आदिकवि)", "category": "culture", "level": "Proficient"},
        {"id": "p_prac_002", "question": "What does 'साहित्य' mean?", "options": ["Art", "Music", "Literature", "Drama"], "correctAnswer": "Literature", "explanation": "साहित्य (sahitya) means literature", "category": "vocabulary", "level": "Proficient"},
        {"id": "p_prac_003", "question": "What is 'न्याय' in English?", "options": ["Law", "Justice", "Court", "Rights"], "correctAnswer": "Justice", "explanation": "न्याय (nyaya) means justice", "category": "vocabulary", "level": "Proficient"},
    ]
}

def generate_practice():
    return PRACTICE_DATA

if __name__ == "__main__":
    print("❓ Generating Practice Questions...")
    data = generate_practice()
    print(f"  Total questions: {len(data['practice'])}")
    for level in ["Beginner", "Elementary", "Intermediate", "Advanced", "Proficient"]:
        count = len([q for q in data['practice'] if q['level'] == level])
        print(f"    {level}: {count} questions")

