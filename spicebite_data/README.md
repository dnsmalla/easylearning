# SpiceBite Data Repository 🍛

**Indian & Nepali Restaurant Data (Worldwide)**

This repository contains JSON data for the SpiceBite iOS app. The app fetches this data from GitHub to display restaurant information.

## 📊 Data Overview

| File | Description | Count |
|------|-------------|-------|
| `restaurants_global.json` | Worldwide restaurants (OSM-derived) | Dynamic |
| `reviews.json` | User reviews | Optional |

## 🌍 Coverage

Worldwide coverage depends on OpenStreetMap data quality in each region.

## 🍽️ Cuisine Types

| Cuisine | Count | Description |
|---------|-------|-------------|
| 🇳🇵 Nepali | 18 | Traditional Nepali dishes |
| 🫓 North Indian | 12 | Punjab, Delhi-style |
| 🇮🇳 Indian | 8 | General Indian |
| 🥘 South Indian | 5 | Tamil Nadu, Kerala |
| 🍛 Indo-Nepali | 3 | Fusion cuisine |
| 🏔️ Himalayan | 1 | Mountain regional |

## 📁 Repository Structure

```
spicebite-data/
├── manifest.json        # Version control & file index
├── data_schema.json     # JSON validation schema
├── data/
│   ├── restaurants_global.json
│   └── reviews.json
├── toolkit/
│   ├── sync_data.sh     # Data management scripts
│   └── build_osm.py     # OSM → JSON pipeline
└── README.md
```

## 🔗 API Endpoints

Base URL: `https://raw.githubusercontent.com/dnsmalla/spicebite-data/main`

| Endpoint | Description |
|----------|-------------|
| `/manifest.json` | Version info & file list |
| `/data/restaurants_global.json` | Worldwide restaurants |
| `/data/reviews.json` | User reviews |

## 📱 App Integration

The SpiceBite app fetches data using:

```swift
let baseURL = "https://raw.githubusercontent.com/dnsmalla/spicebite-data/main"
let manifestURL = "\(baseURL)/manifest.json"
```

### Data Flow:
1. App launches → Load cached data
2. Background → Fetch manifest.json
3. Compare versions → Download updated files
4. Cache locally → Display in UI

## 🛠️ Data Management

### Validate Data
```bash
cd toolkit
./sync_data.sh validate
```

### Update Version
```bash
./sync_data.sh version 1.1.0
```

### Full Pipeline
```bash
./sync_data.sh full --push
```

## 🛠️ Build Global Dataset (OSM)

The `toolkit/build_osm.py` script pulls data from Overpass (OpenStreetMap), converts it into the SpiceBite schema, and writes `data/restaurants_global.json`.

```bash
cd toolkit
python3 build_osm.py --out ../data/restaurants_global.json
./sync_data.sh validate
./sync_data.sh full --push
```

Required fields include `country`, `city`, `latitude`, and `longitude` for nearby search.

## 📋 JSON Schema

### Restaurant Object
```json
{
  "id": "tokyo-001",
  "name": "Restaurant Name",
  "japanese_name": "レストラン名",
  "cuisineType": "Nepali",
  "priceRange": "¥¥",
  "region": "Tokyo",
  "address": "1-2-3 Shinjuku, Shinjuku-ku, Tokyo",
  "rating": 4.5,
  "review_count": 234,
  "description": "Description of the restaurant...",
  "cover_image": "https://images.unsplash.com/...",
  "features": ["Dine-in", "Takeout", "Lunch Set"],
  "specialties": ["Momo", "Dal Bhat", "Curry"],
  "is_halal": false,
  "has_english_menu": true,
  "nearest_station": "Shinjuku Station",
  "walking_minutes": 5
}
```

## 🔄 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-12-06 | Initial release with 47 restaurants |

## 📄 License

This data is provided for use with the SpiceBite app.

---

**Repository:** https://github.com/dnsmalla/spicebite-data  
**App:** SpiceBite - Indian & Nepali Restaurant Finder

### OSM Attribution

If you use OpenStreetMap data, you must attribute OSM contributors and comply with the ODbL license.
