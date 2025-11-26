#!/usr/bin/env python3
"""
NPLearn Data Generator
Generates comprehensive level-based Nepali learning data
NOTE: This uses HARDCODED data - it does NOT search the web or use AI

All content is organized by 5 levels:
- Beginner: Basic greetings, numbers, simple words
- Elementary: Daily life, travel, shopping
- Intermediate: Work, education, health, culture
- Advanced: Politics, economics, technology
- Proficient: Literature, philosophy, academic topics
"""

import json
import os
from pathlib import Path
import random

# Get the resources path
SCRIPT_DIR = Path(__file__).parent
RESOURCES_PATH = SCRIPT_DIR.parent.parent.parent / "NPLearn" / "Resources"

# ═══════════════════════════════════════════════════════════════════════════════
# VOCABULARY DATA - Organized by Level and Category
# ═══════════════════════════════════════════════════════════════════════════════

VOCABULARY_DATA = {
    "beginner": {
        "greetings": [
            ("नमस्ते", "Hello/Greetings", "namaste", "Traditional greeting"),
            ("धन्यवाद", "Thank you", "dhanyabad", "Expression of gratitude"),
            ("माफ गर्नुहोस्", "Sorry/Excuse me", "maaf garnuhos", "Apology"),
            ("कृपया", "Please", "kripaya", "Polite request"),
            ("स्वागतम्", "Welcome", "swagatam", "Welcoming someone"),
            ("शुभ प्रभात", "Good morning", "shubha prabhat", "Morning greeting"),
            ("शुभ रात्रि", "Good night", "shubha ratri", "Night greeting"),
            ("फेरि भेटौंला", "See you again", "pheri bhetaula", "Farewell"),
            ("कस्तो छ?", "How are you?", "kasto chha", "Inquiry about wellbeing"),
            ("ठीक छ", "I'm fine", "thik chha", "Response to how are you"),
        ],
        "pronouns": [
            ("म", "I/Me", "ma", "First person singular"),
            ("तपाईं", "You (polite)", "tapai", "Second person polite"),
            ("तिमी", "You (informal)", "timi", "Second person informal"),
            ("ऊ", "He/She", "u", "Third person singular"),
            ("हामी", "We", "hami", "First person plural"),
            ("उनीहरू", "They", "uniharu", "Third person plural"),
            ("यो", "This", "yo", "Demonstrative pronoun"),
            ("त्यो", "That", "tyo", "Demonstrative pronoun"),
            ("को", "Who", "ko", "Interrogative pronoun"),
            ("के", "What", "ke", "Interrogative pronoun"),
        ],
        "numbers": [
            ("एक", "One", "ek", "Number 1"),
            ("दुई", "Two", "dui", "Number 2"),
            ("तीन", "Three", "tin", "Number 3"),
            ("चार", "Four", "char", "Number 4"),
            ("पाँच", "Five", "panch", "Number 5"),
            ("छ", "Six", "chha", "Number 6"),
            ("सात", "Seven", "saat", "Number 7"),
            ("आठ", "Eight", "aath", "Number 8"),
            ("नौ", "Nine", "nau", "Number 9"),
            ("दश", "Ten", "das", "Number 10"),
        ],
        "family": [
            ("बुबा", "Father", "buba", "Father"),
            ("आमा", "Mother", "aama", "Mother"),
            ("दाजु", "Elder brother", "daju", "Elder brother"),
            ("भाइ", "Younger brother", "bhai", "Younger brother"),
            ("दिदी", "Elder sister", "didi", "Elder sister"),
            ("बहिनी", "Younger sister", "bahini", "Younger sister"),
            ("परिवार", "Family", "pariwar", "Family"),
            ("हजुरबुवा", "Grandfather", "hajurbuwa", "Grandfather"),
            ("हजुरआमा", "Grandmother", "hajuraama", "Grandmother"),
            ("छोरा", "Son", "chhora", "Son"),
            ("छोरी", "Daughter", "chhori", "Daughter"),
        ],
        "food": [
            ("खाना", "Food/Meal", "khana", "Food or meal"),
            ("पानी", "Water", "pani", "Water"),
            ("भात", "Rice (cooked)", "bhaat", "Cooked rice"),
            ("दाल", "Lentils", "daal", "Lentil soup"),
            ("चिया", "Tea", "chiya", "Tea"),
            ("दूध", "Milk", "dudh", "Milk"),
            ("रोटी", "Bread", "roti", "Flatbread"),
            ("तरकारी", "Vegetables", "tarkari", "Vegetable dish"),
            ("फल", "Fruit", "phal", "Fruit"),
            ("मासु", "Meat", "maasu", "Meat"),
        ],
        "places": [
            ("घर", "House/Home", "ghar", "House or home"),
            ("विद्यालय", "School", "vidyalaya", "School"),
            ("बजार", "Market", "bazaar", "Market"),
            ("अस्पताल", "Hospital", "aspatal", "Hospital"),
            ("मन्दिर", "Temple", "mandir", "Temple"),
        ],
        "time": [
            ("आज", "Today", "aaja", "Today"),
            ("भोलि", "Tomorrow", "bholi", "Tomorrow"),
            ("हिजो", "Yesterday", "hijo", "Yesterday"),
            ("बिहान", "Morning", "bihaan", "Morning"),
            ("रात", "Night", "raat", "Night"),
        ],
        "verbs": [
            ("खानु", "To eat", "khanu", "Verb: to eat"),
            ("पिउनु", "To drink", "piunu", "Verb: to drink"),
            ("जानु", "To go", "jaanu", "Verb: to go"),
            ("आउनु", "To come", "aaunu", "Verb: to come"),
            ("गर्नु", "To do", "garnu", "Verb: to do"),
            ("बोल्नु", "To speak", "bolnu", "Verb: to speak"),
            ("सुन्नु", "To listen", "sunnu", "Verb: to listen"),
            ("हेर्नु", "To see/watch", "hernu", "Verb: to see"),
            ("पढ्नु", "To read/study", "padhnu", "Verb: to read"),
            ("लेख्नु", "To write", "lekhnu", "Verb: to write"),
        ],
        "adjectives": [
            ("राम्रो", "Good/Nice", "ramro", "Adjective: good"),
            ("नराम्रो", "Bad", "naramro", "Adjective: bad"),
            ("ठूलो", "Big/Large", "thulo", "Adjective: big"),
            ("सानो", "Small/Little", "sano", "Adjective: small"),
            ("नयाँ", "New", "naya", "Adjective: new"),
        ],
    },
    "elementary": {
        "travel": [
            ("यात्रा", "Travel/Journey", "yatra", "Travel or journey"),
            ("टिकट", "Ticket", "tikat", "Ticket"),
            ("बस", "Bus", "bas", "Bus"),
            ("गाडी", "Car/Vehicle", "gadi", "Car or vehicle"),
            ("सडक", "Road", "sadak", "Road"),
            ("नक्सा", "Map", "naksha", "Map"),
            ("यात्री", "Traveler", "yatri", "Traveler"),
            ("सामान", "Luggage", "saman", "Luggage"),
        ],
        "weather": [
            ("मौसम", "Weather", "mausam", "Weather"),
            ("घाम", "Sun", "gham", "Sun/Sunshine"),
            ("पानी परेको", "Raining", "pani pareko", "It's raining"),
            ("बादल", "Cloud", "badal", "Cloud"),
            ("हावा", "Wind", "hawa", "Wind"),
            ("गर्मी", "Hot weather", "garmi", "Hot weather"),
            ("जाडो", "Cold weather", "jado", "Cold weather"),
        ],
        "body": [
            ("शरीर", "Body", "sharir", "Body"),
            ("टाउको", "Head", "tauko", "Head"),
            ("आँखा", "Eye", "aankha", "Eye"),
            ("कान", "Ear", "kaan", "Ear"),
            ("नाक", "Nose", "nak", "Nose"),
            ("मुख", "Mouth", "mukh", "Mouth"),
            ("हात", "Hand", "haat", "Hand"),
            ("खुट्टा", "Leg/Foot", "khutta", "Leg or foot"),
        ],
        "emotions": [
            ("खुसी", "Happy", "khusi", "Happy"),
            ("दुखी", "Sad", "dukhi", "Sad"),
            ("रिस", "Angry", "ris", "Angry"),
            ("डर", "Fear/Scared", "dar", "Fear"),
            ("माया", "Love", "maya", "Love"),
        ],
        "shopping": [
            ("किन्नु", "To buy", "kinnu", "Verb: to buy"),
            ("बेच्नु", "To sell", "bechnu", "Verb: to sell"),
            ("मोल", "Price", "mol", "Price"),
            ("पैसा", "Money", "paisa", "Money"),
            ("रुपैयाँ", "Rupees", "rupaiya", "Nepali currency"),
        ],
        "directions": [
            ("दायाँ", "Right", "daya", "Right side"),
            ("बायाँ", "Left", "baya", "Left side"),
            ("सिधा", "Straight", "sidha", "Straight ahead"),
            ("माथि", "Up/Above", "mathi", "Up or above"),
            ("तल", "Down/Below", "tala", "Down or below"),
        ],
    },
    "intermediate": {
        "work": [
            ("काम", "Work/Job", "kaam", "Work or job"),
            ("कर्मचारी", "Employee", "karmachari", "Employee"),
            ("तलब", "Salary", "talab", "Salary"),
            ("बैठक", "Meeting", "baithak", "Meeting"),
            ("व्यवसाय", "Business", "byabasaya", "Business"),
            ("कम्पनी", "Company", "company", "Company"),
            ("अनुभव", "Experience", "anubhav", "Experience"),
        ],
        "education": [
            ("शिक्षा", "Education", "shiksha", "Education"),
            ("विश्वविद्यालय", "University", "vishwavidyalaya", "University"),
            ("परीक्षा", "Exam", "pariksha", "Exam"),
            ("किताब", "Book", "kitab", "Book"),
            ("विद्यार्थी", "Student", "vidyarthi", "Student"),
            ("शिक्षक", "Teacher", "shikshak", "Teacher"),
        ],
        "health": [
            ("स्वास्थ्य", "Health", "swasthya", "Health"),
            ("रोग", "Disease", "rog", "Disease"),
            ("औषधि", "Medicine", "aushadhi", "Medicine"),
            ("डाक्टर", "Doctor", "doctor", "Doctor"),
            ("ज्वरो", "Fever", "jwaro", "Fever"),
        ],
        "nature": [
            ("प्रकृति", "Nature", "prakriti", "Nature"),
            ("पहाड", "Mountain", "pahad", "Mountain"),
            ("नदी", "River", "nadi", "River"),
            ("जंगल", "Forest", "jangal", "Forest"),
            ("रूख", "Tree", "rukh", "Tree"),
        ],
        "culture": [
            ("संस्कृति", "Culture", "sanskriti", "Culture"),
            ("चाड", "Festival", "chaad", "Festival"),
            ("परम्परा", "Tradition", "parampara", "Tradition"),
            ("पूजा", "Worship", "puja", "Worship/Prayer"),
            ("विवाह", "Wedding", "bibah", "Wedding"),
        ],
    },
    "advanced": {
        "politics": [
            ("राजनीति", "Politics", "rajniti", "Politics"),
            ("सरकार", "Government", "sarkar", "Government"),
            ("संविधान", "Constitution", "sambidhan", "Constitution"),
            ("चुनाव", "Election", "chunav", "Election"),
            ("संसद", "Parliament", "sansad", "Parliament"),
            ("कानून", "Law", "kanun", "Law"),
            ("न्याय", "Justice", "nyaya", "Justice"),
        ],
        "economics": [
            ("अर्थतन्त्र", "Economy", "arthatantra", "Economy"),
            ("व्यापार", "Trade", "byapar", "Trade"),
            ("लगानी", "Investment", "lagani", "Investment"),
            ("बजेट", "Budget", "bajet", "Budget"),
            ("कर", "Tax", "kar", "Tax"),
        ],
        "technology": [
            ("प्रविधि", "Technology", "prawidhi", "Technology"),
            ("कम्प्युटर", "Computer", "computer", "Computer"),
            ("इन्टरनेट", "Internet", "internet", "Internet"),
            ("मोबाइल", "Mobile", "mobile", "Mobile phone"),
            ("डाटा", "Data", "data", "Data"),
        ],
        "environment": [
            ("वातावरण", "Environment", "watawaran", "Environment"),
            ("प्रदूषण", "Pollution", "pradushan", "Pollution"),
            ("जलवायु", "Climate", "jalwayu", "Climate"),
            ("संरक्षण", "Conservation", "sanrakshan", "Conservation"),
        ],
    },
    "proficient": {
        "philosophy": [
            ("दर्शन", "Philosophy", "darshan", "Philosophy"),
            ("ज्ञान", "Knowledge", "gyan", "Knowledge"),
            ("सत्य", "Truth", "satya", "Truth"),
            ("चेतना", "Consciousness", "chetna", "Consciousness"),
            ("आत्मा", "Soul", "atma", "Soul"),
            ("कर्म", "Karma/Action", "karma", "Karma or action"),
            ("धर्म", "Religion/Duty", "dharma", "Religion or duty"),
        ],
        "literature": [
            ("साहित्य", "Literature", "sahitya", "Literature"),
            ("कविता", "Poetry", "kabita", "Poetry"),
            ("उपन्यास", "Novel", "upanyas", "Novel"),
            ("कथा", "Story", "katha", "Story"),
            ("लेखक", "Author", "lekhak", "Author"),
        ],
        "science": [
            ("विज्ञान", "Science", "bigyan", "Science"),
            ("अनुसन्धान", "Research", "anusandhan", "Research"),
            ("प्रयोग", "Experiment", "prayog", "Experiment"),
            ("सिद्धान्त", "Theory", "siddhanta", "Theory"),
        ],
        "law": [
            ("न्यायशास्त्र", "Jurisprudence", "nyaya shastra", "Jurisprudence"),
            ("वकिल", "Lawyer", "wakil", "Lawyer"),
            ("अदालत", "Court", "adalat", "Court"),
            ("फैसला", "Verdict", "phaisla", "Verdict"),
        ],
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
# GRAMMAR DATA - Organized by Level
# ═══════════════════════════════════════════════════════════════════════════════

GRAMMAR_DATA = {
    "beginner": [
        {
            "title": "Simple Present Tense",
            "pattern": "Subject + Verb stem + छु/छौ/छ/छौं/छन्",
            "meaning": "Used for habitual actions and general truths",
            "usage": "म खान्छु (I eat), तिमी खान्छौ (You eat)",
            "examples": [
                {"nepali": "म नेपाली बोल्छु।", "romanization": "Ma nepali bolchhu.", "english": "I speak Nepali."},
                {"nepali": "ऊ विद्यालय जान्छ।", "romanization": "U vidyalaya janchha.", "english": "He/She goes to school."},
            ],
            "notes": "The verb ending changes based on the subject"
        },
        {
            "title": "Simple Past Tense",
            "pattern": "Subject + Verb stem + एँ/यौ/यो/यौं/ए",
            "meaning": "Used for completed actions in the past",
            "usage": "म गएँ (I went), ऊ गयो (He went)",
            "examples": [
                {"nepali": "म हिजो घर गएँ।", "romanization": "Ma hijo ghar gaen.", "english": "I went home yesterday."},
            ],
            "notes": "Past tense formation varies by verb type"
        },
        {
            "title": "Question Formation",
            "pattern": "Question word + Subject + Verb + ?",
            "meaning": "How to form questions in Nepali",
            "usage": "के, को, कहाँ, कसरी, किन, कति",
            "examples": [
                {"nepali": "तपाईंको नाम के हो?", "romanization": "Tapaiko naam ke ho?", "english": "What is your name?"},
            ],
            "notes": "Question words come at the beginning of sentences"
        },
        {
            "title": "Negation",
            "pattern": "Subject + Verb stem + दिन/दैन/दिनौं",
            "meaning": "How to form negative sentences",
            "usage": "म जान्दिनँ (I don't go)",
            "examples": [
                {"nepali": "म मासु खान्दिनँ।", "romanization": "Ma maasu khandina.", "english": "I don't eat meat."},
            ],
            "notes": "Negation changes the verb ending"
        },
        {
            "title": "Postpositions",
            "pattern": "Noun + Postposition",
            "meaning": "Nepali uses postpositions instead of prepositions",
            "usage": "मा (in), बाट (from), सँग (with)",
            "examples": [
                {"nepali": "म घरमा छु।", "romanization": "Ma gharma chhu.", "english": "I am at home."},
            ],
            "notes": "Postpositions come after the noun"
        },
    ],
    "elementary": [
        {
            "title": "Continuous Tense",
            "pattern": "Subject + Verb stem + दै + छु/छ",
            "meaning": "Used for ongoing actions",
            "usage": "म पढ्दैछु (I am reading)",
            "examples": [
                {"nepali": "म किताब पढ्दैछु।", "romanization": "Ma kitab padhdaichhu.", "english": "I am reading a book."},
            ],
            "notes": "Shows action in progress"
        },
        {
            "title": "Future Tense",
            "pattern": "Subject + Verb stem + नेछु/नेछौ/नेछ",
            "meaning": "Used for future actions",
            "usage": "म जानेछु (I will go)",
            "examples": [
                {"nepali": "म भोलि आउनेछु।", "romanization": "Ma bholi aaunechhu.", "english": "I will come tomorrow."},
            ],
            "notes": "Indicates future actions or intentions"
        },
        {
            "title": "Imperative Mood",
            "pattern": "Verb stem + ओस्/नुहोस्",
            "meaning": "Used for commands and requests",
            "usage": "बस् (sit - informal), बस्नुहोस् (please sit - polite)",
            "examples": [
                {"nepali": "यहाँ बस्नुहोस्।", "romanization": "Yaha basnuhos.", "english": "Please sit here."},
            ],
            "notes": "Politeness level affects the verb form"
        },
    ],
    "intermediate": [
        {
            "title": "Conditional Sentences",
            "pattern": "यदि + condition + भने + result",
            "meaning": "If-then structures",
            "usage": "यदि पानी पर्यो भने म जान्दिनँ।",
            "examples": [
                {"nepali": "यदि तपाईं आउनुभयो भने राम्रो हुन्छ।", "romanization": "Yadi tapai aaunubhayo bhane ramro hunchha.", "english": "If you come, it will be good."},
            ],
            "notes": "भने marks the conditional clause"
        },
        {
            "title": "Passive Voice",
            "pattern": "Object + Verb stem + इन्छ/इयो",
            "meaning": "When the focus is on the action, not the doer",
            "usage": "यो काम गरियो (This work was done)",
            "examples": [
                {"nepali": "घर बनाइयो।", "romanization": "Ghar banaiyo.", "english": "The house was built."},
            ],
            "notes": "Used when the agent is unknown or unimportant"
        },
    ],
    "advanced": [
        {
            "title": "Causative Verbs",
            "pattern": "Verb stem + आउनु",
            "meaning": "Making someone do something",
            "usage": "गराउनु (to make do), खुवाउनु (to feed)",
            "examples": [
                {"nepali": "मैले काम गराएँ।", "romanization": "Maile kaam garayen.", "english": "I made (someone) work."},
            ],
            "notes": "Indicates causing an action"
        },
        {
            "title": "Reported Speech",
            "pattern": "Subject + भन्नुभयो कि + reported content",
            "meaning": "Reporting what someone said",
            "usage": "उहाँले भन्नुभयो कि...",
            "examples": [
                {"nepali": "उहाँले भन्नुभयो कि उहाँ भोलि आउनुहुन्छ।", "romanization": "Uhanle bhannubhayo ki uhã bholi aaunuhunchha.", "english": "He/She said that he/she will come tomorrow."},
            ],
            "notes": "कि introduces the reported clause"
        },
    ],
    "proficient": [
        {
            "title": "Literary Nepali",
            "pattern": "Formal/archaic verb forms",
            "meaning": "Used in formal writing and literature",
            "usage": "गर्दछ → गर्छ, भएको → भयो",
            "examples": [
                {"nepali": "त्यस बेला राजाले शासन गर्थे।", "romanization": "Tyas bela rajale shasan garthe.", "english": "At that time, the king ruled."},
            ],
            "notes": "Different verb forms used in formal/literary contexts"
        },
        {
            "title": "Complex Sentence Structures",
            "pattern": "Multiple clauses with subordination",
            "meaning": "Sophisticated sentence construction",
            "usage": "जब...तब, जसरी...त्यसरी",
            "examples": [
                {"nepali": "जब म साना थिएँ, तब म खेल्न मन पराउँथें।", "romanization": "Jaba ma sana thien, taba ma khelna man parauthẽ.", "english": "When I was small, I used to like playing."},
            ],
            "notes": "Used in formal and literary writing"
        },
    ]
}

# ═══════════════════════════════════════════════════════════════════════════════
# READING DATA - Level-based passages
# ═══════════════════════════════════════════════════════════════════════════════

READING_DATA = {
    "beginner": [
        {
            "title": "मेरो परिवार",
            "englishTitle": "My Family",
            "difficulty": "easy",
            "paragraphs": [
                "मेरो नाम राम हो। म नेपालमा बस्छु।",
                "मेरो परिवारमा चार जना छन्। बुबा, आमा, बहिनी र म।",
                "मेरो बुबा शिक्षक हुनुहुन्छ। मेरी आमा डाक्टर हुनुहुन्छ।",
                "मेरी बहिनी विद्यार्थी हो। म पनि विद्यार्थी हुँ।"
            ],
            "englishParagraphs": [
                "My name is Ram. I live in Nepal.",
                "There are four people in my family. Father, mother, sister, and me.",
                "My father is a teacher. My mother is a doctor.",
                "My sister is a student. I am also a student."
            ],
            "vocabulary": [
                {"nepali": "परिवार", "english": "family", "romanization": "pariwar"},
                {"nepali": "शिक्षक", "english": "teacher", "romanization": "shikshak"},
            ],
            "questions": [
                {"question": "रामको परिवारमा कति जना छन्?", "options": ["दुई जना", "तीन जना", "चार जना", "पाँच जना"], "correctAnswer": "चार जना"},
            ]
        },
        {
            "title": "मेरो दिन",
            "englishTitle": "My Day",
            "difficulty": "easy",
            "paragraphs": [
                "म बिहान छ बजे उठ्छु।",
                "म नुहाउँछु र खाना खान्छु।",
                "म विद्यालय जान्छु।",
                "साँझ म घर फर्कन्छु।"
            ],
            "englishParagraphs": [
                "I wake up at 6 in the morning.",
                "I take a bath and eat food.",
                "I go to school.",
                "In the evening, I return home."
            ],
            "vocabulary": [
                {"nepali": "उठ्नु", "english": "to wake up", "romanization": "uthnu"},
                {"nepali": "फर्कनु", "english": "to return", "romanization": "pharkanu"},
            ],
            "questions": [
                {"question": "कति बजे उठ्छ?", "options": ["५ बजे", "६ बजे", "७ बजे", "८ बजे"], "correctAnswer": "६ बजे"},
            ]
        },
        {
            "title": "मेरो घर",
            "englishTitle": "My House",
            "difficulty": "easy",
            "paragraphs": [
                "मेरो घर सानो छ।",
                "घरमा दुईवटा कोठा छन्।",
                "एउटा भान्सा छ।",
                "घर राम्रो छ।"
            ],
            "englishParagraphs": [
                "My house is small.",
                "There are two rooms in the house.",
                "There is one kitchen.",
                "The house is nice."
            ],
            "vocabulary": [
                {"nepali": "घर", "english": "house", "romanization": "ghar"},
                {"nepali": "कोठा", "english": "room", "romanization": "kotha"},
            ],
            "questions": [
                {"question": "घरमा कतिवटा कोठा छन्?", "options": ["एउटा", "दुईवटा", "तीनवटा", "चारवटा"], "correctAnswer": "दुईवटा"},
            ]
        },
    ],
    "elementary": [
        {
            "title": "बजारमा",
            "englishTitle": "At the Market",
            "difficulty": "medium",
            "paragraphs": [
                "आज म बजार गएँ।",
                "बजारमा धेरै पसलहरू छन्।",
                "मैले तरकारी र फलफूल किनें।",
                "बजार धेरै भिड थियो।",
                "मैले सबै सामान किनेर घर फर्केँ।"
            ],
            "englishParagraphs": [
                "Today I went to the market.",
                "There are many shops in the market.",
                "I bought vegetables and fruits.",
                "The market was very crowded.",
                "I returned home after buying all the items."
            ],
            "vocabulary": [
                {"nepali": "बजार", "english": "market", "romanization": "bazaar"},
                {"nepali": "तरकारी", "english": "vegetables", "romanization": "tarkari"},
                {"nepali": "किन्नु", "english": "to buy", "romanization": "kinnu"},
            ],
            "questions": [
                {"question": "बजारमा के किन्यो?", "options": ["कपडा", "तरकारी र फलफूल", "किताब", "खेलौना"], "correctAnswer": "तरकारी र फलफूल"},
            ]
        },
        {
            "title": "यात्रा",
            "englishTitle": "A Journey",
            "difficulty": "medium",
            "paragraphs": [
                "हामी पोखरा जाँदैछौं।",
                "बसमा तीन घण्टा लाग्छ।",
                "बाटोमा राम्रो दृश्य छ।",
                "पोखरा राम्रो ठाउँ हो।"
            ],
            "englishParagraphs": [
                "We are going to Pokhara.",
                "It takes three hours by bus.",
                "There is beautiful scenery on the way.",
                "Pokhara is a nice place."
            ],
            "vocabulary": [
                {"nepali": "यात्रा", "english": "journey", "romanization": "yatra"},
                {"nepali": "दृश्य", "english": "scenery", "romanization": "drishya"},
            ],
            "questions": [
                {"question": "पोखरा जान कति समय लाग्छ?", "options": ["एक घण्टा", "दुई घण्टा", "तीन घण्टा", "चार घण्टा"], "correctAnswer": "तीन घण्टा"},
            ]
        },
    ],
    "intermediate": [
        {
            "title": "नेपालको संस्कृति",
            "englishTitle": "Culture of Nepal",
            "difficulty": "medium-hard",
            "paragraphs": [
                "नेपालको संस्कृति धेरै पुरानो छ।",
                "यहाँ विभिन्न जातजाति र धर्मका मानिसहरू बस्छन्।",
                "दशैं र तिहार नेपालका ठूला चाडहरू हुन्।",
                "नेपालीहरू अतिथिलाई देवता मान्छन्।",
                "नेपालको संस्कृति विश्वमा प्रसिद्ध छ।"
            ],
            "englishParagraphs": [
                "Nepal's culture is very old.",
                "People of different castes and religions live here.",
                "Dashain and Tihar are the big festivals of Nepal.",
                "Nepalis consider guests as gods.",
                "Nepal's culture is famous in the world."
            ],
            "vocabulary": [
                {"nepali": "संस्कृति", "english": "culture", "romanization": "sanskriti"},
                {"nepali": "चाड", "english": "festival", "romanization": "chaad"},
                {"nepali": "अतिथि", "english": "guest", "romanization": "atithi"},
            ],
            "questions": [
                {"question": "नेपालका ठूला चाडहरू के हुन्?", "options": ["होली र दिवाली", "दशैं र तिहार", "क्रिसमस", "इद"], "correctAnswer": "दशैं र तिहार"},
            ]
        },
        {
            "title": "शिक्षाको महत्व",
            "englishTitle": "Importance of Education",
            "difficulty": "medium-hard",
            "paragraphs": [
                "शिक्षा जीवनको महत्वपूर्ण अंग हो।",
                "शिक्षाले मानिसलाई ज्ञान दिन्छ।",
                "पढेका मानिसहरूले राम्रो जागिर पाउँछन्।",
                "शिक्षाले समाजको विकास गर्छ।"
            ],
            "englishParagraphs": [
                "Education is an important part of life.",
                "Education gives knowledge to people.",
                "Educated people get good jobs.",
                "Education develops society."
            ],
            "vocabulary": [
                {"nepali": "शिक्षा", "english": "education", "romanization": "shiksha"},
                {"nepali": "ज्ञान", "english": "knowledge", "romanization": "gyan"},
                {"nepali": "विकास", "english": "development", "romanization": "bikas"},
            ],
            "questions": [
                {"question": "शिक्षाले के दिन्छ?", "options": ["पैसा", "ज्ञान", "खाना", "कपडा"], "correctAnswer": "ज्ञान"},
            ]
        },
    ],
    "advanced": [
        {
            "title": "नेपालको अर्थतन्त्र",
            "englishTitle": "Economy of Nepal",
            "difficulty": "hard",
            "paragraphs": [
                "नेपाल एक विकासोन्मुख देश हो।",
                "कृषि नेपालको मुख्य आर्थिक क्षेत्र हो।",
                "पर्यटन उद्योग पनि महत्वपूर्ण छ।",
                "विदेशमा काम गर्ने नेपालीहरूको रेमिट्यान्स अर्थतन्त्रमा ठूलो योगदान गर्छ।",
                "सरकारले आर्थिक विकासको लागि विभिन्न योजनाहरू बनाएको छ।"
            ],
            "englishParagraphs": [
                "Nepal is a developing country.",
                "Agriculture is the main economic sector of Nepal.",
                "Tourism industry is also important.",
                "Remittances from Nepalis working abroad contribute greatly to the economy.",
                "The government has made various plans for economic development."
            ],
            "vocabulary": [
                {"nepali": "अर्थतन्त्र", "english": "economy", "romanization": "arthatantra"},
                {"nepali": "विकासोन्मुख", "english": "developing", "romanization": "bikasonmukh"},
                {"nepali": "रेमिट्यान्स", "english": "remittance", "romanization": "remittance"},
            ],
            "questions": [
                {"question": "नेपालको मुख्य आर्थिक क्षेत्र के हो?", "options": ["उद्योग", "कृषि", "पर्यटन", "व्यापार"], "correctAnswer": "कृषि"},
            ]
        },
    ],
    "proficient": [
        {
            "title": "नेपाली साहित्यको इतिहास",
            "englishTitle": "History of Nepali Literature",
            "difficulty": "very hard",
            "paragraphs": [
                "नेपाली साहित्यको इतिहास धेरै पुरानो छ।",
                "भानुभक्त आचार्यलाई आदिकवि मानिन्छ।",
                "उहाँले रामायण नेपाली भाषामा अनुवाद गर्नुभयो।",
                "लक्ष्मीप्रसाद देवकोटालाई महाकवि भनिन्छ।",
                "नेपाली साहित्यमा कविता, कथा, उपन्यास र निबन्ध सबै विधाहरू छन्।",
                "आधुनिक साहित्यले समाजका विभिन्न पक्षहरूलाई चित्रण गर्छ।"
            ],
            "englishParagraphs": [
                "The history of Nepali literature is very old.",
                "Bhanubhakta Acharya is considered the first poet.",
                "He translated Ramayana into Nepali language.",
                "Laxmi Prasad Devkota is called the great poet.",
                "Nepali literature has all genres including poetry, stories, novels and essays.",
                "Modern literature portrays various aspects of society."
            ],
            "vocabulary": [
                {"nepali": "साहित्य", "english": "literature", "romanization": "sahitya"},
                {"nepali": "आदिकवि", "english": "first poet", "romanization": "aadikavi"},
                {"nepali": "महाकवि", "english": "great poet", "romanization": "mahakavi"},
            ],
            "questions": [
                {"question": "नेपाली साहित्यको आदिकवि को हुन्?", "options": ["लक्ष्मीप्रसाद देवकोटा", "भानुभक्त आचार्य", "मोतिराम भट्ट", "लेखनाथ पौड्याल"], "correctAnswer": "भानुभक्त आचार्य"},
            ]
        },
    ],
}

# ═══════════════════════════════════════════════════════════════════════════════
# SPEAKING DATA - Level-based pronunciation and conversation practice
# ═══════════════════════════════════════════════════════════════════════════════

SPEAKING_DATA = {
    "beginner": [
        {
            "id": "beginner_speak_001",
            "title": "Basic Greetings",
            "description": "Learn to greet people in Nepali",
            "phrases": [
                {"nepali": "नमस्ते", "romanization": "namaste", "english": "Hello", "audioText": "नमस्ते"},
                {"nepali": "धन्यवाद", "romanization": "dhanyabad", "english": "Thank you", "audioText": "धन्यवाद"},
                {"nepali": "माफ गर्नुहोस्", "romanization": "maaf garnuhos", "english": "Sorry", "audioText": "माफ गर्नुहोस्"},
            ],
            "dialogues": [
                {"speaker": "A", "nepali": "नमस्ते, तपाईंलाई कस्तो छ?", "english": "Hello, how are you?"},
                {"speaker": "B", "nepali": "नमस्ते, म ठीक छु। तपाईंलाई?", "english": "Hello, I am fine. And you?"},
            ],
        },
        {
            "id": "beginner_speak_002",
            "title": "Introducing Yourself",
            "description": "Learn to introduce yourself",
            "phrases": [
                {"nepali": "मेरो नाम ... हो", "romanization": "mero naam ... ho", "english": "My name is ...", "audioText": "मेरो नाम राम हो"},
                {"nepali": "म ... बाट आएको हुँ", "romanization": "ma ... bata aayeko hun", "english": "I am from ...", "audioText": "म नेपाल बाट आएको हुँ"},
            ],
            "dialogues": [
                {"speaker": "A", "nepali": "तपाईंको नाम के हो?", "english": "What is your name?"},
                {"speaker": "B", "nepali": "मेरो नाम सीता हो।", "english": "My name is Sita."},
            ],
        },
        {
            "id": "beginner_speak_003",
            "title": "Numbers 1-10",
            "description": "Practice counting in Nepali",
            "phrases": [
                {"nepali": "एक", "romanization": "ek", "english": "One", "audioText": "एक"},
                {"nepali": "दुई", "romanization": "dui", "english": "Two", "audioText": "दुई"},
                {"nepali": "तीन", "romanization": "tin", "english": "Three", "audioText": "तीन"},
                {"nepali": "चार", "romanization": "char", "english": "Four", "audioText": "चार"},
                {"nepali": "पाँच", "romanization": "panch", "english": "Five", "audioText": "पाँच"},
            ],
            "dialogues": [],
        },
    ],
    "elementary": [
        {
            "id": "elementary_speak_001",
            "title": "At the Restaurant",
            "description": "Order food at a restaurant",
            "phrases": [
                {"nepali": "मेनु दिनुहोस्", "romanization": "menu dinuhos", "english": "Please give menu", "audioText": "मेनु दिनुहोस्"},
                {"nepali": "यो कति हो?", "romanization": "yo kati ho", "english": "How much is this?", "audioText": "यो कति हो?"},
                {"nepali": "बिल दिनुहोस्", "romanization": "bil dinuhos", "english": "Please give bill", "audioText": "बिल दिनुहोस्"},
            ],
            "dialogues": [
                {"speaker": "A", "nepali": "के खानुहुन्छ?", "english": "What will you eat?"},
                {"speaker": "B", "nepali": "दाल भात दिनुहोस्।", "english": "Please give dal bhat."},
            ],
        },
        {
            "id": "elementary_speak_002",
            "title": "Asking Directions",
            "description": "Ask and understand directions",
            "phrases": [
                {"nepali": "... कहाँ छ?", "romanization": "... kaha chha?", "english": "Where is ...?", "audioText": "बजार कहाँ छ?"},
                {"nepali": "दायाँ जानुहोस्", "romanization": "daya januhos", "english": "Go right", "audioText": "दायाँ जानुहोस्"},
                {"nepali": "सिधा जानुहोस्", "romanization": "sidha januhos", "english": "Go straight", "audioText": "सिधा जानुहोस्"},
            ],
            "dialogues": [
                {"speaker": "A", "nepali": "माफ गर्नुहोस्, बस स्टप कहाँ छ?", "english": "Excuse me, where is the bus stop?"},
                {"speaker": "B", "nepali": "सिधा जानुहोस्, त्यसपछि दायाँ।", "english": "Go straight, then turn right."},
            ],
        },
    ],
    "intermediate": [
        {
            "id": "intermediate_speak_001",
            "title": "At the Doctor",
            "description": "Describe symptoms to a doctor",
            "phrases": [
                {"nepali": "मलाई टाउको दुख्छ", "romanization": "malai tauko dukhchha", "english": "I have a headache", "audioText": "मलाई टाउको दुख्छ"},
                {"nepali": "मलाई ज्वरो आएको छ", "romanization": "malai jwaro aayeko chha", "english": "I have fever", "audioText": "मलाई ज्वरो आएको छ"},
            ],
            "dialogues": [
                {"speaker": "Doctor", "nepali": "के भयो?", "english": "What happened?"},
                {"speaker": "Patient", "nepali": "मलाई दुई दिनदेखि ज्वरो आएको छ।", "english": "I have had fever for two days."},
            ],
        },
        {
            "id": "intermediate_speak_002",
            "title": "Job Interview",
            "description": "Common phrases for job interviews",
            "phrases": [
                {"nepali": "मसँग पाँच वर्षको अनुभव छ", "romanization": "masanga panch barshako anubhav chha", "english": "I have 5 years experience", "audioText": "मसँग पाँच वर्षको अनुभव छ"},
                {"nepali": "म यो कामको लागि उपयुक्त छु", "romanization": "ma yo kaamko lagi upayukta chhu", "english": "I am suitable for this job", "audioText": "म यो कामको लागि उपयुक्त छु"},
            ],
            "dialogues": [
                {"speaker": "Interviewer", "nepali": "तपाईंको अनुभव के छ?", "english": "What is your experience?"},
                {"speaker": "Candidate", "nepali": "मसँग तीन वर्षको अनुभव छ।", "english": "I have three years of experience."},
            ],
        },
    ],
    "advanced": [
        {
            "id": "advanced_speak_001",
            "title": "Discussing Current Events",
            "description": "Discuss news and current affairs",
            "phrases": [
                {"nepali": "मेरो विचारमा...", "romanization": "mero bicharma...", "english": "In my opinion...", "audioText": "मेरो विचारमा यो राम्रो निर्णय हो"},
                {"nepali": "यो मुद्दा महत्वपूर्ण छ", "romanization": "yo mudda mahatwapurna chha", "english": "This issue is important", "audioText": "यो मुद्दा महत्वपूर्ण छ"},
            ],
            "dialogues": [
                {"speaker": "A", "nepali": "तपाईंको नयाँ नीतिबारे के विचार छ?", "english": "What is your opinion about the new policy?"},
                {"speaker": "B", "nepali": "मेरो विचारमा यसले अर्थतन्त्रलाई मद्दत गर्छ।", "english": "In my opinion, this will help the economy."},
            ],
        },
    ],
    "proficient": [
        {
            "id": "proficient_speak_001",
            "title": "Academic Discussion",
            "description": "Discuss academic and philosophical topics",
            "phrases": [
                {"nepali": "यो सिद्धान्त अनुसार...", "romanization": "yo siddhanta anusar...", "english": "According to this theory...", "audioText": "यो सिद्धान्त अनुसार"},
                {"nepali": "यसको विश्लेषण गर्दा...", "romanization": "yasko bishleshan garda...", "english": "Analyzing this...", "audioText": "यसको विश्लेषण गर्दा"},
            ],
            "dialogues": [
                {"speaker": "A", "nepali": "यो दार्शनिक सोचको बारेमा तपाईंको के धारणा छ?", "english": "What is your view on this philosophical thought?"},
                {"speaker": "B", "nepali": "यो विचारधाराले मानव अस्तित्वको गहिरो प्रश्न उठाउँछ।", "english": "This ideology raises deep questions about human existence."},
            ],
        },
    ],
}

# ═══════════════════════════════════════════════════════════════════════════════
# WRITING DATA - Level-based writing exercises
# ═══════════════════════════════════════════════════════════════════════════════

WRITING_DATA = {
    "beginner": [
        {
            "id": "beginner_write_001",
            "title": "Devanagari Vowels",
            "description": "Practice writing Nepali vowels",
            "type": "script",
            "characters": [
                {"character": "अ", "romanization": "a", "strokeOrder": "Start from top"},
                {"character": "आ", "romanization": "aa", "strokeOrder": "Write अ then add vertical line"},
                {"character": "इ", "romanization": "i", "strokeOrder": "Start from top curve"},
                {"character": "ई", "romanization": "ii", "strokeOrder": "Write इ then extend"},
                {"character": "उ", "romanization": "u", "strokeOrder": "Start from top left"},
                {"character": "ऊ", "romanization": "uu", "strokeOrder": "Write उ then add hook"},
                {"character": "ए", "romanization": "e", "strokeOrder": "Start from top horizontal"},
                {"character": "ऐ", "romanization": "ai", "strokeOrder": "Write ए then add mark"},
                {"character": "ओ", "romanization": "o", "strokeOrder": "Start from top"},
                {"character": "औ", "romanization": "au", "strokeOrder": "Write ओ then add mark"},
            ],
            "exercises": [
                {"instruction": "Write 'अ' five times", "expectedAnswer": "अ अ अ अ अ"},
                {"instruction": "Write 'आ' five times", "expectedAnswer": "आ आ आ आ आ"},
            ],
        },
        {
            "id": "beginner_write_002",
            "title": "Devanagari Consonants (Ka-Na)",
            "description": "Practice writing basic consonants",
            "type": "script",
            "characters": [
                {"character": "क", "romanization": "ka", "strokeOrder": "Start from top left"},
                {"character": "ख", "romanization": "kha", "strokeOrder": "Write क then add horizontal line"},
                {"character": "ग", "romanization": "ga", "strokeOrder": "Start from top"},
                {"character": "घ", "romanization": "gha", "strokeOrder": "Start from top left"},
                {"character": "ङ", "romanization": "nga", "strokeOrder": "Start from top"},
            ],
            "exercises": [
                {"instruction": "Write 'क' five times", "expectedAnswer": "क क क क क"},
                {"instruction": "Write 'ख' five times", "expectedAnswer": "ख ख ख ख ख"},
            ],
        },
        {
            "id": "beginner_write_003",
            "title": "Simple Words",
            "description": "Write simple Nepali words",
            "type": "words",
            "words": [
                {"word": "घर", "meaning": "house", "romanization": "ghar"},
                {"word": "पानी", "meaning": "water", "romanization": "pani"},
                {"word": "खाना", "meaning": "food", "romanization": "khana"},
                {"word": "नाम", "meaning": "name", "romanization": "naam"},
            ],
            "exercises": [
                {"instruction": "Write 'घर' (house)", "expectedAnswer": "घर"},
                {"instruction": "Write 'पानी' (water)", "expectedAnswer": "पानी"},
            ],
        },
    ],
    "elementary": [
        {
            "id": "elementary_write_001",
            "title": "Simple Sentences",
            "description": "Write basic sentences in Nepali",
            "type": "sentences",
            "examples": [
                {"nepali": "म घर जान्छु।", "english": "I go home.", "romanization": "Ma ghar janchhu."},
                {"nepali": "उनी किताब पढ्छन्।", "english": "They read books.", "romanization": "Uni kitab padhchhan."},
            ],
            "exercises": [
                {"instruction": "Write: I eat food", "hint": "म ... खान्छु", "expectedAnswer": "म खाना खान्छु।"},
                {"instruction": "Write: She goes to school", "hint": "ऊ ... जान्छे", "expectedAnswer": "ऊ विद्यालय जान्छे।"},
            ],
        },
        {
            "id": "elementary_write_002",
            "title": "Numbers in Words",
            "description": "Write numbers as words",
            "type": "numbers",
            "examples": [
                {"number": 11, "nepali": "एघार", "romanization": "eghara"},
                {"number": 20, "nepali": "बीस", "romanization": "bis"},
                {"number": 50, "nepali": "पचास", "romanization": "pachas"},
                {"number": 100, "nepali": "सय", "romanization": "saya"},
            ],
            "exercises": [
                {"instruction": "Write 15 in Nepali", "expectedAnswer": "पन्ध्र"},
                {"instruction": "Write 25 in Nepali", "expectedAnswer": "पच्चीस"},
            ],
        },
    ],
    "intermediate": [
        {
            "id": "intermediate_write_001",
            "title": "Paragraph Writing",
            "description": "Write short paragraphs",
            "type": "paragraph",
            "topics": [
                {"topic": "My Family", "nepaliTopic": "मेरो परिवार", "hints": ["परिवारको सदस्य", "के गर्छन्", "कहाँ बस्छन्"]},
                {"topic": "My Daily Routine", "nepaliTopic": "मेरो दैनिक दिनचर्या", "hints": ["बिहान", "दिउँसो", "साँझ"]},
            ],
            "exercises": [
                {"instruction": "Write 3-4 sentences about your family", "minWords": 20},
                {"instruction": "Write about your daily routine", "minWords": 30},
            ],
        },
        {
            "id": "intermediate_write_002",
            "title": "Letter Writing",
            "description": "Write informal letters",
            "type": "letter",
            "examples": [
                {
                    "type": "Informal Letter",
                    "format": "प्रिय ...,\n\nसप्रेम नमस्कार।\n\n[शरीर]\n\nतपाईंको,\n[नाम]"
                }
            ],
            "exercises": [
                {"instruction": "Write a letter to your friend about your vacation", "minWords": 50},
            ],
        },
    ],
    "advanced": [
        {
            "id": "advanced_write_001",
            "title": "Essay Writing",
            "description": "Write structured essays",
            "type": "essay",
            "topics": [
                {"topic": "Importance of Education", "nepaliTopic": "शिक्षाको महत्व", "structure": ["परिचय", "महत्व", "निष्कर्ष"]},
                {"topic": "Environmental Protection", "nepaliTopic": "वातावरण संरक्षण", "structure": ["समस्या", "कारण", "समाधान"]},
            ],
            "exercises": [
                {"instruction": "Write an essay on 'Importance of Education' (150+ words)", "minWords": 150},
            ],
        },
        {
            "id": "advanced_write_002",
            "title": "Formal Letter Writing",
            "description": "Write formal/official letters",
            "type": "formal_letter",
            "examples": [
                {
                    "type": "Application Letter",
                    "format": "श्री ...,\n[पद],\n[संस्था],\n\nविषय: ...\n\nमहोदय,\n\n[शरीर]\n\nभवदीय,\n[नाम]\n[मिति]"
                }
            ],
            "exercises": [
                {"instruction": "Write a job application letter", "minWords": 100},
            ],
        },
    ],
    "proficient": [
        {
            "id": "proficient_write_001",
            "title": "Creative Writing",
            "description": "Write creative pieces",
            "type": "creative",
            "topics": [
                {"topic": "Short Story", "nepaliTopic": "छोटो कथा", "hints": ["पात्र", "कथावस्तु", "अन्त्य"]},
                {"topic": "Poetry", "nepaliTopic": "कविता", "hints": ["विषय", "भाव", "लय"]},
            ],
            "exercises": [
                {"instruction": "Write a short story (200+ words)", "minWords": 200},
                {"instruction": "Write a poem on nature", "minWords": 50},
            ],
        },
        {
            "id": "proficient_write_002",
            "title": "Academic Writing",
            "description": "Write academic papers",
            "type": "academic",
            "topics": [
                {"topic": "Research Summary", "nepaliTopic": "अनुसन्धान सारांश", "structure": ["उद्देश्य", "विधि", "निष्कर्ष"]},
            ],
            "exercises": [
                {"instruction": "Write a research summary on a topic of your choice", "minWords": 250},
            ],
        },
    ],
}

# ═══════════════════════════════════════════════════════════════════════════════
# GENERATOR FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

def generate_vocabulary():
    """Generate vocabulary.json"""
    vocab_data = {
        "category": "vocabulary",
        "description": "Comprehensive Nepali vocabulary organized by level",
        "levels": {}
    }
    
    for level, categories in VOCABULARY_DATA.items():
        vocab_data["levels"][level] = []
        item_index = 1
        
        for category, words in categories.items():
            for nepali, english, romanization, meaning in words:
                vocab_item = {
                    "id": f"{level}_vocab_{category}_{item_index:03d}",
                    "nepali": nepali,
                    "english": english,
                    "romanization": romanization,
                    "meaning": meaning,
                    "examples": [f"{nepali}"],
                    "audioUrl": None,
                    "category": category,
                    "level": level.capitalize()
                }
                vocab_data["levels"][level].append(vocab_item)
                item_index += 1
    
    return vocab_data


def generate_grammar():
    """Generate grammar.json"""
    grammar_data = {
        "category": "grammar",
        "description": "Nepali grammar points organized by level",
        "levels": {}
    }
    
    for level, points in GRAMMAR_DATA.items():
        grammar_data["levels"][level] = []
        for i, point in enumerate(points):
            grammar_data["levels"][level].append({
                "id": f"{level}_gram_{i+1:03d}",
                "title": point["title"],
                "pattern": point["pattern"],
                "meaning": point["meaning"],
                "usage": point["usage"],
                "examples": point["examples"],
                "level": level.capitalize(),
                "notes": point.get("notes")
            })
    
    return grammar_data


def generate_practice():
    """Generate practice.json with questions for all levels"""
    practice_data = {
        "category": "practice",
        "description": "Practice questions organized by level and category",
        "levels": {}
    }
    
    for level in ["beginner", "elementary", "intermediate", "advanced", "proficient"]:
        practice_data["levels"][level] = {
            "vocabulary": [],
            "grammar": [],
            "listening": []
        }
        
        if level in VOCABULARY_DATA:
            vocab_items = []
            for category, words in VOCABULARY_DATA[level].items():
                vocab_items.extend(words)
            
            # Generate vocabulary questions
            for i, (nepali, english, romanization, meaning) in enumerate(vocab_items[:15]):
                other_options = [w[1] for w in vocab_items if w[0] != nepali][:3]
                options = [english] + other_options
                random.shuffle(options)
                
                practice_data["levels"][level]["vocabulary"].append({
                    "id": f"{level}_vocab_q_{i+1:03d}",
                    "question": f"What does '{nepali}' mean?",
                    "options": options,
                    "correctAnswer": english,
                    "explanation": f"{nepali} ({romanization}) means {english}",
                    "category": "vocabulary",
                    "level": level.capitalize(),
                    "audioText": nepali
                })
            
            # Generate listening questions
            for i, (nepali, english, romanization, meaning) in enumerate(vocab_items[:10]):
                other_options = [w[1] for w in vocab_items if w[0] != nepali][:3]
                options = [english] + other_options
                random.shuffle(options)
                
                practice_data["levels"][level]["listening"].append({
                    "id": f"{level}_listen_q_{i+1:03d}",
                    "question": "Listen and select the correct meaning",
                    "options": options,
                    "correctAnswer": english,
                    "explanation": f"The word was '{nepali}' meaning '{english}'",
                    "category": "listening",
                    "level": level.capitalize(),
                    "audioText": nepali
                })
        
        # Add grammar questions
        grammar_questions = [
            {"question": "Which ending is for first person singular present tense?", "options": ["छु", "छ", "छन्", "छौ"], "correct": "छु", "explanation": "छु is used for 'I' (म)"},
            {"question": "What is the negative of 'म जान्छु'?", "options": ["म जान्दिनँ", "म जाएन", "म जान्न", "म नजानु"], "correct": "म जान्दिनँ", "explanation": "जान्दिनँ is the negative form"},
            {"question": "Which postposition means 'in/at'?", "options": ["मा", "बाट", "सँग", "लाई"], "correct": "मा", "explanation": "मा indicates location"},
        ]
        
        for i, q in enumerate(grammar_questions):
            practice_data["levels"][level]["grammar"].append({
                "id": f"{level}_gram_q_{i+1:03d}",
                "question": q["question"],
                "options": q["options"],
                "correctAnswer": q["correct"],
                "explanation": q["explanation"],
                "category": "grammar",
                "level": level.capitalize(),
                "audioText": None
            })
    
    return practice_data


def generate_reading():
    """Generate reading.json"""
    reading_data = {
        "category": "reading",
        "description": "Reading passages organized by level",
        "levels": {}
    }
    
    for level, passages in READING_DATA.items():
        reading_data["levels"][level] = []
        for i, passage in enumerate(passages):
            reading_data["levels"][level].append({
                "id": f"{level}_read_{i+1:03d}",
                "title": passage["title"],
                "englishTitle": passage["englishTitle"],
                "difficulty": passage["difficulty"],
                "paragraphs": passage["paragraphs"],
                "englishParagraphs": passage["englishParagraphs"],
                "vocabulary": passage["vocabulary"],
                "questions": passage["questions"],
                "level": level.capitalize()
            })
    
    return reading_data


def generate_speaking():
    """Generate speaking.json"""
    speaking_data = {
        "category": "speaking",
        "description": "Speaking and pronunciation practice organized by level",
        "levels": {}
    }
    
    for level, lessons in SPEAKING_DATA.items():
        speaking_data["levels"][level] = lessons
    
    return speaking_data


def generate_writing():
    """Generate writing.json"""
    writing_data = {
        "category": "writing",
        "description": "Writing exercises organized by level",
        "levels": {}
    }
    
    for level, exercises in WRITING_DATA.items():
        writing_data["levels"][level] = exercises
    
    return writing_data


def generate_games():
    """Generate games.json"""
    games_data = {
        "category": "games",
        "description": "Mini-games for practicing Nepali",
        "levels": {
            "beginner": [
                {"id": "beginner_game_001", "type": "matching", "title": "Word Match", "description": "Match Nepali words with meanings", "icon": "rectangle.grid.2x2", "timeLimit": 60, "level": "Beginner"},
                {"id": "beginner_game_002", "type": "flashcard", "title": "Speed Cards", "description": "Review flashcards quickly", "icon": "bolt.fill", "timeLimit": 120, "level": "Beginner"},
            ],
            "elementary": [
                {"id": "elementary_game_001", "type": "sentence", "title": "Sentence Builder", "description": "Arrange words to form sentences", "icon": "text.alignleft", "timeLimit": 120, "level": "Elementary"},
            ],
            "intermediate": [
                {"id": "intermediate_game_001", "type": "fill_blank", "title": "Fill in the Blank", "description": "Complete sentences", "icon": "rectangle.and.pencil.and.ellipsis", "timeLimit": 150, "level": "Intermediate"},
            ],
            "advanced": [
                {"id": "advanced_game_001", "type": "translation", "title": "Quick Translate", "description": "Translate sentences quickly", "icon": "globe", "timeLimit": 180, "level": "Advanced"},
            ],
            "proficient": [
                {"id": "proficient_game_001", "type": "dictation", "title": "Dictation", "description": "Write what you hear", "icon": "ear.fill", "timeLimit": 200, "level": "Proficient"},
            ]
        }
    }
    return games_data


def save_json(data, filename):
    """Save data to JSON file"""
    filepath = RESOURCES_PATH / filename
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    print(f"  ✅ {filename}")


def main():
    """Main function to generate all data files"""
    print("=" * 60)
    print("NPLearn Data Generator")
    print("=" * 60)
    print()
    print("NOTE: This generates HARDCODED data - no web search or AI")
    print()
    
    RESOURCES_PATH.mkdir(parents=True, exist_ok=True)
    
    print("Generating data files...")
    
    vocab_data = generate_vocabulary()
    save_json(vocab_data, "vocabulary.json")
    
    grammar_data = generate_grammar()
    save_json(grammar_data, "grammar.json")
    
    practice_data = generate_practice()
    save_json(practice_data, "practice.json")
    
    reading_data = generate_reading()
    save_json(reading_data, "reading.json")
    
    speaking_data = generate_speaking()
    save_json(speaking_data, "speaking.json")
    
    writing_data = generate_writing()
    save_json(writing_data, "writing.json")
    
    games_data = generate_games()
    save_json(games_data, "games.json")
    
    # Print summary
    print()
    print("=" * 60)
    print("Summary by Level:")
    print("=" * 60)
    print(f"{'Level':<15} {'Vocab':<8} {'Grammar':<8} {'Practice':<10} {'Reading':<8} {'Speaking':<10} {'Writing':<8}")
    print("-" * 60)
    
    for level in ["beginner", "elementary", "intermediate", "advanced", "proficient"]:
        vocab = len(vocab_data["levels"].get(level, []))
        grammar = len(grammar_data["levels"].get(level, []))
        practice = sum(len(v) for v in practice_data["levels"].get(level, {}).values())
        reading = len(reading_data["levels"].get(level, []))
        speaking = len(speaking_data["levels"].get(level, []))
        writing = len(writing_data["levels"].get(level, []))
        print(f"{level.capitalize():<15} {vocab:<8} {grammar:<8} {practice:<10} {reading:<8} {speaking:<10} {writing:<8}")
    
    print()
    print("✅ All data generated successfully!")


if __name__ == "__main__":
    main()
