#!/usr/bin/env python3
"""
Generate realistic practice content for Listening, Speaking, and Writing
"""

import json

# Realistic N4-level listening practice questions
listening_n4 = [
    {
        "id": "n4_practice_listening_001",
        "question": "Listen and choose the correct meaning",
        "correctAnswer": "I go to the library every day",
        "options": [
            "I go to the library every day",
            "I went to the library yesterday",
            "I will go to the library tomorrow",
            "I don't go to the library"
        ],
        "explanation": "毎日 (mainichi) means 'every day', and 行きます (ikimasu) is present tense 'go'",
        "audio": "私は毎日図書館に行きます",
        "category": "listening",
        "level": "N4"
    },
    {
        "id": "n4_practice_listening_002",
        "question": "What is the speaker talking about?",
        "correctAnswer": "Tomorrow's weather",
        "options": [
            "Tomorrow's weather",
            "Today's schedule",
            "Yesterday's news",
            "Next week's plan"
        ],
        "explanation": "明日 (ashita) means 'tomorrow' and 天気 (tenki) means 'weather'",
        "audio": "明日の天気は晴れです",
        "category": "listening",
        "level": "N4"
    },
    {
        "id": "n4_practice_listening_003",
        "question": "Where does the person want to go?",
        "correctAnswer": "To the station",
        "options": [
            "To the station",
            "To the hospital",
            "To the school",
            "To the shop"
        ],
        "explanation": "駅 (eki) means 'station'",
        "audio": "駅まで行きたいです",
        "category": "listening",
        "level": "N4"
    },
    {
        "id": "n4_practice_listening_004",
        "question": "How does the speaker feel?",
        "correctAnswer": "Happy",
        "options": [
            "Happy",
            "Sad",
            "Angry",
            "Tired"
        ],
        "explanation": "嬉しい (ureshii) means 'happy' or 'glad'",
        "audio": "今日はとても嬉しいです",
        "category": "listening",
        "level": "N4"
    },
    {
        "id": "n4_practice_listening_005",
        "question": "What time is mentioned?",
        "correctAnswer": "3 o'clock",
        "options": [
            "3 o'clock",
            "2 o'clock",
            "4 o'clock",
            "5 o'clock"
        ],
        "explanation": "3時 (sanji) means '3 o'clock'",
        "audio": "会議は3時からです",
        "category": "listening",
        "level": "N4"
    }
]

# Realistic N4-level speaking practice questions
speaking_n4 = [
    {
        "id": "n4_practice_speaking_001",
        "question": "Practice saying: 'Nice to meet you'",
        "correctAnswer": "はじめまして",
        "options": ["はじめまして", "Hajimemashite"],
        "explanation": "This is the standard Japanese greeting when meeting someone for the first time",
        "category": "speaking",
        "level": "N4"
    },
    {
        "id": "n4_practice_speaking_002",
        "question": "Practice saying: 'Thank you very much'",
        "correctAnswer": "ありがとうございます",
        "options": ["ありがとうございます", "Arigatou gozaimasu"],
        "explanation": "This is the polite form of 'thank you'",
        "category": "speaking",
        "level": "N4"
    },
    {
        "id": "n4_practice_speaking_003",
        "question": "Practice saying: 'I am a student'",
        "correctAnswer": "私は学生です",
        "options": ["私は学生です", "Watashi wa gakusei desu"],
        "explanation": "学生 (gakusei) means 'student', です (desu) is the copula",
        "category": "speaking",
        "level": "N4"
    },
    {
        "id": "n4_practice_speaking_004",
        "question": "Practice saying: 'Where is the toilet?'",
        "correctAnswer": "トイレはどこですか",
        "options": ["トイレはどこですか", "Toire wa doko desu ka"],
        "explanation": "どこ (doko) means 'where', useful for asking directions",
        "category": "speaking",
        "level": "N4"
    },
    {
        "id": "n4_practice_speaking_005",
        "question": "Practice saying: 'I don't understand'",
        "correctAnswer": "分かりません",
        "options": ["分かりません", "Wakarimasen"],
        "explanation": "This is essential for when you need clarification",
        "category": "speaking",
        "level": "N4"
    }
]

# Realistic N4-level writing practice questions
writing_n4 = [
    {
        "id": "n4_practice_writing_001",
        "question": "Write the hiragana for 'watashi' (I/me)",
        "correctAnswer": "わたし",
        "options": ["わたし", "あたし", "わだし", "わたじ"],
        "explanation": "わたし is the standard hiragana spelling for 'watashi' (I/me)",
        "category": "writing",
        "level": "N4"
    },
    {
        "id": "n4_practice_writing_002",
        "question": "Write the hiragana for 'arigatou' (thank you)",
        "correctAnswer": "ありがとう",
        "options": ["ありがとう", "あいがとう", "ありがどう", "あいがどう"],
        "explanation": "ありがとう is the correct hiragana for 'arigatou'",
        "category": "writing",
        "level": "N4"
    },
    {
        "id": "n4_practice_writing_003",
        "question": "Write the kanji for 'person'",
        "correctAnswer": "人",
        "options": ["人", "入", "大", "木"],
        "explanation": "人 (hito/jin) is the kanji for 'person'",
        "category": "writing",
        "level": "N4"
    },
    {
        "id": "n4_practice_writing_004",
        "question": "Write the kanji for 'day/sun'",
        "correctAnswer": "日",
        "options": ["日", "目", "月", "白"],
        "explanation": "日 (hi/nichi) is the kanji for 'day' or 'sun'",
        "category": "writing",
        "level": "N4"
    },
    {
        "id": "n4_practice_writing_005",
        "question": "Write the hiragana for 'konnichiwa' (hello)",
        "correctAnswer": "こんにちは",
        "options": ["こんにちは", "こんにちわ", "こんいちは", "こんいちわ"],
        "explanation": "Note: though pronounced 'wa', it's written with 'は' in this greeting",
        "category": "writing",
        "level": "N4"
    }
]

def update_json_file(filepath):
    """Update a JSON file with new practice content"""
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # Filter out old listening/speaking placeholder questions
    data['practiceQuestions'] = [
        q for q in data['practiceQuestions']
        if q.get('category') not in ['listening', 'speaking', 'writing']
    ]
    
    # Add new realistic content
    data['practiceQuestions'].extend(listening_n4)
    data['practiceQuestions'].extend(speaking_n4)
    data['practiceQuestions'].extend(writing_n4)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"✅ Updated {filepath}")
    print(f"   - Added {len(listening_n4)} listening questions")
    print(f"   - Added {len(speaking_n4)} speaking questions")
    print(f"   - Added {len(writing_n4)} writing questions")

if __name__ == "__main__":
    # Update N4 file
    update_json_file('../jpleanrning/japanese_learning_data_n4_jisho.json')
    update_json_file('../JPLearning/Resources/japanese_learning_data_n4_jisho.json')
    print("\n✅ Practice content generation complete!")

