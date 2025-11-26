#!/usr/bin/env python3
"""
Games Generator for NPLearn
============================
Generates game data for matching, flashcard, sentence builder, etc.
"""

import json

GAMES_DATA = [
    # BEGINNER GAMES
    {
        "id": "beginner_matching_001",
        "type": "matching",
        "title": "Word Match - Greetings",
        "titleNepali": "शब्द मिलान - अभिवादन",
        "description": "Match Nepali greetings with English meanings",
        "icon": "rectangle.grid.2x2",
        "timeLimit": 60,
        "level": "Beginner",
        "points": 100,
        "pairs": [
            {"nepali": "नमस्ते", "romanization": "namaste", "meaning": "Hello"},
            {"nepali": "धन्यवाद", "romanization": "dhanyabad", "meaning": "Thank you"},
            {"nepali": "माफ गर्नुहोस्", "romanization": "maaf garnuhos", "meaning": "Sorry"},
            {"nepali": "कृपया", "romanization": "kripaya", "meaning": "Please"},
            {"nepali": "स्वागतम्", "romanization": "swagatam", "meaning": "Welcome"},
            {"nepali": "शुभ प्रभात", "romanization": "shubha prabhat", "meaning": "Good morning"},
        ]
    },
    {
        "id": "beginner_matching_002",
        "type": "matching",
        "title": "Word Match - Numbers",
        "titleNepali": "शब्द मिलान - संख्या",
        "description": "Match Nepali numbers with their values",
        "icon": "number",
        "timeLimit": 60,
        "level": "Beginner",
        "points": 100,
        "pairs": [
            {"nepali": "एक", "romanization": "ek", "meaning": "One"},
            {"nepali": "दुई", "romanization": "dui", "meaning": "Two"},
            {"nepali": "तीन", "romanization": "tin", "meaning": "Three"},
            {"nepali": "चार", "romanization": "char", "meaning": "Four"},
            {"nepali": "पाँच", "romanization": "panch", "meaning": "Five"},
            {"nepali": "दश", "romanization": "das", "meaning": "Ten"},
        ]
    },
    {
        "id": "beginner_matching_003",
        "type": "matching",
        "title": "Word Match - Colors",
        "titleNepali": "शब्द मिलान - रङ",
        "description": "Match Nepali colors with English",
        "icon": "paintpalette",
        "timeLimit": 60,
        "level": "Beginner",
        "points": 100,
        "pairs": [
            {"nepali": "रातो", "romanization": "rato", "meaning": "Red"},
            {"nepali": "निलो", "romanization": "nilo", "meaning": "Blue"},
            {"nepali": "हरियो", "romanization": "hariyo", "meaning": "Green"},
            {"nepali": "पहेंलो", "romanization": "pahelo", "meaning": "Yellow"},
            {"nepali": "सेतो", "romanization": "seto", "meaning": "White"},
            {"nepali": "कालो", "romanization": "kalo", "meaning": "Black"},
        ]
    },
    {
        "id": "beginner_matching_004",
        "type": "matching",
        "title": "Word Match - Family",
        "titleNepali": "शब्द मिलान - परिवार",
        "description": "Match family member words",
        "icon": "person.3",
        "timeLimit": 60,
        "level": "Beginner",
        "points": 100,
        "pairs": [
            {"nepali": "बुबा", "romanization": "buba", "meaning": "Father"},
            {"nepali": "आमा", "romanization": "aama", "meaning": "Mother"},
            {"nepali": "दाजु", "romanization": "daju", "meaning": "Elder brother"},
            {"nepali": "दिदी", "romanization": "didi", "meaning": "Elder sister"},
            {"nepali": "भाइ", "romanization": "bhai", "meaning": "Younger brother"},
            {"nepali": "बहिनी", "romanization": "bahini", "meaning": "Younger sister"},
        ]
    },
    {
        "id": "beginner_matching_005",
        "type": "matching",
        "title": "Word Match - Food",
        "titleNepali": "शब्द मिलान - खाना",
        "description": "Match food vocabulary",
        "icon": "fork.knife",
        "timeLimit": 60,
        "level": "Beginner",
        "points": 100,
        "pairs": [
            {"nepali": "भात", "romanization": "bhaat", "meaning": "Rice"},
            {"nepali": "दाल", "romanization": "daal", "meaning": "Lentils"},
            {"nepali": "पानी", "romanization": "pani", "meaning": "Water"},
            {"nepali": "चिया", "romanization": "chiya", "meaning": "Tea"},
            {"nepali": "दूध", "romanization": "dudh", "meaning": "Milk"},
            {"nepali": "रोटी", "romanization": "roti", "meaning": "Bread"},
        ]
    },
    {
        "id": "beginner_sentence_001",
        "type": "sentence",
        "title": "Sentence Builder - Basic",
        "titleNepali": "वाक्य निर्माण",
        "description": "Arrange words to form sentences",
        "icon": "text.alignleft",
        "timeLimit": 120,
        "level": "Beginner",
        "points": 150,
        "questions": [
            {"sentence": "म नेपाली हुँ", "translation": "I am Nepali", "words": ["म", "नेपाली", "हुँ"], "correctOrder": [0, 1, 2]},
            {"sentence": "यो किताब हो", "translation": "This is a book", "words": ["यो", "किताब", "हो"], "correctOrder": [0, 1, 2]},
            {"sentence": "मेरो नाम राम हो", "translation": "My name is Ram", "words": ["मेरो", "नाम", "राम", "हो"], "correctOrder": [0, 1, 2, 3]},
            {"sentence": "म घर जान्छु", "translation": "I go home", "words": ["म", "घर", "जान्छु"], "correctOrder": [0, 1, 2]},
            {"sentence": "तिमी कहाँ जान्छौ", "translation": "Where do you go?", "words": ["तिमी", "कहाँ", "जान्छौ"], "correctOrder": [0, 1, 2]},
        ]
    },
    {
        "id": "beginner_fillblank_001",
        "type": "fill_blank",
        "title": "Fill in the Blank",
        "titleNepali": "खाली ठाउँ भर्नुहोस्",
        "description": "Complete the sentences",
        "icon": "rectangle.and.pencil.and.ellipsis",
        "timeLimit": 90,
        "level": "Beginner",
        "points": 120,
        "questions": [
            {"sentence": "म ___ खान्छु।", "options": ["खाना", "पानी", "किताब", "गाडी"], "correctAnswer": "खाना", "translation": "I eat food."},
            {"sentence": "यो ___ हो।", "options": ["पानी", "किताब", "खान्छु", "जान्छु"], "correctAnswer": "किताब", "translation": "This is a book."},
            {"sentence": "मेरो नाम ___ हो।", "options": ["राम", "खान्छु", "पानी", "जान्छु"], "correctAnswer": "राम", "translation": "My name is Ram."},
            {"sentence": "___ पानी पिउँछु।", "options": ["म", "यो", "के", "किन"], "correctAnswer": "म", "translation": "I drink water."},
            {"sentence": "तपाईं ___ जानुहुन्छ?", "options": ["कहाँ", "के", "किन", "कसरी"], "correctAnswer": "कहाँ", "translation": "Where do you go?"},
        ]
    },
    {
        "id": "beginner_translation_001",
        "type": "translation",
        "title": "Quick Translate",
        "titleNepali": "छिटो अनुवाद",
        "description": "Translate words quickly",
        "icon": "globe",
        "timeLimit": 120,
        "level": "Beginner",
        "points": 150,
        "questions": [
            {"word": "नमस्ते", "romanization": "namaste", "correctMeaning": "Hello", "options": ["Hello", "Goodbye", "Thank you", "Please"]},
            {"word": "धन्यवाद", "romanization": "dhanyabad", "correctMeaning": "Thank you", "options": ["Hello", "Sorry", "Thank you", "Please"]},
            {"word": "पानी", "romanization": "pani", "correctMeaning": "Water", "options": ["Food", "Water", "Rice", "Milk"]},
            {"word": "घर", "romanization": "ghar", "correctMeaning": "House", "options": ["School", "Market", "House", "Office"]},
            {"word": "राम्रो", "romanization": "ramro", "correctMeaning": "Good", "options": ["Bad", "Big", "Good", "Small"]},
        ]
    },
    # ELEMENTARY GAMES
    {
        "id": "elementary_matching_001",
        "type": "matching",
        "title": "Word Match - Animals",
        "titleNepali": "शब्द मिलान - जनावर",
        "description": "Match animal names",
        "icon": "hare",
        "timeLimit": 60,
        "level": "Elementary",
        "points": 120,
        "pairs": [
            {"nepali": "कुकुर", "romanization": "kukur", "meaning": "Dog"},
            {"nepali": "बिरालो", "romanization": "biralo", "meaning": "Cat"},
            {"nepali": "गाई", "romanization": "gai", "meaning": "Cow"},
            {"nepali": "हात्ती", "romanization": "hatti", "meaning": "Elephant"},
            {"nepali": "बाघ", "romanization": "bagh", "meaning": "Tiger"},
            {"nepali": "माछा", "romanization": "machha", "meaning": "Fish"},
        ]
    },
    {
        "id": "elementary_matching_002",
        "type": "matching",
        "title": "Word Match - Weather",
        "titleNepali": "शब्द मिलान - मौसम",
        "description": "Match weather vocabulary",
        "icon": "cloud.sun",
        "timeLimit": 60,
        "level": "Elementary",
        "points": 120,
        "pairs": [
            {"nepali": "घाम", "romanization": "gham", "meaning": "Sun"},
            {"nepali": "बादल", "romanization": "badal", "meaning": "Cloud"},
            {"nepali": "हावा", "romanization": "hawa", "meaning": "Wind"},
            {"nepali": "हिउँ", "romanization": "hiun", "meaning": "Snow"},
            {"nepali": "वर्षा", "romanization": "barsha", "meaning": "Rain"},
            {"nepali": "कुहिरो", "romanization": "kuhiro", "meaning": "Fog"},
        ]
    },
    {
        "id": "elementary_sentence_001",
        "type": "sentence",
        "title": "Sentence Builder - Intermediate",
        "titleNepali": "वाक्य निर्माण",
        "description": "Build more complex sentences",
        "icon": "text.alignleft",
        "timeLimit": 120,
        "level": "Elementary",
        "points": 180,
        "questions": [
            {"sentence": "म बिहान ६ बजे उठ्छु", "translation": "I wake up at 6 in the morning", "words": ["म", "बिहान", "६", "बजे", "उठ्छु"], "correctOrder": [0, 1, 2, 3, 4]},
            {"sentence": "आज मौसम राम्रो छ", "translation": "Today the weather is good", "words": ["आज", "मौसम", "राम्रो", "छ"], "correctOrder": [0, 1, 2, 3]},
            {"sentence": "मलाई नेपाली खाना मन पर्छ", "translation": "I like Nepali food", "words": ["मलाई", "नेपाली", "खाना", "मन", "पर्छ"], "correctOrder": [0, 1, 2, 3, 4]},
        ]
    },
    # INTERMEDIATE GAMES
    {
        "id": "intermediate_matching_001",
        "type": "matching",
        "title": "Word Match - Work",
        "titleNepali": "शब्द मिलान - काम",
        "description": "Match workplace vocabulary",
        "icon": "briefcase",
        "timeLimit": 60,
        "level": "Intermediate",
        "points": 150,
        "pairs": [
            {"nepali": "कार्यालय", "romanization": "karyalaya", "meaning": "Office"},
            {"nepali": "कर्मचारी", "romanization": "karmachari", "meaning": "Employee"},
            {"nepali": "तलब", "romanization": "talab", "meaning": "Salary"},
            {"nepali": "बैठक", "romanization": "baithak", "meaning": "Meeting"},
            {"nepali": "परियोजना", "romanization": "pariyojana", "meaning": "Project"},
            {"nepali": "छुट्टी", "romanization": "chhuti", "meaning": "Leave"},
        ]
    },
    {
        "id": "intermediate_matching_002",
        "type": "matching",
        "title": "Word Match - Health",
        "titleNepali": "शब्द मिलान - स्वास्थ्य",
        "description": "Match health vocabulary",
        "icon": "heart",
        "timeLimit": 60,
        "level": "Intermediate",
        "points": 150,
        "pairs": [
            {"nepali": "डाक्टर", "romanization": "doctor", "meaning": "Doctor"},
            {"nepali": "औषधि", "romanization": "ausadhi", "meaning": "Medicine"},
            {"nepali": "अस्पताल", "romanization": "aspatal", "meaning": "Hospital"},
            {"nepali": "ज्वरो", "romanization": "jwaro", "meaning": "Fever"},
            {"nepali": "रुघा", "romanization": "rugha", "meaning": "Cold"},
            {"nepali": "खोकी", "romanization": "khoki", "meaning": "Cough"},
        ]
    },
    # ADVANCED GAMES
    {
        "id": "advanced_matching_001",
        "type": "matching",
        "title": "Word Match - Politics",
        "titleNepali": "शब्द मिलान - राजनीति",
        "description": "Match political vocabulary",
        "icon": "building.columns",
        "timeLimit": 60,
        "level": "Advanced",
        "points": 180,
        "pairs": [
            {"nepali": "सरकार", "romanization": "sarkar", "meaning": "Government"},
            {"nepali": "संसद", "romanization": "sansad", "meaning": "Parliament"},
            {"nepali": "चुनाव", "romanization": "chunav", "meaning": "Election"},
            {"nepali": "संविधान", "romanization": "sambidhan", "meaning": "Constitution"},
            {"nepali": "कानून", "romanization": "kanun", "meaning": "Law"},
            {"nepali": "अधिकार", "romanization": "adhikar", "meaning": "Rights"},
        ]
    },
    {
        "id": "advanced_matching_002",
        "type": "matching",
        "title": "Word Match - Technology",
        "titleNepali": "शब्द मिलान - प्रविधि",
        "description": "Match technology vocabulary",
        "icon": "laptopcomputer",
        "timeLimit": 60,
        "level": "Advanced",
        "points": 180,
        "pairs": [
            {"nepali": "इन्टरनेट", "romanization": "internet", "meaning": "Internet"},
            {"nepali": "सफ्टवेयर", "romanization": "software", "meaning": "Software"},
            {"nepali": "डाटा", "romanization": "data", "meaning": "Data"},
            {"nepali": "नेटवर्क", "romanization": "network", "meaning": "Network"},
            {"nepali": "पासवर्ड", "romanization": "password", "meaning": "Password"},
            {"nepali": "वेबसाइट", "romanization": "website", "meaning": "Website"},
        ]
    },
    # PROFICIENT GAMES  
    {
        "id": "proficient_matching_001",
        "type": "matching",
        "title": "Word Match - Literature",
        "titleNepali": "शब्द मिलान - साहित्य",
        "description": "Match literary vocabulary",
        "icon": "book",
        "timeLimit": 60,
        "level": "Proficient",
        "points": 200,
        "pairs": [
            {"nepali": "साहित्य", "romanization": "sahitya", "meaning": "Literature"},
            {"nepali": "कविता", "romanization": "kavita", "meaning": "Poetry"},
            {"nepali": "उपन्यास", "romanization": "upanyas", "meaning": "Novel"},
            {"nepali": "नाटक", "romanization": "natak", "meaning": "Drama"},
            {"nepali": "निबन्ध", "romanization": "nibandha", "meaning": "Essay"},
            {"nepali": "कवि", "romanization": "kavi", "meaning": "Poet"},
        ]
    },
]

def generate_games():
    return {"games": GAMES_DATA}

if __name__ == "__main__":
    print("🎮 Generating Games...")
    data = generate_games()
    print(f"  Total games: {len(data['games'])}")
    for level in ["Beginner", "Elementary", "Intermediate", "Advanced", "Proficient"]:
        count = len([g for g in data['games'] if g['level'] == level])
        print(f"    {level}: {count} games")

