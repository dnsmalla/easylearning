# SpiceBite 🍛

**Indian & Nepali Restaurant Discovery App (Worldwide)**

SpiceBite helps users discover, compare, and explore Indian and Nepali restaurants worldwide. Whether you're looking for Nepali momos in New York, South Indian dosas in London, or Himalayan dining in Tokyo, SpiceBite has you covered.

## Features

### 🔍 Discover
- Browse restaurants by city and country
- Filter by cuisine type (Indian, Nepali, North Indian, South Indian, Himalayan)
- Search by restaurant name, dish, or location

### ⚖️ Compare
- Side-by-side comparison of restaurants
- Compare prices, ratings, features, and menus
- Make informed dining decisions

### 📱 App Features
- **Cuisine Filters**: Indian, Nepali, Indo-Nepali, North Indian, South Indian, Himalayan
- **Price Range**: Budget (¥), Moderate (¥¥), Upscale (¥¥¥), Premium (¥¥¥¥)
- **Dietary Options**: Halal, Vegetarian, Vegan
- **Special Features**: English menu, Nepali/Hindi speaking staff
- **Detailed Info**: Operating hours, address, distance from you (when location is enabled)

### 💾 Save & Share
- Save favorite restaurants
- Share restaurant details with friends
- Access offline (cached data)

## Screenshots

*Coming soon*

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Location permission (for nearby results)

## Installation

1. Clone the repository
2. Open terminal and navigate to the SpiceBite folder
3. Run XcodeGen to generate the project:
   ```bash
   xcodegen generate
   ```
4. Open `SpiceBite.xcodeproj` in Xcode
5. Build and run on simulator or device

## Project Structure

```
SpiceBite/
├── Sources/
│   ├── App/
│   │   └── SpiceBiteApp.swift          # App entry point
│   ├── Assets.xcassets/               # App icons and colors
│   ├── Models/
│   │   ├── AppState.swift             # Global app state
│   │   └── Models.swift               # Data models
│   ├── Services/
│   │   ├── DataService.swift          # Data loading and management
│   │   └── HapticManager.swift        # Haptic feedback
│   ├── Utilities/
│   │   └── Theme.swift                # Colors, typography, styling
│   └── Views/
│       ├── Compare/                   # Comparison views
│       ├── Explore/                   # Browse and filter
│       ├── Home/                      # Home screen
│       ├── Main/                      # Tab navigation
│       ├── Profile/                   # User profile
│       ├── Restaurant/                # Restaurant list/detail
│       ├── Saved/                     # Saved restaurants
│       └── Search/                    # Search functionality
├── Resources/
│   └── Data/
│       ├── restaurants.json           # Restaurant data
│       ├── regions.json               # Region information
│       └── reviews.json               # User reviews
├── Tests/                             # Unit tests
├── project.yml                        # XcodeGen configuration
└── README.md                          # This file
```

## Data

Restaurant data is stored in JSON format and can be updated without app updates via a GitHub-hosted manifest and data files. The app supports:

- **Global coverage** (depends on the data source)
- **Multiple cuisines**: Indian, Nepali, Indo-Nepali, North/South Indian, Himalayan
- **Detailed information**: menus, operating hours, features, reviews

### Data Source

The global dataset is intended to be built from OpenStreetMap (OSM) `amenity=restaurant` entries tagged with `cuisine=indian` or `cuisine=nepali`, and hosted as JSON in a data repo for the app to sync.
If you use OSM data, include proper attribution and comply with the ODbL license.

## Cuisine Types

| Type | Description |
|------|-------------|
| 🇮🇳 Indian | General Indian cuisine |
| 🇳🇵 Nepali | Traditional Nepali dishes |
| 🍛 Indo-Nepali | Fusion of both cuisines |
| 🫓 North Indian | Punjab, Delhi-style cooking |
| 🥘 South Indian | Tamil Nadu, Kerala specialties |
| 🏔️ Himalayan | High-altitude regional cuisine |

## Key Dishes

### Nepali Specialties
- **Momo**: Steamed dumplings (chicken, lamb, vegetable)
- **Dal Bhat**: Rice with lentil soup and sides
- **Thukpa**: Tibetan-style noodle soup
- **Choila**: Spiced grilled meat
- **Sel Roti**: Sweet rice flour rings

### Indian Favorites
- **Butter Chicken**: Creamy tomato curry
- **Biryani**: Fragrant rice dish
- **Dosa**: Crispy rice crepe (South Indian)
- **Naan**: Tandoor-baked flatbread
- **Tandoori Chicken**: Clay oven roasted chicken

## Development

### Build with XcodeGen

This project uses [XcodeGen](https://github.com/yonaskolb/XcodeGen) for project file generation.

```bash
# Install XcodeGen
brew install xcodegen

# Generate project
cd SpiceBite
xcodegen generate

# Open project
open SpiceBite.xcodeproj
```

### Configuration

Edit `project.yml` to configure:
- Bundle ID: `com.company.spicebite`
- Deployment target: iOS 17.0
- Development team (required for device builds)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## License

This project is for educational purposes.

---

**SpiceBite** - Discover the flavors of India and Nepal worldwide 🇮🇳🇳🇵
