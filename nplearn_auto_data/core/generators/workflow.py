#!/usr/bin/env python3
"""
NPLearn Data Generation Workflow
==================================
Complete workflow: Generate prompts → Web Search → Process → Validate → Push to GitHub
"""

import json
import subprocess
import sys
from pathlib import Path
from datetime import datetime

from prompt_generator import generate_vocab_prompt, generate_grammar_prompt, CATEGORIES
from data_processor import DataProcessor, DataValidator

BASE_DIR = Path(__file__).parent.parent.parent.parent
RESOURCES_DIR = BASE_DIR / "NPLearn" / "Resources"

class WorkflowManager:
    """Manages the complete data generation workflow"""
    
    def __init__(self):
        self.processor = DataProcessor(RESOURCES_DIR)
        self.pending_tasks = []
        self.completed_tasks = []
    
    def show_menu(self):
        """Show interactive menu"""
        print("""
╔══════════════════════════════════════════════════════════════════╗
║           🇳🇵 NPLearn Data Generation System                      ║
╠══════════════════════════════════════════════════════════════════╣
║  1. Generate prompt for vocabulary                               ║
║  2. Generate prompt for grammar                                  ║
║  3. Process web search response                                  ║
║  4. Show current statistics                                      ║
║  5. Validate all data                                            ║
║  6. Push to GitHub                                               ║
║  7. Check what's missing                                         ║
║  8. Full workflow (guided)                                       ║
║  0. Exit                                                         ║
╚══════════════════════════════════════════════════════════════════╝
        """)
    
    def generate_vocab_prompt_interactive(self):
        """Generate vocabulary prompt interactively"""
        print("\n📚 Available Levels: beginner, elementary, intermediate, advanced, proficient")
        level = input("Enter level: ").strip().lower()
        
        if level not in CATEGORIES:
            print(f"❌ Invalid level. Choose from: {list(CATEGORIES.keys())}")
            return
        
        print(f"\n📂 Categories for {level}: {', '.join(CATEGORIES[level])}")
        category = input("Enter category: ").strip().lower()
        
        if category not in CATEGORIES[level]:
            print(f"❌ Invalid category for {level}")
            return
        
        count = input("How many words? (default 25): ").strip()
        count = int(count) if count else 25
        
        prompt = generate_vocab_prompt(level, category, count)
        
        print("\n" + "="*70)
        print("📋 COPY THIS PROMPT AND USE WITH @Web IN CURSOR:")
        print("="*70)
        print(prompt)
        print("="*70)
        print("\n✅ After getting the response, use option 3 to process it.")
    
    def check_missing(self):
        """Check what data is missing"""
        print("\n🔍 Checking what's missing...\n")
        
        stats = self.processor.get_stats()
        missing = []
        
        for level, categories in CATEGORIES.items():
            level_data = stats.get(level, {})
            fc_count = level_data.get('flashcards', 0)
            
            if fc_count < 100:
                needed = 100 - fc_count
                missing.append({
                    'level': level,
                    'needed': needed,
                    'categories': categories[:3]  # First 3 categories to focus on
                })
        
        if not missing:
            print("✅ All levels have 100+ flashcards!")
            return
        
        print("📝 Missing data:")
        for item in missing:
            print(f"\n  {item['level'].title()}: Need {item['needed']} more flashcards")
            print(f"    Suggested categories: {', '.join(item['categories'])}")
            
            # Generate a prompt for the first missing category
            cat = item['categories'][0]
            print(f"\n    Quick prompt for '{cat}':")
            print(f"    python workflow.py prompt {item['level']} {cat}")
    
    def validate_all(self):
        """Validate all JSON files"""
        print("\n🔍 Validating all data files...\n")
        
        all_valid = True
        
        for level in ['beginner', 'elementary', 'intermediate', 'advanced', 'proficient']:
            level_file = RESOURCES_DIR / f"nepali_learning_data_{level}.json"
            
            if not level_file.exists():
                print(f"  ❌ {level_file.name}: File not found")
                all_valid = False
                continue
            
            try:
                with open(level_file, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                
                fc_count = len(data.get('flashcards', []))
                gr_count = len(data.get('grammar', []))
                
                status = "✅" if fc_count >= 100 else "⚠️"
                print(f"  {status} {level_file.name}: {fc_count} flashcards, {gr_count} grammar")
                
            except json.JSONDecodeError as e:
                print(f"  ❌ {level_file.name}: Invalid JSON - {e}")
                all_valid = False
        
        # Check standalone files
        for filename in ['games.json', 'reading.json', 'practice.json', 'grammar.json']:
            filepath = RESOURCES_DIR / filename
            if filepath.exists():
                try:
                    with open(filepath, 'r', encoding='utf-8') as f:
                        json.load(f)
                    print(f"  ✅ {filename}: Valid JSON")
                except json.JSONDecodeError:
                    print(f"  ❌ {filename}: Invalid JSON")
                    all_valid = False
        
        return all_valid
    
    def push_to_github(self):
        """Push changes to GitHub"""
        print("\n📤 Pushing to GitHub...\n")
        
        try:
            # Add all changes
            subprocess.run(['git', 'add', '.'], cwd=BASE_DIR, check=True)
            
            # Get status
            result = subprocess.run(['git', 'status', '--short'], cwd=BASE_DIR, 
                                  capture_output=True, text=True)
            
            if not result.stdout.strip():
                print("  ℹ️  No changes to commit")
                return True
            
            print(f"  Changes:\n{result.stdout}")
            
            # Commit
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M")
            commit_msg = f"🇳🇵 NPLearn data update - {timestamp}"
            
            subprocess.run(['git', 'commit', '-m', commit_msg], cwd=BASE_DIR, check=True)
            
            # Push
            subprocess.run(['git', 'push'], cwd=BASE_DIR, check=True)
            
            print("\n✅ Successfully pushed to GitHub!")
            return True
            
        except subprocess.CalledProcessError as e:
            print(f"\n❌ Git error: {e}")
            return False
    
    def run_interactive(self):
        """Run interactive mode"""
        while True:
            self.show_menu()
            choice = input("Select option: ").strip()
            
            if choice == '0':
                print("\n👋 Goodbye!")
                break
            elif choice == '1':
                self.generate_vocab_prompt_interactive()
            elif choice == '2':
                # Grammar prompt
                level = input("Enter level: ").strip().lower()
                topic = input("Enter grammar topic: ").strip()
                print("\n" + generate_grammar_prompt(level, topic))
            elif choice == '3':
                # Process response
                from data_processor import process_clipboard_data
                process_clipboard_data()
            elif choice == '4':
                self.processor.print_stats()
            elif choice == '5':
                self.validate_all()
            elif choice == '6':
                self.push_to_github()
            elif choice == '7':
                self.check_missing()
            elif choice == '8':
                self.full_workflow()
            else:
                print("❌ Invalid option")
            
            input("\nPress Enter to continue...")
    
    def full_workflow(self):
        """Guide through full workflow"""
        print("""
╔══════════════════════════════════════════════════════════════════╗
║           Full Workflow Guide                                    ║
╠══════════════════════════════════════════════════════════════════╣
║  Step 1: Generate a prompt for @Web search                       ║
║  Step 2: Copy the prompt and use with @Web in Cursor             ║
║  Step 3: Copy the JSON response                                  ║
║  Step 4: Process the response (option 3)                         ║
║  Step 5: Repeat for all categories                               ║
║  Step 6: Validate all data (option 5)                            ║
║  Step 7: Push to GitHub (option 6)                               ║
╚══════════════════════════════════════════════════════════════════╝
        """)
        
        # Check what's missing first
        self.check_missing()


def main():
    """Main entry point"""
    args = sys.argv[1:]
    
    if not args:
        # Interactive mode
        manager = WorkflowManager()
        manager.run_interactive()
    
    elif args[0] == "prompt" and len(args) >= 3:
        # Generate prompt: workflow.py prompt <level> <category>
        level = args[1]
        category = args[2]
        count = int(args[3]) if len(args) > 3 else 25
        
        print(generate_vocab_prompt(level, category, count))
    
    elif args[0] == "stats":
        processor = DataProcessor(RESOURCES_DIR)
        processor.print_stats()
    
    elif args[0] == "validate":
        manager = WorkflowManager()
        manager.validate_all()
    
    elif args[0] == "push":
        manager = WorkflowManager()
        manager.push_to_github()
    
    elif args[0] == "missing":
        manager = WorkflowManager()
        manager.check_missing()
    
    else:
        print("""
NPLearn Workflow Manager
========================

Usage:
  python workflow.py              # Interactive mode
  python workflow.py prompt <level> <category> [count]
  python workflow.py stats        # Show statistics
  python workflow.py validate     # Validate all data
  python workflow.py push         # Push to GitHub
  python workflow.py missing      # Check what's missing

Examples:
  python workflow.py prompt beginner greetings 30
  python workflow.py prompt elementary animals
        """)


if __name__ == "__main__":
    main()

