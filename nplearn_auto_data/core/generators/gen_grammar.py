#!/usr/bin/env python3
"""
Grammar Generator for NPLearn
==============================
Generates comprehensive grammar points for all levels
"""

import json

GRAMMAR_DATA = {
    "grammar": [
        # BEGINNER GRAMMAR
        {
            "id": "b_gram_001",
            "title": "Simple Present Tense",
            "pattern": "Subject + Verb stem + छु/छौ/छ/छौं/छन्",
            "meaning": "For habitual actions",
            "usage": "म खान्छु, तिमी खान्छौ, ऊ खान्छ",
            "examples": [
                {"nepali": "म नेपाली बोल्छु।", "romanization": "Ma nepali bolchhu.", "english": "I speak Nepali."},
                {"nepali": "ऊ स्कुल जान्छ।", "romanization": "U school janchha.", "english": "He/She goes to school."}
            ],
            "level": "Beginner",
            "notes": "Endings: छु(I), छौ(you informal), छ(he/she), छौं(we), छन्(they)"
        },
        {
            "id": "b_gram_002",
            "title": "Simple Past Tense",
            "pattern": "Subject + Verb stem + एँ/यौ/यो/यौं/ए",
            "meaning": "For completed actions",
            "usage": "म गएँ, ऊ गयो",
            "examples": [
                {"nepali": "म हिजो घर गएँ।", "romanization": "Ma hijo ghar gaen.", "english": "I went home yesterday."},
                {"nepali": "उसले खाना खायो।", "romanization": "Usle khana khayo.", "english": "He/She ate food."}
            ],
            "level": "Beginner",
            "notes": "Past endings vary by verb type"
        },
        {
            "id": "b_gram_003",
            "title": "Question Words",
            "pattern": "के, को, कहाँ, कसरी, किन, कति",
            "meaning": "Basic question words",
            "usage": "के=what, को=who, कहाँ=where, किन=why",
            "examples": [
                {"nepali": "तपाईंको नाम के हो?", "romanization": "Tapaiko naam ke ho?", "english": "What is your name?"},
                {"nepali": "तिमी कहाँ जान्छौ?", "romanization": "Timi kaha janchhau?", "english": "Where do you go?"}
            ],
            "level": "Beginner",
            "notes": "Question words come before the verb"
        },
        {
            "id": "b_gram_004",
            "title": "Negation",
            "pattern": "Verb stem + दिन/दैन",
            "meaning": "Making negative sentences",
            "usage": "म जान्दिनँ, ऊ खान्दैन",
            "examples": [
                {"nepali": "म मासु खान्दिनँ।", "romanization": "Ma maasu khandina.", "english": "I don't eat meat."},
                {"nepali": "ऊ स्कुल जान्दैन।", "romanization": "U school jandaina.", "english": "He doesn't go to school."}
            ],
            "level": "Beginner",
            "notes": "दिनँ for I, दैन for he/she/it"
        },
        {
            "id": "b_gram_005",
            "title": "Postpositions",
            "pattern": "Noun + मा/बाट/सँग/लाई/को",
            "meaning": "Position words after nouns",
            "usage": "घरमा=at home, नेपालबाट=from Nepal",
            "examples": [
                {"nepali": "म घरमा छु।", "romanization": "Ma gharma chhu.", "english": "I am at home."},
                {"nepali": "ऊ नेपालबाट हो।", "romanization": "U nepalbata ho.", "english": "He/She is from Nepal."}
            ],
            "level": "Beginner",
            "notes": "मा=in/at, बाट=from, सँग=with, लाई=to, को=of"
        },
        {
            "id": "b_gram_006",
            "title": "To Be: हो/छ",
            "pattern": "Subject + Noun/Adj + हो/छ",
            "meaning": "Two forms of 'to be'",
            "usage": "हो for identity, छ for state/location",
            "examples": [
                {"nepali": "यो किताब हो।", "romanization": "Yo kitab ho.", "english": "This is a book."},
                {"nepali": "ऊ घरमा छ।", "romanization": "U gharma chha.", "english": "He is at home."}
            ],
            "level": "Beginner",
            "notes": "हो=is (identity), छ=is (location/state)"
        },
        {
            "id": "b_gram_007",
            "title": "Possessive को",
            "pattern": "Owner + को + Possession",
            "meaning": "Showing possession",
            "usage": "मेरो, तिम्रो, उसको",
            "examples": [
                {"nepali": "मेरो नाम राम हो।", "romanization": "Mero naam Ram ho.", "english": "My name is Ram."},
                {"nepali": "तिम्रो घर कहाँ छ?", "romanization": "Timro ghar kaha chha?", "english": "Where is your house?"}
            ],
            "level": "Beginner",
            "notes": "म+को=मेरो, तिमी+को=तिम्रो, ऊ+को=उसको"
        },
        {
            "id": "b_gram_008",
            "title": "Future Tense",
            "pattern": "Verb stem + नेछु/नेछ/नेछन्",
            "meaning": "For future actions",
            "usage": "म जानेछु, ऊ आउनेछ",
            "examples": [
                {"nepali": "म भोलि जानेछु।", "romanization": "Ma bholi janechhu.", "english": "I will go tomorrow."},
                {"nepali": "ऊ आउनेछ।", "romanization": "U aaunechha.", "english": "He/She will come."}
            ],
            "level": "Beginner",
            "notes": "Add ने + छु/छ/छन् to verb stem"
        },
        {
            "id": "b_gram_009",
            "title": "Imperative (Commands)",
            "pattern": "Verb stem + नुहोस्/नुस्/",
            "meaning": "Giving commands",
            "usage": "बस्नुहोस्=please sit, जानुस्=go",
            "examples": [
                {"nepali": "यहाँ बस्नुहोस्।", "romanization": "Yaha basnuhos.", "english": "Please sit here."},
                {"nepali": "खाना खानुहोस्।", "romanization": "Khana khanuhos.", "english": "Please eat."}
            ],
            "level": "Beginner",
            "notes": "नुहोस् is polite, नुस् is neutral"
        },
        {
            "id": "b_gram_010",
            "title": "Continuous Tense",
            "pattern": "Verb stem + दैछु/दैछ/दैछन्",
            "meaning": "Ongoing actions",
            "usage": "म खाँदैछु=I am eating",
            "examples": [
                {"nepali": "ऊ पढ्दैछ।", "romanization": "U padhdaichha.", "english": "He is studying."},
                {"nepali": "म खाँदैछु।", "romanization": "Ma khadaichhu.", "english": "I am eating."}
            ],
            "level": "Beginner",
            "notes": "Shows action happening now"
        },
        # ELEMENTARY GRAMMAR
        {
            "id": "e_gram_001",
            "title": "Past Continuous",
            "pattern": "Verb stem + दै थिएँ/थ्यो",
            "meaning": "Was doing",
            "usage": "म खाँदै थिएँ",
            "examples": [
                {"nepali": "म पढ्दै थिएँ।", "romanization": "Ma padhdai thien.", "english": "I was studying."},
                {"nepali": "ऊ खाँदै थियो।", "romanization": "U khadai thiyo.", "english": "He was eating."}
            ],
            "level": "Elementary",
            "notes": "For ongoing past actions"
        },
        {
            "id": "e_gram_002",
            "title": "Comparatives",
            "pattern": "Noun + भन्दा + Adj",
            "meaning": "Comparing things",
            "usage": "यो त्यो भन्दा राम्रो छ",
            "examples": [
                {"nepali": "यो घर त्यो भन्दा ठूलो छ।", "romanization": "Yo ghar tyo bhanda thulo chha.", "english": "This house is bigger than that."},
                {"nepali": "राम श्याम भन्दा लामो छ।", "romanization": "Ram Shyam bhanda lamo chha.", "english": "Ram is taller than Shyam."}
            ],
            "level": "Elementary",
            "notes": "भन्दा means 'than'"
        },
        {
            "id": "e_gram_003",
            "title": "Must/Have to",
            "pattern": "Verb stem + नुपर्छ",
            "meaning": "Obligation",
            "usage": "म जानुपर्छ = I have to go",
            "examples": [
                {"nepali": "मैले काम गर्नुपर्छ।", "romanization": "Maile kaam garnuparchha.", "english": "I have to work."},
                {"nepali": "तिमीले पढ्नुपर्छ।", "romanization": "Timilai padhnuparchha.", "english": "You have to study."}
            ],
            "level": "Elementary",
            "notes": "नुपर्छ shows necessity"
        },
        {
            "id": "e_gram_004",
            "title": "Can/Able to",
            "pattern": "Verb stem + न सक्छु/सक्छ",
            "meaning": "Ability",
            "usage": "म बोल्न सक्छु = I can speak",
            "examples": [
                {"nepali": "म नेपाली बोल्न सक्छु।", "romanization": "Ma nepali bolna sakchhu.", "english": "I can speak Nepali."},
                {"nepali": "ऊ पौडी खेल्न सक्छ।", "romanization": "U paudi khelna sakchha.", "english": "He can swim."}
            ],
            "level": "Elementary",
            "notes": "सक्नु means 'to be able'"
        },
        {
            "id": "e_gram_005",
            "title": "Want to",
            "pattern": "Verb stem + न चाहन्छु",
            "meaning": "Desire/Want",
            "usage": "म जान चाहन्छु = I want to go",
            "examples": [
                {"nepali": "म नेपाल जान चाहन्छु।", "romanization": "Ma Nepal jana chahanchhu.", "english": "I want to go to Nepal."},
                {"nepali": "मलाई खाना खान मन छ।", "romanization": "Malai khana khana man chha.", "english": "I want to eat food."}
            ],
            "level": "Elementary",
            "notes": "चाहनु means 'to want'"
        },
        # INTERMEDIATE GRAMMAR
        {
            "id": "i_gram_001",
            "title": "Conditional",
            "pattern": "यदि...भने",
            "meaning": "If...then",
            "usage": "यदि तिमी आयौ भने म खुसी हुनेछु",
            "examples": [
                {"nepali": "यदि पानी पर्यो भने म जान्न।", "romanization": "Yadi pani paryo bhane ma janna.", "english": "If it rains, I won't go."},
                {"nepali": "यदि तिमी आयौ भने राम्रो हुन्छ।", "romanization": "Yadi timi aayau bhane ramro hunchha.", "english": "It will be good if you come."}
            ],
            "level": "Intermediate",
            "notes": "यदि=if, भने=then"
        },
        {
            "id": "i_gram_002",
            "title": "Passive Voice",
            "pattern": "Object + Verb + इन्छ/इयो",
            "meaning": "Passive construction",
            "usage": "खाना खाइन्छ",
            "examples": [
                {"nepali": "नेपालीमा बोलिन्छ।", "romanization": "Nepalima bolinchha.", "english": "Nepali is spoken."},
                {"nepali": "यो काम गरियो।", "romanization": "Yo kaam gariyo.", "english": "This work was done."}
            ],
            "level": "Intermediate",
            "notes": "Subject becomes object"
        },
        {
            "id": "i_gram_003",
            "title": "Relative Clauses",
            "pattern": "जो/जुन...त्यो/त्यसैले",
            "meaning": "Who/which...that",
            "usage": "जो आउँछ त्यो खान्छ",
            "examples": [
                {"nepali": "जो मेहनत गर्छ त्यो सफल हुन्छ।", "romanization": "Jo mehenat garchha tyo saphal hunchha.", "english": "Who works hard succeeds."},
                {"nepali": "जुन किताब तिमीले दियौ त्यो राम्रो थियो।", "romanization": "Jun kitab timilai diyau tyo ramro thiyo.", "english": "The book you gave was good."}
            ],
            "level": "Intermediate",
            "notes": "जो for people, जुन for things"
        },
        # ADVANCED GRAMMAR
        {
            "id": "a_gram_001",
            "title": "Causative Verbs",
            "pattern": "Verb + आउनु/दिनु",
            "meaning": "Making someone do",
            "usage": "गराउनु, खुवाउनु",
            "examples": [
                {"nepali": "आमाले बच्चालाई खुवाउनुहुन्छ।", "romanization": "Amaale bachchalai khuwaunuhunchha.", "english": "Mother feeds the child."},
                {"nepali": "मैले उसलाई काम गराएँ।", "romanization": "Maile uslai kaam garaen.", "english": "I made him work."}
            ],
            "level": "Advanced",
            "notes": "Causative adds आउ to verb"
        },
        {
            "id": "a_gram_002",
            "title": "Reported Speech",
            "pattern": "Subject + भन्यो कि...",
            "meaning": "Indirect speech",
            "usage": "उसले भन्यो कि ऊ जान्छ",
            "examples": [
                {"nepali": "उसले भन्यो कि ऊ आउँछ।", "romanization": "Usle bhanyo ki u aaunchha.", "english": "He said that he will come."},
                {"nepali": "शिक्षकले भन्नुभयो कि परीक्षा भोलि हुन्छ।", "romanization": "Shikshakle bhannubhayo ki pariksha bholi hunchha.", "english": "Teacher said exam is tomorrow."}
            ],
            "level": "Advanced",
            "notes": "भन्नु + कि for reporting"
        },
        {
            "id": "a_gram_003",
            "title": "Honorific Forms",
            "pattern": "Verb + हुन्छ/नुहुन्छ",
            "meaning": "Respectful forms",
            "usage": "तपाईं जानुहुन्छ",
            "examples": [
                {"nepali": "हजुर कहाँ जानुहुन्छ?", "romanization": "Hajur kaha januhunchha?", "english": "Where are you going? (polite)"},
                {"nepali": "तपाईंले के खानुहुन्छ?", "romanization": "Tapainle ke khanuhunchha?", "english": "What will you eat? (polite)"}
            ],
            "level": "Advanced",
            "notes": "नुहुन्छ for high respect"
        },
        # PROFICIENT GRAMMAR
        {
            "id": "p_gram_001",
            "title": "Literary Forms",
            "pattern": "Classical constructions",
            "meaning": "Formal/literary language",
            "usage": "Used in formal writing",
            "examples": [
                {"nepali": "श्रीमान्ले भन्नुभयो।", "romanization": "Shrimanle bhannubhayo.", "english": "The gentleman said. (formal)"},
                {"nepali": "यो कार्य सम्पन्न गरियो।", "romanization": "Yo karya sampanna gariyo.", "english": "This task was completed. (formal)"}
            ],
            "level": "Proficient",
            "notes": "Used in formal writing"
        },
        {
            "id": "p_gram_002",
            "title": "Proverbs & Idioms",
            "pattern": "Fixed expressions",
            "meaning": "Traditional sayings",
            "usage": "जे बोए त्यही काटिन्छ",
            "examples": [
                {"nepali": "जे बोए त्यही काटिन्छ।", "romanization": "Je boe tyahi katinchha.", "english": "As you sow, so shall you reap."},
                {"nepali": "खाली भाँडो ठुलो आवाज।", "romanization": "Khali bhado thulo awaj.", "english": "Empty vessels make most noise."}
            ],
            "level": "Proficient",
            "notes": "Common Nepali proverbs"
        },
    ]
}

def generate_grammar():
    return GRAMMAR_DATA

if __name__ == "__main__":
    print("📚 Generating Grammar...")
    data = generate_grammar()
    print(f"  Total grammar points: {len(data['grammar'])}")
    for level in ["Beginner", "Elementary", "Intermediate", "Advanced", "Proficient"]:
        count = len([g for g in data['grammar'] if g['level'] == level])
        print(f"    {level}: {count} points")

