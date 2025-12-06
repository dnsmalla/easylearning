#!/usr/bin/env python3
"""
Educa Data Validator
Validates JSON data files against the schema
"""

import json
import sys
import os
from pathlib import Path
from typing import Dict, List, Tuple, Any
from dataclasses import dataclass
import re
from datetime import datetime

@dataclass
class ValidationResult:
    is_valid: bool
    errors: List[str]
    warnings: List[str]
    stats: Dict[str, Any]

class EducaDataValidator:
    """Validates Educa data files against schema"""
    
    def __init__(self, schema_path: Path):
        self.schema = self.load_schema(schema_path)
        self.definitions = self.schema.get("definitions", {})
        self.metadata = self.schema.get("metadata", {})
    
    def load_schema(self, path: Path) -> Dict:
        with open(path, 'r', encoding='utf-8') as f:
            return json.load(f)
    
    def validate_field(self, field_name: str, value: Any, field_schema: Dict) -> List[str]:
        """Validate a single field against its schema"""
        errors = []
        
        field_type = field_schema.get("type")
        
        # Type checking
        if field_type == "string":
            if not isinstance(value, str):
                errors.append(f"Field '{field_name}' should be string, got {type(value).__name__}")
            else:
                # Min length
                min_length = field_schema.get("minLength")
                if min_length and len(value) < min_length:
                    errors.append(f"Field '{field_name}' too short (min {min_length} chars)")
                
                # Pattern
                pattern = field_schema.get("pattern")
                if pattern and not re.match(pattern, value):
                    errors.append(f"Field '{field_name}' doesn't match pattern {pattern}")
                
                # Enum
                enum = field_schema.get("enum")
                if enum and value not in enum:
                    errors.append(f"Field '{field_name}' must be one of {enum}")
                    
        elif field_type == "number" or field_type == "integer":
            if not isinstance(value, (int, float)):
                errors.append(f"Field '{field_name}' should be number, got {type(value).__name__}")
            else:
                minimum = field_schema.get("minimum")
                maximum = field_schema.get("maximum")
                if minimum is not None and value < minimum:
                    errors.append(f"Field '{field_name}' below minimum ({minimum})")
                if maximum is not None and value > maximum:
                    errors.append(f"Field '{field_name}' above maximum ({maximum})")
                    
        elif field_type == "boolean":
            if not isinstance(value, bool):
                errors.append(f"Field '{field_name}' should be boolean, got {type(value).__name__}")
                
        elif field_type == "array":
            if not isinstance(value, list):
                errors.append(f"Field '{field_name}' should be array, got {type(value).__name__}")
            else:
                min_items = field_schema.get("minItems")
                if min_items and len(value) < min_items:
                    errors.append(f"Field '{field_name}' needs at least {min_items} items")
        
        return errors
    
    def validate_item(self, item: Dict, definition_name: str, item_index: int) -> List[str]:
        """Validate a single item against its definition"""
        errors = []
        definition = self.definitions.get(definition_name, {})
        properties = definition.get("properties", {})
        required_fields = definition.get("required", [])
        
        # Check required fields
        for field in required_fields:
            if field not in item:
                errors.append(f"Item #{item_index}: Missing required field '{field}'")
            elif item[field] is None or (isinstance(item[field], str) and not item[field].strip()):
                errors.append(f"Item #{item_index}: Empty required field '{field}'")
        
        # Validate each field
        for field_name, value in item.items():
            if field_name in properties:
                field_errors = self.validate_field(field_name, value, properties[field_name])
                for error in field_errors:
                    errors.append(f"Item #{item_index}: {error}")
        
        return errors
    
    def validate_file(self, file_path: Path) -> ValidationResult:
        """Validate a complete data file"""
        errors = []
        warnings = []
        stats = {
            "total_items": 0,
            "valid_items": 0,
            "invalid_items": 0,
            "file_size_kb": 0
        }
        
        # Check file exists
        if not file_path.exists():
            errors.append(f"File not found: {file_path}")
            return ValidationResult(False, errors, warnings, stats)
        
        # Get file size
        stats["file_size_kb"] = file_path.stat().st_size / 1024
        
        # Load JSON
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
        except json.JSONDecodeError as e:
            errors.append(f"Invalid JSON: {e}")
            return ValidationResult(False, errors, warnings, stats)
        
        # Check version field
        if "version" not in data:
            warnings.append("Missing 'version' field")
        
        # Determine definition name from filename
        filename = file_path.stem
        definition_map = {
            "universities": "university",
            "countries": "country",
            "courses": "course",
            "guides": "guide",
            "remittance": "remittance_provider",
            "jobs": "job_listing",
            "scholarships": "scholarship",
            "services": "service",
            "updates": "update"
        }
        
        definition_name = definition_map.get(filename)
        
        if not definition_name or definition_name not in self.definitions:
            warnings.append(f"No schema definition found for {filename}")
            # Still validate basic structure
            for key in data:
                if isinstance(data[key], list):
                    stats["total_items"] = len(data[key])
            return ValidationResult(len(errors) == 0, errors, warnings, stats)
        
        # Find the array key in data
        array_key = None
        for key in data:
            if isinstance(data[key], list):
                array_key = key
                break
        
        if not array_key:
            errors.append("No data array found in file")
            return ValidationResult(False, errors, warnings, stats)
        
        # Validate each item
        items = data[array_key]
        stats["total_items"] = len(items)
        
        for idx, item in enumerate(items):
            item_errors = self.validate_item(item, definition_name, idx)
            if item_errors:
                errors.extend(item_errors)
                stats["invalid_items"] += 1
            else:
                stats["valid_items"] += 1
        
        # Check against min/max items from metadata
        file_metadata = self.metadata.get("data_files", {}).get(filename, {})
        min_items = file_metadata.get("min_items", 0)
        max_items = file_metadata.get("max_items", float('inf'))
        
        if stats["total_items"] < min_items:
            warnings.append(f"Item count ({stats['total_items']}) below minimum ({min_items})")
        if stats["total_items"] > max_items:
            warnings.append(f"Item count ({stats['total_items']}) above maximum ({max_items})")
        
        return ValidationResult(len(errors) == 0, errors, warnings, stats)
    
    def validate_all(self, data_dir: Path) -> Dict[str, ValidationResult]:
        """Validate all data files"""
        results = {}
        
        for json_file in data_dir.glob("*.json"):
            results[json_file.name] = self.validate_file(json_file)
        
        return results
    
    def generate_report(self, results: Dict[str, ValidationResult]) -> str:
        """Generate a validation report"""
        report = []
        report.append("")
        report.append("╔══════════════════════════════════════════════════════════╗")
        report.append("║           EDUCA DATA VALIDATION REPORT                   ║")
        report.append("╚══════════════════════════════════════════════════════════╝")
        report.append("")
        report.append(f"Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        report.append("")
        
        all_valid = True
        total_items = 0
        total_errors = 0
        
        for filename, result in results.items():
            status = "✅ PASS" if result.is_valid else "❌ FAIL"
            report.append(f"{status} {filename}")
            report.append(f"     Items: {result.stats['total_items']} | Valid: {result.stats['valid_items']} | Invalid: {result.stats['invalid_items']}")
            report.append(f"     Size: {result.stats['file_size_kb']:.1f} KB")
            
            if result.errors:
                all_valid = False
                total_errors += len(result.errors)
                for error in result.errors[:3]:  # Show first 3 errors
                    report.append(f"     ⚠️  {error}")
                if len(result.errors) > 3:
                    report.append(f"     ... and {len(result.errors) - 3} more errors")
            
            if result.warnings:
                for warning in result.warnings:
                    report.append(f"     💡 {warning}")
            
            report.append("")
            total_items += result.stats['total_items']
        
        report.append("─" * 60)
        report.append(f"Total Items: {total_items}")
        report.append(f"Total Errors: {total_errors}")
        report.append(f"Overall Status: {'✅ ALL VALID' if all_valid else '❌ ERRORS FOUND'}")
        report.append("")
        
        return "\n".join(report)


def main():
    import argparse
    
    parser = argparse.ArgumentParser(description="Validate Educa data files")
    parser.add_argument("--schema", default=None, help="Path to schema file")
    parser.add_argument("--data", default=None, help="Path to data directory")
    parser.add_argument("--file", default=None, help="Validate specific file")
    parser.add_argument("--quiet", action="store_true", help="Only show errors")
    
    args = parser.parse_args()
    
    # Determine paths
    script_dir = Path(__file__).parent
    data_dir = Path(args.data) if args.data else script_dir.parent / "data"
    schema_path = Path(args.schema) if args.schema else script_dir.parent / "data_schema.json"
    
    if not schema_path.exists():
        print(f"❌ Schema file not found: {schema_path}")
        sys.exit(1)
    
    validator = EducaDataValidator(schema_path)
    
    if args.file:
        # Validate single file
        file_path = Path(args.file) if os.path.isabs(args.file) else data_dir / args.file
        result = validator.validate_file(file_path)
        
        if not args.quiet:
            print(f"\nValidating: {file_path.name}")
            print(f"Status: {'✅ VALID' if result.is_valid else '❌ INVALID'}")
            print(f"Items: {result.stats['total_items']}")
            
        if result.errors:
            print("\nErrors:")
            for error in result.errors:
                print(f"  - {error}")
                
        sys.exit(0 if result.is_valid else 1)
    else:
        # Validate all files
        if not data_dir.exists():
            print(f"❌ Data directory not found: {data_dir}")
            sys.exit(1)
            
        results = validator.validate_all(data_dir)
        
        if not args.quiet:
            report = validator.generate_report(results)
            print(report)
        
        all_valid = all(r.is_valid for r in results.values())
        sys.exit(0 if all_valid else 1)


if __name__ == "__main__":
    main()

