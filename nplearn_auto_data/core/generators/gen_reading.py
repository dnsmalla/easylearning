#!/usr/bin/env python3
"""
Reading Passages Generator for NPLearn
=======================================
Generates reading passages for all levels
"""

import json

READING_DATA = {
    "passages": [
        # BEGINNER PASSAGES
        {
            "id": "b_read_001",
            "title": "मेरो परिचय",
            "titleEnglish": "My Introduction",
            "level": "Beginner",
            "content": "नमस्ते! मेरो नाम रितु हो। म नेपाली हुँ। म काठमाडौंमा बस्छु। मेरो परिवारमा चार जना छन्: बुबा, आमा, दाजु र म। म विद्यार्थी हुँ। म विद्यालयमा पढ्छु।",
            "translation": "Hello! My name is Ritu. I am Nepali. I live in Kathmandu. There are four people in my family: father, mother, elder brother, and me. I am a student. I study at school.",
            "vocabulary": [
                {"word": "परिचय", "meaning": "Introduction", "romanization": "parichaya"},
                {"word": "परिवार", "meaning": "Family", "romanization": "pariwar"},
                {"word": "विद्यार्थी", "meaning": "Student", "romanization": "vidyarthi"},
                {"word": "विद्यालय", "meaning": "School", "romanization": "vidyalaya"},
            ],
            "questions": [
                {"question": "रितुको नाम के हो?", "answer": "रितुको नाम रितु हो।"},
                {"question": "रितु कहाँ बस्छिन्?", "answer": "रितु काठमाडौंमा बस्छिन्।"},
                {"question": "रितुको परिवारमा कति जना छन्?", "answer": "चार जना छन्।"},
            ]
        },
        {
            "id": "b_read_002",
            "title": "मेरो दिनचर्या",
            "titleEnglish": "My Daily Routine",
            "level": "Beginner",
            "content": "म बिहान ६ बजे उठ्छु। म मुख धुन्छु र दाँत माझ्छु। त्यसपछि म खाना खान्छु। म ८ बजे स्कुल जान्छु। म ४ बजे घर आउँछु। साँझमा म पढ्छु। म राति १० बजे सुत्छु।",
            "translation": "I wake up at 6 in the morning. I wash my face and brush my teeth. Then I eat food. I go to school at 8. I come home at 4. In the evening I study. I sleep at 10 at night.",
            "vocabulary": [
                {"word": "दिनचर्या", "meaning": "Daily routine", "romanization": "dincharya"},
                {"word": "उठ्नु", "meaning": "To wake up", "romanization": "uthnu"},
                {"word": "सुत्नु", "meaning": "To sleep", "romanization": "sutnu"},
                {"word": "बिहान", "meaning": "Morning", "romanization": "bihan"},
            ],
            "questions": [
                {"question": "तिमी बिहान कति बजे उठ्छौ?", "answer": "म ६ बजे उठ्छु।"},
                {"question": "तिमी स्कुल कति बजे जान्छौ?", "answer": "म ८ बजे जान्छु।"},
            ]
        },
        {
            "id": "b_read_003",
            "title": "मेरो घर",
            "titleEnglish": "My House",
            "level": "Beginner",
            "content": "मेरो घर सुन्दर छ। मेरो घरमा तीनवटा कोठा छन्। एउटा भान्सा छ। एउटा बाथरुम छ। मेरो घर अगाडि बगैंचा छ। बगैंचामा फूलहरू छन्। म मेरो घर मन पराउँछु।",
            "translation": "My house is beautiful. There are three rooms in my house. There is one kitchen. There is one bathroom. There is a garden in front of my house. There are flowers in the garden. I like my house.",
            "vocabulary": [
                {"word": "घर", "meaning": "House", "romanization": "ghar"},
                {"word": "कोठा", "meaning": "Room", "romanization": "kotha"},
                {"word": "भान्सा", "meaning": "Kitchen", "romanization": "bhansa"},
                {"word": "बगैंचा", "meaning": "Garden", "romanization": "bagaincha"},
            ],
            "questions": [
                {"question": "घरमा कतिवटा कोठा छन्?", "answer": "तीनवटा कोठा छन्।"},
                {"question": "घर अगाडि के छ?", "answer": "बगैंचा छ।"},
            ]
        },
        # ELEMENTARY PASSAGES
        {
            "id": "e_read_001",
            "title": "नेपालको मौसम",
            "titleEnglish": "Nepal's Weather",
            "level": "Elementary",
            "content": "नेपालमा चारवटा मौसम हुन्छन्। बसन्त, ग्रीष्म, शरद र हेमन्त। बसन्तमा मौसम सुहावना हुन्छ। फूलहरू फुल्छन्। ग्रीष्ममा गर्मी हुन्छ। वर्षामा धेरै पानी पर्छ। जाडोमा चिसो हुन्छ र पहाडमा हिउँ पर्छ।",
            "translation": "Nepal has four seasons. Spring, summer, autumn, and winter. In spring the weather is pleasant. Flowers bloom. In summer it is hot. In monsoon there is much rain. In winter it is cold and snow falls in the mountains.",
            "vocabulary": [
                {"word": "मौसम", "meaning": "Weather/Season", "romanization": "mausam"},
                {"word": "बसन्त", "meaning": "Spring", "romanization": "basanta"},
                {"word": "ग्रीष्म", "meaning": "Summer", "romanization": "grishma"},
                {"word": "हिउँ", "meaning": "Snow", "romanization": "hiun"},
            ],
            "questions": [
                {"question": "नेपालमा कतिवटा मौसम हुन्छन्?", "answer": "चारवटा मौसम हुन्छन्।"},
                {"question": "बसन्तमा के हुन्छ?", "answer": "फूलहरू फुल्छन्।"},
            ]
        },
        {
            "id": "e_read_002",
            "title": "बजारमा",
            "titleEnglish": "At the Market",
            "level": "Elementary",
            "content": "हिजो म बजार गएँ। बजारमा धेरै पसलहरू थिए। मैले तरकारी किनेँ। आलु, गोलभेडा र प्याज किनेँ। फलफूल पनि किनेँ। स्याउ र केरा किनेँ। बजारमा धेरै मान्छेहरू थिए। म संग मेरी आमा पनि हुनुहुन्थ्यो।",
            "translation": "Yesterday I went to the market. There were many shops in the market. I bought vegetables. I bought potatoes, tomatoes, and onions. I also bought fruits. I bought apples and bananas. There were many people in the market. My mother was also with me.",
            "vocabulary": [
                {"word": "बजार", "meaning": "Market", "romanization": "bazaar"},
                {"word": "पसल", "meaning": "Shop", "romanization": "pasal"},
                {"word": "तरकारी", "meaning": "Vegetables", "romanization": "tarkari"},
                {"word": "फलफूल", "meaning": "Fruits", "romanization": "phalphul"},
            ],
            "questions": [
                {"question": "बजारमा के के थिए?", "answer": "धेरै पसलहरू थिए।"},
                {"question": "के के तरकारी किनेँ?", "answer": "आलु, गोलभेडा र प्याज किनेँ।"},
            ]
        },
        # INTERMEDIATE PASSAGES
        {
            "id": "i_read_001",
            "title": "नेपालको संस्कृति",
            "titleEnglish": "Nepal's Culture",
            "level": "Intermediate",
            "content": "नेपाल विविधताले भरिएको देश हो। यहाँ विभिन्न जातजाति र धर्मका मानिसहरू बस्छन्। नेपालमा हिन्दू, बौद्ध, इस्लाम र ईसाई धर्मका मानिसहरू छन्। सबैले मिलेर चाडपर्व मनाउँछन्। दशैं र तिहार सबैभन्दा ठूला चाडहरू हुन्। दशैंमा टीका लगाउँछन् र तिहारमा दियो बाल्छन्। नेपाली संस्कृति धेरै समृद्ध छ।",
            "translation": "Nepal is a country full of diversity. People of different castes and religions live here. In Nepal there are Hindus, Buddhists, Muslims, and Christians. Everyone celebrates festivals together. Dashain and Tihar are the biggest festivals. In Dashain people apply tika and in Tihar they light lamps. Nepali culture is very rich.",
            "vocabulary": [
                {"word": "विविधता", "meaning": "Diversity", "romanization": "bibiddhata"},
                {"word": "संस्कृति", "meaning": "Culture", "romanization": "sanskriti"},
                {"word": "चाडपर्व", "meaning": "Festivals", "romanization": "chadparva"},
                {"word": "समृद्ध", "meaning": "Rich/Prosperous", "romanization": "samriddha"},
            ],
            "questions": [
                {"question": "नेपालमा कुन कुन धर्मका मानिसहरू छन्?", "answer": "हिन्दू, बौद्ध, इस्लाम र ईसाई धर्मका।"},
                {"question": "सबैभन्दा ठूला चाडहरू कुन हुन्?", "answer": "दशैं र तिहार।"},
            ]
        },
        # ADVANCED PASSAGES
        {
            "id": "a_read_001",
            "title": "नेपालको अर्थतन्त्र",
            "titleEnglish": "Nepal's Economy",
            "level": "Advanced",
            "content": "नेपालको अर्थतन्त्र मुख्यतया कृषि, पर्यटन र विप्रेषणमा आधारित छ। कुल गार्हस्थ्य उत्पादनको एक तिहाइ भाग कृषिबाट आउँछ। पर्यटन उद्योग पनि महत्त्वपूर्ण छ। हरेक वर्ष लाखौं पर्यटकहरू नेपाल भ्रमणमा आउँछन्। विदेशमा कार्यरत नेपालीहरूले पठाउने रेमिट्यान्स अर्थतन्त्रको प्रमुख स्रोत हो।",
            "translation": "Nepal's economy is mainly based on agriculture, tourism, and remittances. One third of GDP comes from agriculture. Tourism industry is also important. Millions of tourists visit Nepal every year. Remittances sent by Nepalis working abroad is a major source of the economy.",
            "vocabulary": [
                {"word": "अर्थतन्त्र", "meaning": "Economy", "romanization": "arthatantra"},
                {"word": "कृषि", "meaning": "Agriculture", "romanization": "krishi"},
                {"word": "पर्यटन", "meaning": "Tourism", "romanization": "paryatan"},
                {"word": "विप्रेषण", "meaning": "Remittance", "romanization": "bipreshan"},
            ],
            "questions": [
                {"question": "नेपालको अर्थतन्त्र केमा आधारित छ?", "answer": "कृषि, पर्यटन र विप्रेषणमा।"},
                {"question": "GDP को कति भाग कृषिबाट आउँछ?", "answer": "एक तिहाइ भाग।"},
            ]
        },
        # PROFICIENT PASSAGES
        {
            "id": "p_read_001",
            "title": "नेपाली साहित्य",
            "titleEnglish": "Nepali Literature",
            "level": "Proficient",
            "content": "नेपाली साहित्यको इतिहास धेरै पुरानो छ। भानुभक्त आचार्यलाई आदिकवि मानिन्छ। उनले रामायणको नेपाली अनुवाद गरे। लक्ष्मीप्रसाद देवकोटालाई महाकवि भनिन्छ। उनको 'मुनामदन' प्रसिद्ध कृति हो। आधुनिक साहित्यमा कविता, कथा, उपन्यास र नाटक सबैको विकास भएको छ। नेपाली साहित्यले सामाजिक, राजनीतिक र दार्शनिक विषयहरूलाई समेट्दछ।",
            "translation": "Nepali literature has a very old history. Bhanubhakta Acharya is considered the first poet. He translated Ramayana into Nepali. Laxmi Prasad Devkota is called the great poet. His 'Muna Madan' is a famous work. In modern literature, poetry, stories, novels, and drama have all developed. Nepali literature covers social, political, and philosophical subjects.",
            "vocabulary": [
                {"word": "साहित्य", "meaning": "Literature", "romanization": "sahitya"},
                {"word": "आदिकवि", "meaning": "First poet", "romanization": "adikavi"},
                {"word": "महाकवि", "meaning": "Great poet", "romanization": "mahakavi"},
                {"word": "कृति", "meaning": "Work/Creation", "romanization": "kriti"},
            ],
            "questions": [
                {"question": "आदिकवि को हुन्?", "answer": "भानुभक्त आचार्य।"},
                {"question": "देवकोटाको प्रसिद्ध कृति कुन हो?", "answer": "मुनामदन।"},
            ]
        },
    ]
}

def generate_reading():
    return READING_DATA

if __name__ == "__main__":
    print("📖 Generating Reading Passages...")
    data = generate_reading()
    print(f"  Total passages: {len(data['passages'])}")
    for level in ["Beginner", "Elementary", "Intermediate", "Advanced", "Proficient"]:
        count = len([p for p in data['passages'] if p['level'] == level])
        print(f"    {level}: {count} passages")

