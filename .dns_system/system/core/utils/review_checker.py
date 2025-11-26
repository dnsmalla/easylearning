#!/usr/bin/env python3
"""
App Store Review Requirements Checker
Automatically validates apps against known App Store review requirements
to prevent rejections before submission.

Usage:
    python review_checker.py [app_directory]
    python review_checker.py --check account_deletion
    python review_checker.py --report
"""

import os
import sys
import yaml
import json
import re
from pathlib import Path
from typing import Dict, List, Tuple, Optional
from enum import Enum

class Severity(Enum):
    CRITICAL = "critical"
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"

class CheckResult:
    def __init__(self, check_id: str, passed: bool, severity: Severity, 
                 message: str, details: str = ""):
        self.check_id = check_id
        self.passed = passed
        self.severity = severity
        self.message = message
        self.details = details

class ReviewChecker:
    def __init__(self, app_dir: str, requirements_file: str = None):
        self.app_dir = Path(app_dir)
        self.requirements_file = requirements_file or self._find_requirements_file()
        self.requirements = self._load_requirements()
        self.results: List[CheckResult] = []
    
    def _find_requirements_file(self) -> str:
        """Find the requirements YAML file"""
        # Look in .dns_system/data/
        candidates = [
            self.app_dir / ".dns_system/data/app_store_review_requirements.yml",
            self.app_dir.parent / ".dns_system/data/app_store_review_requirements.yml",
            Path(__file__).parent / "../../../../data/app_store_review_requirements.yml",
            Path(__file__).parent / "../../../data/app_store_review_requirements.yml",
            Path(__file__).parent / "app_store_review_requirements.yml",
        ]
        for path in candidates:
            if path.exists():
                return str(path)
        raise FileNotFoundError(f"Could not find app_store_review_requirements.yml. Tried: {[str(p) for p in candidates]}")
    
    def _load_requirements(self) -> Dict:
        """Load requirements from YAML file"""
        with open(self.requirements_file, 'r') as f:
            return yaml.safe_load(f)
    
    def run_all_checks(self) -> Tuple[int, int]:
        """Run all automated checks. Returns (passed, total)"""
        print(f"\n🔍 Running App Store Review Checks...")
        print(f"App Directory: {self.app_dir}")
        print(f"Requirements: {self.requirements_file}\n")
        
        # Run critical checks
        self._check_bundle_identifier()
        self._check_privacy_policy()
        self._check_terms_of_service()
        self._check_app_icon()
        self._check_account_deletion()
        self._check_permission_descriptions()
        
        # Summary
        passed = sum(1 for r in self.results if r.passed)
        total = len(self.results)
        
        self._print_results()
        return passed, total
    
    def _check_bundle_identifier(self):
        """Check for placeholder bundle identifiers"""
        check_id = "bundle_identifier"
        
        # Check Info.plist
        info_plist = self.app_dir / "Sources/Info.plist"
        if not info_plist.exists():
            info_plist = self.app_dir / "Info.plist"
        
        if not info_plist.exists():
            self.results.append(CheckResult(
                check_id, False, Severity.CRITICAL,
                "Info.plist not found",
                "Could not locate Info.plist to check bundle identifier"
            ))
            return
        
        content = info_plist.read_text()
        
        # Check for placeholder patterns
        invalid_patterns = [
            r'com\.example',
            r'com\.company',
            r'com\.yourcompany',
            r'com\.test\.'
        ]
        
        for pattern in invalid_patterns:
            if re.search(pattern, content, re.IGNORECASE):
                self.results.append(CheckResult(
                    check_id, False, Severity.CRITICAL,
                    f"Placeholder bundle identifier detected: {pattern}",
                    "Update bundle identifier in Info.plist and project.yml"
                ))
                return
        
        self.results.append(CheckResult(
            check_id, True, Severity.CRITICAL,
            "Bundle identifier appears valid"
        ))
    
    def _check_privacy_policy(self):
        """Check for valid privacy policy URL"""
        check_id = "privacy_policy"
        
        # Check AppConfiguration.swift
        config_file = self.app_dir / "Sources/AppConfiguration.swift"
        if not config_file.exists():
            config_file = self.app_dir / "AppConfiguration.swift"
        
        if not config_file.exists():
            self.results.append(CheckResult(
                check_id, False, Severity.CRITICAL,
                "AppConfiguration.swift not found",
                "Could not verify privacy policy URL"
            ))
            return
        
        content = config_file.read_text()
        
        # Check for placeholder URLs
        if 'example.com' in content.lower():
            # Check if it's in the privacy policy section
            if re.search(r'privacyPolicyURL.*example\.com', content, re.IGNORECASE | re.DOTALL):
                self.results.append(CheckResult(
                    check_id, False, Severity.CRITICAL,
                    "Privacy policy URL is a placeholder (example.com)",
                    "Update privacyPolicyURL in AppConfiguration.swift"
                ))
                return
        
        # Check if privacy policy URL exists
        if 'privacyPolicyURL' in content:
            self.results.append(CheckResult(
                check_id, True, Severity.CRITICAL,
                "Privacy policy URL configured"
            ))
        else:
            self.results.append(CheckResult(
                check_id, False, Severity.CRITICAL,
                "No privacy policy URL found",
                "Add privacyPolicyURL to AppConfiguration.swift"
            ))
    
    def _check_terms_of_service(self):
        """Check for valid terms of service URL"""
        check_id = "terms_of_service"
        
        config_file = self.app_dir / "Sources/AppConfiguration.swift"
        if not config_file.exists():
            config_file = self.app_dir / "AppConfiguration.swift"
        
        if not config_file.exists():
            return
        
        content = config_file.read_text()
        
        # Check for placeholder URLs
        if re.search(r'termsOfServiceURL.*example\.com', content, re.IGNORECASE | re.DOTALL):
            self.results.append(CheckResult(
                check_id, False, Severity.CRITICAL,
                "Terms of service URL is a placeholder",
                "Update termsOfServiceURL in AppConfiguration.swift"
            ))
        elif 'termsOfServiceURL' in content:
            self.results.append(CheckResult(
                check_id, True, Severity.CRITICAL,
                "Terms of service URL configured"
            ))
    
    def _check_app_icon(self):
        """Check for app icon assets"""
        check_id = "app_icon"
        
        icon_path = self.app_dir / "Sources/Assets.xcassets/AppIcon.appiconset"
        if not icon_path.exists():
            icon_path = self.app_dir / "Assets.xcassets/AppIcon.appiconset"
        
        if not icon_path.exists():
            self.results.append(CheckResult(
                check_id, False, Severity.CRITICAL,
                "AppIcon.appiconset not found",
                "Add app icons to Assets.xcassets/AppIcon.appiconset"
            ))
            return
        
        # Check Contents.json
        contents_file = icon_path / "Contents.json"
        if not contents_file.exists():
            self.results.append(CheckResult(
                check_id, False, Severity.CRITICAL,
                "AppIcon Contents.json not found",
                "AppIcon.appiconset is missing Contents.json"
            ))
            return
        
        # Count icon files
        icon_files = list(icon_path.glob("*.png"))
        if len(icon_files) < 7:  # Minimum required
            self.results.append(CheckResult(
                check_id, False, Severity.CRITICAL,
                f"Not enough app icon sizes ({len(icon_files)} found, need at least 7)",
                "Add all required app icon sizes"
            ))
        else:
            self.results.append(CheckResult(
                check_id, True, Severity.CRITICAL,
                f"App icons present ({len(icon_files)} sizes)"
            ))
    
    def _check_account_deletion(self):
        """Check for account deletion implementation"""
        check_id = "account_deletion"
        
        # Check AuthService for deleteAccount method
        auth_service = self.app_dir / "Sources/AuthService.swift"
        if not auth_service.exists():
            auth_service = self.app_dir / "AuthService.swift"
        
        if not auth_service.exists():
            self.results.append(CheckResult(
                check_id, False, Severity.CRITICAL,
                "⚠️  AuthService.swift not found",
                "Cannot verify account deletion implementation"
            ))
            return
        
        auth_content = auth_service.read_text()
        
        # Check for deleteAccount method
        if 'deleteAccount' not in auth_content:
            self.results.append(CheckResult(
                check_id, False, Severity.CRITICAL,
                "❌ No account deletion method found in AuthService",
                "Add deleteAccount() method to AuthService (Apple Guideline 5.1.1(v))"
            ))
            return
        
        # Check ProfileView for delete UI
        profile_view = self.app_dir / "Sources/ProfileView.swift"
        if not profile_view.exists():
            profile_view = self.app_dir / "ProfileView.swift"
        
        if profile_view.exists():
            profile_content = profile_view.read_text()
            if 'Delete Account' in profile_content or 'delete' in profile_content.lower():
                self.results.append(CheckResult(
                    check_id, True, Severity.CRITICAL,
                    "✅ Account deletion implemented (method + UI)"
                ))
            else:
                self.results.append(CheckResult(
                    check_id, False, Severity.CRITICAL,
                    "⚠️  Account deletion method exists but no UI found",
                    "Add 'Delete Account' button to ProfileView"
                ))
        else:
            self.results.append(CheckResult(
                check_id, False, Severity.HIGH,
                "⚠️  Account deletion method exists but ProfileView not found",
                "Cannot verify UI implementation"
            ))
    
    def _check_permission_descriptions(self):
        """Check that all permissions have usage descriptions"""
        check_id = "permission_descriptions"
        
        info_plist = self.app_dir / "Sources/Info.plist"
        if not info_plist.exists():
            info_plist = self.app_dir / "Info.plist"
        
        if not info_plist.exists():
            return
        
        content = info_plist.read_text()
        
        # List of permissions that require descriptions
        required_descriptions = {
            'NSCameraUsageDescription': 'Camera',
            'NSPhotoLibraryUsageDescription': 'Photo Library',
            'NSLocationWhenInUseUsageDescription': 'Location',
            'NSMicrophoneUsageDescription': 'Microphone',
            'NSContactsUsageDescription': 'Contacts',
            'NSCalendarsUsageDescription': 'Calendar',
            'NSFaceIDUsageDescription': 'Face ID',
        }
        
        missing = []
        for key, name in required_descriptions.items():
            if key in content:
                # Check if it has a non-empty value
                match = re.search(f'<key>{key}</key>\\s*<string>([^<]*)</string>', content)
                if match and match.group(1).strip():
                    continue  # Has description
                else:
                    missing.append(name)
        
        if missing and len(missing) > 0:
            self.results.append(CheckResult(
                check_id, False, Severity.HIGH,
                f"Missing descriptions for: {', '.join(missing)}",
                "Add usage descriptions in Info.plist"
            ))
        elif any(key in content for key in required_descriptions.keys()):
            self.results.append(CheckResult(
                check_id, True, Severity.HIGH,
                "All requested permissions have descriptions"
            ))
    
    def _print_results(self):
        """Print check results"""
        print("\n" + "="*70)
        print("CHECK RESULTS")
        print("="*70 + "\n")
        
        # Group by severity
        by_severity = {s: [] for s in Severity}
        for result in self.results:
            by_severity[result.severity].append(result)
        
        # Print critical first
        for severity in [Severity.CRITICAL, Severity.HIGH, Severity.MEDIUM, Severity.LOW]:
            results = by_severity[severity]
            if not results:
                continue
            
            print(f"\n{severity.value.upper()} CHECKS:")
            print("-" * 70)
            
            for result in results:
                icon = "✅" if result.passed else "❌"
                print(f"{icon} {result.message}")
                if result.details:
                    print(f"   └─ {result.details}")
        
        # Summary
        passed = sum(1 for r in self.results if r.passed)
        failed = len(self.results) - passed
        
        print("\n" + "="*70)
        print(f"SUMMARY: {passed}/{len(self.results)} checks passed")
        if failed > 0:
            print(f"❌ {failed} issue(s) need attention before submission")
        else:
            print("✅ All checks passed! Ready for submission.")
        print("="*70 + "\n")
    
    def generate_report(self, output_file: str = "review_check_report.json"):
        """Generate JSON report of results"""
        report = {
            "app_directory": str(self.app_dir),
            "check_date": __import__('datetime').datetime.now().isoformat(),
            "total_checks": len(self.results),
            "passed": sum(1 for r in self.results if r.passed),
            "failed": sum(1 for r in self.results if not r.passed),
            "results": [
                {
                    "check_id": r.check_id,
                    "passed": r.passed,
                    "severity": r.severity.value,
                    "message": r.message,
                    "details": r.details
                }
                for r in self.results
            ]
        }
        
        with open(output_file, 'w') as f:
            json.dump(report, f, indent=2)
        
        print(f"\n📄 Report saved to: {output_file}")
        return report

def main():
    import argparse
    
    parser = argparse.ArgumentParser(
        description="Check app against App Store review requirements"
    )
    parser.add_argument(
        'app_dir',
        nargs='?',
        default='.',
        help='App directory to check (default: current directory)'
    )
    parser.add_argument(
        '--report',
        action='store_true',
        help='Generate JSON report'
    )
    parser.add_argument(
        '--requirements',
        help='Path to requirements YAML file'
    )
    
    args = parser.parse_args()
    
    try:
        checker = ReviewChecker(args.app_dir, args.requirements)
        passed, total = checker.run_all_checks()
        
        if args.report:
            checker.generate_report()
        
        # Exit code: 0 if all passed, 1 if any failed
        sys.exit(0 if passed == total else 1)
    
    except FileNotFoundError as e:
        print(f"❌ Error: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"❌ Unexpected error: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == '__main__':
    main()

