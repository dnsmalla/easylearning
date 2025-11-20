# Easy Learning - Japanese Learning Data

Learning data repository for JLearn iOS app.

## Contents

This repository contains Japanese learning data for JLPT levels N5 to N1:

- `japanese_learning_data_n5_jisho.json` - N5 Level (Beginner)
- `japanese_learning_data_n4_jisho.json` - N4 Level (Basic)
- `japanese_learning_data_n3_jisho.json` - N3 Level (Intermediate)
- `japanese_learning_data_n2_jisho.json` - N2 Level (Advanced)
- `japanese_learning_data_n1_jisho.json` - N1 Level (Expert)
- `manifest.json` - Version tracking and file information

## How It Works

1. The JLearn iOS app downloads these JSON files on first launch
2. Data is cached locally on the device for offline use
3. App checks for updates every 30 days
4. Users only download what they need (one level at a time)

## Data Structure

Each JSON file contains:
- **Flashcards**: Vocabulary with readings, meanings, and examples
- **Grammar**: Grammar points with usage and examples
- **Practice**: Practice questions for each category

## Updating Content

To update the learning data:

1. Edit the JSON files locally
2. Update the version in `manifest.json`
3. Commit and push changes to GitHub
4. Users automatically receive updates within 30 days

## Current Version

Check `manifest.json` for the current version and changelog.

## App

**JLearn** - Japanese Learning iOS App  
Repository: https://github.com/dnsmalla/easylearning

## License

Educational Use

