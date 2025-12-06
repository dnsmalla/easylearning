# Educa Data Repository

📚 **JSON Data Source for Educa - Student Information Aggregator App**

This repository contains all the JSON data files and images used by the Educa iOS app. The app fetches data from this repository to display universities, countries, courses, scholarships, and more.

## 📁 Repository Structure

```
educa-data/
├── manifest.json          # Version control & file manifest
├── data_schema.json       # JSON Schema for validation
├── README.md              # This file
├── data/
│   ├── universities.json  # University listings
│   ├── countries.json     # Country visa & info
│   ├── courses.json       # Course details
│   ├── guides.json        # Student guides/articles
│   ├── remittance.json    # Money transfer providers
│   ├── jobs.json          # Job listings
│   ├── services.json      # App service categories
│   ├── scholarships.json  # Scholarship opportunities
│   └── updates.json       # News & announcements
└── images/
    ├── universities/      # University images
    ├── countries/         # Country flag icons
    ├── guides/            # Guide cover images
    ├── services/          # Service icons
    └── updates/           # Update/news images
```

## 🔗 GitHub Raw URLs

The app fetches data from GitHub raw URLs:

**Base URL:** `https://raw.githubusercontent.com/dnsmalla/educa-data/main`

**Example URLs:**
- Manifest: `{base_url}/manifest.json`
- Universities: `{base_url}/data/universities.json`
- Images: `{base_url}/images/universities/melbourne.jpg`

## 📋 How the App Uses This Data

1. **App Launch:** Fetches `manifest.json` to check for updates
2. **Version Check:** Compares local version with manifest version
3. **Download if needed:** Downloads only changed files
4. **Cache locally:** Stores data in app cache for offline use
5. **Fallback:** Uses bundled data if network unavailable

## 📝 Data Format

All JSON files follow this structure:

```json
{
  "version": "1.0.0",
  "last_updated": "2025-12-05",
  "data_key": [
    { "id": "...", "field": "..." }
  ]
}
```

## 🔄 Updating Data

### Adding New University
1. Edit `data/universities.json`
2. Add new entry following the schema
3. Add image to `images/universities/`
4. Update `version` in the file
5. Update `manifest.json` with new version
6. Commit and push

### Example: Adding a University

```json
{
  "id": "uni-009",
  "title": "Harvard University",
  "location": "Cambridge, Massachusetts",
  "country": "United States",
  "description": "Harvard University is a private Ivy League research university...",
  "image": "universities/harvard.jpg",
  "rating": 4.9,
  "programs": ["Law", "Business", "Medicine", "Engineering"],
  "annual_fee": "USD 57,000",
  "ranking": 3,
  "website": "https://www.harvard.edu",
  "accreditation": "NECHE",
  "student_count": 23000,
  "founded_year": 1636
}
```

## ✅ Validation

Before pushing, validate JSON files:

```bash
# Validate JSON syntax
python -m json.tool data/universities.json > /dev/null

# Run full validation (if toolkit installed)
./toolkit/validate.sh
```

## 🚀 Deployment

### Manual Push
```bash
cd educa_data
git add data/
git commit -m "📝 Update universities data"
git push
```

### Using Data Toolkit
```bash
# Validate all data
./toolkit/sync_data.sh validate

# Full pipeline (validate + commit + push)
./toolkit/sync_data.sh full --push
```

## 📊 Data Schema

See `data_schema.json` for complete validation rules.

### Key Rules:
- University IDs: `uni-XXX` format
- Country IDs: ISO 3166-1 alpha-3 codes
- Course IDs: `course-XXX` format
- All dates: `YYYY-MM-DD` format
- Ratings: 0.0 to 5.0 scale
- Images: Relative paths from `images/` folder

## 🖼️ Image Guidelines

| Type | Size | Format | Max Size |
|------|------|--------|----------|
| Universities | 800x600 | JPG/PNG | 500KB |
| Guides | 1200x630 | JPG/PNG | 300KB |
| Services | 400x400 | PNG | 100KB |
| Logos | 200x200 | PNG | 50KB |

## 🔒 Important Notes

- **Never push app source code** to this repository
- This repo is **data only** - JSON files and images
- Keep files small for fast mobile loading
- Test data in app before pushing to main

## 📈 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-12-05 | Initial release |

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes following the schema
4. Validate JSON files
5. Submit pull request

## 📞 Support

For issues with data or schema:
- Check `data_schema.json` for validation rules
- Open an issue on GitHub
- Contact the Educa development team

---

**Repository:** https://github.com/dnsmalla/educa-data  
**App:** Educa - Student Information Aggregator  
**Last Updated:** 2025-12-05

