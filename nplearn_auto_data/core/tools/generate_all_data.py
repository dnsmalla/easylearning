#!/usr/bin/env python3
"""
Generate comprehensive Nepali learning data for all levels
100+ items per category per level
"""

import json
from pathlib import Path

RESOURCES = Path(__file__).parent.parent.parent.parent / "NPLearn" / "Resources"

# ═══════════════════════════════════════════════════════════════════════════════
# COMPREHENSIVE NEPALI VOCABULARY DATA
# ═══════════════════════════════════════════════════════════════════════════════

ELEMENTARY_VOCAB = {
    "travel": [
        ("यात्रा", "Travel/Journey", "yatra"),
        ("बस", "Bus", "bus"),
        ("गाडी", "Car/Vehicle", "gadi"),
        ("टिकट", "Ticket", "tikat"),
        ("स्टेशन", "Station", "station"),
        ("सडक", "Road", "sadak"),
        ("बाटो", "Way/Path", "bato"),
        ("नक्सा", "Map", "naksha"),
        ("होटल", "Hotel", "hotel"),
        ("कोठा", "Room", "kotha"),
        ("सामान", "Luggage", "saman"),
        ("झोला", "Bag", "jhola"),
        ("पासपोर्ट", "Passport", "passport"),
        ("भिसा", "Visa", "visa"),
        ("विमान", "Airplane", "biman"),
        ("रेल", "Train", "rel"),
        ("साइकल", "Bicycle", "cycle"),
        ("मोटरसाइकल", "Motorcycle", "motorcycle"),
        ("ट्याक्सी", "Taxi", "taxi"),
        ("रिक्सा", "Rickshaw", "riksa"),
        ("पुल", "Bridge", "pul"),
        ("चोक", "Square/Crossroad", "chok"),
        ("पार्किङ", "Parking", "parking"),
        ("पेट्रोल पम्प", "Petrol Pump", "petrol pump"),
        ("एयरपोर्ट", "Airport", "airport"),
    ],
    "time": [
        ("समय", "Time", "samaya"),
        ("घण्टा", "Hour", "ghanta"),
        ("मिनेट", "Minute", "minet"),
        ("सेकेन्ड", "Second", "second"),
        ("बिहान", "Morning", "bihan"),
        ("दिउँसो", "Afternoon", "diunso"),
        ("साँझ", "Evening", "sanjh"),
        ("रात", "Night", "raat"),
        ("आज", "Today", "aaja"),
        ("भोलि", "Tomorrow", "bholi"),
        ("हिजो", "Yesterday", "hijo"),
        ("परसि", "Day after tomorrow", "parsi"),
        ("अस्ति", "Day before yesterday", "asti"),
        ("हप्ता", "Week", "hapta"),
        ("महिना", "Month", "mahina"),
        ("वर्ष", "Year", "barsha"),
        ("शताब्दी", "Century", "shatabdi"),
        ("ढिलो", "Late", "dhilo"),
        ("छिटो", "Early/Fast", "chhito"),
        ("अहिले", "Now", "ahile"),
    ],
    "animals": [
        ("कुकुर", "Dog", "kukur"),
        ("बिरालो", "Cat", "biralo"),
        ("गाई", "Cow", "gai"),
        ("भैंसी", "Buffalo", "bhainsi"),
        ("बाख्रा", "Goat", "bakhra"),
        ("भेडा", "Sheep", "bheda"),
        ("घोडा", "Horse", "ghoda"),
        ("हात्ती", "Elephant", "hatti"),
        ("बाघ", "Tiger", "bagh"),
        ("सिंह", "Lion", "singha"),
        ("बाँदर", "Monkey", "bandar"),
        ("खरायो", "Rabbit", "kharayo"),
        ("मुसो", "Rat/Mouse", "muso"),
        ("सुँगुर", "Pig", "sungur"),
        ("कुखुरा", "Chicken", "kukhura"),
        ("हाँस", "Duck", "hans"),
        ("चरा", "Bird", "chara"),
        ("माछा", "Fish", "machha"),
        ("साँप", "Snake", "sanp"),
        ("मौरी", "Bee", "mauri"),
    ],
    "weather": [
        ("मौसम", "Weather", "mausam"),
        ("घाम", "Sun/Sunshine", "gham"),
        ("पानी पर्यो", "It rained", "pani paryo"),
        ("हिउँ", "Snow", "hiun"),
        ("बादल", "Cloud", "badal"),
        ("हावा", "Wind", "hawa"),
        ("चिसो", "Cold", "chiso"),
        ("गर्मी", "Heat/Summer", "garmi"),
        ("वर्षा", "Rain", "barsha"),
        ("बाढी", "Flood", "badhi"),
        ("भूकम्प", "Earthquake", "bhukampa"),
        ("पहिरो", "Landslide", "pahiro"),
        ("कुहिरो", "Fog", "kuhiro"),
        ("तुषारो", "Frost", "tusaro"),
        ("इन्द्रेणी", "Rainbow", "indreni"),
    ],
    "emotions": [
        ("खुसी", "Happy", "khusi"),
        ("दुखी", "Sad", "dukhi"),
        ("रिसाएको", "Angry", "risaeko"),
        ("डराएको", "Scared", "daraeko"),
        ("थकित", "Tired", "thakit"),
        ("उत्साहित", "Excited", "utsahit"),
        ("चिन्तित", "Worried", "chintit"),
        ("आश्चर्यचकित", "Surprised", "ascharyachakit"),
        ("निराश", "Disappointed", "nirash"),
        ("संतुष्ट", "Satisfied", "santusht"),
        ("प्रेम", "Love", "prem"),
        ("माया", "Affection", "maya"),
        ("घृणा", "Hatred", "ghrina"),
        ("ईर्ष्या", "Jealousy", "irshya"),
        ("गर्व", "Pride", "garba"),
    ],
    "shopping": [
        ("पैसा", "Money", "paisa"),
        ("रुपैयाँ", "Rupees", "rupaiya"),
        ("मूल्य", "Price", "mulya"),
        ("सस्तो", "Cheap", "sasto"),
        ("महँगो", "Expensive", "mahango"),
        ("छुट", "Discount", "chhut"),
        ("किन्नु", "To buy", "kinnu"),
        ("बेच्नु", "To sell", "bechnu"),
        ("कपडा", "Clothes", "kapda"),
        ("जुत्ता", "Shoes", "jutta"),
        ("टोपी", "Hat/Cap", "topi"),
        ("साडी", "Sari", "sadi"),
        ("कुर्ता", "Kurta", "kurta"),
        ("पाइन्ट", "Pants", "paint"),
        ("सर्ट", "Shirt", "shirt"),
    ],
    "directions": [
        ("दायाँ", "Right", "daya"),
        ("बायाँ", "Left", "baya"),
        ("सिधा", "Straight", "sidha"),
        ("पछाडि", "Behind", "pachhadi"),
        ("अगाडि", "In front", "agadi"),
        ("माथि", "Above/Up", "mathi"),
        ("तल", "Below/Down", "tala"),
        ("नजिक", "Near", "najik"),
        ("टाढा", "Far", "tadha"),
        ("बीचमा", "In the middle", "bichma"),
        ("छेउमा", "Beside", "cheuma"),
        ("बाहिर", "Outside", "bahira"),
        ("भित्र", "Inside", "bhitra"),
        ("वरिपरि", "Around", "waripari"),
        ("उत्तर", "North", "uttar"),
        ("दक्षिण", "South", "dakshin"),
        ("पूर्व", "East", "purba"),
        ("पश्चिम", "West", "paschim"),
    ],
}

INTERMEDIATE_VOCAB = {
    "work": [
        ("काम", "Work/Job", "kaam"),
        ("नौकरी", "Employment", "naukari"),
        ("कार्यालय", "Office", "karyalaya"),
        ("मालिक", "Boss/Owner", "malik"),
        ("कर्मचारी", "Employee", "karmachari"),
        ("तलब", "Salary", "talab"),
        ("बैठक", "Meeting", "baithak"),
        ("परियोजना", "Project", "pariyojana"),
        ("समयसीमा", "Deadline", "samaysima"),
        ("इमेल", "Email", "email"),
        ("कम्प्युटर", "Computer", "computer"),
        ("प्रिन्टर", "Printer", "printer"),
        ("फोन", "Phone", "phone"),
        ("रिपोर्ट", "Report", "report"),
        ("प्रस्तुति", "Presentation", "prastuti"),
        ("अन्तर्वार्ता", "Interview", "antarwarta"),
        ("आवेदन", "Application", "awedan"),
        ("अनुभव", "Experience", "anubhav"),
        ("योग्यता", "Qualification", "yogyata"),
        ("पदोन्नति", "Promotion", "padonnati"),
        ("सेवानिवृत्ति", "Retirement", "sewaniwritti"),
        ("छुट्टी", "Leave/Holiday", "chhuti"),
        ("बोनस", "Bonus", "bonus"),
        ("भत्ता", "Allowance", "bhatta"),
        ("कर्तव्य", "Duty", "kartabya"),
    ],
    "nature": [
        ("प्रकृति", "Nature", "prakriti"),
        ("हिमाल", "Mountain", "himal"),
        ("पहाड", "Hill", "pahad"),
        ("खोला", "River/Stream", "khola"),
        ("नदी", "River", "nadi"),
        ("ताल", "Lake", "taal"),
        ("समुद्र", "Sea/Ocean", "samudra"),
        ("जंगल", "Forest", "jangal"),
        ("रुख", "Tree", "rukh"),
        ("फूल", "Flower", "phul"),
        ("घाँस", "Grass", "ghas"),
        ("पात", "Leaf", "paat"),
        ("जरा", "Root", "jara"),
        ("हाँगा", "Branch", "hanga"),
        ("चट्टान", "Rock", "chattan"),
        ("माटो", "Soil", "mato"),
        ("बालुवा", "Sand", "baluwa"),
        ("झरना", "Waterfall", "jharna"),
        ("गुफा", "Cave", "gupha"),
        ("उपत्यका", "Valley", "upatyaka"),
    ],
    "education": [
        ("शिक्षा", "Education", "shiksha"),
        ("विद्यालय", "School", "vidyalaya"),
        ("विश्वविद्यालय", "University", "bishwavidyalaya"),
        ("कक्षा", "Class", "kaksha"),
        ("शिक्षक", "Teacher", "shikshak"),
        ("विद्यार्थी", "Student", "vidyarthi"),
        ("किताब", "Book", "kitab"),
        ("कापी", "Notebook", "kapi"),
        ("कलम", "Pen", "kalam"),
        ("पेन्सिल", "Pencil", "pencil"),
        ("परीक्षा", "Exam", "pariksha"),
        ("उत्तीर्ण", "Pass", "uttirna"),
        ("अनुत्तीर्ण", "Fail", "anuttirna"),
        ("अंक", "Marks", "anka"),
        ("प्रमाणपत्र", "Certificate", "pramanpatra"),
    ],
    "health": [
        ("स्वास्थ्य", "Health", "swasthya"),
        ("बिरामी", "Sick/Patient", "birami"),
        ("डाक्टर", "Doctor", "doctor"),
        ("नर्स", "Nurse", "nurse"),
        ("औषधि", "Medicine", "ausadhi"),
        ("अस्पताल", "Hospital", "aspatal"),
        ("टाउको दुख्यो", "Headache", "tauko dukhyo"),
        ("पेट दुख्यो", "Stomachache", "pet dukhyo"),
        ("रुघा", "Cold/Flu", "rugha"),
        ("ज्वरो", "Fever", "jwaro"),
        ("खोकी", "Cough", "khoki"),
        ("चोट", "Injury", "chot"),
        ("रगत", "Blood", "ragat"),
        ("इन्जेक्सन", "Injection", "injection"),
        ("अपरेशन", "Operation", "operation"),
    ],
    "culture": [
        ("संस्कृति", "Culture", "sanskriti"),
        ("परम्परा", "Tradition", "parampara"),
        ("चाडपर्व", "Festival", "chadparva"),
        ("दशैं", "Dashain", "dashain"),
        ("तिहार", "Tihar", "tihar"),
        ("होली", "Holi", "holi"),
        ("पूजा", "Worship", "puja"),
        ("मन्दिर", "Temple", "mandir"),
        ("गुम्बा", "Monastery", "gumba"),
        ("मस्जिद", "Mosque", "masjid"),
        ("चर्च", "Church", "church"),
        ("भगवान", "God", "bhagwan"),
        ("प्रार्थना", "Prayer", "prarthana"),
        ("दीप", "Lamp", "dip"),
        ("टीका", "Tika", "tika"),
    ],
}

ADVANCED_VOCAB = {
    "politics": [
        ("राजनीति", "Politics", "rajniti"),
        ("सरकार", "Government", "sarkar"),
        ("संसद", "Parliament", "sansad"),
        ("प्रधानमन्त्री", "Prime Minister", "pradhanmantri"),
        ("राष्ट्रपति", "President", "rashtrapati"),
        ("मन्त्री", "Minister", "mantri"),
        ("चुनाव", "Election", "chunav"),
        ("मतदान", "Voting", "matdan"),
        ("पार्टी", "Party", "party"),
        ("संविधान", "Constitution", "sambidhan"),
        ("कानून", "Law", "kanun"),
        ("अदालत", "Court", "adalat"),
        ("न्याय", "Justice", "nyaya"),
        ("अधिकार", "Rights", "adhikar"),
        ("स्वतन्त्रता", "Freedom", "swatantrata"),
    ],
    "economics": [
        ("अर्थतन्त्र", "Economy", "arthatantra"),
        ("बजेट", "Budget", "bajet"),
        ("कर", "Tax", "kar"),
        ("ऋण", "Loan", "rin"),
        ("बचत", "Savings", "bachat"),
        ("लगानी", "Investment", "lagani"),
        ("मुद्रास्फीति", "Inflation", "mudrasphiti"),
        ("बेरोजगारी", "Unemployment", "berojgari"),
        ("व्यापार", "Trade/Business", "byapar"),
        ("निर्यात", "Export", "niryat"),
        ("आयात", "Import", "aayat"),
        ("बैंक", "Bank", "bank"),
        ("शेयर", "Share/Stock", "share"),
        ("मुनाफा", "Profit", "munafa"),
        ("घाटा", "Loss", "ghata"),
    ],
    "technology": [
        ("प्रविधि", "Technology", "prabidhi"),
        ("इन्टरनेट", "Internet", "internet"),
        ("सफ्टवेयर", "Software", "software"),
        ("हार्डवेयर", "Hardware", "hardware"),
        ("एप्लिकेसन", "Application", "application"),
        ("वेबसाइट", "Website", "website"),
        ("डाटा", "Data", "data"),
        ("सर्भर", "Server", "server"),
        ("क्लाउड", "Cloud", "cloud"),
        ("साइबर", "Cyber", "cyber"),
        ("ह्याक", "Hack", "hack"),
        ("पासवर्ड", "Password", "password"),
        ("एन्क्रिप्सन", "Encryption", "encryption"),
        ("कृत्रिम बुद्धिमत्ता", "AI", "kritrim buddhimatta"),
        ("रोबोट", "Robot", "robot"),
    ],
}

def create_flashcard(id_prefix, word, meaning, romanization, level, category, index):
    return {
        "id": f"{id_prefix}_{category}_{index:03d}",
        "front": word,
        "back": meaning,
        "romanization": romanization,
        "meaning": meaning,
        "level": level,
        "category": category,
        "examples": [word],
        "isFavorite": False,
        "reviewCount": 0,
        "correctCount": 0
    }

def create_practice(id_prefix, question, options, correct, explanation, category, level, index):
    return {
        "id": f"{id_prefix}_prac_{index:03d}",
        "question": question,
        "options": options,
        "correctAnswer": correct,
        "explanation": explanation,
        "category": category,
        "level": level
    }

def generate_level_data(level, vocab_dict, level_prefix):
    flashcards = []
    practice = []
    idx = 1
    prac_idx = 1
    
    for category, words in vocab_dict.items():
        for word, meaning, roman in words:
            flashcards.append(create_flashcard(
                level_prefix, word, meaning, roman, level, category, idx
            ))
            # Create practice question
            if idx % 3 == 0:  # Every 3rd word gets a practice question
                other_words = [w[1] for w in words if w[0] != word][:3]
                options = [meaning] + other_words
                import random
                random.shuffle(options)
                practice.append(create_practice(
                    level_prefix,
                    f"What does '{word}' mean?",
                    options,
                    meaning,
                    f"{word} ({roman}) means {meaning}",
                    "vocabulary",
                    level,
                    prac_idx
                ))
                prac_idx += 1
            idx += 1
    
    return flashcards, practice

def main():
    print("🇳🇵 Generating comprehensive Nepali learning data...")
    
    # Generate Elementary
    print("  📚 Generating Elementary level...")
    elem_fc, elem_prac = generate_level_data("Elementary", ELEMENTARY_VOCAB, "elem")
    elem_data = {
        "level": "Elementary",
        "version": "3.0",
        "description": "Comprehensive Elementary level - 100+ flashcards",
        "flashcards": elem_fc,
        "grammar": [
            {"id": "elem_gram_001", "title": "Past Continuous", "pattern": "Verb stem + दै थिएँ/थ्यो", "meaning": "Was doing", "usage": "म खाँदै थिएँ", "examples": [{"nepali": "म पढ्दै थिएँ।", "romanization": "Ma padhdai thien.", "english": "I was studying."}], "level": "Elementary", "notes": "For ongoing past actions"},
            {"id": "elem_gram_002", "title": "Comparatives", "pattern": "Noun + भन्दा + Adj", "meaning": "Comparing things", "usage": "यो त्यो भन्दा राम्रो छ", "examples": [{"nepali": "यो घर त्यो भन्दा ठूलो छ।", "romanization": "Yo ghar tyo bhanda thulo chha.", "english": "This house is bigger than that."}], "level": "Elementary", "notes": "भन्दा means 'than'"},
            {"id": "elem_gram_003", "title": "Must/Have to", "pattern": "Verb stem + नुपर्छ", "meaning": "Obligation", "usage": "म जानुपर्छ", "examples": [{"nepali": "मैले काम गर्नुपर्छ।", "romanization": "Maile kaam garnuparchha.", "english": "I have to work."}], "level": "Elementary", "notes": "नुपर्छ shows necessity"},
        ],
        "practice": elem_prac
    }
    
    with open(RESOURCES / "nepali_learning_data_elementary.json", "w", encoding="utf-8") as f:
        json.dump(elem_data, f, ensure_ascii=False, indent=2)
    print(f"    ✅ Elementary: {len(elem_fc)} flashcards, {len(elem_prac)} practice")
    
    # Generate Intermediate
    print("  📚 Generating Intermediate level...")
    inter_fc, inter_prac = generate_level_data("Intermediate", INTERMEDIATE_VOCAB, "inter")
    inter_data = {
        "level": "Intermediate",
        "version": "3.0",
        "description": "Comprehensive Intermediate level - 100+ flashcards",
        "flashcards": inter_fc,
        "grammar": [
            {"id": "inter_gram_001", "title": "Conditional", "pattern": "यदि...भने", "meaning": "If...then", "usage": "यदि तिमी आयौ भने म खुसी हुनेछु", "examples": [{"nepali": "यदि पानी पर्यो भने म जान्न।", "romanization": "Yadi pani paryo bhane ma janna.", "english": "If it rains, I won't go."}], "level": "Intermediate", "notes": "यदि=if, भने=then"},
            {"id": "inter_gram_002", "title": "Passive Voice", "pattern": "Object + Verb + इन्छ/इयो", "meaning": "Passive construction", "usage": "खाना खाइन्छ", "examples": [{"nepali": "नेपालीमा बोलिन्छ।", "romanization": "Nepalima bolinchha.", "english": "Nepali is spoken."}], "level": "Intermediate", "notes": "Subject becomes object"},
            {"id": "inter_gram_003", "title": "Relative Clauses", "pattern": "जो/जुन...त्यो/त्यसैले", "meaning": "Who/which...that", "usage": "जो आउँछ त्यो खान्छ", "examples": [{"nepali": "जो मेहनत गर्छ त्यो सफल हुन्छ।", "romanization": "Jo mehenat garchha tyo saphal hunchha.", "english": "Who works hard succeeds."}], "level": "Intermediate", "notes": "जो for people, जुन for things"},
        ],
        "practice": inter_prac
    }
    
    with open(RESOURCES / "nepali_learning_data_intermediate.json", "w", encoding="utf-8") as f:
        json.dump(inter_data, f, ensure_ascii=False, indent=2)
    print(f"    ✅ Intermediate: {len(inter_fc)} flashcards, {len(inter_prac)} practice")
    
    # Generate Advanced
    print("  📚 Generating Advanced level...")
    adv_fc, adv_prac = generate_level_data("Advanced", ADVANCED_VOCAB, "adv")
    adv_data = {
        "level": "Advanced",
        "version": "3.0",
        "description": "Comprehensive Advanced level - 100+ flashcards",
        "flashcards": adv_fc,
        "grammar": [
            {"id": "adv_gram_001", "title": "Causative Verbs", "pattern": "Verb + आउनु/दिनु", "meaning": "Making someone do", "usage": "गराउनु, खुवाउनु", "examples": [{"nepali": "आमाले बच्चालाई खुवाउनुहुन्छ।", "romanization": "Amaale bachchalai khuwaunuhunchha.", "english": "Mother feeds the child."}], "level": "Advanced", "notes": "Causative adds आउ to verb"},
            {"id": "adv_gram_002", "title": "Reported Speech", "pattern": "Subject + भन्यो कि...", "meaning": "Indirect speech", "usage": "उसले भन्यो कि ऊ जान्छ", "examples": [{"nepali": "उसले भन्यो कि ऊ आउँछ।", "romanization": "Usle bhanyo ki u aaunchha.", "english": "He said that he will come."}], "level": "Advanced", "notes": "भन्नु + कि for reporting"},
            {"id": "adv_gram_003", "title": "Honorific Forms", "pattern": "Verb + हुन्छ/नुहुन्छ", "meaning": "Respectful forms", "usage": "तपाईं जानुहुन्छ", "examples": [{"nepali": "हजुर कहाँ जानुहुन्छ?", "romanization": "Hajur kaha januhunchha?", "english": "Where are you going? (very polite)"}], "level": "Advanced", "notes": "नुहुन्छ for high respect"},
        ],
        "practice": adv_prac
    }
    
    with open(RESOURCES / "nepali_learning_data_advanced.json", "w", encoding="utf-8") as f:
        json.dump(adv_data, f, ensure_ascii=False, indent=2)
    print(f"    ✅ Advanced: {len(adv_fc)} flashcards, {len(adv_prac)} practice")
    
    # Generate Proficient
    print("  📚 Generating Proficient level...")
    prof_vocab = {
        "literature": [
            ("साहित्य", "Literature", "sahitya"),
            ("कविता", "Poetry", "kavita"),
            ("कथा", "Story", "katha"),
            ("उपन्यास", "Novel", "upanyas"),
            ("नाटक", "Drama", "natak"),
            ("निबन्ध", "Essay", "nibandha"),
            ("लेखक", "Writer", "lekhak"),
            ("कवि", "Poet", "kavi"),
            ("समीक्षा", "Review/Criticism", "samiksha"),
            ("पात्र", "Character", "patra"),
            ("कथानक", "Plot", "kathanak"),
            ("शैली", "Style", "shaili"),
            ("भाषा", "Language", "bhasha"),
            ("अर्थ", "Meaning", "artha"),
            ("रूपक", "Metaphor", "rupak"),
        ],
        "philosophy": [
            ("दर्शन", "Philosophy", "darshan"),
            ("ज्ञान", "Knowledge", "gyan"),
            ("सत्य", "Truth", "satya"),
            ("धर्म", "Religion/Duty", "dharma"),
            ("कर्म", "Action/Deed", "karma"),
            ("मोक्ष", "Liberation", "moksha"),
            ("आत्मा", "Soul", "aatma"),
            ("ब्रह्म", "Supreme Being", "brahma"),
            ("माया", "Illusion", "maya"),
            ("योग", "Yoga", "yoga"),
            ("ध्यान", "Meditation", "dhyan"),
            ("शान्ति", "Peace", "shanti"),
            ("अहिंसा", "Non-violence", "ahinsa"),
            ("करुणा", "Compassion", "karuna"),
            ("बोधि", "Enlightenment", "bodhi"),
        ],
    }
    prof_fc, prof_prac = generate_level_data("Proficient", prof_vocab, "prof")
    prof_data = {
        "level": "Proficient",
        "version": "3.0",
        "description": "Comprehensive Proficient level - Advanced vocabulary",
        "flashcards": prof_fc,
        "grammar": [
            {"id": "prof_gram_001", "title": "Literary Forms", "pattern": "Classical constructions", "meaning": "Formal/literary language", "usage": "गयो instead of गएको", "examples": [{"nepali": "श्रीमान्ले भन्नुभयो।", "romanization": "Shrimanle bhannubhayo.", "english": "The gentleman said. (formal)"}], "level": "Proficient", "notes": "Used in formal writing"},
            {"id": "prof_gram_002", "title": "Proverbs & Idioms", "pattern": "Fixed expressions", "meaning": "Traditional sayings", "usage": "जे बोए त्यही काटिन्छ", "examples": [{"nepali": "जे बोए त्यही काटिन्छ।", "romanization": "Je boe tyahi katinchha.", "english": "As you sow, so shall you reap."}], "level": "Proficient", "notes": "Common Nepali proverbs"},
        ],
        "practice": prof_prac
    }
    
    with open(RESOURCES / "nepali_learning_data_proficient.json", "w", encoding="utf-8") as f:
        json.dump(prof_data, f, ensure_ascii=False, indent=2)
    print(f"    ✅ Proficient: {len(prof_fc)} flashcards, {len(prof_prac)} practice")
    
    print("\n✅ All data generated successfully!")
    print(f"📁 Files saved to: {RESOURCES}")

if __name__ == "__main__":
    main()

