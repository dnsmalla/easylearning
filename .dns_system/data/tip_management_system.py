#!/usr/bin/env python3
"""
DNS System - Tip Management System
Systematically manages tips from errors, debugging, and successful patterns
to improve future code generation quality and reduce repeated mistakes.
"""

import csv
import json
import logging
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any, Optional, Tuple
from dataclasses import dataclass, asdict
from enum import Enum


class TipCategory(Enum):
    """Categories of tips for better organization."""
    SYNTAX_ERROR = "syntax_error"
    IMPORT_MISSING = "import_missing"
    LOGIC_ERROR = "logic_error"
    TEMPLATE_PLACEHOLDER = "template_placeholder"
    BEST_PRACTICE = "best_practice"
    PERFORMANCE = "performance"
    SECURITY = "security"
    DEBUGGING = "debugging"


class TipPriority(Enum):
    """Priority levels for tips."""
    CRITICAL = "critical"      # Must fix immediately
    HIGH = "high"             # Important improvements
    MEDIUM = "medium"         # Good to have
    LOW = "low"              # Nice to have


@dataclass
class CodeTip:
    """Represents a single tip extracted from errors or successful patterns."""
    tip_id: str
    category: TipCategory
    priority: TipPriority
    project_type: str          # ecommerce, mobile, web_api, etc.
    language: str              # python, swift, dart, etc.
    error_pattern: str         # Original error or issue description
    solution: str              # How to fix or implement
    prevention_code: str       # Code example to prevent issue
    success_rate: float        # 0.0 to 1.0 - how often this solution works
    usage_count: int           # Times this tip was applied
    created_date: datetime
    last_used: Optional[datetime] = None
    tags: List[str] = None     # Additional searchable tags
    
    def __post_init__(self):
        if self.tags is None:
            self.tags = []


class TipManager:
    """Manages the systematic collection, storage, and retrieval of coding tips."""
    
    def __init__(self, data_dir: str = ".dns_system/data"):
        self.data_dir = Path(data_dir)
        self.data_dir.mkdir(parents=True, exist_ok=True)
        
        # File paths
        self.tips_csv = self.data_dir / "coding_tips.csv"
        self.tips_json = self.data_dir / "tips_backup.json"
        self.usage_stats = self.data_dir / "tip_usage_stats.json"
        
        # Logger
        self.logger = logging.getLogger(self.__class__.__name__)
        
        # In-memory tip storage
        self.tips: Dict[str, CodeTip] = {}
        self.load_tips()
    
    def load_tips(self) -> None:
        """Load tips from CSV file into memory."""
        if not self.tips_csv.exists():
            self.logger.info("No existing tips file found. Starting fresh.")
            return
        
        try:
            with open(self.tips_csv, 'r', newline='', encoding='utf-8') as file:
                reader = csv.DictReader(file)
                for row in reader:
                    tip = self._dict_to_tip(row)
                    self.tips[tip.tip_id] = tip
            
            self.logger.info(f"Loaded {len(self.tips)} tips from {self.tips_csv}")
        except Exception as e:
            self.logger.error(f"Error loading tips: {e}")
    
    def save_tips(self) -> None:
        """Save all tips to CSV file."""
        try:
            with open(self.tips_csv, 'w', newline='', encoding='utf-8') as file:
                if not self.tips:
                    return
                
                fieldnames = list(asdict(next(iter(self.tips.values()))).keys())
                writer = csv.DictWriter(file, fieldnames=fieldnames)
                writer.writeheader()
                
                for tip in self.tips.values():
                    row = self._tip_to_dict(tip)
                    writer.writerow(row)
            
            # Also save JSON backup
            self._save_json_backup()
            self.logger.info(f"Saved {len(self.tips)} tips to {self.tips_csv}")
        except Exception as e:
            self.logger.error(f"Error saving tips: {e}")
    
    def add_tip(self, tip: CodeTip) -> bool:
        """Add a new tip to the system."""
        try:
            if tip.tip_id in self.tips:
                self.logger.warning(f"Tip {tip.tip_id} already exists. Use update_tip() instead.")
                return False
            
            self.tips[tip.tip_id] = tip
            self.save_tips()
            self.logger.info(f"Added new tip: {tip.tip_id}")
            return True
        except Exception as e:
            self.logger.error(f"Error adding tip: {e}")
            return False
    
    def update_tip_usage(self, tip_id: str, success: bool) -> None:
        """Update tip usage statistics."""
        if tip_id not in self.tips:
            self.logger.warning(f"Tip {tip_id} not found for usage update")
            return
        
        tip = self.tips[tip_id]
        tip.usage_count += 1
        tip.last_used = datetime.now()
        
        # Update success rate using moving average
        if tip.usage_count == 1:
            tip.success_rate = 1.0 if success else 0.0
        else:
            # Weighted average favoring recent results
            weight = 0.2  # 20% weight for new result
            new_success = 1.0 if success else 0.0
            tip.success_rate = (tip.success_rate * (1 - weight)) + (new_success * weight)
        
        self.save_tips()
        self.logger.info(f"Updated tip {tip_id} usage. Success rate: {tip.success_rate:.2f}")
    
    def get_relevant_tips(self, 
                         project_type: str, 
                         language: str, 
                         category: Optional[TipCategory] = None,
                         min_success_rate: float = 0.5,
                         max_tips: int = 10) -> List[CodeTip]:
        """Get relevant tips for a specific project type and language."""
        relevant_tips = []
        
        for tip in self.tips.values():
            # Filter by project type and language
            if tip.project_type.lower() != project_type.lower():
                continue
            if tip.language.lower() != language.lower():
                continue
            
            # Filter by category if specified
            if category and tip.category != category:
                continue
            
            # Filter by success rate
            if tip.success_rate < min_success_rate:
                continue
            
            relevant_tips.append(tip)
        
        # Sort by priority and success rate
        relevant_tips.sort(key=lambda t: (
            t.priority == TipPriority.CRITICAL,
            t.priority == TipPriority.HIGH,
            t.success_rate
        ), reverse=True)
        
        return relevant_tips[:max_tips]
    
    def generate_prevention_prompt(self, project_type: str, language: str) -> str:
        """Generate a prompt section with relevant prevention tips."""
        tips = self.get_relevant_tips(project_type, language)
        
        if not tips:
            return "## 💡 Best Practices\n- Follow standard coding conventions\n- Include proper error handling\n"
        
        prompt = "## 🛡️ Prevention Tips (Based on Past Errors)\n\n"
        prompt += "Apply these proven solutions to avoid common issues:\n\n"
        
        # Group by priority
        critical_tips = [t for t in tips if t.priority == TipPriority.CRITICAL]
        high_tips = [t for t in tips if t.priority == TipPriority.HIGH]
        
        if critical_tips:
            prompt += "### 🚨 Critical (Must Apply)\n"
            for tip in critical_tips[:3]:  # Top 3 critical
                prompt += f"- **{tip.solution}**\n"
                if tip.prevention_code.strip():
                    prompt += f"  ```{language}\n  {tip.prevention_code}\n  ```\n"
                prompt += f"  *(Success rate: {tip.success_rate:.1%})*\n\n"
        
        if high_tips:
            prompt += "### ⚡ High Priority\n"
            for tip in high_tips[:5]:  # Top 5 high priority
                prompt += f"- **{tip.solution}**\n"
                if tip.prevention_code.strip():
                    prompt += f"  ```{language}\n  {tip.prevention_code}\n  ```\n"
                prompt += f"  *(Used {tip.usage_count} times)*\n\n"
        
        prompt += "### 📋 Remember\n"
        prompt += "- These tips are based on real error patterns from previous generations\n"
        prompt += "- Apply relevant patterns to prevent common mistakes\n"
        prompt += "- Focus on critical items first\n\n"
        
        return prompt
    
    def extract_tips_from_correction_files(self, corrections_dir: str) -> int:
        """Extract tips from existing correction files."""
        corrections_path = Path(corrections_dir)
        if not corrections_path.exists():
            self.logger.warning(f"Corrections directory not found: {corrections_dir}")
            return 0
        
        extracted_count = 0
        
        for correction_file in corrections_path.glob("fix_*.md"):
            try:
                tips = self._parse_correction_file(correction_file)
                for tip in tips:
                    if self.add_tip(tip):
                        extracted_count += 1
            except Exception as e:
                self.logger.error(f"Error processing {correction_file}: {e}")
        
        self.logger.info(f"Extracted {extracted_count} tips from correction files")
        return extracted_count
    
    def _parse_correction_file(self, file_path: Path) -> List[CodeTip]:
        """Parse a correction file to extract tips."""
        tips = []
        
        try:
            content = file_path.read_text(encoding='utf-8')
            
            # Extract language from filename
            language = self._detect_language_from_filename(file_path.name)
            
            # Extract project type from content
            project_type = self._detect_project_type_from_content(content)
            
            # Look for error patterns and solutions
            if "SyntaxError" in content:
                tip_id = f"syntax_{language}_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
                tip = CodeTip(
                    tip_id=tip_id,
                    category=TipCategory.SYNTAX_ERROR,
                    priority=TipPriority.CRITICAL,
                    project_type=project_type,
                    language=language,
                    error_pattern="Syntax errors in generated code",
                    solution="Always validate syntax before code generation",
                    prevention_code="# Add syntax validation step\nast.parse(generated_code)",
                    success_rate=0.8,
                    usage_count=0,
                    created_date=datetime.now(),
                    tags=["syntax", "validation"]
                )
                tips.append(tip)
            
            # Look for import issues
            if "import" in content.lower() and ("missing" in content.lower() or "error" in content.lower()):
                tip_id = f"import_{language}_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
                
                # Extract specific imports that were missing
                prevention_code = self._extract_import_pattern(content, language)
                
                tip = CodeTip(
                    tip_id=tip_id,
                    category=TipCategory.IMPORT_MISSING,
                    priority=TipPriority.HIGH,
                    project_type=project_type,
                    language=language,
                    error_pattern="Missing import statements",
                    solution=f"Always include standard {language} imports for {project_type} projects",
                    prevention_code=prevention_code,
                    success_rate=0.9,
                    usage_count=0,
                    created_date=datetime.now(),
                    tags=["imports", project_type]
                )
                tips.append(tip)
        
        except Exception as e:
            self.logger.error(f"Error parsing correction file {file_path}: {e}")
        
        return tips
    
    def _detect_language_from_filename(self, filename: str) -> str:
        """Detect programming language from filename."""
        if "swift" in filename.lower():
            return "swift"
        elif "dart" in filename.lower() or "flutter" in filename.lower():
            return "dart"
        else:
            return "python"  # Default
    
    def _detect_project_type_from_content(self, content: str) -> str:
        """Detect project type from file content."""
        content_lower = content.lower()
        
        if any(word in content_lower for word in ["ecommerce", "shop", "cart", "payment"]):
            return "ecommerce"
        elif any(word in content_lower for word in ["mobile", "ios", "android", "app"]):
            return "mobile"
        elif any(word in content_lower for word in ["api", "endpoint", "rest", "web"]):
            return "web_api"
        elif any(word in content_lower for word in ["database", "sql", "data", "storage"]):
            return "database"
        else:
            return "generic"
    
    def _extract_import_pattern(self, content: str, language: str) -> str:
        """Extract import pattern from content."""
        if language == "python":
            return """from __future__ import annotations
import logging
from datetime import datetime
from typing import Optional, Dict, List, Any, Union"""
        elif language == "swift":
            return """import Foundation
import os.log
import UIKit"""
        elif language == "dart":
            return """import 'package:flutter/material.dart';
import 'dart:developer' as developer;"""
        else:
            return "// Add appropriate imports"
    
    def _tip_to_dict(self, tip: CodeTip) -> Dict[str, str]:
        """Convert CodeTip to dictionary for CSV serialization."""
        data = asdict(tip)
        data['category'] = tip.category.value
        data['priority'] = tip.priority.value
        data['created_date'] = tip.created_date.isoformat()
        data['last_used'] = tip.last_used.isoformat() if tip.last_used else ""
        data['tags'] = ",".join(tip.tags) if tip.tags else ""
        return data
    
    def _dict_to_tip(self, data: Dict[str, str]) -> CodeTip:
        """Convert dictionary to CodeTip object."""
        return CodeTip(
            tip_id=data['tip_id'],
            category=TipCategory(data['category']),
            priority=TipPriority(data['priority']),
            project_type=data['project_type'],
            language=data['language'],
            error_pattern=data['error_pattern'],
            solution=data['solution'],
            prevention_code=data['prevention_code'],
            success_rate=float(data['success_rate']),
            usage_count=int(data['usage_count']),
            created_date=datetime.fromisoformat(data['created_date']),
            last_used=datetime.fromisoformat(data['last_used']) if data['last_used'] else None,
            tags=data['tags'].split(',') if data['tags'] else []
        )
    
    def _save_json_backup(self) -> None:
        """Save tips as JSON backup."""
        try:
            tips_data = []
            for tip in self.tips.values():
                tip_dict = self._tip_to_dict(tip)
                tips_data.append(tip_dict)
            
            with open(self.tips_json, 'w', encoding='utf-8') as file:
                json.dump(tips_data, file, indent=2, ensure_ascii=False)
        except Exception as e:
            self.logger.error(f"Error saving JSON backup: {e}")
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get statistics about the tip database."""
        if not self.tips:
            return {"total_tips": 0}
        
        stats = {
            "total_tips": len(self.tips),
            "by_category": {},
            "by_language": {},
            "by_project_type": {},
            "by_priority": {},
            "avg_success_rate": 0.0,
            "most_used": None,
            "recently_added": 0
        }
        
        # Count by categories
        for tip in self.tips.values():
            # Category stats
            cat = tip.category.value
            stats["by_category"][cat] = stats["by_category"].get(cat, 0) + 1
            
            # Language stats
            lang = tip.language
            stats["by_language"][lang] = stats["by_language"].get(lang, 0) + 1
            
            # Project type stats
            proj = tip.project_type
            stats["by_project_type"][proj] = stats["by_project_type"].get(proj, 0) + 1
            
            # Priority stats
            pri = tip.priority.value
            stats["by_priority"][pri] = stats["by_priority"].get(pri, 0) + 1
        
        # Calculate average success rate
        success_rates = [tip.success_rate for tip in self.tips.values()]
        stats["avg_success_rate"] = sum(success_rates) / len(success_rates)
        
        # Find most used tip
        most_used = max(self.tips.values(), key=lambda t: t.usage_count)
        stats["most_used"] = {
            "tip_id": most_used.tip_id,
            "usage_count": most_used.usage_count,
            "solution": most_used.solution
        }
        
        # Count recently added (last 7 days)
        week_ago = datetime.now().timestamp() - (7 * 24 * 60 * 60)
        stats["recently_added"] = sum(
            1 for tip in self.tips.values() 
            if tip.created_date.timestamp() > week_ago
        )
        
        return stats


def main():
    """Example usage and testing."""
    logging.basicConfig(level=logging.INFO)
    
    # Initialize tip manager
    tip_manager = TipManager()
    
    # Add some example tips
    example_tip = CodeTip(
        tip_id="python_ecommerce_001",
        category=TipCategory.IMPORT_MISSING,
        priority=TipPriority.HIGH,
        project_type="ecommerce",
        language="python",
        error_pattern="NameError: name 'datetime' is not defined",
        solution="Always include datetime import for ecommerce projects",
        prevention_code="from datetime import datetime",
        success_rate=0.95,
        usage_count=0,
        created_date=datetime.now(),
        tags=["datetime", "imports"]
    )
    
    tip_manager.add_tip(example_tip)
    
    # Extract tips from existing corrections
    corrections_dir = ".dns_system/system/workspace/corrections"
    tip_manager.extract_tips_from_correction_files(corrections_dir)
    
    # Generate prevention prompt
    prompt = tip_manager.generate_prevention_prompt("ecommerce", "python")
    print("Generated Prevention Prompt:")
    print(prompt)
    
    # Show statistics
    stats = tip_manager.get_statistics()
    print(f"\nTip Database Statistics:")
    print(f"Total tips: {stats['total_tips']}")
    print(f"Average success rate: {stats['avg_success_rate']:.1%}")


if __name__ == "__main__":
    main()
