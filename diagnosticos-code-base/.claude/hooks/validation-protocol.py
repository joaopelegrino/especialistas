#!/usr/bin/env python3

"""
Universal Validation Protocol Hook
Implements zero-trust verification of any claims made during analysis
"""

import os
import sys
import re
import json
import subprocess
from pathlib import Path

class ValidationProtocol:
    """Implements the zero-trust validation protocol."""

    def __init__(self, project_path):
        self.project_path = project_path
        self.confidence_levels = {
            'README/Docs': 0,
            'Comments': 10,
            'Commit Messages': 20,
            'Code Structure': 60,
            'Passing Tests': 80,
            'Verified Execution': 100
        }

    def validate_claim(self, claim_description, claimed_status, file_evidence=None):
        """
        Validate a specific claim about functionality or status.

        Args:
            claim_description: What is being claimed
            claimed_status: Status claimed (e.g., "implemented", "working", "complete")
            file_evidence: Optional file path where evidence should be found
        """

        print(f"\n🔍 VALIDATING CLAIM: {claim_description}")
        print(f"📝 Claimed Status: {claimed_status}")
        print("=" * 50)

        evidence_score = 0
        evidence_details = []

        # Step 1: Look for code evidence
        code_evidence = self._find_code_evidence(claim_description, file_evidence)
        if code_evidence['found']:
            evidence_score = 60
            evidence_details.append(f"✅ Code Evidence: {code_evidence['details']}")
        else:
            evidence_details.append(f"❌ Code Evidence: Not found or insufficient")

        # Step 2: Look for tests
        test_evidence = self._find_test_evidence(claim_description)
        if test_evidence['found']:
            evidence_score = max(evidence_score, 80)
            evidence_details.append(f"✅ Test Evidence: {test_evidence['details']}")
        else:
            evidence_details.append(f"❌ Test Evidence: No tests found")

        # Step 3: Check for execution evidence (if possible)
        exec_evidence = self._check_execution_evidence(claim_description)
        if exec_evidence['found']:
            evidence_score = 100
            evidence_details.append(f"✅ Execution Evidence: {exec_evidence['details']}")

        # Step 4: Look for red flags
        red_flags = self._detect_red_flags(claim_description, claimed_status)
        if red_flags:
            evidence_score = max(0, evidence_score - 20)
            evidence_details.extend([f"🚩 Red Flag: {flag}" for flag in red_flags])

        # Determine verdict
        verdict = self._determine_verdict(evidence_score, claimed_status)

        # Output validation result
        print("📊 EVIDENCE ANALYSIS:")
        for detail in evidence_details:
            print(f"  {detail}")

        print(f"\n🎯 CONFIDENCE SCORE: {evidence_score}%")
        print(f"⚖️  VERDICT: {verdict}")

        return {
            'claim': claim_description,
            'claimed_status': claimed_status,
            'confidence_score': evidence_score,
            'verdict': verdict,
            'evidence_details': evidence_details
        }

    def _find_code_evidence(self, claim_description, file_evidence=None):
        """Find code evidence for the claim."""

        # Extract keywords from claim description
        keywords = self._extract_keywords(claim_description)

        code_files = []
        search_paths = [file_evidence] if file_evidence else []

        if not search_paths:
            # Search in common code directories
            code_extensions = ['.py', '.js', '.ts', '.ex', '.exs', '.rb', '.go', '.rs', '.java', '.php']
            for root, dirs, files in os.walk(self.project_path):
                # Skip common ignore directories
                dirs[:] = [d for d in dirs if d not in ['node_modules', 'vendor', '.git', 'build', 'dist']]

                for file in files:
                    if any(file.endswith(ext) for ext in code_extensions):
                        search_paths.append(os.path.join(root, file))

        # Search for keywords in code files
        evidence_found = False
        evidence_details = []

        for file_path in search_paths[:20]:  # Limit to first 20 files
            if os.path.exists(file_path):
                try:
                    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                        content = f.read().lower()
                        line_number = 0

                        for line in content.split('\n'):
                            line_number += 1
                            if any(keyword.lower() in line for keyword in keywords):
                                evidence_found = True
                                relative_path = os.path.relpath(file_path, self.project_path)
                                evidence_details.append(f"{relative_path}:{line_number}")

                                if len(evidence_details) >= 3:  # Limit to 3 examples
                                    break

                except Exception:
                    continue

            if len(evidence_details) >= 3:
                break

        return {
            'found': evidence_found,
            'details': ', '.join(evidence_details) if evidence_details else 'No matching code found'
        }

    def _find_test_evidence(self, claim_description):
        """Find test evidence for the claim."""

        keywords = self._extract_keywords(claim_description)
        test_files = []

        # Find test files
        test_patterns = ['test_*.py', '*_test.py', '*.test.js', '*.test.ts', '*.spec.js', '*.spec.ts',
                        '*_test.ex', '*_test.exs', '*_spec.rb', '*_test.go', '*_test.rs']

        for root, dirs, files in os.walk(self.project_path):
            dirs[:] = [d for d in dirs if d not in ['node_modules', 'vendor', '.git']]

            for file in files:
                if any(
                    file.lower().startswith(pattern.split('*')[0].lower()) and
                    file.lower().endswith(pattern.split('*')[1].lower())
                    for pattern in test_patterns
                ) or 'test' in file.lower() or 'spec' in file.lower():
                    test_files.append(os.path.join(root, file))

        # Search for relevant tests
        evidence_found = False
        evidence_details = []

        for test_file in test_files:
            try:
                with open(test_file, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read().lower()
                    if any(keyword.lower() in content for keyword in keywords):
                        evidence_found = True
                        relative_path = os.path.relpath(test_file, self.project_path)
                        evidence_details.append(relative_path)

                        if len(evidence_details) >= 3:
                            break

            except Exception:
                continue

        return {
            'found': evidence_found,
            'details': ', '.join(evidence_details) if evidence_details else 'No relevant tests found'
        }

    def _check_execution_evidence(self, claim_description):
        """Check for execution evidence (build scripts, CI, etc.)."""

        execution_indicators = [
            'package.json',  # npm scripts
            'Makefile',      # make targets
            'scripts/',      # script directory
            '.github/workflows/',  # GitHub Actions
            '.gitlab-ci.yml',      # GitLab CI
            'docker-compose.yml',  # Docker setup
            'Dockerfile'           # Docker build
        ]

        evidence_found = False
        evidence_details = []

        for indicator in execution_indicators:
            indicator_path = os.path.join(self.project_path, indicator)
            if os.path.exists(indicator_path):
                evidence_found = True
                evidence_details.append(indicator)

        return {
            'found': evidence_found,
            'details': ', '.join(evidence_details) if evidence_details else 'No execution indicators found'
        }

    def _detect_red_flags(self, claim_description, claimed_status):
        """Detect red flags that indicate unreliable claims."""

        red_flags = []

        # Red flag patterns
        suspicious_patterns = [
            ('fully implemented', 'Claim of "fully implemented" without evidence'),
            ('working', 'Vague "working" status'),
            ('complete', 'Claim of "complete" without verification'),
            ('100%', 'Round percentage without backing data'),
            ('done', 'Simple "done" status'),
        ]

        # Check for suspicious patterns in claimed status
        for pattern, description in suspicious_patterns:
            if pattern in claimed_status.lower():
                red_flags.append(description)

        # Check for TODO/FIXME in relevant code
        keywords = self._extract_keywords(claim_description)
        todo_found = False

        try:
            for root, dirs, files in os.walk(self.project_path):
                dirs[:] = [d for d in dirs if d not in ['node_modules', 'vendor', '.git']]

                for file in files:
                    if file.endswith(('.py', '.js', '.ts', '.ex', '.exs')):
                        file_path = os.path.join(root, file)
                        try:
                            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                                content = f.read()
                                lines = content.split('\n')

                                for i, line in enumerate(lines):
                                    if any(keyword.lower() in line.lower() for keyword in keywords):
                                        # Check surrounding lines for TODO/FIXME
                                        for j in range(max(0, i-2), min(len(lines), i+3)):
                                            if any(flag in lines[j].upper() for flag in ['TODO', 'FIXME', 'HACK', 'XXX']):
                                                todo_found = True
                                                break
                                    if todo_found:
                                        break
                        except Exception:
                            continue

                if todo_found:
                    break

            if todo_found:
                red_flags.append("TODO/FIXME found near claimed functionality")

        except Exception:
            pass

        return red_flags

    def _extract_keywords(self, claim_description):
        """Extract relevant keywords from claim description."""

        # Remove common words and extract meaningful terms
        stop_words = {'the', 'is', 'are', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'of', 'with', 'by', 'a', 'an'}
        words = re.findall(r'\w+', claim_description.lower())
        keywords = [word for word in words if len(word) > 2 and word not in stop_words]

        # Prioritize technical terms
        technical_terms = [word for word in keywords if any(tech in word for tech in
                          ['api', 'auth', 'login', 'user', 'data', 'service', 'function', 'method', 'class'])]

        return technical_terms[:5] if technical_terms else keywords[:5]

    def _determine_verdict(self, evidence_score, claimed_status):
        """Determine the final verdict based on evidence score."""

        if evidence_score >= 100:
            return "CONFIRMED"
        elif evidence_score >= 80:
            return "HIGHLY_LIKELY"
        elif evidence_score >= 60:
            return "PARTIALLY_CONFIRMED"
        elif evidence_score >= 20:
            return "WEAK_EVIDENCE"
        else:
            return "UNSUBSTANTIATED"

def main():
    """Main validation function."""

    project_path = sys.argv[1] if len(sys.argv) > 1 else os.getcwd()

    print("🛡️  UNIVERSAL VALIDATION PROTOCOL")
    print("================================")
    print(f"📁 Project: {project_path}")
    print(f"⚡ Zero-trust validation active")
    print()

    validator = ValidationProtocol(project_path)

    # Example validations - in real use, these would be provided as arguments
    example_claims = [
        ("User authentication system", "implemented", "auth.py"),
        ("API endpoints", "working", None),
        ("Database integration", "complete", None),
        ("Test coverage", "80%", None),
    ]

    results = []

    print("📋 VALIDATION PROTOCOL ACTIVE:")
    print("  ❌ Documentation claims: 0% trust")
    print("  🤔 Comments/TODO: 10% trust")
    print("  📝 Code structure: 60% trust")
    print("  ✅ Passing tests: 80% trust")
    print("  🎯 Verified execution: 100% trust")
    print()

    for claim, status, evidence_file in example_claims:
        result = validator.validate_claim(claim, status, evidence_file)
        results.append(result)

    print("\n" + "="*60)
    print("📊 VALIDATION SUMMARY:")
    print("="*60)

    for result in results:
        print(f"🔍 {result['claim']}: {result['verdict']} ({result['confidence_score']}%)")

    print(f"\n✅ Validation protocol completed!")
    print("💡 Use CONFIRMED/HIGHLY_LIKELY findings with confidence")
    print("⚠️  Investigate WEAK_EVIDENCE/UNSUBSTANTIATED claims")

if __name__ == "__main__":
    main()